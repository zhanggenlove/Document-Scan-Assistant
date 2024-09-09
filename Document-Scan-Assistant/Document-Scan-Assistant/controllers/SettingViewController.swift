//
//  SettingViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/7/10.
//

import SafariServices
import UIKit
import MessageUI
import StoreKit

class SettingViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var tableView: UITableView!
    let dataSource: [[SettingCell]] = [
        [
            SettingCell(label: String.localize("Setting.rate"), icon: UIImage(systemName: "hand.thumbsup.fill"), accessoryType: .none),
            SettingCell(label: String.localize("EditorVC.action.share"), icon: UIImage(systemName: "square.and.arrow.up.fill"), accessoryType: .none),
            SettingCell(label: String.localize("Setting.feedback"), icon: UIImage(systemName: "questionmark.circle.fill"), accessoryType: .none)
        ],
        [
            SettingCell(label: String.localize("Setting.restore"), icon: UIImage(systemName: "arrow.clockwise.circle.fill"), accessoryType: .none),
            SettingCell(label: String.localize("Setting.premium"), icon: UIImage(systemName: "crown.fill"), accessoryType: .none)
        ],
        [
            SettingCell(label: String.localize("Setting.terms"), icon: UIImage(systemName: "checkmark.seal.fill"), accessoryType: .disclosureIndicator),
            SettingCell(label: String.localize("Setting.pravicy"), icon: UIImage(systemName: "hand.raised.slash.fill"), accessoryType: .disclosureIndicator)
        ],
        [
            SettingCell(label: String.localize("Setting.wallpaper"), icon: UIImage(systemName: "app.gift.fill"), accessoryType: .disclosureIndicator),
            SettingCell(label: String.localize("Setting.keyboard"), icon: UIImage(systemName: "app.gift.fill"), accessoryType: .disclosureIndicator)
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    private func initUI() {
        title = String.localize("Setting.title")
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        SKPaymentQueue.default().add(self)
    }
    
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: delegate、datasource

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        let item = dataSource[indexPath.section][indexPath.row]
        var configContent = cell.defaultContentConfiguration()
        configContent.image = item.icon
        configContent.text = item.label
        cell.accessoryType = item.accessoryType
        cell.contentConfiguration = configContent
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 评价
        switch indexPath {
        case [0, 0]:
            rateApp()
        case [0, 1]:
            shareApp()
        case [0, 2]:
            feedbackApp()
        case [1, 0]:
            restoreApp()
        case [1, 1]:
            purchaseApp()
        case [2, 0]:
            serviceOfApp()
        case [2, 1]:
            privacyApp()
        case [3, 0]:
            openAppstore(with: "6458101439")
        case [3, 1]:
            openAppstore(with: "1643396533")
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: tableView.bounds.width, height: 34))
        label.text = "powered by zhanggen"
        label.font = MyFont.font(with: .light, size: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return section == 3 ? label : nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: tableView.bounds.width, height: 34))
        label.text = "my other app"
        label.font = MyFont.font(with: .light, size: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return section == 3 ? label : nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 34
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    private func rateApp() {
        let urlString =  "itms-apps://itunes.apple.com/app/id\(APPID)?action=write-review"
        let url = URL(string: urlString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    private func shareApp() {
        let urlShare = URL(string: "itms-apps://itunes.apple.com/app/id\(APPID)")!
        let activityItems = [urlShare] as [Any]
        let activity = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
    
    private func openAppstore(with id: String) {
        let urlString =  "itms-apps://itunes.apple.com/app/id\(id)"
        let url = URL(string: urlString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    private func feedbackApp() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            //设置邮件地址、主题及正文
            mailComposeVC.setToRecipients(["1519149300@qq.com"])
            mailComposeVC.setSubject("【文档扫描小助手】APP问题反馈")
            mailComposeVC.setMessageBody("问题反馈:", isHTML: false)
            present(mailComposeVC, animated: true, completion: nil)
        }
    }
    private func restoreApp() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    private func purchaseApp() {
        let vc = PurchaseViewController()
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if let sheetVC = vc.sheetPresentationController {
                sheetVC.detents = [.large()]
            }
            present(vc, animated: true)
        }
    }
    private func serviceOfApp() {
        let sfvc = SFSafariViewController(url: URL(string: "https://zhanggenlove.github.io/service")!)
        sfvc.modalPresentationStyle = .formSheet
        present(sfvc, animated: true)
    }

    private func privacyApp() {
        let sfvc = SFSafariViewController(url: URL(string: "https://zhanggenlove.github.io/terms")!)
        sfvc.modalPresentationStyle = .formSheet
        present(sfvc, animated: true)
    }
}

extension SettingViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {

            case .purchasing:
                break
            case .purchased:
                break
            case .failed:
                break
            case .restored:
                UserDefaults.standard.set(true, forKey: IS_PREMIUM)
                let indicatorView = SPIndicatorView(title: String.localize("Setting.restore.succ"), preset: .done)
                indicatorView.present(duration: 2,haptic: .success)
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        })
    }
}

// cell items
struct SettingCell {
    var label: String
    var icon: UIImage?
    var accessoryType: UITableViewCell.AccessoryType

    init(label: String, icon: UIImage? = nil, accessoryType: UITableViewCell.AccessoryType) {
        self.label = label
        self.icon = icon?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        self.accessoryType = accessoryType
    }
}
