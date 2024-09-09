//
//  mainContainer.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/10.
//

import UIKit
import Spring

class MainContainer: SpringView {
    var items: [SheetItem] = []
    weak var delegate: ActionSheetDelegate?
    lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(list: [SheetItem]) {
        self.init()
        items = list
        initUI()
        layoutSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        backgroundColor = UIColor(named: "folderCellBgViewColor")
        layer.cornerRadius = 12.0
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        addGradient(start_color: UIColor(named: "folderCellBgViewColor")!, end_color: UIColor(named: "folderCellBgViewColorMirror")!, frame: CGRect(x: 0, y: 0, width: windowW, height: 160))
    }
    
    // 布局子控件
    private func layoutSubview() {
        addSubview(mainStackView)
        var delay = 0.3
        items.forEach { item in
            let stackView = UIStackView()
            stackView.tag = item.tag ?? 0
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 2
            // 给添加click事件
            stackView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postMessage))
            stackView.addGestureRecognizer(tapGesture)
            let imageView = SpringImageView()
            imageView.image = UIImage(named: item.icon)
            imageView.contentMode = .scaleAspectFill
            let titlelabel = SpringLabel()
            titlelabel.text = item.title
            titlelabel.font = MyFont.font(with: .light, size: 12)
            // ANIMATE
            imageView.animation = (Spring.AnimationPreset.SlideDown).rawValue
            imageView.duration = 0.6
            delay += 0.05
            imageView.delay = delay
            imageView.force = 0.2
            imageView.animate()
            stackView.addArrangedSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 44),
                imageView.heightAnchor.constraint(equalToConstant: 44)
            ])
            stackView.addArrangedSubview(titlelabel)
            
            mainStackView.addArrangedSubview(stackView)
        }
        // 约束
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 24),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -24)
//            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60)
        ])
    }
    
    @objc func postMessage(sender: UITapGestureRecognizer) {
        guard let viewTag = sender.view?.tag else {
            return
        }
        delegate?.didItemSelect(tagIndex: viewTag)
    }
}
