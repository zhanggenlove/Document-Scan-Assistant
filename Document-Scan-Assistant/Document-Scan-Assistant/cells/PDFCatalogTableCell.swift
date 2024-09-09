//
//  PDFCatalogTableCell.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/25.
//

import UIKit

class PDFCatalogTableCell: UITableViewCell {
    @IBOutlet weak var expandButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pageLabel: UILabel!
    
    @IBAction func ExpandBtnTap(_ sender: UIButton) {
        expandBtnClickClosure?(sender)
    }
    
    @IBOutlet weak var leftOffset: NSLayoutConstraint!
    
    var expandBtnClickClosure:((_ sender: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func loadNib() -> UINib  {
        return UINib(nibName: "PDFCatalogTableCell", bundle: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if indentationLevel == 1 {
            titleLabel.font = UIFont.systemFont(ofSize: 18)
        } else if indentationLevel == 2 {
            titleLabel.font = UIFont.systemFont(ofSize: 17)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 16)
        }
        leftOffset.constant = CGFloat(indentationWidth * CGFloat(indentationLevel))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        print("prepareForReuse")
//        expandButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
    }
}
