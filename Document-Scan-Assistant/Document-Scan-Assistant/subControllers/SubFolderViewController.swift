//
//  SubFolderViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/7/15.
//


import PDFKit
import PhotosUI
import UIKit
import Vision
import VisionKit

class SubFolderViewController: EvaluateBaseController {
    //接收file
    var file:File!
    // documents
    var documents: [File] = [] {
        didSet {
        }
    }

    // documents pdf
    var documentsOfPDF: [File] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.documentsOfPDF.isEmpty {
                    self.tableView.showEmpty(message: "\(String.localize("HomeVC.empty.addtips"))¨̮")
                } else {
                    self.tableView.removeEmpty()
                }
            }
        }
    }

    // documents folder
    var documentsOfFolder: [File] = []
    // 常量
    static let addBtnWidth: CGFloat = 60.0
    let tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .grouped)
        tv.register(FileTableViewCell.loadNib(), forCellReuseIdentifier: "FileTableViewCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    let addBtn: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        var bgConfig = UIBackgroundConfiguration.listPlainCell()
//        bgConfig.backgroundColor = .blue
        bgConfig.cornerRadius = addBtnWidth / 2
        config.background = bgConfig
        let button = UIButton(configuration: config)
        button.addGradient(start_color: "#495aff", end_color: "#0acffe", frame: CGRect(x: 0, y: 0, width: addBtnWidth, height: addBtnWidth), cornerRadius: addBtnWidth / 2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initConfig()
        fetchDocuments()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: SubFolderViewController的私有方法

extension SubFolderViewController {
    private func initUI() {
        title = file.name
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        //  添加button的约束
        view.insertSubview(addBtn, at: 2)
        NSLayoutConstraint.activate([
            addBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            addBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            addBtn.widthAnchor.constraint(equalToConstant: SubFolderViewController.addBtnWidth),
            addBtn.heightAnchor.constraint(equalToConstant: SubFolderViewController.addBtnWidth)
        ])
        // 给addBtn增加点击事件
        addBtn.addTarget(self, action: #selector(addBtnTap), for: .touchUpInside)
    }

    @objc func addBtnTap() {
        ActionSheet.instance.show(delegate: self)
    }

    // init config
    private func initConfig() {
        // 注册documents更新
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDocuments), name: documentsUpdateNot, object: nil)
    }

    func deleteDirHandle(index: Int) {
        let file = documentsOfFolder[index]
        let alert = UIAlertController(title: String.localize("HomeVC.alert.title"), message: "\(String.localize("HomeVC.alert.pretext"))\(file.name ?? "")？", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: String.localize("HomeVC.alert.submit"), style: .destructive) { [weak self] _ in
            // 删除documentsOfFolder 同时删除文件
            MyFileManager.shared.removeFile(with: file.url)
            self?.documentsOfFolder.remove(at: index)
            self?.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: String.localize("HomeVC.alert.cancel"), style: .cancel) { _ in
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    func renameDirHandle(index: Int) {
        let file = documentsOfFolder[index]
        let vc = FileRenameViewController()
        vc.fileName = file.name
        vc.isFileRename = false
        vc.closure = { [weak self] name in
            let state = MyFileManager.shared.changeFolderName(at: file.url, with: name)
            switch state {
            case .success(state: _):
                postDocumentsUpdate(object: nil)
            case .error(error: let error):
                showModal(parent: self, content: error)
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }

    // MARK: 加载本地文件夹和PDF文件

    @objc private func fetchDocuments() {
        let list = MyFileManager.shared.scanDirectory2Files(with: file.url)
        documentsOfPDF = list.filter { $0.type == .pdf }
        documentsOfFolder = list.filter { $0.type == .folder }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("fetchDocuments", "我将要更新...")
    }

    // MARK: actions

    func addFolder() {
        print("创建文件夹。。。", self)
        let vc = CreateFolderController()
        vc.folderPath = file.url
        let rootVC = UINavigationController(rootViewController: vc)
        if let sheetController = vc.sheetPresentationController {
            sheetController.detents = [.medium(), .large()]
        }
        present(rootVC, animated: true)
    }
}

// MARK: Tableview的相关数据源代理

extension SubFolderViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        // 两个section，一个是文件夹，一个是文件
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return documentsOfPDF.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileTableViewCell")! as! FileTableViewCell
        let index = indexPath.row
        let file = documentsOfPDF[index]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/M/d HH:mm"
        cell.imageCover.image = file.image
        cell.titleLabel.text = file.name
        cell.pageLabel.text = "\(file.page)\(String.localize("HomeVC.page"))"
        cell.timeLabel.text = dateFormatter.string(from: file.updateDate)
        return cell
    }

    // viewForHeaderInSection
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TableHeaderView()
        headerView.folders = documentsOfFolder
        headerView.delegate = self
        switch section {
        case 0:
            return headerView
        case 1:
            return nil
        default:
            return nil
        }
    }

    // title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return String.localize("HomeVC.alert.recentFile")
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    // header-view的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 160
        case 1:
            return 10
        default:
            return 0
        }
    }

    // cell 的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    // 左滑单元格操作
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let index = indexPath.row
        let file = documentsOfPDF[index]
        let delete = UIContextualAction(style: .destructive, title: String.localize("HomeVC.alert.delete")) { [weak self] _, _, completionHandler in
            let alert = UIAlertController(title: String.localize("HomeVC.alert.title"), message: "\(String.localize("HomeVC.alert.pretext"))\(file.name ?? "")？", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: String.localize("HomeVC.alert.submit"), style: .destructive) { _ in
                // 删除documentsOfPDF 同时删除文件
                MyFileManager.shared.removeFile(with: file.url)
                self?.documentsOfPDF.remove(at: indexPath.row)
                tableView.reloadData()
                completionHandler(true)
            }
            let cancelAction = UIAlertAction(title: String.localize("HomeVC.alert.cancel"), style: .cancel) { _ in
                completionHandler(true)
            }
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true, completion: nil)
        }
        let editor = UIContextualAction(style: .normal, title: String.localize("HomeVC.alert.rename")) { [weak self] _, _, completionHandler in
            let vc = FileRenameViewController()
            vc.fileName = file.name
            vc.closure = { [weak self] name in
                let state = MyFileManager.shared.changeFileName(for: file.url, with: name)
                switch state {
                case .success(state: _):
                    postDocumentsUpdate(object: nil)
                case .error(error: let error):
                    showModal(parent: self, content: error)
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            self?.present(vc, animated: true)
            completionHandler(true)
        }

        let actions = UISwipeActionsConfiguration(actions: [delete, editor])
        actions.performsFirstActionWithFullSwipe = false
        return actions
    }
}

// MARK: tableView的action 代理

extension SubFolderViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let file = documentsOfPDF[indexPath.row]
        let vc = EditorViewController()
//        navigationItem.backButtonTitle = file.name
        navigationItem.backButtonDisplayMode = .minimal
        vc.pdfFile = file
        navigationController?.pushViewController(vc, animated: true)
    }

    // 添加文档扫描一类的操作
    private func scanDocFromCamera() {
        let docVC = VNDocumentCameraViewController()
        docVC.delegate = self
        present(docVC, animated: true)
    }

    // 添加-从相册选择
    func fromPhotos() {
        var pConfig = PHPickerConfiguration(photoLibrary: .shared())
        pConfig.selectionLimit = 0
        pConfig.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: pConfig)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    // 从系统文件选择
    func fromSysFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        present(documentPicker, animated: true, completion: nil)
    }
}

extension SubFolderViewController: PHPickerViewControllerDelegate, VNDocumentCameraViewControllerDelegate {
    // pdf version 代理
    // 扫描成功
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var images: [UIImage] = []
        for index in 0 ..< scan.pageCount {
            let image = scan.imageOfPage(at: index)
            images.append(image)
        }
        pic2Document(images: images)
    }

    // 扫描发生错误
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
        // toast
        SPIndicatorView(title: "error", preset: .custom((UIImage(systemName: "doc.viewfinder.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.systemRed))!)).present(duration: 3, haptic: .error)
    }

    // 用户取消扫描
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    // 照片选择代理
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var images: [UIImage] = []
        var index = 0
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                index += 1
                guard let image = reading as? UIImage, error == nil else { return }
                // DO something
                images.append(image)
                if index == results.count {
                    DispatchQueue.main.async {
                        self?.pic2Document(images: images)
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }

    func pic2Document(images: [UIImage]) {
        let vc = FileRenameViewController()
        vc.fileName = ""
        vc.closure = { [weak self] name in
            ProgressHud.show()
            DispatchQueue.global().async {
                let pdfDocument = PDFDocument()
                let compressionQuality = 0.8
                for (index, image) in images.enumerated() {
                    if let data = image.jpegData(compressionQuality: compressionQuality), let compressImage = UIImage(data: data), let page = PDFPage(image: compressImage) {
                        pdfDocument.insert(page, at: index)
                    }
                }
                let data = pdfDocument.dataRepresentation()
                let docURL = MyFileManager.shared.getUniqueFileUrl(path: self?.file.url ?? MyFileManager.shared.documentPath, name: name, type: ".pdf")
                do {
                    print("Documet: \(docURL)")
                    try data?.write(to: docURL)
                    recordDocumentsCount()
                    ProgressHud.hide()
                    postDocumentsUpdate(object: nil)
                } catch (let error) {
                    ProgressHud.hide()
                    showModal(parent: self, content: error.localizedDescription)
                }
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

// 从系统文件选择
extension SubFolderViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        print(self)
        appSaveFile(dir: file.url, url: url)
        print("import result : \(url)")
    }
          

    public func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}

extension SubFolderViewController: FolderCellDelegate, ActionSheetDelegate {
    func didItemSelect(tagIndex: Int) {
        ActionSheet.instance.closeSheet(sender: nil)
        let pass = checkCanUseAppWithMaxFileCount(tag: tagIndex)
        if !pass {
            let vc = PurchaseViewController()
            if let sheetVC = vc.sheetPresentationController {
                sheetVC.detents = [.large()]
            }
            present(vc, animated: true)
            return
        }
        if tagIndex == 1 {
            scanDocFromCamera()
        } else if tagIndex == 2 {
            addFolder()
        } else if tagIndex == 3 {
            fromPhotos()
        } else if tagIndex == 4 {
            fromSysFile()
        }
    }
    
    func didFolderRename(index: Int) {
        renameDirHandle(index: index)
    }
    
    func didFolderDelete(index: Int) {
        deleteDirHandle(index: index)
    }
    
    func didFolderCellClick(file: File) {
        let vc = SubFolderViewController()
        vc.file = file
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didAddFolder() {
        addFolder()
    }
}
