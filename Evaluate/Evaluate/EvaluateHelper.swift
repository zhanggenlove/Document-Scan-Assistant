//
//  EvaluateHelper.swift
//  Evaluate
//
//  Created by Mister Grizzly on 12/17/20.
//

import Foundation

class EvaluateHelper: NSObject {
  enum EvaluateError: Error {
    case malformedURL
    case missingBundleIdOrAppId
  }
  
  enum EvaluateErrorCode: Int {
    case malformedURL = 1000
    case appStoreDataRetrievalFailure
    case appStoreJSONParsingFailure
    case appStoreAppIDFailure
  }
  
  static let `default` = EvaluateHelper()
  
  @objc let EvaluateErrorDomain = "EvaluateHelper Error Domain"
  
  private override init() {
    super.init()
  }
  
  func startParsingData() {
    // If not set, get appID and version from itunes
    do {
      let url = try EvaluateHelper.default.getiTunesURL()
      let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
      URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        EvaluateHelper.default.processResults(withData: data, response: response, error: error)
      }).resume()
    } catch let error {
      EvaluateHelper.default.postError(.malformedURL, underlyingError: error)
    }
  }
  
  private func processResults(withData data: Data?, response: URLResponse?, error: Error?) {
    if let error = error {
      self.postError(.appStoreDataRetrievalFailure, underlyingError: error)
    } else {
      guard let data = data else {
        self.postError(.appStoreDataRetrievalFailure, underlyingError: nil)
        return
      }
      
      do {
        let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        guard let appData = jsonData as? [String: Any] else {
          self.postError(.appStoreJSONParsingFailure, underlyingError: nil)
          return
        }
        
        DispatchQueue.main.async { [weak self] in
          self?.processVersionCheck(withResults: appData)
        }
        
      } catch let error {
        self.postError(.appStoreDataRetrievalFailure, underlyingError: error)
      }
    }
  }
  
  private func processVersionCheck(withResults results: [String: Any]) {
    defer {
      Evaluate.default.incrementAppUsagesCount()
    }
    guard let allResults = results["results"] as? [[String: Any]] else {
      self.postError(.appStoreDataRetrievalFailure, underlyingError: nil)
      return
    }
    
    // The App is not in App Store
    guard !allResults.isEmpty else {
      postError(.appStoreDataRetrievalFailure, underlyingError: nil)
      return
    }
    
    guard let appID = allResults.first?["trackId"] as? Int else {
      postError(.appStoreAppIDFailure, underlyingError: nil)
      return
    }
    
    Evaluate.default.setAppID(String(appID))
  }
  
  private func getiTunesURL() throws -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "itunes.apple.com"
    if let countryCode = Evaluate.countryCode {
      components.path = "/\(countryCode)/lookup"
    } else {
      components.path = "/lookup"
    }
    
    let items: [URLQueryItem] = [URLQueryItem(name: "bundleId", value: Bundle.bundleID)]
    
    components.queryItems = items
    
    guard let url = components.url, !url.absoluteString.isEmpty else {
      throw EvaluateError.malformedURL
    }
    
    return url
  }
  
  private func postError(_ code: EvaluateErrorCode, underlyingError: Error?) {
    let description: String
    
    switch code {
    case .malformedURL:
      description = "The iTunes URL is malformed. Please leave an issue on http://github.com/ArtSabintsev/Siren with as many details as possible."
    case .appStoreDataRetrievalFailure:
      description = "Error retrieving App Store data as an error was returned."
    case .appStoreJSONParsingFailure:
      description = "Error parsing App Store JSON data."
    case .appStoreAppIDFailure:
      description = "Error retrieving trackId as results.first does not contain a 'trackId' key."
    }
    
    var userInfo: [String: Any] = [NSLocalizedDescriptionKey: description]
    
    if let underlyingError = underlyingError {
      userInfo[NSUnderlyingErrorKey] = underlyingError
    }
    
    let error = NSError(domain: EvaluateErrorDomain, code: code.rawValue, userInfo: userInfo)
    printMessage(message: error.localizedDescription)
  }
  
  private func printMessage(message: String) {
    if Evaluate.canShowLogs {
      print("[Evaluate] \(message)")
    }
  }
}
