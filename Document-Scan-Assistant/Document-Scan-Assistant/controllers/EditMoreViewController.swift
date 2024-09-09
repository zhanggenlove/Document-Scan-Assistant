//
//  EditMoreViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/27.
//

import MessageUI
import PDFKit
import UIKit

protocol pdfviewNeedGoPageDelegate: AnyObject {
    func pdfviewNeedGoPage(page: PDFPage)
}

protocol documentDidChangeDelegate: AnyObject {
    func fileNameDidChange(_ newName: String, _ newUrl: URL)
}

// 更多【删除当前页、删除整页、设置在当前页前插入还是后插入、PDF压缩率设置、修改名称、打印、详细信息、发送邮件】
class EditMoreViewController: UIViewController {
    var file: File?
    var pageIndex: Int?
    var pdfDocument: PDFDocument?
    var tableView: UITableView!
    let titleLabel = UILabel()
    weak var delegate: pdfviewNeedGoPageDelegate?
    weak var reNameDelegate: documentDidChangeDelegate?
    let dataSource = [
        MoreAction(icon: "magnifyingglass", title: String.localize("EditMoreVC.search"), action: .search),
        MoreAction(icon: "square.and.pencil", title: String.localize("EditMoreVC.rename"), action: .rename),
        MoreAction(icon: "printer", title: String.localize("EditMoreVC.printer"), action: .printer),
        MoreAction(icon: "trash", title: String.localize("EditMoreVC.transh"), action: .delete),
//        MoreAction(icon: "move.3d", title: "移动"),
        MoreAction(icon: "paperplane", title: String.localize("EditMoreVC.email"), action: .send),
        MoreAction(icon: "text.viewfinder", title: String.localize("EditMoreVC.get.text"), action: .ocr),
        MoreAction(icon: "drop", title: String.localize("EditMoreVC.drop"), action: .waterMark),
//        MoreAction(icon: "w.square", title: "转word文档", action: .world)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @objc func closeVC() {
        dismiss(animated: true)
    }

    func didSelectRowAt(row: Int) {
        let action = dataSource[row].action
        switch action {
        case .search:
            search()
        case .delete:
            deleteDocment()
        case .rename:
            rename()
        case .send:
            email()
        case .printer:
            printer()
        case .ocr:
            getText()
        case .waterMark:
            waterMark()
        case .world: break
        }
    }

    func rename() {
        let vc = FileRenameViewController()
        vc.fileName = file?.name
//        vc.isModalInPresentation = true
//        if let sheetVC = vc.sheetPresentationController {
//            sheetVC.detents = [.medium()]
//            sheetVC.largestUndimmedDetentIdentifier = .medium
//            sheetVC.prefersScrollingExpandsWhenScrolledToEdge = false
//        }
        vc.closure = { [weak self] name in
            self?.file?.name = name
            self?.titleLabel.text = name
            let state = MyFileManager.shared.changeFileName(for: (self?.file?.url)!, with: name)
            switch state {
            case .success(state: _, path: let path):
                if let newPath = path {
                    self?.reNameDelegate?.fileNameDidChange(name, newPath)
                }
            case .error(error: let error):
                showModal(parent: self, content: error)
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }

    func printer() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = file?.name ?? ""
        printInfo.outputType = .general
        printController.printInfo = printInfo
        printController.printingItem = file?.url
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            printController.present(from: titleLabel.frame, in: titleLabel, animated: true)
        } else {
            printController.present(animated: true, completionHandler: nil)
        }
    }

    func search() {
        let vc = PDFSearchViewController()
        vc.pdfDocument = pdfDocument
        vc.delegate = self
        let rootVC = UINavigationController(rootViewController: vc)
//        rootVC.isModalInPresentation = true
        if let sheetVC = rootVC.sheetPresentationController {
            sheetVC.detents = [.large()]
        }
        present(rootVC, animated: true)
    }

    // 后续需增加删除当前页还是整页
    func deleteDocment() {
        let alert = UIAlertController(title: "", message: "\(String.localize("EditMoreVC.alert.pretext"))【\(pageIndex! + 1)\(String.localize("EditMoreVC.alert.page"))】？", preferredStyle: .alert)
        let ok = UIAlertAction(title: String.localize("HomeVC.alert.submit"), style: .destructive) { _ in
            postDocumentsDeletePage(object: nil)
        }
        let cancel = UIAlertAction(title: String.localize("HomeVC.alert.cancel"), style: .default)
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    func email() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            // 设置邮件地址、主题及正文
            mailComposeVC.setSubject(file?.name ?? "")
            if let data = pdfDocument?.dataRepresentation() {
                mailComposeVC.addAttachmentData(data, mimeType: "pdf", fileName: file?.name ?? "")
                present(mailComposeVC, animated: true, completion: nil)
            }
        } else {
            SPIndicator.present(title: "not support email", preset: .error)
        }
    }

    // 获取文字
    func getText() {
        let vc = PDFTextViewController()
        vc.string = pdfDocument?.page(at: pageIndex!)?.attributedString
        if let sheetVC = vc.sheetPresentationController {
            sheetVC.detents = [.medium(), .large()]
        }
        present(vc, animated: true)
    }

    // 水印设置
    func waterMark() {
        let isPremium = UserDefaults.standard.bool(forKey: IS_PREMIUM)
        if (!isPremium) {
            let vc = PurchaseViewController()
            if let sheetVC = vc.sheetPresentationController {
                sheetVC.detents = [.large()]
            }
            present(vc, animated: true)
            return
        }
        let vc = WatermarkViewController()
        if let sheetPresentationController = vc.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
        }
        present(vc, animated: true)
    }
}

extension EditMoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreActionCell", for: indexPath)
        cell.selectionStyle = .none
        var config = cell.defaultContentConfiguration()
        let imageConfig = UIImage.SymbolConfiguration(font: MyFont.font(with: .bold, size: 15), scale: .medium)
        config.image = UIImage(systemName: dataSource[indexPath.row].icon, withConfiguration: imageConfig)?.withTintColor(.label, renderingMode: .alwaysOriginal)
        config.text = dataSource[indexPath.row].title
        config.textProperties.font = MyFont.font(with: .defalut, size: 14)
//        config.imageProperties.maximumSize = CGSize(width: 26, height: 26)
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        didSelectRowAt(row: indexPath.row)
    }
}

extension EditMoreViewController {
    private func setupUI() {
        view.backgroundColor = .systemBackground
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoreActionCell")
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "editVCHeaderBgColor")
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let headerImage = UIImageView(frame: CGRect.zero)
        headerImage.contentMode = .scaleToFill
        headerImage.layer.cornerRadius = 4
        headerImage.layer.masksToBounds = true
        headerImage.image = file?.image
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = file?.name
        titleLabel.font = MyFont.font(with: .bold, size: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let sizeLabel = UILabel()
        sizeLabel.text = "\(String(describing: file?.size ?? "unkonwn"))"
        sizeLabel.textColor = .secondaryLabel
        sizeLabel.font = MyFont.font(with: .defalut, size: 12)
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        let closeBtn = UIButton(type: .close)
        closeBtn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        // 约束
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(sizeLabel)
        headerView.addSubview(headerImage)
        NSLayoutConstraint.activate([
            headerImage.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 10),
            headerImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerImage.widthAnchor.constraint(equalToConstant: 36),
            headerImage.heightAnchor.constraint(equalToConstant: 44)
        ])
        headerView.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.widthAnchor.constraint(equalToConstant: 26),
            closeBtn.heightAnchor.constraint(equalToConstant: 26),
            closeBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeBtn.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10)
        ])
        headerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: headerImage.rightAnchor, constant: 12),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            stackView.rightAnchor.constraint(equalTo: closeBtn.leftAnchor)
        ])
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}

extension EditMoreViewController: PDFSearchViewDelegate {
    func didDocumentResultSelect(didSelectSerchResult selection: PDFSelection?) {
        guard let page = selection?.pages.first else { return }
        delegate?.pdfviewNeedGoPage(page: page)
        dismiss(animated: true)
        dismiss(animated: true)
    }
}

// 邮件代理
extension EditMoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        if error != nil {
            SPIndicator.present(title: String.localize("EditMoreVC.email.succ"), message: error?.localizedDescription, preset: .error)
        } else {
            SPIndicator.present(title: String.localize("EditMoreVC.email.fail"), preset: .done)
        }
    }
}
