//
//  define.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/24.
//

import Foundation
import UIKit

// 常量
let windowW = UIScreen.main.bounds.width

let windowH = UIScreen.main.bounds.height

// 是否island系列手机
let is14Pro = UIDevice.modelName().contains("14 Pro")

// 判断字符串是否包含特殊字符
func isNotLegalText(text: String) -> Bool {
    return text.contains(".") || text.contains("\\") || text.contains("/") || text.contains("*") || text.contains("|") || text.contains(">") || text.contains("=") || text.contains("<") ||
        text.contains("?")
}

// show alert
func showModal(title: String = "", parent: UIViewController?, content: String) {
    let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
    let ok = UIAlertAction(title: String.localize("HomeVC.alert.submit"), style: .default)
    alert.addAction(ok)
    parent?.present(alert, animated: true)
}

// appdelegate 保存文件
func appSaveFile(dir: URL = MyFileManager.shared.documentPath, url: URL) {
    ProgressHud.show()
    // 保存文件📃
    DispatchQueue.global().async {
        MyFileManager.shared.writeFile(dir: dir, for: try? Data(contentsOf: url), with: url.lastPathComponent)
        recordDocumentsCount()
        postDocumentsUpdate(object: nil)
        ProgressHud.hide()
        DispatchQueue.main.async {
            let spView = SPIndicatorView(title: String.localize("define.file.succ"), preset: .done)
            spView.present(duration: 2, haptic: .success)
        }
    }
}

// 校验最多能保存的文件
func checkCanUseAppWithMaxFileCount(tag: Int) -> Bool {
    let isPremium = UserDefaults.standard.bool(forKey: IS_PREMIUM)
    let hasSaveFileCount = UserDefaults.standard.integer(forKey: HAS_SAVE_DOCUMENTS_COUNT)
    if ([1, 3, 4].contains(tag) && !isPremium && hasSaveFileCount >= MAX_FILE_CAN_USE_COUNT) {
        return false
    } else {
        return true
    }
}
// 保存文件计数
func recordDocumentsCount() {
    let MAX_FILE_CAN_USE_COUNT = UserDefaults.standard.integer(forKey: HAS_SAVE_DOCUMENTS_COUNT)
    UserDefaults.standard.set(MAX_FILE_CAN_USE_COUNT + 1, forKey: HAS_SAVE_DOCUMENTS_COUNT)
}
// 我的App ID
let APPID = "6452550631"
// Google ad id
#if !DEBUG
let GOOGLE_AD_ID = "ca-app-pub-7760048861932972/4745910977"
#else
let GOOGLE_AD_ID = "ca-app-pub-3940256099942544/4411468910"
#endif
// 安装时间
let APP_FIRST_LAUNCH_TIME = "APP_FIRST_LAUNCH_TIME"
// 最大限制使用文件个数
let MAX_FILE_CAN_USE_COUNT = 20
let HAS_SAVE_DOCUMENTS_COUNT = "HAS_SAVE_DOCUMENTS_COUNT"
// 是否购买了premium
let IS_PREMIUM = "IS_PREMIUM"
// 用户使用app几天后显示广告 2天
let someDaySeconds = 2.0 * 24 * 60 * 60
