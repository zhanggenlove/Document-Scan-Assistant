//
//  documentsUpdateNot.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/20.
//

import Foundation

public let documentsUpdateNot = NSNotification.Name.init("documentsUpdateNot")
public func postDocumentsUpdate(object: Any?) {
    NotificationCenter.default.post(name: documentsUpdateNot, object: object)
}
// 删除PDF page通知
public let documentsDeletePageNot = NSNotification.Name.init("documentsDeletePageNot")
public func postDocumentsDeletePage(object: Any?) {
    NotificationCenter.default.post(name: documentsDeletePageNot, object: object)
}

// 通知保存文件并更新
public let documentsSaveUpdateNot = NSNotification.Name.init("documentsSaveUpdate")
public func postDocumentsSaveUpdate(object: Any?) {
    NotificationCenter.default.post(name: documentsSaveUpdateNot, object: object)
}

// 通知删除文件夹
public let deleteDirNot = NSNotification.Name.init("deleteDirNot")
public func postDeleteDirNot(object: Any?) {
    NotificationCenter.default.post(name: deleteDirNot, object: object)
}
// 通知重命名文件夹
public let renameDirNot = NSNotification.Name.init("renameDirNot")
public func postRenameDirNot(object: Any?) {
    NotificationCenter.default.post(name: renameDirNot, object: object)
}
// 通知添加文件夹
public let addDirNot = NSNotification.Name.init("addDirNot")
public func postAddDirNot(object: Any?) {
    NotificationCenter.default.post(name: addDirNot, object: object)
}

// 通知显示Google ads
public let showGooleAdsNot = NSNotification.Name.init("showGooleAdsNot")
public func postShowGooleAdsNot(object: Any?) {
    NotificationCenter.default.post(name: showGooleAdsNot, object: object)
}
