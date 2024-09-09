//
//  CellForTextField.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/6/15.
//

import UIKit

class CellForTextField: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    private func initUI() {
        textField.text = "版权所有"
    }
    static func loadNib() -> UINib{
        let nib = UINib(nibName: "CellForTextField", bundle: nil)
        return nib
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
