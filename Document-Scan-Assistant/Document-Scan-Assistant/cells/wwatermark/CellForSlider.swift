//
//  CellForSlider.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/6/15.
//

import UIKit

class CellForSlider: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    static func loadNib() -> UINib{
        let nib = UINib(nibName: "CellForSlider", bundle: nil)
        return nib
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
