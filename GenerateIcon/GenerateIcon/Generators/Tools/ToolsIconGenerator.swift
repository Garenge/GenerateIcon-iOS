import Foundation
import SwiftUI
import UIKit

// MARK: - 工具图标生成器
class ToolsIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let image = self.renderToolsIcon(size: size, settings: settings)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func renderToolsIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制工具图标
            drawToolsIcon(in: cgContext, size: size)
        }
    }
    
    private func drawToolsIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 齿轮图标
        let gearSize = iconSize * 0.8
        let gearRect = CGRect(
            x: centerX - gearSize * 0.5,
            y: centerY - gearSize * 0.5,
            width: gearSize,
            height: gearSize
        )
        
        // 齿轮主体
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fillEllipse(in: gearRect)
        
        // 齿轮边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.strokeEllipse(in: gearRect)
        
        // 齿轮中心
        let centerSize = gearSize * 0.3
        let centerRect = CGRect(
            x: centerX - centerSize * 0.5,
            y: centerY - centerSize * 0.5,
            width: centerSize,
            height: centerSize
        )
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: centerRect)
        
        // 齿轮齿
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        
        let toothLength = gearSize * 0.1
        let toothCount = 8
        
        for i in 0..<toothCount {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(toothCount)
            let startRadius = gearSize * 0.4
            let endRadius = startRadius + toothLength
            
            let startX = centerX + cos(angle) * startRadius
            let startY = centerY + sin(angle) * startRadius
            let endX = centerX + cos(angle) * endRadius
            let endY = centerY + sin(angle) * endRadius
            
            context.move(to: CGPoint(x: startX, y: startY))
            context.addLine(to: CGPoint(x: endX, y: endY))
        }
        context.strokePath()
    }
}
