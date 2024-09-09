//
//  MyFont.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/6.
//

import Foundation
import UIKit

enum FontTye {
    case defalut
    case light
    case bold
}

enum MyFont {
    static func font(with type: FontTye, size: Int = 14) -> UIFont {
        let fontSize = CGFloat(size)
        switch type {
        case .defalut:
            return UIFont(name: "Karoll-Round", size: fontSize)!
        case .light:
            return UIFont(name: "Karoll-LightRound", size: fontSize)!
        case .bold:
            return UIFont(name: "Karoll-BoldRound", size: fontSize)!
        }
    }
}
