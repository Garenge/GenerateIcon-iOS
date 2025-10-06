import Foundation
import SwiftUI
import UIKit

// MARK: - 工具图标生成器
class ToolsIconGenerator: BaseIconGenerator {
    private let iconType: IconType
    
    init(iconType: IconType) {
        self.iconType = iconType
        super.init()
    }
    
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
            
            // 根据图标类型绘制不同的工具图标
            switch iconType {
            case .settings:
                drawSettingsIcon(in: cgContext, size: size)
            case .search:
                drawSearchIcon(in: cgContext, size: size)
            case .heart:
                drawHeartIcon(in: cgContext, size: size)
            case .star:
                drawStarIcon(in: cgContext, size: size)
            default:
                drawSettingsIcon(in: cgContext, size: size)
            }
        }
    }
    
    private func drawSettingsIcon(in context: CGContext, size: CGSize) {
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
    
    private func drawSearchIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 放大镜
        let magnifierSize = iconSize * 0.6
        let magnifierRect = CGRect(
            x: centerX - magnifierSize * 0.5,
            y: centerY - magnifierSize * 0.5,
            width: magnifierSize,
            height: magnifierSize
        )
        
        // 放大镜边框
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(4)
        context.strokeEllipse(in: magnifierRect)
        
        // 放大镜手柄
        let handleLength = magnifierSize * 0.4
        let handleStartX = magnifierRect.maxX - magnifierSize * 0.2
        let handleStartY = magnifierRect.maxY - magnifierSize * 0.2
        let handleEndX = handleStartX + handleLength * 0.7
        let handleEndY = handleStartY + handleLength * 0.7
        
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(4)
        context.move(to: CGPoint(x: handleStartX, y: handleStartY))
        context.addLine(to: CGPoint(x: handleEndX, y: handleEndY))
        context.strokePath()
        
        // 搜索内容（小圆点）
        let dotSize: CGFloat = 3
        let dotSpacing: CGFloat = 6
        let startX = magnifierRect.minX + magnifierSize * 0.2
        let startY = magnifierRect.minY + magnifierSize * 0.2
        
        context.setFillColor(UIColor.systemBlue.cgColor)
        for i in 0..<2 {
            for j in 0..<2 {
                let dotX = startX + CGFloat(j) * dotSpacing
                let dotY = startY + CGFloat(i) * dotSpacing
                let dotRect = CGRect(x: dotX - dotSize/2, y: dotY - dotSize/2, width: dotSize, height: dotSize)
                context.fillEllipse(in: dotRect)
            }
        }
    }
    
    private func drawHeartIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 全新的爱心绘制方法 - 使用数学心形公式
        let heartSize = iconSize * 0.8
        let scale = heartSize / 100.0 // 标准化缩放
        
        // 设置爱心颜色
        context.setFillColor(UIColor.systemRed.cgColor)
        
        // 使用数学心形公式绘制
        let heartPath = CGMutablePath()
        
        // 心形参数
        let tStep: CGFloat = 0.1
        var firstPoint = true
        
        // 使用参数方程绘制心形
        for t in stride(from: CGFloat(0), to: CGFloat(2 * CGFloat.pi), by: tStep) {
            // 心形参数方程
            let x = 16 * pow(sin(t), 3)
            let y = -(13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t))
            
            // 转换到实际坐标
            let actualX = centerX + x * scale
            let actualY = centerY + y * scale
            
            if firstPoint {
                heartPath.move(to: CGPoint(x: actualX, y: actualY))
                firstPoint = false
            } else {
                heartPath.addLine(to: CGPoint(x: actualX, y: actualY))
            }
        }
        
        // 闭合路径
        heartPath.closeSubpath()
        
        // 填充爱心
        context.addPath(heartPath)
        context.fillPath()
        
        // 添加爱心边框
        context.setStrokeColor(UIColor.systemRed.withAlphaComponent(0.8).cgColor)
        context.setLineWidth(2)
        context.addPath(heartPath)
        context.strokePath()
    }
    
    private func drawStarIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 五角星图标
        let starSize = iconSize * 0.8
        let outerRadius = starSize * 0.4
        let innerRadius = outerRadius * 0.4
        
        context.setFillColor(UIColor.systemYellow.cgColor)
        
        // 绘制五角星
        let points = 5
        let angleStep = 2 * .pi / CGFloat(points)
        
        context.move(to: CGPoint(x: centerX, y: centerY - outerRadius))
        
        for i in 0..<points {
            let outerAngle = CGFloat(i) * angleStep - .pi / 2
            let innerAngle = outerAngle + angleStep / 2
            
            let outerX = centerX + cos(outerAngle) * outerRadius
            let outerY = centerY + sin(outerAngle) * outerRadius
            
            let innerX = centerX + cos(innerAngle) * innerRadius
            let innerY = centerY + sin(innerAngle) * innerRadius
            
            context.addLine(to: CGPoint(x: outerX, y: outerY))
            context.addLine(to: CGPoint(x: innerX, y: innerY))
        }
        
        context.closePath()
        context.fillPath()
        
        // 星星边框
        context.setStrokeColor(UIColor.systemOrange.cgColor)
        context.setLineWidth(2)
        context.strokePath()
    }
}
