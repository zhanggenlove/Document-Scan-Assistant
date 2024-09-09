//
//  index.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/11.
//

import Foundation


// actionsheet点击事件的通知
public let actionSheetItemTapName = NSNotification.Name.init("actionSheetItemClick")
public func postActionSheetItemClick(object: Any?) {
    NotificationCenter.default.post(name: actionSheetItemTapName, object: object)
}

