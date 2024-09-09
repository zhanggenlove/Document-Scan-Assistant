//
//  WatermarkPDFPage.swift
//  文档扫描小助手
//
//  Created by 张根 on 2023/5/8.
//

import Foundation
import PDFKit

class WatermarkPDFPage: PDFPage {
    
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        super.draw(with: box, to: context)
        guard let markText: NSString = WaterMarkInfo.shared.content else {
            return
        }
        let color = WaterMarkInfo.shared.color
        let size = WaterMarkInfo.shared.size
        let opacity = WaterMarkInfo.shared.opacity
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color.withAlphaComponent(CGFloat(opacity)),
            .font: UIFont.systemFont(ofSize: CGFloat(size))
        ]
        let stringSize = markText.size(withAttributes: attributes)
        let pageBounds = bounds(for: box)
//        UIGraphicsPushContext(context)
//        context.saveGState()
//        context.translateBy(x: 0, y: pageBounds.size.height)
//        context.scaleBy(x: 1, y: -1)
//        context.rotate(by: -CGFloat.pi / 4)
//        markText.draw(at: CGPoint(x: -stringSize.width / 2, y: stringSize.width / 2 + 20), withAttributes: attributes)
//        context.restoreGState()
//        UIGraphicsPopContext()
        // ----- 采用全屏铺满的水印方式
        // 1.计算对角线的长度
        let width = pageBounds.size.width
        let height = pageBounds.size.height
        let diagonal = sqrt(width * width + height * height)
        let rowGap = 80.0 // 每行的间距 (x * width) + (x + 1) * rowGap = diagonal
        let rowNum = Int(diagonal / stringSize.width) // 每行放几个
        let columnGap = 100.0
        let columnNum = Int(diagonal / columnGap) // 循环几行
        var startY = -stringSize.height
        var startX = -(diagonal)
        for index in 0...columnNum {
            UIGraphicsPushContext(context)
            context.saveGState()
            context.translateBy(x: 0, y: height)
            context.scaleBy(x: 1, y: -1)
            context.rotate(by: -CGFloat.pi / 4)
            markText.draw(at: CGPoint(x: startX, y: startY), withAttributes: attributes)
            context.restoreGState()
            UIGraphicsPopContext()
            startY = -stringSize.height + (columnGap + stringSize.height)  * Double(index)
            for xIndex in 0...rowNum {
                UIGraphicsPushContext(context)
                context.saveGState()
                context.translateBy(x: 0, y: height)
                context.scaleBy(x: 1, y: -1)
                context.rotate(by: -CGFloat.pi / 4)
                markText.draw(at: CGPoint(x: startX, y: startY), withAttributes: attributes)
                context.restoreGState()
                UIGraphicsPopContext()
                let x = Float(xIndex) * Float(stringSize.width)
                startX = -diagonal + rowGap * Double(xIndex) + Double(x)
            }
        }
        // -----
//        UIGraphicsPushContext(context)
//        context.saveGState()
//        context.translateBy(x: 0, y: pageBounds.size.height)
//        context.scaleBy(x: 1, y: -1)
//        context.rotate(by: -CGFloat.pi / 4)
//        markText.draw(at: CGPoint(x: -stringSize.width / 2, y: 300 + 200), withAttributes: attributes)
//        context.restoreGState()
//        UIGraphicsPopContext()
//        // -----
//        UIGraphicsPushContext(context)
//        context.saveGState()
//        context.translateBy(x: 0, y: pageBounds.size.height)
//        context.scaleBy(x: 1, y: -1)
//        context.rotate(by: -CGFloat.pi / 4)
//        markText.draw(at: CGPoint(x: -stringSize.width / 2, y: 300 - 200), withAttributes: attributes)
//        context.restoreGState()
//        UIGraphicsPopContext()
    }
}

// 保存水印信息的单例
class WaterMarkInfo {
    static let shared = WaterMarkInfo()
    public var content: NSString? = nil
    public var size: Float = 14.0
    public var opacity: Float = 0.5
    public var color: UIColor = UIColor.black
    // 修改content
    public func setDrawConfig(content: NSString?, size: Float, opacity: Float, color: UIColor) {
        self.content = content
        self.size = size
        self.opacity = opacity
        self.color = color
    }
}
