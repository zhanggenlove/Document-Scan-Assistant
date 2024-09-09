//
//  String+Extensions.swift
//  Evaluate
//
//  Created by Mister Grizzly on 12/17/20.
//

import Foundation

extension String {
  static func localize(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "EvaluateLocalization", bundle: Bundle(for: Evaluate.self), comment: "")
  }
  
  var localize: String {
    return NSLocalizedString(self, tableName: "EvaluateLocalization", bundle: Bundle(for: Evaluate.self), comment: "")
  }
}
