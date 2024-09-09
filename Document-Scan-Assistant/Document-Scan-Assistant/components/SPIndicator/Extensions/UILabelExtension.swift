
import UIKit

extension UILabel {
    
    func layoutDynamicHeight(width: CGFloat) {
        layoutDynamicHeight(x: frame.origin.x, y: frame.origin.y, width: width)
    }
    
    func layoutDynamicHeight(x: CGFloat, y: CGFloat, width: CGFloat) {
        frame = CGRect.init(x: x, y: y, width: width, height: frame.height)
        sizeToFit()
        if frame.width != width {
            frame = .init(x: x, y: y, width: width, height: frame.height)
        }
    }
}
