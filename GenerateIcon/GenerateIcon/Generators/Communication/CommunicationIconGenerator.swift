import Foundation
import SwiftUI
import UIKit

// MARK: - 通信图标生成器
class CommunicationIconGenerator: BaseIconGenerator {
    private let iconType: IconType
    
    init(iconType: IconType) {
        self.iconType = iconType
        super.init()
    }
    
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
            
            // 根据图标类型绘制不同的通信图标
            switch iconType {
            case .phone:
                drawPhoneIcon(in: cgContext, size: size)
            case .email:
                drawEmailIcon(in: cgContext, size: size)
            case .message:
                drawMessageIcon(in: cgContext, size: size)
            case .video:
                drawVideoIcon(in: cgContext, size: size)
            default:
                drawPhoneIcon(in: cgContext, size: size)
            }
        }
    }
    
    private func drawPhoneIcon(in context: CGContext, size: CGSize) {
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
    
    private func drawEmailIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 邮件信封
        let envelopeRect = CGRect(
            x: centerX - iconSize * 0.4,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.8,
            height: iconSize * 0.6
        )
        
        // 信封背景
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(envelopeRect)
        
        // 信封边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.stroke(envelopeRect)
        
        // 信封内容线条
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        
        // 水平线
        for i in 1..<3 {
            let y = envelopeRect.minY + envelopeRect.height * CGFloat(i) / 3
            context.move(to: CGPoint(x: envelopeRect.minX + 8, y: y))
            context.addLine(to: CGPoint(x: envelopeRect.maxX - 8, y: y))
        }
        context.strokePath()
        
        // 垂直线
        let centerX_envelope = envelopeRect.midX
        context.move(to: CGPoint(x: centerX_envelope, y: envelopeRect.minY + 8))
        context.addLine(to: CGPoint(x: centerX_envelope, y: envelopeRect.maxY - 8))
        context.strokePath()
    }
    
    private func drawMessageIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 消息气泡
        let bubbleRect = CGRect(
            x: centerX - iconSize * 0.4,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.8,
            height: iconSize * 0.6
        )
        
        // 气泡背景
        context.setFillColor(UIColor.systemGreen.cgColor)
        context.fillEllipse(in: bubbleRect)
        
        // 气泡边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.strokeEllipse(in: bubbleRect)
        
        // 消息内容
        context.setFillColor(UIColor.white.cgColor)
        
        // 三个点
        let dotSize: CGFloat = 4
        let dotSpacing: CGFloat = 8
        let startX = centerX - dotSpacing
        let startY = centerY
        
        for i in 0..<3 {
            let dotX = startX + CGFloat(i) * dotSpacing
            let dotRect = CGRect(x: dotX - dotSize/2, y: startY - dotSize/2, width: dotSize, height: dotSize)
            context.fillEllipse(in: dotRect)
        }
        
        // 气泡尾巴
        let tailSize: CGFloat = 8
        context.move(to: CGPoint(x: bubbleRect.minX + 20, y: bubbleRect.maxY))
        context.addLine(to: CGPoint(x: bubbleRect.minX + 20 - tailSize, y: bubbleRect.maxY + tailSize))
        context.addLine(to: CGPoint(x: bubbleRect.minX + 20 + tailSize, y: bubbleRect.maxY + tailSize))
        context.closePath()
        context.fillPath()
    }
    
    private func drawVideoIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 视频相机
        let cameraRect = CGRect(
            x: centerX - iconSize * 0.3,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.6,
            height: iconSize * 0.6
        )
        
        // 相机主体
        context.setFillColor(UIColor.systemRed.cgColor)
        context.fill(cameraRect)
        
        // 相机边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.stroke(cameraRect)
        
        // 镜头
        let lensSize = iconSize * 0.3
        let lensRect = CGRect(
            x: centerX - lensSize * 0.5,
            y: centerY - lensSize * 0.5,
            width: lensSize,
            height: lensSize
        )
        
        context.setFillColor(UIColor.black.cgColor)
        context.fillEllipse(in: lensRect)
        
        // 镜头边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        context.strokeEllipse(in: lensRect)
        
        // 闪光灯
        let flashSize: CGFloat = 6
        let flashRect = CGRect(
            x: cameraRect.maxX - 12,
            y: cameraRect.minY + 8,
            width: flashSize,
            height: flashSize
        )
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: flashRect)
    }
}
