//
//  Evaluate.swift
//  Evaluate
//
//  Created by Mister Grizzly on 12/8/20.
//

import Foundation
import UIKit
import StoreKit

@objc public class Evaluate: NSObject {
  
  @objc public static var useStoreKitIfAvailable: Bool = true
  @objc public static var showRemindLaterButton: Bool = true
  
  @objc public static var countryCode: String?
  
  @objc public static var alertTitle: String?
  @objc public static var alertMessage: String?
  @objc public static var alertCancelTitle: String?
  @objc static var alertRateAppTitle: String?
  @objc public static var alertAppStoreTitle: String?
  @objc public static var alertRemindLaterTitle: String?
  @objc public static var appName: String?
  
  @objc public static var uiConfiguration: EvaluateUIAlertConfig?
  
  @objc public static var canShowLogs: Bool = false
  @objc public static var resetEverythingWhenAppIsUpdated: Bool = true
  
  @objc public static let `default` = Evaluate()
  
  @objc public static var isRateDone: Bool {
    return UserPreferencesManager.default.isRateDone
  }
  
  @objc public static var appID: String?
  
  private var appName: String {
    return Evaluate.appName ?? Bundle.appName
  }
  
  private var titleText: String {
    return Evaluate.alertTitle ?? String(format: String.localize("Rate %@"), appName)
  }
  
  private var messageText: String {
    return Evaluate.alertMessage ?? String(format: String.localize("Rater.title"), appName)
  }
  
  private var rateText: String {
    return Evaluate.alertRateAppTitle ?? String(format: String.localize("Rate %@"), appName)
  }
  
  private var writeReviewText: String {
    return Evaluate.alertRateAppTitle ?? String.localize("Write a review on App Store")
  }
  
  private var cancelText: String {
    return Evaluate.alertCancelTitle ?? String.localize("No, Thanks")
  }
  
  private var remindLaterText: String {
    return Evaluate.alertRemindLaterTitle ?? String.localize("Remind me later")
  }
    
  /// Check if the app has been used enough days
  @objc public static var daysUntilAlertWillBeShown: Int {
    get {
      return UserPreferencesManager.default.daysUntilAlertWillBeShown
    }
    set {
      UserPreferencesManager.default.daysUntilAlertWillBeShown = newValue
    }
  }
  
  /// Check if the app has been used enough times
  @objc public static var appUsesUntilAlertWillBeShown: Int {
    get {
      return UserPreferencesManager.default.appUsesUntilAlertWillBeShown
    }
    set {
      UserPreferencesManager.default.appUsesUntilAlertWillBeShown = newValue
    }
  }
  
  /// Check if the user has done enough significant events
  @objc public static var significantUsesUntilAlertWillBeShown: Int {
    get {
      return UserPreferencesManager.default.significantUsesUntilAlertWillBeShown
    }
    set {
      UserPreferencesManager.default.significantUsesUntilAlertWillBeShown = newValue
    }
  }
  
  /// If the user wants to be reminded later, has passed enough time passed since then?
  @objc public static var numberOfDaysBeforeRemindingAfterCancelation: Int {
    get {
      return UserPreferencesManager.default.numberOfDaysBeforeReminding
    }
    set {
      UserPreferencesManager.default.numberOfDaysBeforeReminding = newValue
    }
  }
  
  @objc public static var activateDebugMode: Bool {
    get {
      return UserPreferencesManager.default.isDebugModeEnabled
    }
    set {
      UserPreferencesManager.default.isDebugModeEnabled = newValue
    }
  }
  
  private static var controller: UIViewController?
  
  private override init() {
    super.init()
  }
  
  @objc public static func rateApp(in controller: UIViewController) {
    self.controller = controller
    DispatchQueue.main.async {
      if UserPreferencesManager.default.allConditionsHaveBeenMet {
        let viewModel = ReviewAlertViewModel(title: Evaluate.default.titleText, message: Evaluate.default.messageText,
                                             rateAppOption: UIApplication.shared.isAvailableRequestReview() ? ReviewAlertAction(title: Evaluate.default.rateText, preferredStyle: .default) : nil,
                                             writeAppStoreReviewOption: ReviewAlertAction(title: Evaluate.default.writeReviewText, preferredStyle: .default),
                                             remindLaterOption: showRemindLaterButton ?  ReviewAlertAction(title: Evaluate.default.remindLaterText, preferredStyle: .default) : nil,
                                             cancelOption: ReviewAlertAction(title: Evaluate.default.cancelText, preferredStyle: .cancel))
        
        controller.showAlert(using: uiConfiguration, viewModel: viewModel) { _ in
          UIApplication.shared.requestReview()
        } writeAppStoreReviewCompletion: { _ in
          UIApplication.shared.rateAppInAppStore(using: Evaluate.appID)
        } remindLaterCompletion: { _ in
          UserPreferencesManager.default.saveReminderRequestDate()
          controller.dismiss(animated: true, completion: nil)
        } cancelCompletion: { _ in
          UserPreferencesManager.default.isRateDone = true
          controller.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
  
  @objc public static func start() {
    if Evaluate.resetEverythingWhenAppIsUpdated && Bundle.appVersion != UserPreferencesManager.default.appTrackingVersion {
      UserPreferencesManager.default.resetAllValues()
      UserPreferencesManager.default.appTrackingVersion = Bundle.appVersion
    }
    
    Evaluate.default.perform()
  }
  
  @objc public static func reset() {
    UserPreferencesManager.default.resetAllValues()
  }
  
  // MARK: Private methods

  private func perform() {
    if Evaluate.appName != nil {
      incrementAppUsagesCount()
    } else {
      EvaluateHelper.default.startParsingData()
    }
  }
  
  func incrementAppUsagesCount() {
    UserPreferencesManager.default.incrementAppUsesCount()
  }
  
  func setAppID(_ id: String) {
    Evaluate.appID = id
  }
  
  private func incrementSignificantUseCount() {
    UserPreferencesManager.default.incrementSignificantUsesCount()
  }
}
