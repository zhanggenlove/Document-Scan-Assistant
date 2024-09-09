//
//  CellForColor.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/6/15.
//

import UIKit

class CellForColor: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var colorBg: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    static func loadNib() -> UINib{
        let nib = UINib(nibName: "CellForColor", bundle: nil)
        return nib
    }
    private func initUI() {
        colorBg.layer.cornerRadius = colorBg.bounds.width / 2
        colorBg.layer.masksToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
