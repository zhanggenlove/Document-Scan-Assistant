//
//  extension+String.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/23.
//

import Foundation

extension String {
    static func localize(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "Localizable", comment: "")
    }

    var localize: String {
        return NSLocalizedString(self, tableName: "Localizable", comment: "")
    }
}
