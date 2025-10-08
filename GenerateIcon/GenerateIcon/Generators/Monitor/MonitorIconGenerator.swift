import Foundation
import SwiftUI
import UIKit

// MARK: - 显示器图标生成器
class MonitorIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.renderMonitorIcon(size: size, settings: settings)
                continuation.resume(returning: image)
            }
        }
    }
    
    private func renderMonitorIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制显示器屏幕
            drawMonitorScreen(in: cgContext, size: size)
            
            // 绘制显示器支架
            drawMonitorStand(in: cgContext, size: size)
            
            // 绘制屏幕内容
            drawScreenContent(in: cgContext, size: size)
        }
    }
    
    private func drawMonitorScreen(in context: CGContext, size: CGSize) {
        let screenRect = CGRect(
            x: size.width * 0.15,
            y: size.height * 0.1,
            width: size.width * 0.7,
            height: size.height * 0.6
        )
        
        // 屏幕背景
        context.setFillColor(UIColor.black.cgColor)
        context.fill(screenRect)
        
        // 屏幕边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(3)
        context.stroke(screenRect)
    }
    
    private func drawMonitorStand(in context: CGContext, size: CGSize) {
        // 显示器支架
        let standRect = CGRect(
            x: size.width * 0.4,
            y: size.height * 0.7,
            width: size.width * 0.2,
            height: size.height * 0.15
        )
        
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(standRect)
        
        // 显示器底座
        let baseRect = CGRect(
            x: size.width * 0.2,
            y: size.height * 0.8,
            width: size.width * 0.6,
            height: size.height * 0.1
        )
        
        context.setFillColor(UIColor.systemGray2.cgColor)
        context.fill(baseRect)
    }
    
    private func drawScreenContent(in context: CGContext, size: CGSize) {
        let screenRect = CGRect(
            x: size.width * 0.15,
            y: size.height * 0.1,
            width: size.width * 0.7,
            height: size.height * 0.6
        )
        
        // 屏幕内容
        let fontSize = screenRect.height * 0.1
        let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        let text = "Hello World"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.green
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: screenRect.midX - textSize.width / 2,
            y: screenRect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
    }
}
