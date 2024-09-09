//
//  UIApplication+Extensions.swift
//  Evaluate
//
//  Created by Mister Grizzly on 12/17/20.
//

import StoreKit
import UIKit

extension UIApplication {
    @available(iOS 13.0, *)
    var currentScene: UIWindowScene? {
        connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
  
    func requestReview() {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.currentScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
    }
  
    func isAvailableRequestReview() -> Bool {
        if #available(iOS 10.3, *) {
            return true
        }
    
        return false
    }
  
    func rateAppInAppStore(using appID: String?) {
        #if arch(i386) || arch(x86_64)
        debugPrint("SIMULATOR NOTE: iTunes App Store is not supported on the iOS simulator. Unable to open App Store page.")
        #else
        guard let appID = appID else { return }
        let reviewURL = "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review"
        guard let url = URL(string: reviewURL) else { return }
        UIApplication.shared.open(url)
        #endif
    }
}
