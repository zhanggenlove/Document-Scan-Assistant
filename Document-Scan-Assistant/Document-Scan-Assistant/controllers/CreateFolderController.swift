//
//  CreateFolderController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/20.
//

import UIKit

class CreateFolderController: UIViewController, UITextFieldDelegate {
    var folderPath: URL?
    lazy var folderImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Folder3"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var nameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        field.text = String.localize("CreateFolder.field.text")
        field.placeholder = String.localize("CreateFolder.field.placeholder")
        field.textAlignment = .center
        field.borderStyle = .none
        field.layer.cornerRadius = 10
        field.layer.masksToBounds = true
        field.clearButtonMode = .whileEditing
        field.backgroundColor = UIColor(named: "textFieldBgColor")
        return field
    }()
    
    lazy var errorText: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = MyFont.font(with: .light, size: 12)
        return label
    }()
    
    lazy var errorSvg: UIImageView = {
        let errorImg = UIImageView()
        errorImg.contentMode = .scaleAspectFit
        errorImg.image = UIImage(named: "svg_warn")
        return errorImg
    }()
    
    lazy var errorStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    var backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 34))
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    private func initUI() {
        title = String.localize("CreateFolder.field.text")
        var btnConfig = UIButton.Configuration.plain()
        btnConfig.image = UIImage(systemName: "chevron.backward")
        btnConfig.imagePlacement = .leading
        btnConfig.imagePadding = 6
        btnConfig.title = String.localize("CreateFolder.nav.back")
        backBtn.configuration = btnConfig
        backBtn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String.localize("CreateFolder.nav.done"), style: .plain, target: self, action: #selector(createFolder))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(closeVC))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        view.backgroundColor = .systemBackground
        view.addSubview(folderImage)
        NSLayoutConstraint.activate([
            folderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            folderImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            folderImage.widthAnchor.constraint(equalToConstant: 64),
            folderImage.heightAnchor.constraint(equalToConstant: 64)
        ])
        view.addSubview(nameField)
        nameField.becomeFirstResponder()
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: folderImage.bottomAnchor, constant: 40),
            nameField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            nameField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            nameField.heightAnchor.constraint(equalToConstant: 48)
        ])
        // warn
        view.addSubview(errorStack)
        errorStack.isHidden = true
        NSLayoutConstraint.activate([
            errorStack.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 10),
            errorStack.leftAnchor.constraint(equalTo: nameField.leftAnchor, constant: 4),
            errorStack.rightAnchor.constraint(equalTo: nameField.rightAnchor)
        ])
        errorStack.addArrangedSubview(errorSvg)
        NSLayoutConstraint.activate([
            errorSvg.heightAnchor.constraint(equalToConstant: 20),
            errorSvg.widthAnchor.constraint(equalToConstant: 20)
        ])
        errorStack.addArrangedSubview(errorText)
    }
    
    // 创建文件夹
    @objc func createFolder() {
        guard let text = nameField.text else { return }
        if (text.elementsEqual("")) {
            errorText.text = String.localize("CreateFolder.errorText.text")
            errorStack.isHidden = false
        }
        // 匹配敏感字符串
        if (isNotLegalText(text: text)) {
            errorText.text = "\(String.localize("CreateFolder.errorText.reg.text")).\\|/*?>=<"
            errorStack.isHidden = false
            return
        }
        if let path = folderPath {
            MyFileManager.shared.createFolder(for: path, with: text)
        } else {
            MyFileManager.shared.createFolder(with: text)
        }
        postDocumentsUpdate(object: nil)
        closeVC()
    }
    
    @objc func closeVC() {
        dismiss(animated: true)
    }
    
    // MARK: delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorStack.isHidden = true
    }
}
