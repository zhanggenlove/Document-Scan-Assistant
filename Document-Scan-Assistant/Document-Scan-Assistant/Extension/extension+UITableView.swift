//
//  extension+UITableView.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/7/6.
//

import Foundation
import UIKit

extension UITableView {
    func showEmpty(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = MyFont.font(with: .light, size: 16)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func removeEmpty() {
        self.backgroundView = nil
    }
}