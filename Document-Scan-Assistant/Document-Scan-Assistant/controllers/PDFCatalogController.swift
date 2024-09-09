//
//  PDFCatalogController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/24.
//

import UIKit
import PDFKit

typealias DFCatalogCallback = (_ page: PDFPage?) -> Void

class PDFCatalogController: UIViewController {
    var pdfDocument: PDFDocument?
    var segment: UISegmentedControl!
    var index = 0
    // 回调闭包
    var closure: DFCatalogCallback?
    
    let pdfGridVC = PDFCatalogGridController()
    let pdfTableVC = PDFCatalogTableController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    private func initUI() {
        view.backgroundColor = .white
        segment = UISegmentedControl(items: [String.localize("PDFCatalogVC.segment.first"), String.localize("PDFCatalogVC.segment.second")])
        navigationController?.navigationBar.tintColor = .label
//        let bgImage: UIImage = UIColor.white.imageWithColor(width: segment.bounds.width, height: segment.bounds.height)
//        segment.setBackgroundImage(bgImage, for: .normal, barMetrics: .default)
        segment.selectedSegmentTintColor = .systemBackground
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChange), for: .valueChanged)
        navigationItem.titleView = segment
        let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .medium, scale: .medium)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark", withConfiguration: config), style: .plain, target: self, action: #selector(coloseVC))
        pdfGridVC.delegate = self
        pdfGridVC.pdfDocument = pdfDocument
        pdfTableVC.delegate = self
        pdfTableVC.pdfDocument = pdfDocument
        setViewController(pdfGridVC, using: .none)
    }
    
    @objc private func coloseVC() {
        dismiss(animated: true)
    }
    
    @objc private func segmentChange(_ sender: UISegmentedControl) {
        index = sender.selectedSegmentIndex
        if (index == 0) {
            setViewController(pdfGridVC, using: .animate)
        } else {
            setViewController(pdfTableVC, using: .animate)
        }
    }
}

extension PDFCatalogController {
    func setViewController(_ viewController: UIViewController, using transition: Transition) {
        switch transition {
        case .none:
            setChildViewController(viewController)
        case .animate:
            addChildViewControllerWithAnimation(viewController)
        }
    }
    
    // 设置子控制器
    func setChildViewController(_ viewController: UIViewController) {
        removeChildViewController()
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        viewController.didMove(toParent: self)
    }
    
    // 移除子控制器
    func removeChildViewController() {
        children.forEach { controller in
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
    }
    
    // 动画切换子控制器
    func addChildViewControllerWithAnimation(_ viewController: UIViewController) {
        // 此处必须使用setChildViewController，来保证数组最大的size为1
        guard let previousViewController = children.first else {
            setChildViewController(viewController)
            return
        }
        addChild(viewController)
        previousViewController.willMove(toParent: nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        view.layoutIfNeeded()
        UIView.transition(from: previousViewController.view, to: viewController.view, duration: 1, options: [.curveLinear]) { finish in
            previousViewController.view.removeFromSuperview()
            previousViewController.removeFromParent()
            viewController.didMove(toParent: self)
        }
    }
}

extension PDFCatalogController: PDFCatalogThumbDelegate, PDFCatalogOutlineDelegate {
    func didOutlineSelect(page: PDFPage) {
        closure?(page)
        dismiss(animated: true)
    }
    
    func didThumbItemSelect(page: PDFPage) {
        closure?(page)
        dismiss(animated: true)
        print("page:", page)
    }
}



enum Transition {
    case none
    case animate
}
