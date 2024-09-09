//
//  ProgressHud.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/27.
//

import Foundation
import UIKit

// 来个单例
public class ProgressHud {
    static let shared = ProgressHud()
    
    // 公开变量
    // 背景色
    public var backgroundColor: UIColor = UIColor(hexStr: "#000000", alpha: 0.2)!
    // 透明度
    public var alpha: Double = 1
    // 圆角
    public var cornerRadius: CGFloat = 8.0
    // hub背景
    public var mainViewBgColor: UIColor = .systemGroupedBackground
    // hud image
    public var hudImage: UIImage?
    // 私有变量
    // window
    private var window: UIWindow?
    // 背景
    private var background: UIView?
    // HUD view
    private var mainView: UIView?
    // hud image view
    private var imageView: UIImageView?
    
    private var spinnerView: UIActivityIndicatorView?
    // 公开两个方法 show 和 hide
    class func show(type: ProgressHudType = .spinner) {
        DispatchQueue.main.async {
            shared.setupHUD(type: type)
        }
    }
    
    class func hide() {
        DispatchQueue.main.async {
            shared.destoryHUD()
        }
    }
}

extension ProgressHud {
    // 私有方法
    private func setupHUD(type: ProgressHudType) {
        if window == nil {
            window = Windows.getWindow()
        }
        if background == nil {
            background = UIView(frame: UIScreen.main.bounds)
        }
        let centerX = window!.center.x
        let centerY = window!.center.y
        if mainView == nil {
            mainView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
            mainView?.center = CGPoint(x: centerX, y: centerY)
            mainView?.layer.masksToBounds = true
        }
        if imageView == nil && type == .image {
            imageView = UIImageView()
//            imageView?.center = CGPoint(x: centerX, y: centerY)
            imageView?.translatesAutoresizingMaskIntoConstraints = false
            imageView?.contentMode = .scaleAspectFill
        }
        if spinnerView == nil && type == .spinner {
            spinnerView = UIActivityIndicatorView()
            spinnerView?.color = .label
            spinnerView?.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            spinnerView?.translatesAutoresizingMaskIntoConstraints = false
            spinnerView?.hidesWhenStopped = false
            spinnerView?.startAnimating()
        }
        // 设置外观
        background?.backgroundColor = backgroundColor
        background?.alpha = alpha
        mainView?.backgroundColor = mainViewBgColor
        mainView?.layer.cornerRadius = cornerRadius
        if let hudImage = hudImage {
            imageView?.image = hudImage
        } else {
            imageView?.image = UIImage(systemName: "slowmo")?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        }
        if imageView != nil {
            mainView?.addSubview(imageView!)
            NSLayoutConstraint.activate([
                imageView!.centerYAnchor.constraint(equalTo: mainView!.centerYAnchor),
                imageView!.centerXAnchor.constraint(equalTo: mainView!.centerXAnchor),
                imageView!.widthAnchor.constraint(equalToConstant: 36),
                imageView!.heightAnchor.constraint(equalToConstant: 36),
            ])
        }
        if spinnerView != nil {
            mainView?.addSubview(spinnerView!)
            NSLayoutConstraint.activate([
                spinnerView!.centerYAnchor.constraint(equalTo: mainView!.centerYAnchor),
                spinnerView!.centerXAnchor.constraint(equalTo: mainView!.centerXAnchor),
                spinnerView!.widthAnchor.constraint(equalToConstant: 36),
                spinnerView!.heightAnchor.constraint(equalToConstant: 36),
            ])
        }
        background?.addSubview(mainView!)
        window?.addSubview(background!)
        window?.windowLevel = .alert
        window?.makeKeyAndVisible()
    }
    
    private func destoryHUD() {
        background?.removeFromSuperview(); background = nil
        mainView?.removeFromSuperview(); mainView = nil
        imageView?.removeFromSuperview(); imageView = nil
        spinnerView?.removeFromSuperview(); spinnerView = nil
    }
}

enum ProgressHudType {
    case spinner
    case image
}
