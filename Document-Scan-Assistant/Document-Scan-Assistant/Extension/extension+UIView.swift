//
//  extension+UIView.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/10.
//
import UIKit
import Foundation

extension UIView {
    @discardableResult
    func addGradient(colors: [UIColor],
                     point: (CGPoint, CGPoint) = (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1)),
                     locations: [NSNumber] = [0, 1],
                     frame: CGRect = CGRect.zero,
                     radius: CGFloat = 0,
                     at: UInt32 = 0) -> CAGradientLayer {
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = colors.map { $0.cgColor }
        bgLayer1.locations = locations
        if frame == .zero {
            bgLayer1.frame = self.bounds
        } else {
            bgLayer1.frame = frame
        }
        bgLayer1.startPoint = point.0
        bgLayer1.endPoint = point.1
        bgLayer1.cornerRadius = radius
        self.layer.insertSublayer(bgLayer1, at: at)
        return bgLayer1
    }
 
    func addGradient(start: CGPoint = CGPoint(x: 0.5, y: 0),
                     end: CGPoint = CGPoint(x: 0.5, y: 1),
                     colors: [UIColor],
                     locations: [NSNumber] = [0, 1],
                     frame: CGRect = CGRect.zero,
                     radius: CGFloat = 0,
                     at: UInt32 = 0) {
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = colors.map { $0.cgColor }
        bgLayer1.locations = locations
        bgLayer1.frame = frame
        bgLayer1.startPoint = start
        bgLayer1.endPoint = end
        bgLayer1.cornerRadius = radius
        self.layer.insertSublayer(bgLayer1, at: at)
    }
 
    func addGradient(start_color:String,end_color : String,frame : CGRect?=nil,cornerRadius : CGFloat?=0, at: UInt32 = 0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(hexStr: start_color)!.cgColor, UIColor(hexStr: end_color)!.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
//        bgLayer1.startPoint = CGPoint(x: 0, y: 0.61)
//        bgLayer1.endPoint = CGPoint(x: 0.61, y: 0.61)
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.insertSublayer(bgLayer1, at: at)
    }
    func addGradient(start_color: UIColor, end_color : UIColor,frame : CGRect?=nil,cornerRadius : CGFloat?=0, at: UInt32 = 0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [start_color.cgColor, end_color.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
//        bgLayer1.startPoint = CGPoint(x: 0, y: 0.61)
//        bgLayer1.endPoint = CGPoint(x: 0.61, y: 0.61)
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.insertSublayer(bgLayer1, at: at)
    }
    
    func addGradient(start_color:String,
                     end_color : String,
                     frame : CGRect?=nil,
                     borader: CGFloat = 0,
                     boraderColor: UIColor = .clear,
                     at: UInt32 = 0,
                     corners: UIRectCorner?,
                     radius: CGFloat = 0) {
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(hexStr: start_color)!.cgColor, UIColor(hexStr: end_color)!.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0, y: 0.61)
        bgLayer1.endPoint = CGPoint(x: 0.61, y: 0.61)
        bgLayer1.borderColor = boraderColor.cgColor
        bgLayer1.borderWidth = borader
        if corners != nil {
            let cornerPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners!, cornerRadii: CGSize(width: radius, height: radius))
            let radiusLayer = CAShapeLayer()
            radiusLayer.frame = bounds
            radiusLayer.path = cornerPath.cgPath
            bgLayer1.mask = radiusLayer
        }
        self.layer.insertSublayer(bgLayer1, at: at)
    }
 
    func addGradient(startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
                     start_color:String,
                     endPoint: CGPoint = CGPoint(x: 1, y: 0.5),
                     end_color : String,
                     frame : CGRect? = nil,
                     cornerRadius : CGFloat?=0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.frame = bounds
        bgLayer1.startPoint = startPoint
        bgLayer1.endPoint = endPoint
        bgLayer1.colors = [UIColor(hexStr: start_color)!.cgColor, UIColor(hexStr: end_color)!.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.addSublayer(bgLayer1)
    }
 
    func addVerticalGradient(start_color:String,end_color : String,frame : CGRect?=nil,cornerRadius : CGFloat?=0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(hexStr: start_color)!.cgColor, UIColor(hexStr: end_color)!.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0.5, y: 0)
        bgLayer1.endPoint = CGPoint(x: 1, y: 1)
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.insertSublayer(bgLayer1, at: 0)
    }
 
    //将当前视图转为UIImage
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

