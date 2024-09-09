//
//  EditorViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/11.
//

import PDFKit
import PhotosUI
import QuickLook
import UIKit
import Vision
import VisionKit

class EditorViewController: EvaluateBaseController {
    // document 的当前页
    var currentIndex = 0
    // 记录上一次page页
    var preIndex = 0
    // 显示PDF
    var pdfView: PDFView!
    // FILE
    var pdfFile: File? {
        didSet {
//            loadPDFDocument()
        }
    }

    // PDFDocument
    var pdfDocument: PDFDocument!
    // PDF缩略图
    var pdfThumbailView: PDFThumbnailView!
    // const
    let bottomActionHeight = 170.0
    let pdfThumbailViewH = 50.0
    var quickLookVC = QLPreviewController()
    lazy var pdfContainer = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .link
        return view
    }()

    lazy var actionView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "folderCellBgViewColor")
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    let actions: [ActionItem] = [
        ActionItem(image: "list.bullet", title: String.localize("EditorVC.action.contents"), tag: 0),
        ActionItem(image: "wand.and.stars", title: String.localize("EditorVC.action.edit"), tag: 1),
//        ActionItem(image: "crop", title: "裁剪", tag: 2),
        ActionItem(image: "square.and.arrow.up", title: String.localize("EditorVC.action.share"), tag: 3),
        ActionItem(image: "ellipsis", title: String.localize("EditorVC.action.more"), tag: 4)
    ]

    lazy var actionsStack = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.spacing = 0
        stack.distribution = .equalCentering
        stack.axis = .horizontal
        return stack
    }()

    lazy var btnsStack = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.axis = .horizontal
        return stack
    }()

    lazy var addbtn: UIButton = {
        let actionMenus = UIMenu(title: String.localize("EditorVC.action.adddoc"), children: [
            UIAction(title: String.localize("EditorVC.action.from.album"), image: UIImage(systemName: "rectangle.stack.badge.plus"), handler: { [weak self] _ in
                self?.fromPhotos()
            }),
            UIAction(title: String.localize("EditorVC.action.doc.scan"), image: UIImage(systemName: "doc.viewfinder"), handler: { [weak self] _ in
                self?.fromCamera()
            })
        ])
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(hex: "#2C3863")
        config.baseForegroundColor = UIColor(hex: "#F8F8F8")
        config.image = UIImage(systemName: "plus")
        config.title = String.localize("EditorVC.action.add")
        config.imagePlacement = .trailing
        config.cornerStyle = .medium
        btn.menu = actionMenus
//        btn.showsMenuAsPrimaryAction = true
        btn.addTarget(self, action: #selector(fromCamera), for: .touchUpInside)
        btn.configuration = config
        return btn
    }()

    lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(hex: "#0483FF")
        config.baseForegroundColor = .white
        config.title = String.localize("EditorVC.action.save")
        config.imagePlacement = .trailing
        config.cornerStyle = .medium
        btn.configuration = config
        btn.addTarget(self, action: #selector(saveButtonHandle), for: .touchUpInside)
        return btn
    }()

    var displaySwitch: UIBarButtonItem!
    var ishorizontal: Bool = true {
        didSet {
            displaySwitch.image = ishorizontal ? (UIImage(systemName: "arrow.down.and.line.horizontal.and.arrow.up") ?? UIImage(systemName: "arrow.up.arrow.down")) : (UIImage(systemName: "arrow.right.and.line.vertical.and.arrow.left") ?? UIImage(systemName: "arrow.left.arrow.right"))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initNavgationItem()
        loadPDFDocument()
        initObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    // 初始化观察监听器
    private func initObserver() {
        quickLookVC.setEditing(true, animated: true)
        quickLookVC.dataSource = self
        quickLookVC.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(pdfPageChange), name: NSNotification.Name.PDFViewPageChanged, object: nil)
        // 监听删除PDF page
        NotificationCenter.default.addObserver(self, selector: #selector(pdfPageDelete), name: documentsDeletePageNot, object: nil)
        // 保存文件并跟新
        NotificationCenter.default.addObserver(self, selector: #selector(documentsSaveUpdate), name: documentsSaveUpdateNot, object: nil)
    }

    @objc func pdfPageChange() {
        guard let page = pdfView.currentPage else {
            return
        }
        let index = pdfDocument.index(for: page)
        currentIndex = index
        print("PDF page change：\(index)")
    }

    // 保存documents
    private func saveDoc() {
        let data = pdfDocument?.dataRepresentation()
        let docURL = pdfFile?.url
        do {
            try data?.write(to: docURL!)
        } catch {
            print("error is \(error.localizedDescription)")
        }
    }

    @objc private func saveButtonHandle() {
        ProgressHud.show()
        DispatchQueue.global().async {
            self.saveDoc()
            ProgressHud.hide()
        }
    }
    // 删除文件并且返回
    private func removeFileBack() {
        MyFileManager.shared.removeFile(with: (pdfFile?.url)!)
        postDocumentsUpdate(object: nil)
        navigationController?.popViewController(animated: true)
    }

    @objc func pdfPageDelete() {
        dismiss(animated: true)
        // 移除当前页
        let cIndex = currentIndex
        let totalPage = pdfDocument.pageCount
        if totalPage <= 1 {
            // 就直接删除文件
            removeFileBack()
            return
        }
        ProgressHud.show()
        if cIndex + 1 >= totalPage {
            pdfView.goToPreviousPage(nil)
        } else {
            pdfView.goToNextPage(nil)
        }
        pdfDocument.removePage(at: cIndex)
        DispatchQueue.global().async {
            self.saveDoc()
            ProgressHud.hide()
            postDocumentsUpdate(object: nil)
        }
    }

    @objc func documentsSaveUpdate() {
        saveDoc()
        loadPDFDocument()
        ProgressHud.hide()
        postDocumentsUpdate(object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EditorViewController {
    private func initUI() {
        view.backgroundColor = .systemBackground
        title = pdfFile?.name
        view.addSubview(actionView)
        NSLayoutConstraint.activate([
            actionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            actionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            actionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            actionView.heightAnchor.constraint(equalToConstant: bottomActionHeight)
        ])
        // actions stack
        actionView.addSubview(actionsStack)
        NSLayoutConstraint.activate([
            actionsStack.topAnchor.constraint(equalTo: actionView.topAnchor, constant: 12),
            actionsStack.leftAnchor.constraint(equalTo: actionView.leftAnchor, constant: 24),
            actionsStack.rightAnchor.constraint(equalTo: actionView.rightAnchor, constant: -24)
        ])
        initActionsUI()
        // btns stack
        actionView.addSubview(btnsStack)
        NSLayoutConstraint.activate([
            btnsStack.leftAnchor.constraint(equalTo: actionView.leftAnchor, constant: 16),
            btnsStack.rightAnchor.constraint(equalTo: actionView.rightAnchor, constant: -16),
            btnsStack.topAnchor.constraint(equalTo: actionsStack.bottomAnchor, constant: 10),
            btnsStack.heightAnchor.constraint(equalToConstant: 54)
        ])
        btnsStack.addArrangedSubview(addbtn)
        btnsStack.addArrangedSubview(saveBtn)
        // pdfContainer
        view.addSubview(pdfContainer)
        NSLayoutConstraint.activate([
            pdfContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            pdfContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            pdfContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfContainer.bottomAnchor.constraint(equalTo: actionView.topAnchor)
        ])
        // pdfView config
        let bugH = is14Pro ? 5.0 : 0.0
        let safeH = windowH - (Windows.getWindow()?.safeAreaInsets.top ?? 0) - (navigationController?.navigationBar.frame.height ?? 0) - pdfThumbailViewH - bottomActionHeight - 4 + bugH
        pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: windowW, height: safeH))
        pdfView.translatesAutoresizingMaskIntoConstraints = false
//        pdfView.backgroundColor = .red
        pdfView.usePageViewController(true)
        // 展示方向
        pdfView.displayDirection = .horizontal
        // 是否自动缩放
        pdfView.autoScales = true
        // 是否用户交互
        pdfView.isUserInteractionEnabled = true
        // 如何显示
        pdfView.displayMode = .singlePage
        pdfContainer.addSubview(pdfView)
//        NSLayoutConstraint.activate([
//            pdfView.leftAnchor.constraint(equalTo: pdfContainer.leftAnchor),
//            pdfView.rightAnchor.constraint(equalTo: pdfContainer.rightAnchor),
//            pdfView.topAnchor.constraint(equalTo: pdfContainer.topAnchor),
//            pdfView.bottomAnchor.constraint(equalTo: pdfContainer.bottomAnchor, constant: -pdfThumbailViewH)
//        ])
        // 缩略图
        pdfThumbailView = PDFThumbnailView()
        pdfThumbailView.translatesAutoresizingMaskIntoConstraints = false
        pdfThumbailView.thumbnailSize = CGSize(width: 38, height: 38)
        pdfThumbailView.backgroundColor = .systemBackground
        pdfThumbailView.pdfView = pdfView
        pdfThumbailView.layoutMode = .horizontal
        pdfContainer.addSubview(pdfThumbailView)
        NSLayoutConstraint.activate([
            pdfThumbailView.leftAnchor.constraint(equalTo: pdfContainer.leftAnchor),
            pdfThumbailView.rightAnchor.constraint(equalTo: pdfContainer.rightAnchor),
            pdfThumbailView.heightAnchor.constraint(equalToConstant: pdfThumbailViewH),
            pdfThumbailView.bottomAnchor.constraint(equalTo: pdfContainer.bottomAnchor, constant: -2)
        ])
    }

    // 初始化actions
    private func initActionsUI() {
        actions.forEach { item in
            let button = UIButton()
            var config = UIButton.Configuration.plain()
            config.title = item.title
            config.imagePlacement = .top
            config.imagePadding = 6
            config.image = UIImage(systemName: item.image)
            config.baseForegroundColor = .label
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = MyFont.font(with: .light, size: 12)
                return outgoing
            }
            button.tag = item.tag
            button.addTarget(self, action: #selector(actionHandler), for: .touchUpInside)
            button.configuration = config

            actionsStack.addArrangedSubview(button)
        }
    }

    // init navigationItem
    func initNavgationItem() {
        displaySwitch = UIBarButtonItem(image: UIImage(systemName: "arrow.down.and.line.horizontal.and.arrow.up") ?? UIImage(systemName: "arrow.up.arrow.down"), style: .done, target: self, action: #selector(switchDispaly))
        navigationItem.rightBarButtonItem = displaySwitch
        self.navigationController?.navigationBar.tintColor = .label
    }

    @objc func switchDispaly() {
        ishorizontal = !ishorizontal
        pdfView.displayDirection = ishorizontal ? .horizontal : .vertical
    }

    func loadPDFDocument() {
        guard let url = pdfFile?.url else { return }
        pdfDocument = MyFileManager.shared.loadPDF(for: url)
        pdfDocument.delegate = self
        DispatchQueue.main.async {
            self.pdfView.document = self.pdfDocument!
            let count = self.pdfDocument.pageCount
            if self.preIndex < count {
                self.pdfView.go(to: (self.pdfView.document?.page(at: self.preIndex))!)
            } else { // 到最后一页
                self.pdfView.go(to: (self.pdfView.document?.page(at: count - 1))!)
            }
        }
    }

    @objc func actionHandler(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            showCatalog()
        case 1:
            edit()
        case 2:
            crop()
        case 3:
            share()
        case 4:
            more()
        default:
            assert(true)
        }
    }

    // actions
    func showCatalog() {
        // 判断当前PDF是否有目录
//        guard let outlineRoot = pdfDocument.outlineRoot else {
//            let alert = UIAlertController(title: "提示", message: "当前文稿没有目录", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "确定", style: .cancel))
//            present(alert, animated: true)
//            return
//        }
        let catalog = PDFCatalogController()
        catalog.pdfDocument = pdfDocument
        catalog.closure = { [weak self] page in
            if let page = page {
                self?.pdfView.go(to: page)
            }
        }
        let navCatalog = UINavigationController(rootViewController: catalog)
//        if let sheetController = catalog.sheetPresentationController {
//            sheetController.detents = [.large()]
//        }
        navCatalog.modalPresentationStyle = .fullScreen
        present(navCatalog, animated: true)
    }

    // 编辑
    func edit() {
        // 需要先保存当前page页
        preIndex = currentIndex
        present(quickLookVC, animated: true)
    }

    // 裁剪
    func crop() {}

    // 分享
    func share() {
        let shareVC = UIActivityViewController(activityItems: [(pdfFile?.url)!], applicationActivities: nil)
        if(shareVC.popoverPresentationController != nil){
            shareVC.popoverPresentationController?.sourceView = self.actionView;
        }
        present(shareVC, animated: true)
    }

    // 更多
    func more() {
        let moreVC = EditMoreViewController()
        preIndex = currentIndex
        moreVC.pageIndex = currentIndex
        moreVC.file = pdfFile
        moreVC.pdfDocument = pdfDocument
        moreVC.delegate = self
        moreVC.reNameDelegate = self
        moreVC.isModalInPresentation = true
        if let sheetVC = moreVC.sheetPresentationController {
            sheetVC.detents = [.medium()]
            sheetVC.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(moreVC, animated: true)
    }
}

// MARK: 操作文档和代理

extension EditorViewController: PHPickerViewControllerDelegate, VNDocumentCameraViewControllerDelegate {
    // 添加-从相册选择
    func fromPhotos() {
        var pConfig = PHPickerConfiguration(photoLibrary: .shared())
        pConfig.selectionLimit = 0
        pConfig.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: pConfig)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    // 照片选择代理
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var images: [UIImage] = []
        var index = 0
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                index += 1
                guard let image = reading as? UIImage, error == nil else { return }
                // DO something
                images.append(image)
               if (index == results.count) {
                   self?.pic2Document(images: images)
               }
            }
        }
        picker.dismiss(animated: true)
    }

    // 处理从相册和相机来的文稿
    // 需要一个配置来确定在页面的前置还是后置插入文稿
    // TODO: 只有在第一页的时候需要提示前插还是后插
    // 需要一个配置来配置图片压缩率减小文件大小
    // compressionQuality `default`: 0.8
    func pic2Document(images: [UIImage]) {
        ProgressHud.show()
        let compressionQuality = 0.8
        images.forEach { image in
            if let data = image.jpegData(compressionQuality: compressionQuality), let compressImage = UIImage(data: data), let page = PDFPage(image: compressImage) {
                let indexPath = currentIndex + 1
                DispatchQueue.main.async { [self] in
                    pdfDocument.insert(page, at: indexPath)
                    pdfView.go(to: page)
                }
            }
        }
        preIndex = currentIndex
        saveDoc()
        loadPDFDocument()
        postDocumentsUpdate(object: nil)
        ProgressHud.hide()
    }

    // 从相机扫描文档
    @objc func fromCamera() {
        let docVC = VNDocumentCameraViewController()
        docVC.delegate = self
        present(docVC, animated: true)
    }

    // pdf version 代理
    // 扫描成功
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var images: [UIImage] = []
        for index in 0 ..< scan.pageCount {
            let image = scan.imageOfPage(at: index)
            images.append(image)
        }
        pic2Document(images: images)
    }

    // 扫描发生错误
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
        // toast
        SPIndicatorView(title: "error", preset: .custom((UIImage(systemName: "doc.viewfinder.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.systemRed))!)).present(duration: 3, haptic: .error)
    }

    // 用户取消扫描
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}

// pdf 具有哪些操作

// MARK: Quicklook的代理和回调

extension EditorViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return pdfFile!.url as QLPreviewItem
    }

    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .updateContents
    }

    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        print("currentIndex--：", currentIndex)
        // 刷新文件 跳转到上次的page
        // 通知首页刷新
        postDocumentsUpdate(object: nil)
        DispatchQueue.main.async {
            self.loadPDFDocument()
        }
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
    }
}

extension EditorViewController: pdfviewNeedGoPageDelegate, documentDidChangeDelegate {
    func fileNameDidChange(_ newName: String, _ newUrl: URL) {
        pdfFile = File(with: newUrl)
        title = pdfFile?.name
    }

    func pdfviewNeedGoPage(page: PDFPage) {
        pdfView.go(to: page)
    }
}

// PDF水印
extension EditorViewController: PDFDocumentDelegate {
    func classForPage() -> AnyClass {
        return WatermarkPDFPage.self
    }
}
