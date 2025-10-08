import Foundation
import SwiftUI
import UIKit

// MARK: - 计算器图标生成器
class CalculatorIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        print("🧮 CalculatorIconGenerator: Starting to generate calculator icon")
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.renderCalculatorIcon(size: size, settings: settings)
                print("🧮 CalculatorIconGenerator: Calculator icon generated successfully")
                continuation.resume(returning: image)
            }
        }
    }
    
    private func renderCalculatorIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false  // 支持透明度
        format.scale = 1.0    // 使用设备像素比例
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制计算器主体
            drawCalculatorBody(in: cgContext, size: size)
            
            // 绘制屏幕
            drawCalculatorScreen(in: cgContext, size: size)
            
            // 绘制按钮
            drawCalculatorButtons(in: cgContext, size: size)
        }
    }
    
    private func drawCalculatorBody(in context: CGContext, size: CGSize) {
        let bodyRect = CGRect(
            x: size.width * 0.1,
            y: size.height * 0.1,
            width: size.width * 0.8,
            height: size.height * 0.8
        )
        
        // 计算器主体背景
        context.setFillColor(UIColor.systemGray5.cgColor)
        context.fill(bodyRect)
        
        // 计算器边框
        context.setStrokeColor(UIColor.systemGray3.cgColor)
        context.setLineWidth(2)
        context.stroke(bodyRect)
        
        // 内部阴影效果
        let shadowRect = CGRect(
            x: bodyRect.minX + 2,
            y: bodyRect.minY + 2,
            width: bodyRect.width - 4,
            height: bodyRect.height - 4
        )
        
        context.setFillColor(UIColor.systemGray6.cgColor)
        context.fill(shadowRect)
    }
    
    private func drawCalculatorScreen(in context: CGContext, size: CGSize) {
        let screenRect = CGRect(
            x: size.width * 0.15,
            y: size.height * 0.2,
            width: size.width * 0.7,
            height: size.height * 0.15
        )
        
        // 屏幕背景
        context.setFillColor(UIColor.black.cgColor)
        context.fill(screenRect)
        
        // 屏幕边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(1)
        context.stroke(screenRect)
        
        // 屏幕内容
        drawScreenContent(in: context, rect: screenRect)
    }
    
    private func drawScreenContent(in context: CGContext, rect: CGRect) {
        let fontSize = rect.height * 0.6
        let font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .medium)
        
        let text = "123.45"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.green
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: rect.maxX - textSize.width - rect.width * 0.05,
            y: rect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
    }
    
    private func drawCalculatorButtons(in context: CGContext, size: CGSize) {
        let buttonArea = CGRect(
            x: size.width * 0.15,
            y: size.height * 0.4,
            width: size.width * 0.7,
            height: size.height * 0.5
        )
        
        let buttonSize = CGSize(
            width: buttonArea.width / 4 - 2,
            height: buttonArea.height / 5 - 2
        )
        
        let buttonLabels = [
            ["C", "±", "%", "÷"],
            ["7", "8", "9", "×"],
            ["4", "5", "6", "−"],
            ["1", "2", "3", "+"],
            ["0", "0", ".", "="]
        ]
        
        for (row, labels) in buttonLabels.enumerated() {
            for (col, label) in labels.enumerated() {
                let buttonRect = CGRect(
                    x: buttonArea.minX + CGFloat(col) * (buttonSize.width + 2),
                    y: buttonArea.minY + CGFloat(row) * (buttonSize.height + 2),
                    width: buttonSize.width,
                    height: buttonSize.height
                )
                
                // 特殊处理0按钮（跨两列）
                if row == 4 && col == 0 {
                    let doubleWidthRect = CGRect(
                        x: buttonRect.minX,
                        y: buttonRect.minY,
                        width: buttonSize.width * 2 + 2,
                        height: buttonSize.height
                    )
                    drawButton(in: context, rect: doubleWidthRect, label: label)
                } else if row == 4 && col == 1 {
                    continue // 跳过第二个0
                } else {
                    drawButton(in: context, rect: buttonRect, label: label)
                }
            }
        }
    }
    
    private func drawButton(in context: CGContext, rect: CGRect, label: String) {
        // 按钮背景
        context.setFillColor(UIColor.systemGray4.cgColor)
        context.fill(rect)
        
        // 按钮边框
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(1)
        context.stroke(rect)
        
        // 按钮文字
        let fontSize = rect.height * 0.4
        let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        let textColor: UIColor
        if ["÷", "×", "−", "+", "="].contains(label) {
            textColor = UIColor.systemOrange
        } else if ["C", "±", "%"].contains(label) {
            textColor = UIColor.systemBlue
        } else {
            textColor = UIColor.label
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        let textSize = label.size(withAttributes: attributes)
        let textRect = CGRect(
            x: rect.midX - textSize.width / 2,
            y: rect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        label.draw(in: textRect, withAttributes: attributes)
    }
}
