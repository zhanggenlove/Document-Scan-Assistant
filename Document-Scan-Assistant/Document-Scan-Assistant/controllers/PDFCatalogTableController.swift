//
//  PDFCatalogTableController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/4/24.
//

import PDFKit
import UIKit
// outline点击代理
protocol PDFCatalogOutlineDelegate: NSObjectProtocol {
    func didOutlineSelect(page: PDFPage)
}

class PDFCatalogTableController: UITableViewController {
    var pdfDocument: PDFDocument? {
        didSet {
            guard let outlineRoot = pdfDocument?.outlineRoot else {
                DispatchQueue.main.async {
                    self.tableView.showEmpty(message: "\(String.localize("PDFCatalogTableVC.empty.msg") )o(╥﹏╥)o")
                }
                return
            }
            for index in 0 ..< outlineRoot.numberOfChildren {
                let pdfOutline = outlineRoot.child(at: index)
                if let node = outline2TreeNode(outline: pdfOutline) {
                    catalog.append(node)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private var catalog: [TreeNode] = []
    
    weak var delegate: PDFCatalogOutlineDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    private func initUI() {
        tableView.register(PDFCatalogTableCell.loadNib(), forCellReuseIdentifier: "PDFCatalogTableCell")
    }
    
    func insertChildren(node: TreeNode, indexPath: IndexPath) {
        var insertRows: [IndexPath] = []
        let startIndex = indexPath.row + 1
        let end = node.parent.numberOfChildren
        var insertCatalog: [TreeNode] = []
        let currentLevel = catalog[indexPath.row].level
        for index in 0 ..< end {
            let outline = node.parent.child(at: index)
            insertRows.append(IndexPath(row: startIndex + index, section: indexPath.section))
            let item = outline2TreeNode(outline: outline, level: currentLevel)
            if let item = item {
                insertCatalog.append(item)
            }
        }
        // 增加数组里面的数据
        catalog.insert(contentsOf: insertCatalog, at: startIndex)
        self.tableView.reloadData()
//        tableView.performBatchUpdates({
//            tableView.insertRows(at: insertRows, with: .automatic)
//        }) { finish in
//            print(self.catalog)
//            self.tableView.reloadData()
////            self.tableView.reloadRows(at: insertRows, with: .automatic)
//        }
    }

    func removeChildren(node: TreeNode, indexPath: IndexPath) {
        var deleteRows: [IndexPath] = []
        let startIndex = indexPath.row + 1
        let end = node.parent.numberOfChildren
        for index in 0 ..< end {
            deleteRows.append(IndexPath(row: startIndex + index, section: indexPath.section))
        }
        // 移除数组里面的数据
        catalog.removeSubrange(startIndex..<startIndex + end)
        self.tableView.reloadData()
//        tableView.performBatchUpdates({
//            tableView.deleteRows(at: deleteRows, with: .fade)
//        }) { finish in
//            print(self.catalog)
//            self.tableView.reloadData()
//        }
    }
    
    // outline 2 treenode
    func outline2TreeNode(outline: PDFOutline?, level: Int = 0) -> TreeNode? {
        guard let outline = outline else { return nil }
        let node = TreeNode(title: outline.label ?? "", page: outline.destination?.page?.label ?? "", level: level + 1, isleaf: outline.numberOfChildren == 0, isOpen: false, parent: outline)
        return node
    }
}

extension PDFCatalogTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        catalog.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFCatalogTableCell", for: indexPath) as! PDFCatalogTableCell
        let node = catalog[indexPath.row]
        cell.titleLabel.text = node.title
        cell.pageLabel.text = node.page
        
        if !node.isleaf {
            let smallConfiguration = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .medium, scale: .small)
            cell.expandButton.isHidden = false
            cell.expandButton.setImage(UIImage(systemName: node.isOpen ? "chevron.down" : "chevron.forward", withConfiguration: smallConfiguration)?.withRenderingMode(.alwaysOriginal).withTintColor(.label), for: .normal)
        } else {
            cell.expandButton.isHidden = true
        }
        
        cell.expandBtnClickClosure = { [weak self] sender in
            if !node.isleaf {
                // 展开和收起
                // 收起
                // struct 值类型
                self?.catalog[indexPath.row].isOpen = !node.isOpen
//                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                if (node.isOpen) {
                    self?.removeChildren(node: node, indexPath: indexPath)
                } else {
                 // 展开
                    self?.insertChildren(node: node, indexPath: indexPath)
                }
//                tableView.reloadData()
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let level = catalog[indexPath.row].level;
        return level
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let page = catalog[indexPath.row].parent.destination?.page {
            delegate?.didOutlineSelect(page: page)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
