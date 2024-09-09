//
//  AnyStruct.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/12.
//

import Foundation
import UIKit
import PDFKit

// SheetItem
struct SheetItem {
    var icon: String
    var title: String
    var tag: Int?
}

// ActionItem
struct ActionItem {
    var image: String
    var title: String
    var tag: Int
}

// PDF catalog 缩略图
struct PDFThumbItem {
    var image: UIImage
    var page: Int
}

// PDF 目录结构体
struct TreeNode {
    var title: String
    var page: String
    var level: Int
    var isleaf: Bool
    var isOpen: Bool
    var parent: PDFOutline
}

// more table cell
struct MoreAction {
    var icon: String
    var title: String
    var action: EditMoreType
}

// action enum
enum EditMoreType {
    case search
    case delete
    case rename
    case send
    case printer
    case ocr
    case waterMark
    case world
}

