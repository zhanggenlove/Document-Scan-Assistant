//
//  TableHeaderView.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/6.
//

import UIKit

protocol FolderCellDelegate: NSObjectProtocol {
    func didAddFolder()
    func didFolderCellClick(file: File)
    func didFolderRename(index: Int)
    func didFolderDelete(index: Int)
}

class TableHeaderView: UIView {
    weak var delegate: FolderCellDelegate?
    // 文件夹
    var folders: [File] = [] {
        didSet {
            countLabel.text = "「\(folders.count)」"
            DispatchQueue.main.async {
                self.collectView.reloadData()
                if (self.folders.isEmpty) {
                    self.collectView.showEmpty(message: String.localize("TableHeaderView.long.press"))
                } else {
                    self.collectView.removeEmpty()
                }
            }
        }
    }

    lazy var titleLabel = {
        let label = UILabel()
        label.text = String.localize("TableHeaderView.label.all.folder")
        label.font = MyFont.font(with: .bold, size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var countLabel = {
        let label = UILabel()
        label.text = ""
        label.font = MyFont.font(with: .bold, size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var folderButton = {
        let button = UIImageView()
        button.isUserInteractionEnabled = true
        let gesTap = UITapGestureRecognizer(target: self, action: #selector(addBtnTap))
        button.addGestureRecognizer(gesTap)
        var image = UIImage(named: "folder-plus")?.withTintColor(.label)
        button.image = image
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var filterButton = {
        let button = UIImageView()
        var image = UIImage(named: "arrows-up-down")
        button.image = image
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // collectview
    lazy var collectView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect(x: 10, y: 36, width: windowW - 10, height: 116), collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cv.showsHorizontalScrollIndicator = false
        cv.register(FolderCollectCell.loadNib(), forCellWithReuseIdentifier: "FolderCell")
//        cv.backgroundColor = .green
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initCollectViewConfig()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: privite function

extension TableHeaderView {
    private func initUI() {
        backgroundColor = .systemBackground
        addSubview(titleLabel)
        addSubview(countLabel)
        // titleLabel约束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20.0)
        ])
        // countLabel约束
        NSLayoutConstraint.activate([
            countLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            countLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 0.0)
        ])
        addSubview(folderButton)
//        addSubview(filterButton)
        // folderButton约束
        NSLayoutConstraint.activate([
            folderButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20.0),
            folderButton.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            folderButton.widthAnchor.constraint(equalToConstant: 22.0),
            folderButton.heightAnchor.constraint(equalToConstant: 22.0)
        ])
        // filterButton约束
//        NSLayoutConstraint.activate([
//            filterButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
//            filterButton.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
//            filterButton.widthAnchor.constraint(equalToConstant: 22.0),
//            filterButton.heightAnchor.constraint(equalToConstant: 22.0)
//        ])
        // collectView 约束
        addSubview(collectView)
    }

    private func initCollectViewConfig() {
        collectView.delegate = self
        collectView.dataSource = self
    }

    @objc private func addBtnTap() {
        delegate?.didAddFolder()
    }
}

// MARK: collectView 相关代理

extension TableHeaderView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath) as! FolderCollectCell
        let file = folders[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd"
        cell.titleLabel.text = file.name
        cell.timeLabel.text = formatter.string(from: file.updateDate)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let file = folders[indexPath.row]
        delegate?.didFolderCellClick(file: file)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 146, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { suggestedActions in
            print("indexPaths", indexPaths)
            if indexPaths.count == 0 && self.folders.count == 0 {
                // Construct an empty-space menu.
                return UIMenu(children: [
                    UIAction(title: String.localize("TableHeaderView.add.folder")) { [weak self] _ in
                        self?.addBtnTap()
                    }
                ])
            }
            else if indexPaths.count == 1 {
                // Construct a single-item menu.
                return UIMenu(children: [
                    UIAction(title: String.localize("EditMoreVC.rename")) { [weak self] _ in
                        guard let row = indexPaths.first?.row else {
                            return
                        }
                        self?.delegate?.didFolderRename(index: row)
                    },
                    UIAction(title: String.localize("EditMoreVC.transh"), attributes: .destructive) { [weak self] _ in
                        guard let row = indexPaths.first?.row else {
                            return
                        }
                        self?.delegate?.didFolderDelete(index: row)
                    }
                ])
            }
            return nil
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return UIMenu(children: [
                UIAction(title: String.localize("EditMoreVC.rename")) { [weak self] _ in
                    self?.delegate?.didFolderRename(index: indexPath.row)
                },
                UIAction(title: String.localize("EditMoreVC.transh"), attributes: .destructive) { [weak self] _ in
                    self?.delegate?.didFolderDelete(index: indexPath.row)
                }
            ])
           }
    }
}
