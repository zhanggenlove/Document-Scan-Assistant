//
//  Windows.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/10.
//

import Foundation
import UIKit

class Windows {
    public static func getWindow() -> UIWindow? {
        if let window = UIApplication.shared.connectedScenes.map({ scene in
            return scene as? UIWindowScene
        }).compactMap({$0}).first?.windows.first {
            return window
        } else {
            return nil
        }
    }
}
