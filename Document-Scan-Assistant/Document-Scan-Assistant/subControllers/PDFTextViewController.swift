//
//  PDFTextViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/5/8.
//

import UIKit

class PDFTextViewController: UIViewController {
    var string: NSAttributedString?
    let textArea = UITextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
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
        let doneBtn = UIBarButtonItem(title: String.localize("PDFText.copy.text"), style: .plain, target: self, action: #selector(copyText))
        doneBtn.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue, .font: MyFont.font(with: .defalut, size: 14)], for: .normal)
        doneBtn.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue, .font: MyFont.font(with: .defalut, size: 14)], for: .highlighted)
        let item = UINavigationItem(title: "\(String.localize("PDFText.text.get"))¨̮")
        item.leftBarButtonItem = cancelBtn
        item.rightBarButtonItem = doneBtn
        barView.pushItem(item, animated: true)
        view.addSubview(barView)
        NSLayoutConstraint.activate([
            barView.leftAnchor.constraint(equalTo: view.leftAnchor),
            barView.rightAnchor.constraint(equalTo: view.rightAnchor),
            barView.topAnchor.constraint(equalTo: view.topAnchor),
            barView.heightAnchor.constraint(equalToConstant: 50)
        ])
        textArea.backgroundColor = .white
        textArea.font = MyFont.font(with: .defalut, size: 14)
        textArea.textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 8, right: 12)
        textArea.attributedText = string
        textArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textArea)
        NSLayoutConstraint.activate([
            textArea.leftAnchor.constraint(equalTo: view.leftAnchor),
            textArea.rightAnchor.constraint(equalTo: view.rightAnchor),
            textArea.topAnchor.constraint(equalTo: barView.bottomAnchor),
            textArea.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func closeVC() {
        dismiss(animated: true)
    }
    
    @objc private func copyText() {
        guard let text = textArea.text else { return }
        UIPasteboard.general.string = text
        let config = UIImage.SymbolConfiguration.preferringMulticolor()
        let config1 = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .medium, scale: .medium)
        config.applying(config1)
        let image = UIImage(systemName: "app.badge.checkmark", withConfiguration: config)
        SPIndicator.present(title: String.localize("PDFText.text.get.succ"), preset: .custom(image!))
        dismiss(animated: true)
    }
}
