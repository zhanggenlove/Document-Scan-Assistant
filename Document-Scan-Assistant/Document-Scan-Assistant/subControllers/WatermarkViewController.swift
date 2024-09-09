//
//  WatermarkViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/5/9.
//

import SPLarkController
import UIKit

class WatermarkViewController: UIViewController, UIColorPickerViewControllerDelegate, UITextFieldDelegate {
    var egView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var egLabel: UILabel = {
        let label = UILabel()
        label.text = String.localize("WatermarkVC.copyright.text")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(CellForTextField.loadNib(), forCellReuseIdentifier: "CellForTextField")
        tv.register(CellForColor.loadNib(), forCellReuseIdentifier: "CellForColor")
        tv.register(CellForOpcity.loadNib(), forCellReuseIdentifier: "CellForOpcity")
        tv.register(CellForSlider.loadNib(), forCellReuseIdentifier: "CellForSlider")
        tv.register(CellForPosition.loadNib(), forCellReuseIdentifier: "CellForPosition")
        return tv
    }()

    let list = ["左上角", "右上角", "左下角", "右下角"]
    let imges = ["lt", "rt", "lb", "rb"]
    var pIndex = 0
    var color = UIColor.red
    var opacity: Float = 0.5
    var size: Float = 14.0
    var text = String.localize("WatermarkVC.copyright.text")
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setLabelCss()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
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
        let doneBtn = UIBarButtonItem(title: String.localize("WatermarkVC.apply.text"), style: .plain, target: self, action: #selector(saveFile))
        doneBtn.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue, .font: MyFont.font(with: .defalut, size: 14)], for: .normal)
        doneBtn.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue, .font: MyFont.font(with: .defalut, size: 14)], for: .highlighted)
        let item = UINavigationItem(title: "\(String.localize("WatermarkVC.title"))¨̮")
        item.leftBarButtonItem = cancelBtn
        item.rightBarButtonItem = doneBtn
        barView.pushItem(item, animated: true)
        view.addSubview(barView)
        view.addSubview(egView)
        NSLayoutConstraint.activate([
            barView.topAnchor.constraint(equalTo: view.topAnchor),
            barView.leftAnchor.constraint(equalTo: view.leftAnchor),
            barView.rightAnchor.constraint(equalTo: view.rightAnchor),
            barView.heightAnchor.constraint(equalToConstant: 50),
        ])
        NSLayoutConstraint.activate([
            egView.topAnchor.constraint(equalTo: barView.bottomAnchor),
            egView.leftAnchor.constraint(equalTo: view.leftAnchor),
            egView.rightAnchor.constraint(equalTo: view.rightAnchor),
            egView.heightAnchor.constraint(equalToConstant: 120),
        ])
        egView.addSubview(egLabel)
        NSLayoutConstraint.activate([
            egLabel.centerXAnchor.constraint(equalTo: egView.centerXAnchor),
            egLabel.centerYAnchor.constraint(equalTo: egView.centerYAnchor),
        ])
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: egView.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc private func closeVC() {
        dismiss(animated: true)
    }

    @objc private func saveFile() {
        ProgressHud.show()
        DispatchQueue.global().async {
            postDocumentsSaveUpdate(object: nil)
        }
    }
    private func showPosition() {
        let sheet = UIAlertController(title: "水印位置", message: nil, preferredStyle: .actionSheet)
        for (index, p) in list.enumerated() {
            sheet.addAction(UIAlertAction(title: p, style: .default) { _ in
                self.pIndex = index
                self.tableView.reloadData()
            })
        }
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(sheet, animated: true)
    }
    
    private func showColorWell() {
        let colorVC = UIColorPickerViewController()
        colorVC.delegate = self
        present(colorVC, animated: true)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        color = viewController.selectedColor
        setLabelCss()
        tableView.reloadData()
    }
    
    @objc private func opcityChange (_ sender: UISlider) {
        opacity = sender.value
        setLabelCss()
    }
    @objc private func sizeChange (_ sender: UISlider) {
        size = sender.value
        setLabelCss()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        text = textField.text ?? ""
        setLabelCss()
    }
    
    private func setLabelCss() {
        egLabel.text = text
        egLabel.textColor = color.withAlphaComponent(CGFloat(opacity))
        egLabel.font = .systemFont(ofSize: CGFloat(size))
        WaterMarkInfo.shared.setDrawConfig(content: text as NSString, size: size, opacity: opacity, color: color)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WaterMarkInfo.shared.content = nil
    }
}

extension WatermarkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch index {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellForTextField", for: indexPath) as! CellForTextField
            cell.selectionStyle = .none
            cell.textField.delegate = self
            return cell
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CellForPosition", for: indexPath) as! CellForPosition
//            cell.accessoryType = .disclosureIndicator
//            cell.selectionStyle = .none
//            cell.positionImage.image = UIImage(named: imges[pIndex])
//            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellForColor", for: indexPath) as! CellForColor
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            cell.colorBg.backgroundColor = color
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellForOpcity", for: indexPath) as! CellForOpcity
            cell.selectionStyle = .none
            cell.slider.addTarget(self, action: #selector(opcityChange), for: .valueChanged)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellForSlider", for: indexPath) as! CellForSlider
            cell.selectionStyle = .none
            cell.slider.addTarget(self, action: #selector(sizeChange), for: .valueChanged)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 1 {
//            showPosition()
//        }
        if indexPath.row == 1 {
            showColorWell()
        }
    }
}
