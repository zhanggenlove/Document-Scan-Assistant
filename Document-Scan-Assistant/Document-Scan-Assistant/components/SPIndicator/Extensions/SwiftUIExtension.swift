import SwiftUI

#if os(iOS)

@available(iOS 13.0, *)
@available(iOSApplicationExtension, unavailable)

extension View {
    
    public func SPIndicator(
        isPresent: Binding<Bool>,
        indicatorView: SPIndicatorView,
        duration: TimeInterval = 2.0,
        haptic: SPIndicatorHaptic = .none
    ) -> some View {
        
        if isPresent.wrappedValue {
            let indicatorCompletion  = indicatorView.completion
            let indicatorDismiss = {
                isPresent.wrappedValue = false
                indicatorCompletion?()
            }
            indicatorView.duration = duration
            indicatorView.present(haptic: haptic, completion: indicatorDismiss)
        }
        return self
    }
    
    public func SPIndicator(
        isPresent: Binding<Bool>,
        title: String = "",
        message: String? = nil,
        duration: TimeInterval = 2.0,
        presentSide: SPIndicatorPresentSide = .top,
        dismissByDrag: Bool = true,
        preset: SPIndicatorIconPreset = .done,
        haptic: SPIndicatorHaptic = .none,
        layout: SPIndicatorLayout? = nil,
        completion: (()-> Void)? = nil
    ) -> some View {
        
        let indicatorView = SPIndicatorView(title: title, message: message, preset: preset)
        indicatorView.presentSide = presentSide
        indicatorView.dismissByDrag = dismissByDrag
        indicatorView.layout = layout ??  SPIndicatorLayout(for: preset)
        indicatorView.completion = completion
        return SPIndicator(isPresent: isPresent, indicatorView: indicatorView, duration: duration, haptic: haptic)
    }
    
    public func SPIndicator(
        isPresent: Binding<Bool>,
        title: String,
        duration: TimeInterval = 2.0,
        presentSide: SPIndicatorPresentSide = .top,
        dismissByDrag: Bool = true,
        preset: SPIndicatorIconPreset = .done,
        haptic: SPIndicatorHaptic = .none,
        completion: (()-> Void)? = nil
    ) -> some View {
        
        let indicatorView = SPIndicatorView(title: title, preset: preset)
        indicatorView.presentSide = presentSide
        indicatorView.dismissByDrag = dismissByDrag
        indicatorView.completion = completion
        return SPIndicator(isPresent: isPresent, indicatorView: indicatorView, duration: duration, haptic: haptic)
    }
    
}
#endif
