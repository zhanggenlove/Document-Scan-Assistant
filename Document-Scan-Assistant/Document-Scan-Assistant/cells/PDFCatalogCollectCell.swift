//
//  PDFCatalogCollectCell.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/25.
//

import UIKit

class PDFCatalogCollectCell: UICollectionViewCell {
    @IBOutlet var thumbImage: UIImageView!

    @IBOutlet var pageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    static func loadNib() -> UINib {
        let nib = UINib(nibName: "PDFCatalogCollectCell", bundle: nil)
        return nib
    }
    
    func initUI() {
        pageLabel.layer.cornerRadius = 4.0
        pageLabel.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
        thumbImage.layer.cornerRadius = 8.0
        thumbImage.layer.masksToBounds = true
    }
}
