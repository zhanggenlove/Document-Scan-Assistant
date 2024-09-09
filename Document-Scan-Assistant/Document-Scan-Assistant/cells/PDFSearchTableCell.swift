//
//  PDFSearchTableCell.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/5/5.
//

import UIKit

class PDFSearchTableCell: UITableViewCell {
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var regCountLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    static func loadNib() -> UINib {
        return UINib(nibName: "PDFSearchTableCell", bundle: nil)
    }
    func setupUI() {
        cover.layer.cornerRadius = 8
        cover.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
