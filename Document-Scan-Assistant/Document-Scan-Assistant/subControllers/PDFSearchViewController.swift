//
//  PDFSearchViewController.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/5/5.
//

import PDFKit
import UIKit

protocol PDFSearchViewDelegate: AnyObject {
    func didDocumentResultSelect(didSelectSerchResult selection: PDFSelection?)
}

class PDFSearchViewController: UIViewController {
    var pdfDocument: PDFDocument?
    weak var delegate: PDFSearchViewDelegate?
    private var tableView: UITableView!
    private var searchBar = UISearchBar()
    private var searchResults = [[PDFSelection?]]()
    private var originData: [Int: [PDFSelection?]] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PDFSearchTableCell.loadNib(), forCellReuseIdentifier: "PDFSearchTableCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        searchBar.showsCancelButton = true
        searchBar.placeholder = String.localize("PDFSearchVC.searchBar.placeholder")
        searchBar.delegate = self
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        navigationItem.titleView = searchBar
    }
}

extension PDFSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        pdfDocument?.cancelFindString()
        dismiss(animated: false, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count >= 1 else { return }
        originData.removeAll()
        searchResults.removeAll()
        tableView.reloadData()
        pdfDocument?.cancelFindString()
        pdfDocument?.delegate = self
        pdfDocument?.beginFindString(searchText, withOptions: .caseInsensitive)
    }
}

extension PDFSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFSearchTableCell", for: indexPath) as! PDFSearchTableCell
        
        let selection = searchResults[indexPath.row][0]
        let page = selection?.pages[0]
        let pagestr = page?.label ?? ""
        let txt = "\(String.localize("PDFSearchVC.page.label")):  " + pagestr
        cell.pageLabel.text = txt
        cell.regCountLabel.text = "\(searchResults[indexPath.row].count)\(String.localize("PDFSearchVC.regCountLabel.text"))"
        let extendSelection = selection?.copy() as! PDFSelection
        extendSelection.extend(atStart: 10)
        extendSelection.extend(atEnd: 50)
        extendSelection.extendForLineBoundaries()
        
        let range = (extendSelection.string! as NSString).range(of: (selection?.string!)!, options: .caseInsensitive)
        let attrstr = NSMutableAttributedString(string: extendSelection.string!)
        attrstr.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
        
        cell.contentLabel.attributedText = attrstr
        // image
        cell.cover.image = page?.thumbnail(of: CGSize(width: 60, height: 120), for: .artBox)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didDocumentResultSelect(didSelectSerchResult: searchResults[indexPath.row][0])
//        dismiss(animated: true)
    }
}

extension PDFSearchViewController: PDFDocumentDelegate {
    func didMatchString(_ instance: PDFSelection) {
        beautifyData(instance)
    }
    
    func documentDidEndDocumentFind(_ notification: Notification) {
    }

    // 处理数据
    private func beautifyData(_ instance: PDFSelection) {
        if let page = instance.pages.first, let label = page.label,let pageNum = Int(label) {
            if originData[pageNum] == nil {
                originData[pageNum] = []
            }
            originData[pageNum]?.append(instance)
        }
        let dic = originData.sorted { $0.0 < $1.0 }
        searchResults = dic.map { $0.value }
        tableView.reloadData()
    }
}
