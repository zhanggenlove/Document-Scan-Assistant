//
//  ResizeImgButton.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/12.
//

import Foundation
import UIKit

class ResizeImgButton: UIButton {
    
    var imageSize: CGSize {
        get {
            return self.imageView?.image?.size ?? CGSize.zero
        }
        
        set {
            if let image = self.imageView?.image {
                let resizeImage = image.resizedImage(Size: newValue)
                self.setImage(resizeImage, for: .normal)
            }
        }
    }
    
}
