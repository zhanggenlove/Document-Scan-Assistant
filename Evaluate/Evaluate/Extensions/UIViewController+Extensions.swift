//
//  UIViewController+Extensions.swift
//  Evaluate
//
//  Created by Mister Grizzly on 12/17/20.
//

import UIKit

struct ReviewAlertAction {
  let title: String?
  let preferredStyle: UIAlertAction.Style
}

struct ReviewAlertViewModel {
  let title: String?
  let message: String?
  let rateAppOption: ReviewAlertAction?
  let writeAppStoreReviewOption: ReviewAlertAction
  var remindLaterOption: ReviewAlertAction? = nil
  let cancelOption: ReviewAlertAction?
  
  init(title: String?, message: String?,
       rateAppOption: ReviewAlertAction? = nil,
       writeAppStoreReviewOption: ReviewAlertAction,
       remindLaterOption: ReviewAlertAction? = nil,
       cancelOption: ReviewAlertAction?) {
    
    self.title = title
    self.message = message
    self.rateAppOption = rateAppOption
    self.writeAppStoreReviewOption = writeAppStoreReviewOption
    self.remindLaterOption = remindLaterOption
    self.cancelOption = cancelOption
  }
}

extension UIViewController {
  /**
   This is a simply method to show an alert with two different options button.
   
   - Parameter title: The title to display.
   - Parameter message: The message to display.
   - Parameter doneOptionTitle: The done button name to display.
   - Parameter cancelOptionTitle: The cancel button name to display.
   - Parameter cancelCompletion: returns completion when cancel button is tapped.
   - Parameter doneCompletion: returns completion when done button is tapped.
   */
  func showAlert(using config: EvaluateUIAlertConfig?, viewModel: ReviewAlertViewModel,
                 rateAppCompletion: ((UIAlertAction) -> Void)? = nil,
                 writeAppStoreReviewCompletion: ((UIAlertAction) -> Void)? = nil,
                 remindLaterCompletion: ((UIAlertAction) -> Void)? = nil,
                 cancelCompletion: ((UIAlertAction) -> Void)? = nil) {

    let alertController = EvaluateReviewAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
    if let image = config?.image {
      alertController.setTitleImage(image)
    }
    
    if #available(iOS 10.3, *) {
      if let rateAppOption = viewModel.rateAppOption {
        alertController.addAction(UIAlertAction(title: rateAppOption.title, style: rateAppOption.preferredStyle, handler: rateAppCompletion))
      }
    }
    
    alertController.addAction(UIAlertAction(title: viewModel.writeAppStoreReviewOption.title,
                                            style: viewModel.writeAppStoreReviewOption.preferredStyle, handler: writeAppStoreReviewCompletion))
    
    if let remindLaterOption = viewModel.remindLaterOption {
      alertController.addAction(UIAlertAction(title: remindLaterOption.title,
                                              style: remindLaterOption.preferredStyle, handler: remindLaterCompletion))
    }
    
    if let cancelOption = viewModel.cancelOption {
      alertController.addAction(UIAlertAction(title: cancelOption.title,
                                              style: cancelOption.preferredStyle, handler: cancelCompletion))
    }

    if let config = config {
      set(TitleOrMessage: viewModel.title, config: config, isTitle: true, forKey: "attributedTitle", alertController: alertController)
      set(TitleOrMessage: viewModel.message, config: config, isTitle: false, forKey: "attributedMessage", alertController: alertController)
      
      UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = config.buttonsColor
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      guard let self = self else { return }
      if let navigation = self.navigationController {
        navigation.present(alertController, animated: true)
      } else {
        self.present(alertController, animated: true)
      }
    }
  }
  
  private func set(TitleOrMessage text: String?,
                   config: EvaluateUIAlertConfig,
                   isTitle: Bool,
                   forKey attributedKey: String,
                   alertController: EvaluateReviewAlertController) {
    var messageAttrs: [NSAttributedString.Key : Any]?
    
    if let messageFont = isTitle ? config.titleFont : config.messageFont {
      messageAttrs = [NSAttributedString.Key.font: messageFont]
    }
    
    if let messageColor = isTitle ? config.titleColor : config.messageColor {
      if let messageFont = isTitle ? config.titleFont : config.messageFont {
        messageAttrs = [NSAttributedString.Key.font: messageFont, NSAttributedString.Key.foregroundColor: messageColor]
      } else {
        messageAttrs = [NSAttributedString.Key.foregroundColor: messageColor]
      }
    }
    
    if let messageAttrs = messageAttrs {
      let messageAttributedString = NSAttributedString(string: text ?? "", attributes: messageAttrs)
      alertController.setValue(messageAttributedString, forKey: attributedKey)
    }
  }
}

