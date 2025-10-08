import Foundation
import SwiftUI
import UIKit

// MARK: - 定位图标生成器
class LocationIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.renderLocationIcon(size: size, settings: settings)
                continuation.resume(returning: image)
            }
        }
    }
    
    private func renderLocationIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制定位图标
            drawLocationPin(in: cgContext, size: size)
            
            // 绘制信号波纹
            drawLocationRings(in: cgContext, size: size)
            
            // 绘制坐标网格
            drawLocationGrid(in: cgContext, size: size)
        }
    }
    
    private func drawLocationPin(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let pinSize = min(size.width, size.height) * 0.3
        
        // 定位针主体
        let pinRect = CGRect(
            x: centerX - pinSize / 2,
            y: centerY - pinSize / 2,
            width: pinSize,
            height: pinSize
        )
        
        context.setFillColor(UIColor.systemRed.cgColor)
        context.fillEllipse(in: pinRect)
        
        // 定位针边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.strokeEllipse(in: pinRect)
        
        // 定位针中心点
        let centerPoint = CGRect(
            x: centerX - pinSize * 0.1,
            y: centerY - pinSize * 0.1,
            width: pinSize * 0.2,
            height: pinSize * 0.2
        )
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: centerPoint)
    }
    
    private func drawLocationRings(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let maxRadius = min(size.width, size.height) * 0.4
        
        // 绘制信号波纹
        for i in 1...3 {
            let radius = maxRadius * CGFloat(i) / 3
            let ringRect = CGRect(
                x: centerX - radius,
                y: centerY - radius,
                width: radius * 2,
                height: radius * 2
            )
            
            context.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.3).cgColor)
            context.setLineWidth(2)
            context.strokeEllipse(in: ringRect)
        }
    }
    
    private func drawLocationGrid(in context: CGContext, size: CGSize) {
        let gridSize = size.width * 0.8
        let startX = (size.width - gridSize) / 2
        let startY = (size.height - gridSize) / 2
        
        context.setStrokeColor(UIColor.systemGray4.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(1)
        
        // 绘制网格线
        let gridLines = 5
        for i in 0...gridLines {
            let offset = CGFloat(i) * gridSize / CGFloat(gridLines)
            
            // 垂直线
            context.move(to: CGPoint(x: startX + offset, y: startY))
            context.addLine(to: CGPoint(x: startX + offset, y: startY + gridSize))
            
            // 水平线
            context.move(to: CGPoint(x: startX, y: startY + offset))
            context.addLine(to: CGPoint(x: startX + gridSize, y: startY + offset))
        }
        
        context.strokePath()
    }
}
