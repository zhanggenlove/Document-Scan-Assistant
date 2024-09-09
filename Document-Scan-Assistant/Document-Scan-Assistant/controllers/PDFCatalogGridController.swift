//
//  PDFCatalogGridController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/24.
//

import UIKit
import PDFKit

// 缩略图点击代理
protocol PDFCatalogThumbDelegate: NSObjectProtocol {
    func didThumbItemSelect(page: PDFPage)
}

class PDFCatalogGridController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var pdfDocument: PDFDocument?
    weak var delegate: PDFCatalogThumbDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() {
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView?.register(PDFCatalogCollectCell.loadNib(), forCellWithReuseIdentifier: "PDFCatalogCollectCell")
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .vertical
        let width = (windowW - 10 * 6) / 3
        let height = width * 1.5
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PDFCatalogGridController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdfDocument?.pageCount ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PDFCatalogCollectCell", for: indexPath) as! PDFCatalogCollectCell
        if let page = pdfDocument?.page(at: indexPath.item) {
            let thumbnail = page.thumbnail(of: cell.bounds.size, for: .cropBox)
            cell.thumbImage.image = thumbnail
            cell.pageLabel.text = page.label
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let page = pdfDocument?.page(at: indexPath.item) {
            delegate?.didThumbItemSelect(page: page)
        }
    }
}
