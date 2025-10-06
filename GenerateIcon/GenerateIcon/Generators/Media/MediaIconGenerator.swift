import Foundation
import SwiftUI
import UIKit

// MARK: - 媒体图标生成器
class MediaIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let image = self.renderMediaIcon(size: size, settings: settings)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func renderMediaIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制媒体图标
            drawMediaIcon(in: cgContext, size: size)
        }
    }
    
    private func drawMediaIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 音乐播放器图标
        let playerRect = CGRect(
            x: centerX - iconSize * 0.3,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.6,
            height: iconSize * 0.6
        )
        
        // 播放器背景
        context.setFillColor(UIColor.systemPurple.cgColor)
        context.fillEllipse(in: playerRect)
        
        // 播放器边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.strokeEllipse(in: playerRect)
        
        // 播放按钮（三角形）
        let buttonSize = iconSize * 0.2
        let buttonX = centerX - buttonSize * 0.3
        let buttonY = centerY - buttonSize * 0.5
        
        context.setFillColor(UIColor.white.cgColor)
        context.move(to: CGPoint(x: buttonX, y: buttonY))
        context.addLine(to: CGPoint(x: buttonX, y: buttonY + buttonSize))
        context.addLine(to: CGPoint(x: buttonX + buttonSize, y: buttonY + buttonSize * 0.5))
        context.closePath()
        context.fillPath()
        
        // 音量条
        let barWidth = iconSize * 0.3
        let barHeight = iconSize * 0.05
        let barX = centerX - barWidth * 0.5
        let barY = centerY + iconSize * 0.2
        
        for i in 0..<3 {
            let barRect = CGRect(
                x: barX + CGFloat(i) * barWidth * 0.3,
                y: barY + CGFloat(i) * barHeight,
                width: barWidth * 0.2,
                height: barHeight * (3 - CGFloat(i))
            )
            
            context.setFillColor(UIColor.white.cgColor)
            context.fill(barRect)
        }
    }
}
