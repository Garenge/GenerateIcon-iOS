import Foundation
import SwiftUI
import UIKit

// MARK: - 通信图标生成器
class CommunicationIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let image = self.renderCommunicationIcon(size: size, settings: settings)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func renderCommunicationIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制通信图标
            drawCommunicationIcon(in: cgContext, size: size)
        }
    }
    
    private func drawCommunicationIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 电话图标
        let phoneRect = CGRect(
            x: centerX - iconSize * 0.2,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.4,
            height: iconSize * 0.6
        )
        
        // 电话主体
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(phoneRect)
        
        // 电话边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.stroke(phoneRect)
        
        // 电话屏幕
        let screenRect = CGRect(
            x: phoneRect.minX + 4,
            y: phoneRect.minY + 8,
            width: phoneRect.width - 8,
            height: phoneRect.height * 0.6
        )
        
        context.setFillColor(UIColor.black.cgColor)
        context.fill(screenRect)
        
        // 屏幕内容
        context.setFillColor(UIColor.white.cgColor)
        let dotSize: CGFloat = 3
        let dotSpacing: CGFloat = 8
        
        for row in 0..<3 {
            for col in 0..<3 {
                let x = screenRect.minX + 12 + CGFloat(col) * dotSpacing
                let y = screenRect.minY + 12 + CGFloat(row) * dotSpacing
                let dotRect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                context.fillEllipse(in: dotRect)
            }
        }
        
        // 电话按钮
        let buttonRect = CGRect(
            x: phoneRect.minX + 8,
            y: phoneRect.maxY - 20,
            width: phoneRect.width - 16,
            height: 12
        )
        
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(buttonRect)
    }
}
