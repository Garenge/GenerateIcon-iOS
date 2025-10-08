import Foundation
import SwiftUI
import UIKit

// MARK: - 鼠标图标生成器
class MouseIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        print("🖱️ MouseIconGenerator: Starting to generate mouse icon")
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.renderMouseIcon(size: size, settings: settings)
                print("🖱️ MouseIconGenerator: Mouse icon generated successfully")
                continuation.resume(returning: image)
            }
        }
    }
    
    private func renderMouseIcon(size: CGSize, settings: IconSettings) -> UIImage {
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
            
            // 绘制鼠标主体
            drawMouseBody(in: cgContext, size: size)
            
            // 绘制滚轮
            drawMouseWheel(in: cgContext, size: size)
            
            // 绘制线缆
            drawMouseCable(in: cgContext, size: size)
        }
    }
    
    private func drawMouseBody(in context: CGContext, size: CGSize) {
        let bodyRect = CGRect(
            x: size.width * 0.2,
            y: size.height * 0.3,
            width: size.width * 0.6,
            height: size.height * 0.5
        )
        
        // 鼠标主体背景
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fillEllipse(in: bodyRect)
        
        // 鼠标边框
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(2)
        context.strokeEllipse(in: bodyRect)
    }
    
    private func drawMouseWheel(in context: CGContext, size: CGSize) {
        let wheelRect = CGRect(
            x: size.width * 0.45,
            y: size.height * 0.4,
            width: size.width * 0.1,
            height: size.height * 0.3
        )
        
        // 滚轮背景
        context.setFillColor(UIColor.systemGray3.cgColor)
        context.fill(wheelRect)
        
        // 滚轮线条
        context.setStrokeColor(UIColor.systemGray4.cgColor)
        context.setLineWidth(1)
        
        for i in 0..<3 {
            let y = wheelRect.minY + CGFloat(i + 1) * wheelRect.height / 4
            context.move(to: CGPoint(x: wheelRect.minX, y: y))
            context.addLine(to: CGPoint(x: wheelRect.maxX, y: y))
        }
        context.strokePath()
    }
    
    private func drawMouseCable(in context: CGContext, size: CGSize) {
        let cableStart = CGPoint(x: size.width * 0.3, y: size.height * 0.8)
        let cableEnd = CGPoint(x: size.width * 0.1, y: size.height * 0.9)
        
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(3)
        context.setLineCap(.round)
        
        context.move(to: cableStart)
        context.addLine(to: cableEnd)
        context.strokePath()
    }
}
