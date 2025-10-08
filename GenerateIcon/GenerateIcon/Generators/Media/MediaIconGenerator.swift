import Foundation
import SwiftUI
import UIKit

// MARK: - 媒体图标生成器
class MediaIconGenerator: BaseIconGenerator {
    private let iconType: IconType
    
    init(iconType: IconType) {
        self.iconType = iconType
        super.init()
    }
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.renderMediaIcon(size: size, settings: settings)
                continuation.resume(returning: image)
            }
        }
    }
    
    private func renderMediaIcon(size: CGSize, settings: IconSettings) -> UIImage {
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
            
            // 根据图标类型绘制不同的媒体图标
            switch iconType {
            case .music:
                drawMusicIcon(in: cgContext, size: size)
            case .camera:
                drawCameraIcon(in: cgContext, size: size)
            case .photo:
                drawPhotoIcon(in: cgContext, size: size)
            case .videoPlayer:
                drawVideoPlayerIcon(in: cgContext, size: size)
            default:
                drawMusicIcon(in: cgContext, size: size)
            }
        }
    }
    
    private func drawMusicIcon(in context: CGContext, size: CGSize) {
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
    
    private func drawCameraIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 相机主体
        let cameraRect = CGRect(
            x: centerX - iconSize * 0.3,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.6,
            height: iconSize * 0.6
        )
        
        // 相机背景
        context.setFillColor(UIColor.systemGray.cgColor)
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
    
    private func drawPhotoIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 相册图标
        let albumRect = CGRect(
            x: centerX - iconSize * 0.4,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.8,
            height: iconSize * 0.6
        )
        
        // 相册背景
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(albumRect)
        
        // 相册边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.stroke(albumRect)
        
        // 照片内容
        let photoSize = iconSize * 0.4
        let photoRect = CGRect(
            x: centerX - photoSize * 0.5,
            y: centerY - photoSize * 0.5,
            width: photoSize,
            height: photoSize
        )
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(photoRect)
        
        // 照片边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(2)
        context.stroke(photoRect)
        
        // 照片内容线条
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(1)
        
        // 水平线
        for i in 1..<3 {
            let y = photoRect.minY + photoRect.height * CGFloat(i) / 3
            context.move(to: CGPoint(x: photoRect.minX + 4, y: y))
            context.addLine(to: CGPoint(x: photoRect.maxX - 4, y: y))
        }
        context.strokePath()
    }
    
    private func drawVideoPlayerIcon(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        // 视频播放器
        let playerRect = CGRect(
            x: centerX - iconSize * 0.4,
            y: centerY - iconSize * 0.3,
            width: iconSize * 0.8,
            height: iconSize * 0.6
        )
        
        // 播放器背景
        context.setFillColor(UIColor.black.cgColor)
        context.fill(playerRect)
        
        // 播放器边框
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.stroke(playerRect)
        
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
        
        // 进度条
        let barWidth = iconSize * 0.6
        let barHeight = iconSize * 0.05
        let barX = centerX - barWidth * 0.5
        let barY = centerY + iconSize * 0.2
        
        let barRect = CGRect(x: barX, y: barY, width: barWidth, height: barHeight)
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(barRect)
        
        // 进度指示器
        let progressRect = CGRect(x: barX, y: barY, width: barWidth * 0.6, height: barHeight)
        context.setFillColor(UIColor.systemRed.cgColor)
        context.fill(progressRect)
    }
}
