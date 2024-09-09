//
//  extension+UIColor.swift
//  文档扫描小助手
//
//  Created by 张根 on 2022/10/17.
//

import UIKit

extension UIColor {
    convenience init?(hexStr: String, alpha: CGFloat = 1.0) {
        var cStr = hexStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased() as NSString
        
        if cStr.length < 6 {
            self.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        }
        
        if cStr.hasPrefix("0x") {
            cStr = cStr.substring(from: 2) as NSString
        }
        
        if cStr.hasPrefix("#") {
            cStr = cStr.substring(from: 1) as NSString
        }
        
        if cStr.length != 6 {
            self.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        }
        
        let rStr = (cStr as NSString).substring(to: 2)
        let gStr = ((cStr as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bStr = ((cStr as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r: UInt64 = 0x0
        var g: UInt64 = 0x0
        var b: UInt64 = 0x0
        
        Scanner(string: rStr).scanHexInt64(&r)
        Scanner(string: gStr).scanHexInt64(&g)
        Scanner(string: bStr).scanHexInt64(&b)
        
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
    
    func imageWithColor(width: CGFloat , height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
