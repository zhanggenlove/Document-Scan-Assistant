//
//  index.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/10.
//

import Foundation
import UIKit
import Spring

protocol ActionSheetDelegate: NSObjectProtocol {
    func didItemSelect(tagIndex: Int)
}
class ActionSheet {
    public static let instance = ActionSheet()
    
    var window: UIWindow?
    var bgView: SpringView
    var mainContainer: MainContainer
    var isShow = false
    let viewHeight: CGFloat = 160
//    var delegate: ActionSheetDelegate?
    init() {
        window = Windows.getWindow()
        bgView = SpringView()
        bgView.isUserInteractionEnabled = true
        bgView.backgroundColor = .clear
        bgView.translatesAutoresizingMaskIntoConstraints = false
        mainContainer = MainContainer(list: [
            SheetItem(icon: "doc_scan", title: String.localize("ActionSheet.scan"), tag: 1),
            SheetItem(icon: "add_folder", title: String.localize("ActionSheet.new.folder"), tag: 2),
            SheetItem(icon: "from_photo", title: String.localize("ActionSheet.from.album"), tag: 3),
            SheetItem(icon: "file_upload", title: String.localize("ActionSheet.sys.file"), tag: 4)
        ])
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        // 初始化bgView的子view
        bgView.addSubview(mainContainer)
        NSLayoutConstraint.activate([
            mainContainer.bottomAnchor.constraint(equalTo: bgView.bottomAnchor),
            mainContainer.leftAnchor.constraint(equalTo: bgView.leftAnchor),
            mainContainer.rightAnchor.constraint(equalTo: bgView.rightAnchor),
            mainContainer.heightAnchor.constraint(equalToConstant: viewHeight)
        ])
        // 添加手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeSheet))
        bgView.addGestureRecognizer(tapGesture)
    }
    
    func show(delegate: ActionSheetDelegate? = nil) {
        if (!isShow) {
            mainContainer.delegate = delegate
            window?.insertSubview(bgView, at: 999)
            NSLayoutConstraint.activate([
                bgView.bottomAnchor.constraint(equalTo: window!.bottomAnchor),
                bgView.leftAnchor.constraint(equalTo: window!.leftAnchor),
                bgView.rightAnchor.constraint(equalTo: window!.rightAnchor),
                bgView.heightAnchor.constraint(equalToConstant: windowH)
            ])
            // 动画
            animateMainContainer {
                self.isShow = true
            }
            UIView.animate(withDuration: 0.5) {
                self.bgView.backgroundColor = UIColor(hexStr: "#000000", alpha: 0.2)
            }
            // mainContainer的子view的动画
            subViewsAnimate()
        } else {
            bgView.removeFromSuperview()
            isShow = false
        }
    }
    
    @objc func closeSheet(sender: UITapGestureRecognizer?) {
        guard let point = sender?.location(in: sender?.view) else {
            animateMainContainer(isIn: false) { [weak self] in
                self?.bgView.removeFromSuperview()
                self?.isShow = false
            }
            animateBgview()
            return
        }
        // 限制点击区域在蒙版
        let isInBgView = point.y < windowH - viewHeight
        if (isShow && isInBgView) {
            animateMainContainer(isIn: false) { [weak self] in
                self?.bgView.removeFromSuperview()
                self?.isShow = false
            }
            animateBgview()
        }
    }
    
    // bgview动画
    func animateBgview() {
        UIView.animate(withDuration: 0.5) {
            self.bgView.backgroundColor = .clear
        }
    }
    // container动画
    func animateMainContainer(isIn: Bool = true, complete: @escaping() -> Void) {
        mainContainer.duration = 0.5
        mainContainer.animation = (isIn ? Spring.AnimationPreset.SlideUp : Spring.AnimationPreset.FadeOut).rawValue
        mainContainer.damping = 1.0
        mainContainer.animateNext {
            complete()
        }
    }
    
    //mainContainer的子view的动画
    func subViewsAnimate() {
        var delay = 0.3
        mainContainer.subviews.forEach { view in
            if (view is UIStackView) {
                view.subviews.forEach { sView in
                    if (sView is UIStackView) {
                        sView.subviews.forEach { ssView in
                            if (ssView is SpringImageView) {
                                guard let springView  = ssView as? SpringImageView else {
                                    return
                                }
                                springView.animation = (Spring.AnimationPreset.SlideDown).rawValue
                                springView.duration = 0.6
                                delay += 0.05
                                springView.delay = delay
                                springView.force = 0.2
                                springView.animate()
                            }
                        }
                    }
                }
            }
        }
    }
}


