//
//  extension+UIViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/7/17.
//

import Foundation
import UIKit
import Evaluate

class EvaluateBaseController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Evaluate.rateApp(in: self)
    }
}
