//
//  FileRenameViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/28.
//

import UIKit

class FileRenameViewController: UIViewController, UITextFieldDelegate {
    var sheetHeightAnchor: NSLayoutConstraint?
    var heightAnchorConst: CGFloat = 160
    var keyboardRectHeight: CGFloat = 0
    let nameField = UITextField()
    var fileName: String?
    var isFileRename = true
    var closure: ((_ text: String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConfig()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        // sheetView
        let sheetView = UIView()
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.backgroundColor = .systemBackground
        sheetView.layer.cornerRadius = 12
        sheetView.layer.masksToBounds = true
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let barView = UINavigationBar(frame: CGRect.zero)
        barView.translatesAutoresizingMaskIntoConstraints = false
        barView.tintColor = .label
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = nil
        barView.standardAppearance = appearance
        let cancelBtn = UIBarButtonItem(title: String.localize("HomeVC.alert.cancel"), style: .plain, target: self, action: #selector(closeVC))
        cancelBtn.setTitleTextAttributes([.foregroundColor: UIColor.label, .font: MyFont.font(with: .defalut, size: 14)], for: .normal)
        cancelBtn.setTitleTextAttributes([.foregroundColor: UIColor.label, .font: MyFont.font(with: .defalut, size: 14)], for: .highlighted)
        let doneBtn = UIBarButtonItem(title: String.localize("CreateFolder.nav.done"), style: .plain, target: self, action: #selector(done))
        doneBtn.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue, .font: MyFont.font(with: .defalut, size: 14)], for: .normal)
        doneBtn.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue, .font: MyFont.font(with: .defalut, size: 14)], for: .highlighted)
        let item = UINavigationItem(title: isFileRename ? "\(String.localize("FileRenameVC.file.name"))¨̮" : "\(String.localize("FileRenameVC.folder.name"))¨̮")
        item.leftBarButtonItem = cancelBtn
        item.rightBarButtonItem = doneBtn
        barView.pushItem(item, animated: true)
        sheetView.addSubview(barView)
        NSLayoutConstraint.activate([
            barView.leftAnchor.constraint(equalTo: sheetView.leftAnchor),
            barView.rightAnchor.constraint(equalTo: sheetView.rightAnchor),
            barView.topAnchor.constraint(equalTo: sheetView.topAnchor),
            barView.heightAnchor.constraint(equalToConstant: 50)
        ])
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.delegate = self
        nameField.placeholder = isFileRename ? String.localize("FileRenameVC.file.placeholder") : String.localize("FileRenameVC.folder.placeholder")
        nameField.text = fileName
        nameField.textAlignment = .center
        nameField.borderStyle = .none
        nameField.layer.cornerRadius = 6
        nameField.layer.masksToBounds = true
        nameField.clearButtonMode = .whileEditing
        nameField.setValue(10, forKey: "paddingLeft")
        nameField.setValue(10, forKey: "paddingRight")
        nameField.backgroundColor = UIColor(named: "textFieldBgColor")
        nameField.becomeFirstResponder()
        sheetView.addSubview(nameField)
        NSLayoutConstraint.activate([
            nameField.leftAnchor.constraint(equalTo: sheetView.leftAnchor, constant: 30),
            nameField.rightAnchor.constraint(equalTo: sheetView.rightAnchor, constant: -40),
            nameField.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: 10),
            nameField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        view.addSubview(sheetView)
        NSLayoutConstraint.activate([
            sheetView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sheetView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        sheetHeightAnchor = sheetView.heightAnchor.constraint(equalToConstant: heightAnchorConst)
        sheetHeightAnchor?.isActive = true
    }

    @objc func closeVC() {
        dismiss(animated: true)
    }
    
    @objc func done() {
        // 保存新的文件名称操作
        guard let name = nameField.text else {
            return
        }
        if (name.elementsEqual("")) {
            showModal(parent: self, content: isFileRename ? "\(String.localize("FileRenameVC.file.null.error"))¨̮" : "\(String.localize("FileRenameVC.folder.null.error"))¨̮")
            return
        }
        if (isNotLegalText(text: name)) {
            showModal(parent: self, content: isFileRename ? "\(String.localize("FileRenameVC.file.legal.error"))¨̮" : "\(String.localize("FileRenameVC.folder.legal.error"))¨̮")
            return
        }
        closure?(name)
        closeVC()
    }
    
    func setupConfig() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let user_info = notification.userInfo
        guard let keyboardRect = (user_info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if keyboardRectHeight != heightAnchorConst + keyboardRect.height {
            keyboardRectHeight = heightAnchorConst + keyboardRect.height
            sheetHeightAnchor?.constant = keyboardRectHeight
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardRectHeight = 0
        sheetHeightAnchor?.constant = heightAnchorConst
    }
}
