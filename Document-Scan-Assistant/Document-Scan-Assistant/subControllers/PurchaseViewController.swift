//
//  PurchaseViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/7/10.
//

import StoreKit
import UIKit

class PurchaseViewController: UIViewController {
    var scrollView: UIScrollView!
    let features = [ String.localize("PurchaseVC.features.1"), String.localize("PurchaseVC.features.2"), String.localize("PurchaseVC.features.3")]
    var buyButton: UIButton!
    // 商品
    private var products = [SKProduct]()
    private let productId = "com.zhanggen.io.docscanhelper.Premium"
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initConfig()
        loadInAppProduct()
    }
    
    private func loadInAppProduct() {
        let request = SKProductsRequest(productIdentifiers: Set([productId]))
        request.delegate = self
        request.start()
    }
    
    private func initConfig() {
        SKPaymentQueue.default().add(self)
    }

    private func initUI() {
        title = "Premium❥(^_-)"
        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        // top bg image
        let topImageBgView = UIImageView(image: UIImage(named: "sketch"))
        topImageBgView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(topImageBgView)
        NSLayoutConstraint.activate([
            topImageBgView.widthAnchor.constraint(equalToConstant: 80),
            topImageBgView.heightAnchor.constraint(equalToConstant: 80),
            topImageBgView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 42),
            topImageBgView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        // title
        let titleLabel = UILabel()
        titleLabel.text = String.localize("PurchaseVC.titleLabel.text")
        titleLabel.textAlignment = .center
        titleLabel.font = MyFont.font(with: .bold, size: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topImageBgView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        // sub-title
        let subtitleLabel = UILabel()
        subtitleLabel.text = String.localize("PurchaseVC.subtitleLabel.text")
        subtitleLabel.tintColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = MyFont.font(with: .defalut, size: 14)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            subtitleLabel.widthAnchor.constraint(equalToConstant: view.bounds.width - 16 * 2),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        // features wrap
        let arrangeSubviews = features.map { text in
            let icon = UIImageView(frame: .zero)
            icon.image = UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            icon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                icon.widthAnchor.constraint(equalToConstant: 24),
                icon.heightAnchor.constraint(equalToConstant: 24)
            ])
            let label = UILabel()
            label.text = text
            label.font = MyFont.font(with: .bold, size: 14)
            let hStack = UIStackView(arrangedSubviews: [icon, label])
            hStack.translatesAutoresizingMaskIntoConstraints = false
            hStack.axis = .horizontal
            hStack.alignment = .center
            hStack.spacing = 6
            hStack.distribution = .equalCentering
            return hStack
        }
        let featuresWrap = UIStackView(arrangedSubviews: arrangeSubviews)
        featuresWrap.translatesAutoresizingMaskIntoConstraints = false
        arrangeSubviews.forEach { v in
            NSLayoutConstraint.activate([
                //                v.leftAnchor.constraint(equalTo: featuresWrap.leftAnchor, constant: 32),
//                v.rightAnchor.constraint(equalTo: featuresWrap.rightAnchor, constant: -32),
                v.heightAnchor.constraint(equalToConstant: 36)
            ])
        }
        featuresWrap.layer.cornerRadius = 8
        featuresWrap.layer.masksToBounds = true
        featuresWrap.layer.borderWidth = 1
        featuresWrap.layer.borderColor = UIColor.secondaryLabel.cgColor
        featuresWrap.axis = .vertical
        featuresWrap.spacing = 8
        featuresWrap.alignment = .center
        featuresWrap.distribution = .fillEqually
        scrollView.addSubview(featuresWrap)
        NSLayoutConstraint.activate([
            featuresWrap.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            featuresWrap.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            featuresWrap.widthAnchor.constraint(equalToConstant: view.bounds.width - 16 * 2)
//            featuresWrap.heightAnchor.constraint(equalToConstant: 200)
        ])
        // 购买按钮
        buyButton = UIButton(type: .custom)
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        setBuyButtonTitle()
        scrollView.addSubview(buyButton)
        NSLayoutConstraint.activate([
            buyButton.heightAnchor.constraint(equalToConstant: 54),
            buyButton.widthAnchor.constraint(equalToConstant: view.bounds.width - 16 * 2),
            buyButton.topAnchor.constraint(equalTo: featuresWrap.bottomAnchor, constant: 40),
            buyButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        buyButton.layer.cornerRadius = 27
        buyButton.layer.masksToBounds = true
        buyButton.backgroundColor = .systemBlue
        // 恢复购买按钮
        let restoreBtn = UIButton(type: .custom)
//        restoreBtn.setTitle("恢复购买", for: .normal)
        restoreBtn.setAttributedTitle(NSAttributedString(string: String.localize("Setting.restore"), attributes: [.font : MyFont.font(with: .defalut, size: 14)]), for: .normal)
        restoreBtn.setTitleColor(.label, for: .normal)
        restoreBtn.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(restoreBtn)
        NSLayoutConstraint.activate([
            restoreBtn.heightAnchor.constraint(equalToConstant: 34),
            restoreBtn.widthAnchor.constraint(equalToConstant: view.bounds.width - 16 * 2),
            restoreBtn.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 10),
            restoreBtn.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        // tips
        let tipsText = UILabel()
        tipsText.text = String.localize("PurchaseVC.tipsText.text")
        tipsText.font = MyFont.font(with: .defalut, size: 13)
        tipsText.numberOfLines = 3
        tipsText.textAlignment = .center
        tipsText.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tipsText)
        NSLayoutConstraint.activate([
            tipsText.widthAnchor.constraint(equalToConstant: view.bounds.width - 16 * 2),
            tipsText.topAnchor.constraint(equalTo: restoreBtn.bottomAnchor, constant: 40),
            tipsText.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        // 关闭按钮
        let closeBtn = UIButton(type: .close)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        view.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.widthAnchor.constraint(equalToConstant: 34),
            closeBtn.heightAnchor.constraint(equalToConstant: 34),
            closeBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            closeBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12)
        ])
    }
    
    @objc private func closeVC() {
        dismiss(animated: true)
    }
    
    private func setBuyButtonTitle() {
        let isPremium = UserDefaults.standard.bool(forKey: IS_PREMIUM)
        let btnTitle = isPremium ? "\(String.localize("PurchaseVC.btnTitle"))❤️" : "\(String.localize("PurchaseVC.loading"))..."
        if (!isPremium) {
            buyButton.isUserInteractionEnabled = false
        }
        buyButton.setTitle(btnTitle, for: .normal)
    }
    
    private func updateBuyButtonUI() {
        let isPremium = UserDefaults.standard.bool(forKey: IS_PREMIUM)
        if (isPremium) { return }
        guard let product = products.first else {
            buyButton.setTitle("unknow error", for: .normal)
            buyButton.isUserInteractionEnabled = false
            return
        }
        buyButton.setTitle("\(String.localize("PurchaseVC.get.all.feature"))- \(product.priceLocale.currencySymbol ?? "￥")\(product.price)", for: .normal)
        buyButton.isUserInteractionEnabled = true
        buyButton.addTarget(self, action: #selector(payment), for: .touchUpInside)
    }

    @objc private func payment() {
        let payment = SKPayment(product: products.first!)
        SKPaymentQueue.default().add(payment)
    }
    // deinit
    deinit {
        SKPaymentQueue.default().remove(self)
    }
}

extension PurchaseViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            self.updateBuyButtonUI()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            switch $0.transactionState {
            case .purchasing:
                break
            case .purchased:
                SKPaymentQueue.default().finishTransaction($0)
                UserDefaults.standard.set(true, forKey: IS_PREMIUM)
                setBuyButtonTitle()
                print("purchased")
            case .failed:
                SKPaymentQueue.default().finishTransaction($0)
                let indicatorView = SPIndicatorView(title: String.localize("PurchaseVC.purchase.fail"), preset: .error)
                indicatorView.present(duration: 2, haptic: .success)
            case .restored:
                UserDefaults.standard.set(true, forKey: IS_PREMIUM)
                let indicatorView = SPIndicatorView(title: String.localize("Setting.restore.succ"), preset: .done)
                indicatorView.present(duration: 2, haptic: .success)
                print("restored")
            case .deferred:
                print("deferred")
                break
            @unknown default:
                print("@unknown")
            }
        }
    }
}
