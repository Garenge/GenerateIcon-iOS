import Foundation
import SwiftUI
import UIKit

// MARK: - 键盘图标生成器
class KeyboardIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.renderKeyboardIcon(size: size, settings: settings)
                continuation.resume(returning: image)
            }
        }
    }
    
    private func renderKeyboardIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false  // 支持透明度
        format.scale = UIScreen.main.scale    // 使用设备像素比例
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制键盘主体
            drawKeyboardBody(in: cgContext, size: size)
            
            // 绘制按键
            drawKeyboardKeys(in: cgContext, size: size)
        }
    }
    
    private func drawKeyboardBody(in context: CGContext, size: CGSize) {
        let bodyRect = CGRect(
            x: size.width * 0.1,
            y: size.height * 0.3,
            width: size.width * 0.8,
            height: size.height * 0.4
        )
        
        // 键盘主体背景
        context.setFillColor(UIColor.systemGray5.cgColor)
        context.fill(bodyRect)
        
        // 键盘边框
        context.setStrokeColor(UIColor.systemGray3.cgColor)
        context.setLineWidth(2)
        context.stroke(bodyRect)
    }
    
    private func drawKeyboardKeys(in context: CGContext, size: CGSize) {
        let keyRows = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["Z", "X", "C", "V", "B", "N", "M"]
        ]
        
        let keySize = CGSize(width: size.width * 0.06, height: size.height * 0.08)
        let startX = size.width * 0.15
        let startY = size.height * 0.4
        
        for (rowIndex, row) in keyRows.enumerated() {
            let rowY = startY + CGFloat(rowIndex) * keySize.height * 1.2
            let rowStartX = startX + CGFloat(rowIndex) * keySize.width * 0.5
            
            for (keyIndex, key) in row.enumerated() {
                let keyRect = CGRect(
                    x: rowStartX + CGFloat(keyIndex) * keySize.width * 1.1,
                    y: rowY,
                    width: keySize.width,
                    height: keySize.height
                )
                
                drawKey(in: context, rect: keyRect, text: key)
            }
        }
    }
    
    private func drawKey(in context: CGContext, rect: CGRect, text: String) {
        // 按键背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // 按键边框
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(1)
        context.stroke(rect)
        
        // 按键文字
        let fontSize = rect.height * 0.4
        let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: rect.midX - textSize.width / 2,
            y: rect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
    }
}
