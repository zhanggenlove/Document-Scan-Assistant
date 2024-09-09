//
//  TableViewHeaderView.swift
//  文档扫描小助手
//
//  Created by 张根 on 2022/10/18.
//

import UIKit

class TableViewHeaderView: UIView {
    
    @IBOutlet weak var fileCount: UILabel!
    
    @IBOutlet weak var collectView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
