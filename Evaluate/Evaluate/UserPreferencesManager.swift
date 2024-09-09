//
//  UserPreferencesManager.swift
//  Evaluate
//
//  Created by Mister Grizzly on 12/8/20.
//

import UIKit

final class UserPreferencesManager: NSObject {

  // MARK: - Private properties

  private static let kUDInvalidValue = -1

  private enum UserDefaultsKeys: String {
    case kAppRateDone, kAppTrackingVersion, kAppFirstUseDate, kAlertReminderRequestDate, kAppUsesCount, kAppSignificantEventCount
  }
  
  static let `default` = UserPreferencesManager()
  
  private let userDefaults: UserDefaults
    
  private var firstUseDate: TimeInterval {
    let value = userDefaults.double(forKey: UserDefaultsKeys.kAppFirstUseDate.rawValue)
    
    if value == 0 {
      // store first launch date time
      let firstLaunchTimeInterval = Date().timeIntervalSince1970
      userDefaults.set(firstLaunchTimeInterval, forKey: UserDefaultsKeys.kAppFirstUseDate.rawValue)
      return firstLaunchTimeInterval
    } else {
      return value
    }
  }
  
  private var reminderTimeRequestToRate: TimeInterval {
    get {
      return userDefaults.double(forKey: UserDefaultsKeys.kAlertReminderRequestDate.rawValue)
    }
    set {
      userDefaults.set(newValue, forKey: UserDefaultsKeys.kAlertReminderRequestDate.rawValue)
      userDefaults.synchronize()
    }
  }
  
  private var usesCount: Int {
    get {
      return userDefaults.integer(forKey: UserDefaultsKeys.kAppUsesCount.rawValue)
    }
    set {
      userDefaults.set(newValue, forKey: UserDefaultsKeys.kAppUsesCount.rawValue)
      userDefaults.synchronize()
    }
  }
  
  private var significantEventCount: Int {
    get {
      return userDefaults.integer(forKey: UserDefaultsKeys.kAppSignificantEventCount.rawValue)
    }
    set {
      userDefaults.set(newValue, forKey: UserDefaultsKeys.kAppSignificantEventCount.rawValue)
      userDefaults.synchronize()
    }
  }
  
  // MARK: - Init
  
  private override init() {
    self.userDefaults = UserDefaults.standard
    super.init()
    
    let defaultValues: [String : Any] = [
      UserDefaultsKeys.kAppFirstUseDate.rawValue: 0,
      UserDefaultsKeys.kAppUsesCount.rawValue: 0,
      UserDefaultsKeys.kAppSignificantEventCount.rawValue: 0,
      UserDefaultsKeys.kAppRateDone.rawValue: false,
      UserDefaultsKeys.kAppTrackingVersion.rawValue: "",
      UserDefaultsKeys.kAlertReminderRequestDate.rawValue: 0
    ]
    userDefaults.register(defaults: defaultValues)
  }
  
  // MARK: - Public properties
  
  var daysUntilAlertWillBeShown: Int = kUDInvalidValue
  var appUsesUntilAlertWillBeShown: Int = kUDInvalidValue
  var significantUsesUntilAlertWillBeShown: Int = kUDInvalidValue
  var numberOfDaysBeforeReminding: Int = kUDInvalidValue

  var showLaterButton: Bool = true
  var isDebugModeEnabled: Bool = false
  
  var isRateDone: Bool {
    get {
      return userDefaults.bool(forKey: UserDefaultsKeys.kAppRateDone.rawValue)
    }
    set {
      userDefaults.set(newValue, forKey: UserDefaultsKeys.kAppRateDone.rawValue)
      userDefaults.synchronize()
    }
  }
  
  var appTrackingVersion: String {
    get {
      return userDefaults.string(forKey: UserDefaultsKeys.kAppTrackingVersion.rawValue) ?? ""
    }
    set {
      userDefaults.set(newValue, forKey: UserDefaultsKeys.kAppTrackingVersion.rawValue)
      userDefaults.synchronize()
    }
  }
  
  var allConditionsHaveBeenMet: Bool {
    // if debug mode, return always true cuz of security reasons, if you're not wondering about it, you can remove.
    guard !isDebugModeEnabled else {
      printMessage(message: " In debug mode")
      return true
    }
    
    // if already rated, return false
    guard !isRateDone else {
      printMessage(message: " Already rated")
      return false
    }
    
    if reminderTimeRequestToRate == 0 {
      // check if the app has been used enough days
      if daysUntilAlertWillBeShown != UserPreferencesManager.kUDInvalidValue {
        printMessage(message: "will check daysUntilAlertWillBeShown")
        let dateOfFirstLaunch = Date(timeIntervalSince1970: firstUseDate)
        let timeSinceFirstLaunch = Date().timeIntervalSince(dateOfFirstLaunch)
        let timeUntilRate = 60 * 60 * 24 * daysUntilAlertWillBeShown;
        guard Int(timeSinceFirstLaunch) < timeUntilRate else { return true }
      }
      
      // check if the app has been used enough times
      if appUsesUntilAlertWillBeShown != UserPreferencesManager.kUDInvalidValue {
        printMessage(message: "will check appUsesUntilAlertWillBeShown")
        guard usesCount <= appUsesUntilAlertWillBeShown else { return true }
      }
      
      // check if the user has done enough significant events
      if significantUsesUntilAlertWillBeShown != UserPreferencesManager.kUDInvalidValue {
        printMessage(message: " will check significantUsesUntilPrompt")
        guard significantEventCount <= significantUsesUntilAlertWillBeShown else {
          return true
        }
      }
    } else {
      // if the user wanted to be reminded later, has enough time passed?
      if numberOfDaysBeforeReminding != UserPreferencesManager.kUDInvalidValue {
        printMessage(message: " will check numberOfDaysBeforeReminding")
        let dateOfReminderRequest = Date(timeIntervalSince1970: reminderTimeRequestToRate)
        let timeSinceReminderRequest = Date().timeIntervalSince(dateOfReminderRequest)
        let timeUntilRate = 60 * 60 * 24 * numberOfDaysBeforeReminding;
        guard Int(timeSinceReminderRequest) < timeUntilRate else { return true }
      }
    }
    
    return false
  }
  
  // MARK: - Helper methods
  
  func resetAllValues() {
    userDefaults.set(0, forKey: UserDefaultsKeys.kAppFirstUseDate.rawValue)
    userDefaults.set(0, forKey: UserDefaultsKeys.kAppUsesCount.rawValue)
    userDefaults.set(0, forKey: UserDefaultsKeys.kAppSignificantEventCount.rawValue)
    userDefaults.set(false, forKey: UserDefaultsKeys.kAppRateDone.rawValue)
    userDefaults.set(0, forKey: UserDefaultsKeys.kAlertReminderRequestDate.rawValue)
    userDefaults.synchronize()
  }
  
  func incrementAppUsesCount() {
    usesCount += 1
  }
  
  func incrementSignificantUsesCount() {
    significantEventCount += 1
  }
  
  func saveReminderRequestDate() {
    reminderTimeRequestToRate = Date().timeIntervalSince1970
  }
  
  private func printMessage(message: String) {
    guard Evaluate.canShowLogs else { return }
    print("[\(Bundle.appName)] \(message)")
  }
}
