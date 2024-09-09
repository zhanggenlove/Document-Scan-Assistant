//
//  AppDelegate.swift
//  文档扫描小助手
//
//  Created by 张根 on 2022/10/17.
//

import Evaluate
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化文件夹
        MyFileManager.shared.initFolder()
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: APP_FIRST_LAUNCH_TIME)
        UserDefaults.standard.set(false, forKey: IS_PREMIUM)
        UserDefaults.standard.set(0, forKey: HAS_SAVE_DOCUMENTS_COUNT)
        initEvaluate()
        return true
    }

    private func initEvaluate() {
        let configuration = EvaluateUIAlertConfig(image: UIImage(named: "5stars"), buttonsColor: .systemBlue, titleColor: .label, titleFont: MyFont.font(with: .bold, size: 17), messageColor: .brown, messageFont: MyFont.font(with: .defalut, size: 15))
        Evaluate.uiConfiguration = configuration
        Evaluate.alertAppStoreTitle = String.localize("AppDelegate.alertAppStoreTitle")
        Evaluate.alertMessage = String.localize("AppDelegate.alertMessage")
        Evaluate.alertCancelTitle = String.localize("AppDelegate.alertCancelTitle")
        Evaluate.appID = APPID
        Evaluate.appName = String.localize("app.name") // 1 3 1 2
        Evaluate.daysUntilAlertWillBeShown = 1
        Evaluate.appUsesUntilAlertWillBeShown = 3
        Evaluate.significantUsesUntilAlertWillBeShown = 1
        Evaluate.numberOfDaysBeforeRemindingAfterCancelation = 2
        Evaluate.showRemindLaterButton = true
        Evaluate.activateDebugMode = false
        Evaluate.canShowLogs = false
        Evaluate.start()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
