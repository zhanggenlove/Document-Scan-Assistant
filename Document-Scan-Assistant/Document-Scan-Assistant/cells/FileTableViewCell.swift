//
//  FileTableViewCell.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/7.
//

import UIKit

class FileTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var pageLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var bgView: UIView!
    @IBOutlet var imageCover: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    static func loadNib() -> UINib{
        let nib = UINib(nibName: "FileTableViewCell", bundle: nil)
        return nib
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 初始化UI
    private func initUI() {
        bgView.layer.shadowColor = UIColor.gray.cgColor
        bgView.layer.shadowOffset = CGSize(width: 2, height: 3)
        bgView.layer.shadowRadius = 3
        bgView.layer.shadowOpacity = 0.4
        bgView.layer.cornerRadius = 6
        imageCover.layer.cornerRadius = 6
        imageCover.layer.masksToBounds = true
        self.selectionStyle = .none
    }
}
