import UIKit

@available(iOSApplicationExtension, unavailable)
public enum SPIndicator {
    
    #if os(iOS)
    
    /**
     SPIndicator: Present alert with preset and custom haptic.
     
     - parameter title: Title text in alert.
     - parameter message: Subtitle text in alert. Optional.
     - parameter preset: Icon ready-use style or custom image.
     - parameter haptic: Haptic response with present. Default is `.success`.
     - parameter presentSide: Choose from side appear indicator.
     - parameter completion: Will call with dismiss alert.
     */
    public static func present(title: String, message: String? = nil, preset: SPIndicatorIconPreset, haptic: SPIndicatorHaptic, from presentSide: SPIndicatorPresentSide = .top, completion: (() -> Void)? = nil) {
        let alertView = SPIndicatorView(title: title, message: message, preset: preset)
        alertView.presentSide = presentSide
        alertView.present(haptic: haptic, completion: completion)
    }
    
    /**
     SPIndicator: Present alert with preset and automatically detect type haptic.
     
     - parameter title: Title text in alert.
     - parameter message: Subtitle text in alert. Optional.
     - parameter preset: Icon ready-use style or custom image.
     - parameter presentSide: Choose from side appear indicator. Default is `.top`.
     - parameter completion: Will call with dismiss alert.
     */
    public static func present(title: String, message: String? = nil, preset: SPIndicatorIconPreset, from presentSide: SPIndicatorPresentSide = .top, completion: (() -> Void)? = nil) {
        let alertView = SPIndicatorView(title: title, message: message, preset: preset)
        alertView.presentSide = presentSide
        let haptic = preset.getHaptic()
        alertView.present(haptic: haptic, completion: completion)
    }
    
    /**
     SPIndicator: Show only message, without title and icon.
     
     - parameter message: Title text.
     - parameter haptic: Haptic response with present. Default is `.success`.
     - parameter presentSide: Choose from side appear indicator. Default is `.top`.
     - parameter completion: Will call with dismiss alert.
     */
    public static func present(title: String, message: String? = nil, haptic: SPIndicatorHaptic, from presentSide: SPIndicatorPresentSide = .top, completion: (() -> Void)? = nil) {
        let alertView = SPIndicatorView(title: title, message: message)
        alertView.presentSide = presentSide
        alertView.present(haptic: haptic, completion: completion)
    }
    
    #endif
}
