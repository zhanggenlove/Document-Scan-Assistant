//
//  FolderCollectCell.swift
//  文档扫描小助手
//
//  Created by 张根 on 2022/12/2.
//

import UIKit

class FolderCollectCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    static func loadNib() -> UINib{
        let nib = UINib(nibName: "FolderCollectCell", bundle: nil)
        return nib
    }
    
    private func initUI() {
        bgView.layer.cornerRadius = 8
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = UIColor(named: "folderCellBgViewColor")
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
}
