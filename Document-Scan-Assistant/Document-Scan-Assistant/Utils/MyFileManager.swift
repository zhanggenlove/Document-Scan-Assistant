//
//  MyFileManager.swift
//  文档扫描小助手
//
//  Created by 张根 on 2022/10/17.
//

import Foundation
import PDFKit
import UIKit

class MyFileManager: NSObject {
    static let shared = MyFileManager()
    let FM = FileManager.default
    // 文档保存的沙盒路径 --后续要改为iCloud沙盒路径同步到iCloud
    let documentPath: URL = {
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("documents")
        return path
    }()
   
    // MARK: 初始化应用的沙盒文件夹，没有的话需要创建documents

    func initFolder() {
        if FM.fileExists(atPath: documentPath.path) {
            return
        } else {
            do {
                try FM.createDirectory(atPath: documentPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    // 根据给的文件地址创建文件夹
    @discardableResult
    func createFolder(for directory: URL, with name: String) -> State {
        let folderPath = directory.appendingPathComponent(name)
        if FM.fileExists(atPath: folderPath.path) {
            do {
                try FM.createDirectory(atPath: "\(folderPath.path)1", withIntermediateDirectories: true, attributes: nil)
                return State.success(state: true)
            } catch {
                return State.error(error: error.localizedDescription)
            }
        } else {
            do {
                try FM.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
                return State.success(state: true)
            } catch {
                return State.error(error: error.localizedDescription)
            }
        }
    }
    
    // mark 创建文件夹
    @discardableResult
    func createFolder(with name: String) -> State {
        let folderPath = documentPath.appendingPathComponent(name)
        if FM.fileExists(atPath: folderPath.path) {
            do {
                try FM.createDirectory(atPath: "\(folderPath.path)1", withIntermediateDirectories: true, attributes: nil)
                return State.success(state: true)
            } catch {
                return State.error(error: error.localizedDescription)
            }
        } else {
            do {
                try FM.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
                return State.success(state: true)
            } catch {
                return State.error(error: error.localizedDescription)
            }
        }
    }
    
    // 修改文档的名称
    @discardableResult
    func changeFileName(for path: URL, with name: String, with suffix: String = ".pdf") -> State {
        let newPath = path
        let toPath = newPath.deletingLastPathComponent().appendingPathComponent("\(name)\(suffix)")
        do {
            try FM.moveItem(at: path, to: toPath)
            return State.success(state: true, path: toPath)
        } catch {
            return State.error(error: error.localizedDescription)
        }
    }
    
    // 移动文件
    func moveFile(from url: URL, to newUrl: URL) -> State {
        do {
            try FileManager.default.moveItem(at: url, to: newUrl)
            return State.success(state: true)
        } catch {
            return State.error(error: error.localizedDescription)
        }
    }
    
    // 修改文件夹名称
    func changeFolderName(at path: URL, with name: String) -> State {
        let newPath = path
        do {
            try FM.moveItem(at: path, to: newPath.deletingLastPathComponent().appendingPathComponent("\(name)"))
            return State.success(state: true)
        } catch {
            return State.error(error: error.localizedDescription)
        }
    }
    
    //  获取某个文件夹下的所有文件和目录的路径
    func scanDirectory2Urls() -> [URL] {
        do {
            var files = try FM.contentsOfDirectory(at: documentPath, includingPropertiesForKeys: nil)
            if let index = files.firstIndex(of: documentPath.appendingPathComponent(".DS_Store")) {
                files.remove(at: index)
            }
            return files
        } catch {
            return []
        }
    }
    
    // 扫描文件夹 返回文件
    func scanDirectory2Files(with directory: URL) -> [File] {
        var files: [File] = []
        var fileUrls: [URL] = []
        do {
            fileUrls = try FM.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            if let index = fileUrls.firstIndex(of: documentPath.appendingPathComponent(".DS_Store")) {
                fileUrls.remove(at: index)
            }
        } catch {
            print(error.localizedDescription)
        }
        for fileUrl in fileUrls {
            files.append(File(with: fileUrl))
        }
        let arr = files.filter { file -> Bool in
            file.type != .other
        }
        return arr
    }
    
    // 写入文件
    @discardableResult
    func writeFile(dir: URL = MyFileManager.shared.documentPath, for file: Data?, with name: String) -> Bool {
        guard let data = file else {
            return false
        }
        let path = dir.appendingPathComponent(name)
        if FM.fileExists(atPath: path.path) {
            let newUrl = dir.appendingPathComponent( "\(path.deletingPathExtension().lastPathComponent)1.\(path.pathExtension)")
            return FM.createFile(atPath: newUrl.path, contents: data, attributes: nil)
        }
        let state = FM.createFile(atPath: path.path, contents: data, attributes: nil)
        return state
    }
    
    // 写入文件到文件夹
    func writeFile(to directory: URL, with file: Data, with name: String) -> Bool {
        let path = directory.appendingPathComponent(name)
        let state = FM.createFile(atPath: path.path, contents: file, attributes: nil)
        return state
    }
    
    // 删除文件
    @discardableResult
    func removeFile(with url: URL) -> State {
        do {
            try FM.removeItem(at: url)
            return State.success(state: true)
        } catch {
            return State.error(error: error.localizedDescription.description)
        }
    }
    
    // 获取文件
    func readFile(for path: URL) -> Data? {
        let data = FM.contents(atPath: path.path)
        return data
    }
    
    // 获取唯一文件名
    func getUniqueFileUrl(path: URL = MyFileManager.shared.documentPath, name: String, type: String) -> URL {
        let path = path.appendingPathComponent("\(name)\(type)")
        if (FM.fileExists(atPath: path.path)) {
            return path.appendingPathComponent("\(name)1\(type)")
        } else {
            return path
        }
    }
}

// mark 处理PDF和图片的扩展

extension MyFileManager {
    // PDF转换为图片，可考虑压缩的问题
    func getImageFromPDF(with url: URL) -> [UIImage]? {
        var images: [UIImage] = []
        guard let document = PDFDocument(url: url) else { return nil }
        for i in 0 ..< document.pageCount {
            let page = document.page(at: i)
            let image = UIImage(data: page!.dataRepresentation!)
            images.append(image!)
        }
        return images
    }
    
    // 获取PDF文件
    func getPdfDocument(url: URL) -> PDFDocument? {
        guard let document = PDFDocument(url: url) else { return nil }
        return document
    }

    // 获取某一页的PDF PDFPage
    func getPDFPageByPath(with page: Int, at url: URL) -> PDFPage? {
        guard let document = PDFDocument(url: url) else { return nil }
        guard let page = document.page(at: page) else { return nil }
        return page
    }
    
    // 获取某个文档的页数
    func getPDFCount(at url: URL) -> Int {
        guard let document = PDFDocument(url: url) else { return 0 }
        return document.pageCount
    }
    
    // TODO: 获取某个文件夹下所有文档的页数
    
    // 获取PDF的封面, 前辈(以前的自己)说没用？？？？
    func getCoverFromPDF(at path: URL) -> UIImage? {
        guard let document = PDFDocument(url: path) else {
            return nil
        }
        let page = document.page(at: 0)
        let image = UIImage(data: page!.dataRepresentation!)
        return image
    }
    
    // 获取PDF的封面,提高效率, 压缩率0.4
    func getCoverFromPDF(fast path: URL) -> UIImage? {
        guard let document = PDFDocument(url: path) else {
            return nil
        }
        guard let page = document.page(at: 0) else { return nil }
        let image = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox)
        let data = image.jpegData(compressionQuality: 0.4)!
        let compressImg = UIImage(data: data)
        return compressImg
    }
    
    // 获取文档某一页的图片, 应该没啥用
    func getImageFromPDFByIndex(with url: URL, for indexPath: Int) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: indexPath + 1) else { return nil }
        let size = CGSize(width: 200, height: 200)
        let f = UIGraphicsImageRendererFormat.default() // *
        f.opaque = true
        let r = UIGraphicsImageRenderer(size: size)
        let img = r.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1500, height: 1500)))
            ctx.cgContext.translateBy(x: 0.0, y: page.getBoxRect(.mediaBox).size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.drawPDFPage(page)
        }
        UIGraphicsEndImageContext()
        return img
    }
    
    // 获取文件夹大小,用户应该只会关心文档有几页
    func getFolderSize(for folderUrl: URL) -> String {
        var size = "Bytes"
        // 判断是不是文件夹
        if (try? folderUrl.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
            var folderSize = 0
            (try? FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil))?.lazy.forEach {
                folderSize += (try? $0.resourceValues(forKeys: [.totalFileAllocatedSizeKey]))?.totalFileAllocatedSize ?? 0
            }
            let byteCountFormatter = ByteCountFormatter()
            byteCountFormatter.allowedUnits = .useBytes
            byteCountFormatter.countStyle = .file
            let _ = byteCountFormatter.string(for: folderSize) ?? ""
            size = (folderSize/1000000).description + "MB" //
        }
        return size
    }

    // 获取documentDirectory下文件大小
    func getDocumentsDirectorySize() -> String {
        var size = ""
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // 判断是不是文件夹
        if (try? documentsDirectoryURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
            var folderSize = 0
            (FileManager.default.enumerator(at: documentsDirectoryURL, includingPropertiesForKeys: nil)?.allObjects as? [URL])?.lazy.forEach {
                folderSize += (try? $0.resourceValues(forKeys: [.totalFileAllocatedSizeKey]))?.totalFileAllocatedSize ?? 0
            }
            let byteCountFormatter = ByteCountFormatter()
            byteCountFormatter.allowedUnits = .useBytes
            byteCountFormatter.countStyle = .file
            let _ = byteCountFormatter.string(for: folderSize) ?? ""
            size = (folderSize/1000000).description + "MB"
        }
        return size
    }

    func getFileSize(for fileUrl: URL) -> String {
        var size: Double = 0
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: fileUrl.path)
            size = attr[FileAttributeKey.size] as! Double
            let dict = attr as NSDictionary
            size = Double(dict.fileSize())
        } catch {
            print("Error: \(error)")
        }
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.countStyle = .binary
        return byteCountFormatter.string(fromByteCount: Int64(size))
    }

    // 获取文件相关属性
    func fileAttrbutes(for url: String) -> [FileAttributeKey: Any] {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url) {
            return attributes
        } else {
            return [:]
        }
    }

    // 加载PDF文档
    func loadPDF(for url: URL) -> PDFDocument? {
        guard let pdf = PDFDocument(url: url) else {
            return nil
        }
        return pdf
    }
}

// mark 状态枚举
enum State {
    case success(state: Bool, path: URL? = nil)
    case error(error: String)
}

// 文件类型枚举
public enum FileType: Int {
    case folder, pdf, doc, txt, png, jpg, image, other
}

// 文件结构体
struct File {
    var name: String!
    let type: FileType!
    var size: String! = ""
    var page: Int = 0
    let image: UIImage!
    let path: String!
    let url: URL!
    let createDate: Date!
    let updateDate: Date!
    
    init(with fileUrl: URL) {
        path = fileUrl.path
        url = fileUrl
        let fileExtension = fileUrl.pathExtension
        let attributes = MyFileManager.shared.fileAttrbutes(for: path)
        createDate = attributes[FileAttributeKey("NSFileCreationDate")] as? Date
        updateDate = attributes[FileAttributeKey("NSFileModificationDate")] as? Date
        switch fileExtension {
        case "":
            name = fileUrl.lastPathComponent
            type = .folder
            // TO DO 文件夹的图片
            image = UIImage(systemName: "folder.fill")
            size = MyFileManager.shared.getFolderSize(for: url)
        case "pdf":
            name = fileUrl.deletingPathExtension().lastPathComponent
            type = .pdf
            size = MyFileManager.shared.getFileSize(for: url)
            page = MyFileManager.shared.getPDFCount(at: url)
            image = MyFileManager.shared.getCoverFromPDF(fast: fileUrl)
        default:
            name = fileUrl.lastPathComponent
            type = .other
//            size = FileManagerTool.shared.getFileSize()
            // TO DO 文件夹的图片
            image = UIImage(named: "folder")
        }
    }
}
