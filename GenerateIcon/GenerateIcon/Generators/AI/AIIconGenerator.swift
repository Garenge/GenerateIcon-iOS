import Foundation
import SwiftUI
import UIKit

// MARK: - AI图标生成器
class AIIconGenerator: BaseIconGenerator {
    
    override func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let image = self.renderAIIcon(size: size, settings: settings)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func renderAIIcon(size: CGSize, settings: IconSettings) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制AI生成的图标内容
            drawAIContent(in: cgContext, size: size)
        }
    }
    
    private func drawAIContent(in context: CGContext, size: CGSize) {
        // 这里实现AI生成的具体逻辑
        // 目前先绘制一个简单的占位图标
        
        let centerX = size.width / 2
        let centerY = size.height / 2
        let radius = min(size.width, size.height) * 0.3
        
        // 绘制AI图标（机器人形状）
        drawRobotIcon(in: context, center: CGPoint(x: centerX, y: centerY), radius: radius)
    }
    
    private func drawRobotIcon(in context: CGContext, center: CGPoint, radius: CGFloat) {
        // 机器人头部
        let headRect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fillEllipse(in: headRect)
        
        // 机器人眼睛
        let eyeSize = radius * 0.2
        let leftEye = CGRect(
            x: center.x - radius * 0.4,
            y: center.y - radius * 0.3,
            width: eyeSize,
            height: eyeSize
        )
        let rightEye = CGRect(
            x: center.x + radius * 0.2,
            y: center.y - radius * 0.3,
            width: eyeSize,
            height: eyeSize
        )
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: leftEye)
        context.fillEllipse(in: rightEye)
        
        // 机器人嘴巴
        let mouthRect = CGRect(
            x: center.x - radius * 0.3,
            y: center.y + radius * 0.2,
            width: radius * 0.6,
            height: radius * 0.1
        )
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(mouthRect)
        
        // 机器人天线
        let antennaRect = CGRect(
            x: center.x - radius * 0.1,
            y: center.y - radius * 1.2,
            width: radius * 0.2,
            height: radius * 0.4
        )
        
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(antennaRect)
        
        // 天线顶部
        let antennaTop = CGRect(
            x: center.x - radius * 0.15,
            y: center.y - radius * 1.4,
            width: radius * 0.3,
            height: radius * 0.2
        )
        
        context.setFillColor(UIColor.systemOrange.cgColor)
        context.fillEllipse(in: antennaTop)
    }
}

// MARK: - AI服务协议
protocol AIService {
    func generateIcon(prompt: String, settings: AISettings) async throws -> UIImage
}

// MARK: - 本地AI服务实现
class LocalAIService: AIService {
    func generateIcon(prompt: String, settings: AISettings) async throws -> UIImage {
        // 这里实现本地AI生成逻辑
        // 可以使用Core ML或其他本地AI框架
        
        return try await generateTextBasedIcon(prompt: prompt, settings: settings)
    }
    
    private func generateTextBasedIcon(prompt: String, settings: AISettings) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let image = self.renderTextIcon(prompt: prompt, settings: settings)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func renderTextIcon(prompt: String, settings: AISettings) -> UIImage {
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 绘制渐变背景
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!
            
            cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
            
            // 绘制文字
            drawText(in: cgContext, text: prompt, size: size, settings: settings)
        }
    }
    
    private func drawText(in context: CGContext, text: String, size: CGSize, settings: AISettings) {
        let fontSize = settings.fontSize == .custom ? (settings.customFontSize ?? 100) : settings.fontSize.size
        let font = UIFont(name: settings.fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        
        // 确保文字颜色在渐变背景上可见
        let textColor = UIColor.white
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        // 处理文字内容，提取关键词
        let displayText = extractKeywords(from: text)
        
        let textSize = displayText.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        // 添加文字阴影效果
        context.setShadow(offset: CGSize(width: 2, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.5).cgColor)
        
        displayText.draw(in: textRect, withAttributes: attributes)
        
        // 清除阴影
        context.setShadow(offset: .zero, blur: 0, color: nil)
    }
    
    private func extractKeywords(from text: String) -> String {
        // 提取关键词，用于显示
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
            .prefix(3) // 最多取前3个词
        
        if words.isEmpty {
            return "AI"
        }
        
        return words.joined(separator: " ").uppercased()
    }
}

// MARK: - 网络AI服务实现
class NetworkAIService: AIService {
    private let apiKey: String
    private let baseURL: String
    
    init(apiKey: String, baseURL: String = "https://api.openai.com/v1") {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    func generateIcon(prompt: String, settings: AISettings) async throws -> UIImage {
        // 这里实现网络AI API调用
        // 可以使用OpenAI DALL-E或其他AI图像生成服务
        
        throw IconGenerationError.notImplemented
    }
}
