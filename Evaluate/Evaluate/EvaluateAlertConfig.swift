//
//  EvaluateAlertConfig.swift
//  Evaluate
//
//  Created by Mister Grizzly on 12/17/20.
//

import UIKit

@objc public class EvaluateUIAlertConfig: NSObject {
  
  var image: UIImage?
  
  var buttonsColor: UIColor?
  
  var titleColor: UIColor?
  var titleFont: UIFont?
  
  var messageColor: UIColor?
  var messageFont: UIFont?
  
  public init(image: UIImage? = nil,
              buttonsColor: UIColor? = nil,
              titleColor: UIColor? = nil,
              titleFont: UIFont? = nil,
              messageColor: UIColor? = nil,
              messageFont: UIFont? = nil) {
    
    self.image = image
    self.buttonsColor = buttonsColor
    
    self.titleColor = titleColor
    self.titleFont = titleFont
    
    self.messageColor = messageColor
    self.messageFont = messageFont
  }
}
