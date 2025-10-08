import Foundation
import SwiftUI
import UIKit

// MARK: - 文档图标生成器
class DocumentIconGenerator: BaseIconGenerator {
    private let iconType: IconType
    
    init(iconType: IconType) {
        self.iconType = iconType
        super.init()
    }
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.renderDocumentIcon(size: size, settings: settings)
                continuation.resume(returning: image)
            }
        }
    }
    
    private func renderDocumentIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制文档图标
            drawDocumentIcon(in: cgContext, size: size)
        }
    }
    
    private func drawDocumentIcon(in context: CGContext, size: CGSize) {
        switch iconType {
        case .document:
            drawDocumentIconContent(in: context, size: size)
        case .folder:
            drawFolderIcon(in: context, size: size)
        case .printer:
            drawPrinterIcon(in: context, size: size)
        case .calendar:
            drawCalendarIcon(in: context, size: size)
        default:
            drawDocumentIconContent(in: context, size: size)
        }
    }
    
    private func drawDocumentIconContent(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 文档主体
        let documentRect = CGRect(
            x: centerX - iconSize * 0.3,
            y: centerY - iconSize * 0.4,
            width: iconSize * 0.6,
            height: iconSize * 0.8
        )
        
        // 文档背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(documentRect)
        
        // 文档边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(2)
        context.stroke(documentRect)
        
        // 文档内容线条
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(1)
        
        let lineSpacing = documentRect.height / 8
        for i in 1..<7 {
            let y = documentRect.minY + CGFloat(i) * lineSpacing
            context.move(to: CGPoint(x: documentRect.minX + 8, y: y))
            context.addLine(to: CGPoint(x: documentRect.maxX - 8, y: y))
        }
        context.strokePath()
        
        // 文档折角
        let cornerSize = iconSize * 0.2
        let cornerRect = CGRect(
            x: documentRect.maxX - cornerSize,
            y: documentRect.minY,
            width: cornerSize,
            height: cornerSize
        )
        
        context.setFillColor(UIColor.systemGray3.cgColor)
        context.fill(cornerRect)
        
        // 折角线条
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: cornerRect.minX, y: cornerRect.maxY))
        context.addLine(to: CGPoint(x: cornerRect.maxX, y: cornerRect.minY))
        context.strokePath()
    }
    
    private func drawFolderIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 文件夹主体
        let folderRect = CGRect(
            x: centerX - iconSize * 0.35,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.7,
            height: iconSize * 0.6
        )
        
        // 文件夹背景
        context.setFillColor(UIColor.systemOrange.cgColor)
        context.fill(folderRect)
        
        // 文件夹边框
        context.setStrokeColor(UIColor.systemOrange.withAlphaComponent(0.8).cgColor)
        context.setLineWidth(2)
        context.stroke(folderRect)
        
        // 文件夹标签
        let tabRect = CGRect(
            x: folderRect.minX + iconSize * 0.1,
            y: folderRect.minY - iconSize * 0.15,
            width: iconSize * 0.3,
            height: iconSize * 0.15
        )
        
        context.setFillColor(UIColor.systemOrange.cgColor)
        context.fill(tabRect)
        
        context.setStrokeColor(UIColor.systemOrange.withAlphaComponent(0.8).cgColor)
        context.setLineWidth(2)
        context.stroke(tabRect)
        
        // 文件夹内容线条
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        
        let lineSpacing = folderRect.height / 6
        for i in 1..<5 {
            let y = folderRect.minY + CGFloat(i) * lineSpacing
            context.move(to: CGPoint(x: folderRect.minX + 8, y: y))
            context.addLine(to: CGPoint(x: folderRect.maxX - 8, y: y))
        }
        context.strokePath()
    }
    
    private func drawPrinterIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 打印机主体
        let printerRect = CGRect(
            x: centerX - iconSize * 0.4,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.8,
            height: iconSize * 0.6
        )
        
        // 打印机背景
        context.setFillColor(UIColor.systemGray4.cgColor)
        context.fill(printerRect)
        
        // 打印机边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(2)
        context.stroke(printerRect)
        
        // 打印机顶部面板
        let topPanelRect = CGRect(
            x: printerRect.minX,
            y: printerRect.minY - iconSize * 0.15,
            width: printerRect.width,
            height: iconSize * 0.15
        )
        
        context.setFillColor(UIColor.systemGray3.cgColor)
        context.fill(topPanelRect)
        
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(2)
        context.stroke(topPanelRect)
        
        // 打印机屏幕
        let screenRect = CGRect(
            x: topPanelRect.minX + iconSize * 0.1,
            y: topPanelRect.minY + iconSize * 0.03,
            width: iconSize * 0.2,
            height: iconSize * 0.09
        )
        
        context.setFillColor(UIColor.black.cgColor)
        context.fill(screenRect)
        
        // 打印机出纸口
        let paperRect = CGRect(
            x: printerRect.minX + iconSize * 0.1,
            y: printerRect.minY,
            width: printerRect.width - iconSize * 0.2,
            height: iconSize * 0.05
        )
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(paperRect)
        
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(1)
        context.stroke(paperRect)
        
        // 纸张内容线条
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(1)
        
        let lineSpacing = paperRect.height / 3
        for i in 1..<3 {
            let y = paperRect.minY + CGFloat(i) * lineSpacing
            context.move(to: CGPoint(x: paperRect.minX + 4, y: y))
            context.addLine(to: CGPoint(x: paperRect.maxX - 4, y: y))
        }
        context.strokePath()
    }
    
    private func drawCalendarIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 日历主体
        let calendarRect = CGRect(
            x: centerX - iconSize * 0.35,
            y: centerY - iconSize * 0.4,
            width: iconSize * 0.7,
            height: iconSize * 0.8
        )
        
        // 日历背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(calendarRect)
        
        // 日历边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(2)
        context.stroke(calendarRect)
        
        // 日历顶部标题栏
        let headerRect = CGRect(
            x: calendarRect.minX,
            y: calendarRect.minY,
            width: calendarRect.width,
            height: iconSize * 0.2
        )
        
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(headerRect)
        
        // 日历标题文字
        let fontSize = headerRect.height * 0.5
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let text = "2024"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: headerRect.midX - textSize.width / 2,
            y: headerRect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        // 日历网格
        let gridRect = CGRect(
            x: calendarRect.minX,
            y: headerRect.maxY,
            width: calendarRect.width,
            height: calendarRect.height - headerRect.height
        )
        
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(1)
        
        // 绘制网格线
        let cellWidth = gridRect.width / 7
        let cellHeight = gridRect.height / 6
        
        for i in 0...7 {
            let x = gridRect.minX + CGFloat(i) * cellWidth
            context.move(to: CGPoint(x: x, y: gridRect.minY))
            context.addLine(to: CGPoint(x: x, y: gridRect.maxY))
        }
        
        for i in 0...6 {
            let y = gridRect.minY + CGFloat(i) * cellHeight
            context.move(to: CGPoint(x: gridRect.minX, y: y))
            context.addLine(to: CGPoint(x: gridRect.maxX, y: y))
        }
        context.strokePath()
        
        // 添加一些日期数字
        context.setFillColor(UIColor.label.cgColor)
        let dateFont = UIFont.systemFont(ofSize: cellHeight * 0.3, weight: .medium)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont,
            .foregroundColor: UIColor.label
        ]
        
        let sampleDates = ["1", "2", "3", "4", "5", "6", "7"]
        for (index, date) in sampleDates.enumerated() {
            let dateSize = date.size(withAttributes: dateAttributes)
            let dateRect = CGRect(
                x: gridRect.minX + CGFloat(index) * cellWidth + cellWidth/2 - dateSize.width/2,
                y: gridRect.minY + cellHeight + cellHeight/2 - dateSize.height/2,
                width: dateSize.width,
                height: dateSize.height
            )
            date.draw(in: dateRect, withAttributes: dateAttributes)
        }
    }
}
