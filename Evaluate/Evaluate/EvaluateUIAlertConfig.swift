//
//  EvaluateUIAlertConfig.swift
//  Evaluate
//
//  Created by Mister Grizzly on 12/17/20.
//

import UIKit

@objc public class EvaluateUIAlertConfig: NSObject {
  
  @objc public var image: UIImage?
  
  @objc public var buttonsColor: UIColor?
  
  @objc public var titleColor: UIColor?
  @objc public var titleFont: UIFont?
  
  @objc public var messageColor: UIColor?
  @objc public var messageFont: UIFont?
  
  @objc public init(image: UIImage? = nil,
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
