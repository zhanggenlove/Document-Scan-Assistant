//
//  PositionSettingVC.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/6/16.
//

import UIKit
import SPLarkController

class PositionSettingVC: SPLarkSettingsController {
    var curIndex = 0
    let list = ["左上角", "右上角", "左下角", "右下角"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "设置"
    }
    open override func settingsCount() -> Int {
        return list.count
    }
    
    open override func settingTitle(index: Int, highlighted: Bool) -> String {
        return list[index]
    }
    
    open override func settingSubtitle(index: Int, highlighted: Bool) -> String? {
        return nil
    }
    
    open override func settingHighlighted(index: Int) -> Bool {
        if (curIndex == index) {
            return true
        }
        return false
    }
    
    open override func settingColorHighlighted(index: Int) -> UIColor {
        return UIColor.tint
    }
    
    open override func settingDidSelect(index: Int, completion: @escaping () -> ()) {
        curIndex = index
        completion()
        self.reload(index: index)
    }
}
