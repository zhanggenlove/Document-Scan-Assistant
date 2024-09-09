import UIKit

/**
 SPIndicator: Layout model for view.
 */
open class SPIndicatorLayout {
    
    /**
     SPIndicator: Icon size.
     */
    open var iconSize: CGSize
    
    /**
     SPIndicator: Alert margings for each side.
     */
    open var margins: UIEdgeInsets
    
    public init(iconSize: CGSize, margins: UIEdgeInsets) {
        self.iconSize = iconSize
        self.margins = margins
    }
}
