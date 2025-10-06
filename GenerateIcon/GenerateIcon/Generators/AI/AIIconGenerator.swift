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
                    let image = self.renderSmartIcon(prompt: prompt, settings: settings)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - 智能图标生成
    private func renderSmartIcon(prompt: String, settings: AISettings) -> UIImage {
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 尝试匹配关键词到现有图标
            if let matchedIconType = matchKeywordsToIconType(prompt) {
                // 绘制匹配的图标
                drawMatchedIcon(in: cgContext, iconType: matchedIconType, size: size)
            } else {
                // 没有匹配到图标，显示文字
                drawTextIcon(in: cgContext, text: prompt, size: size, settings: settings)
            }
        }
    }
    
    // MARK: - 关键词匹配逻辑
    private func matchKeywordsToIconType(_ prompt: String) -> IconType? {
        let lowercasePrompt = prompt.lowercased()
        
        // 关键词映射表
        let keywordMappings: [String: IconType] = [
            // 基础图标
            "计算器": .calculator, "calculator": .calculator, "计算": .calculator,
            "鼠标": .mouse, "mouse": .mouse,
            "键盘": .keyboard, "keyboard": .keyboard, "打字": .keyboard,
            "显示器": .monitor, "monitor": .monitor, "屏幕": .monitor, "电脑": .monitor,
            "定位": .location, "location": .location, "位置": .location, "地图": .location,
            
            // 办公图标
            "文档": .document, "document": .document, "文件": .document, "text": .document,
            "文件夹": .folder, "folder": .folder, "目录": .folder,
            "打印机": .printer, "printer": .printer, "打印": .printer,
            "日历": .calendar, "calendar": .calendar, "日期": .calendar, "时间": .calendar,
            
            // 通信图标
            "电话": .phone, "phone": .phone, "通话": .phone, "call": .phone,
            "邮件": .email, "email": .email, "邮箱": .email, "mail": .email,
            "消息": .message, "message": .message, "聊天": .message, "chat": .message,
            "视频": .video, "video": .video, "视频通话": .video, "videoCall": .video,
            
            // 媒体图标
            "音乐": .music, "music": .music, "歌曲": .music, "audio": .music,
            "相机": .camera, "camera": .camera, "拍照": .camera, "cameraPhoto": .camera,
            "相册": .photo, "photo": .photo, "图片": .photo, "image": .photo,
            "视频播放器": .videoPlayer, "videoPlayer": .videoPlayer, "播放器": .videoPlayer, "player": .videoPlayer,
            
            // 工具图标
            "设置": .settings, "settings": .settings, "配置": .settings, "preference": .settings,
            "搜索": .search, "search": .search, "查找": .search, "find": .search,
            "收藏": .heart, "heart": .heart, "喜欢": .heart, "favorite": .heart, "爱心": .heart,
            "评分": .star, "star": .star, "星星": .star, "rating": .star, "评价": .star
        ]
        
        // 检查关键词匹配
        for (keyword, iconType) in keywordMappings {
            if lowercasePrompt.contains(keyword) {
                return iconType
            }
        }
        
        return nil
    }
    
    // MARK: - 绘制匹配的图标
    private func drawMatchedIcon(in context: CGContext, iconType: IconType, size: CGSize) {
        // 绘制渐变背景
        let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
        
        // 根据图标类型绘制对应的图标
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.4
        
        switch iconType {
        case .calculator:
            drawCalculatorIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .mouse:
            drawMouseIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .keyboard:
            drawKeyboardIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .monitor:
            drawMonitorIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .location:
            drawLocationIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .document:
            drawDocumentIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .folder:
            drawFolderIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .printer:
            drawPrinterIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .calendar:
            drawCalendarIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .phone:
            drawPhoneIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .email:
            drawEmailIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .message:
            drawMessageIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .video:
            drawVideoIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .music:
            drawMusicIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .camera:
            drawCameraIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .photo:
            drawPhotoIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .videoPlayer:
            drawVideoPlayerIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .settings:
            drawSettingsIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .search:
            drawSearchIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .heart:
            drawHeartIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .star:
            drawStarIcon(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
        case .custom:
            // AI生成图标，绘制机器人
            drawRobotIcon(in: context, center: CGPoint(x: centerX, y: centerY), radius: iconSize / 2)
        }
    }
    
    // MARK: - 绘制文字图标（当没有匹配到图标时）
    private func drawTextIcon(in context: CGContext, text: String, size: CGSize, settings: AISettings) {
        // 绘制渐变背景
        let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
        
        // 绘制文字
        drawText(in: context, text: text, size: size, settings: settings)
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
    
    // MARK: - 各种图标的绘制方法
    private func drawCalculatorIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 计算器主体
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(rect)
        
        // 屏幕
        let screenRect = CGRect(x: rect.minX + size*0.1, y: rect.minY + size*0.1, width: size*0.8, height: size*0.2)
        context.setFillColor(UIColor.black.cgColor)
        context.fill(screenRect)
        
        // 按钮网格
        let buttonSize = size * 0.15
        let buttonSpacing = size * 0.05
        let startY = rect.minY + size * 0.4
        
        for row in 0..<4 {
            for col in 0..<4 {
                let x = rect.minX + size*0.1 + CGFloat(col) * (buttonSize + buttonSpacing)
                let y = startY + CGFloat(row) * (buttonSize + buttonSpacing)
                let buttonRect = CGRect(x: x, y: y, width: buttonSize, height: buttonSize)
                
                context.setFillColor(UIColor.systemBlue.cgColor)
                context.fill(buttonRect)
            }
        }
    }
    
    private func drawMouseIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 鼠标主体
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fillEllipse(in: rect)
        
        // 滚轮
        let wheelRect = CGRect(x: center.x - size*0.1, y: center.y - size*0.3, width: size*0.2, height: size*0.1)
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(wheelRect)
        
        // 鼠标线
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(size * 0.05)
        context.move(to: CGPoint(x: rect.maxX, y: center.y))
        context.addLine(to: CGPoint(x: rect.maxX + size*0.3, y: center.y))
        context.strokePath()
    }
    
    private func drawKeyboardIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 键盘主体
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(rect)
        
        // 按键
        let keySize = size * 0.08
        let keySpacing = size * 0.02
        
        for row in 0..<4 {
            for col in 0..<6 {
                let x = rect.minX + size*0.1 + CGFloat(col) * (keySize + keySpacing)
                let y = rect.minY + size*0.2 + CGFloat(row) * (keySize + keySpacing)
                let keyRect = CGRect(x: x, y: y, width: keySize, height: keySize)
                
                context.setFillColor(UIColor.white.cgColor)
                context.fill(keyRect)
            }
        }
    }
    
    private func drawMonitorIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 显示器屏幕
        let screenRect = CGRect(x: rect.minX + size*0.1, y: rect.minY + size*0.1, width: size*0.8, height: size*0.6)
        context.setFillColor(UIColor.black.cgColor)
        context.fill(screenRect)
        
        // 显示器边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(size * 0.05)
        context.stroke(screenRect)
        
        // 显示器底座
        let baseRect = CGRect(x: center.x - size*0.2, y: rect.maxY - size*0.2, width: size*0.4, height: size*0.1)
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(baseRect)
    }
    
    private func drawLocationIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let radius = size * 0.3
        
        // 定位图标（大头针）
        context.setFillColor(UIColor.systemRed.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2))
        
        // 中心点
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - radius*0.3, y: center.y - radius*0.3, width: radius*0.6, height: radius*0.6))
    }
    
    private func drawDocumentIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 文档主体
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // 文档边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(size * 0.05)
        context.stroke(rect)
        
        // 文档内容线条
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(size * 0.02)
        
        for i in 1..<4 {
            let y = rect.minY + size * CGFloat(i) * 0.2
            context.move(to: CGPoint(x: rect.minX + size*0.1, y: y))
            context.addLine(to: CGPoint(x: rect.maxX - size*0.1, y: y))
        }
        context.strokePath()
    }
    
    private func drawFolderIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 文件夹主体
        context.setFillColor(UIColor.systemYellow.cgColor)
        context.fill(rect)
        
        // 文件夹标签
        let tabRect = CGRect(x: rect.minX + size*0.1, y: rect.minY, width: size*0.4, height: size*0.2)
        context.setFillColor(UIColor.systemOrange.cgColor)
        context.fill(tabRect)
        
        // 边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(size * 0.05)
        context.stroke(rect)
        context.stroke(tabRect)
    }
    
    private func drawPrinterIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 打印机主体
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(rect)
        
        // 纸张出口
        let paperRect = CGRect(x: rect.minX + size*0.2, y: rect.minY, width: size*0.6, height: size*0.1)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(paperRect)
        
        // 控制面板
        let panelRect = CGRect(x: rect.minX + size*0.1, y: rect.minY + size*0.1, width: size*0.8, height: size*0.2)
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(panelRect)
    }
    
    private func drawCalendarIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 日历主体
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // 日历边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(size * 0.05)
        context.stroke(rect)
        
        // 日历网格
        context.setStrokeColor(UIColor.systemGray2.cgColor)
        context.setLineWidth(size * 0.02)
        
        // 水平线
        for i in 1..<6 {
            let y = rect.minY + size * CGFloat(i) * 0.15
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        
        // 垂直线
        for i in 1..<7 {
            let x = rect.minX + size * CGFloat(i) * 0.15
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        context.strokePath()
    }
    
    private func drawPhoneIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 电话主体
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(rect)
        
        // 听筒
        let receiverRect = CGRect(x: rect.minX + size*0.1, y: rect.minY + size*0.1, width: size*0.8, height: size*0.3)
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(receiverRect)
        
        // 话筒
        let micRect = CGRect(x: rect.minX + size*0.1, y: rect.maxY - size*0.4, width: size*0.8, height: size*0.3)
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(micRect)
    }
    
    private func drawEmailIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 信封
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(rect)
        
        // 信封内容
        let contentRect = CGRect(x: rect.minX + size*0.1, y: rect.minY + size*0.1, width: size*0.8, height: size*0.8)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(contentRect)
        
        // 信封边框
        context.setStrokeColor(UIColor.systemGray.cgColor)
        context.setLineWidth(size * 0.05)
        context.stroke(rect)
    }
    
    private func drawMessageIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 消息气泡
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fillEllipse(in: rect)
        
        // 消息尾巴
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: rect.maxX - size*0.2, y: rect.maxY))
        tailPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY + size*0.2))
        tailPath.addLine(to: CGPoint(x: rect.maxX - size*0.1, y: rect.maxY))
        tailPath.closeSubpath()
        
        context.addPath(tailPath)
        context.fillPath()
    }
    
    private func drawVideoIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 摄像头
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fillEllipse(in: rect)
        
        // 镜头
        let lensRect = CGRect(x: center.x - size*0.2, y: center.y - size*0.2, width: size*0.4, height: size*0.4)
        context.setFillColor(UIColor.black.cgColor)
        context.fillEllipse(in: lensRect)
        
        // 镜头中心
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - size*0.1, y: center.y - size*0.1, width: size*0.2, height: size*0.2))
    }
    
    private func drawMusicIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 音符
        context.setFillColor(UIColor.systemPurple.cgColor)
        
        // 音符杆
        context.setStrokeColor(UIColor.systemPurple.cgColor)
        context.setLineWidth(size * 0.1)
        context.move(to: CGPoint(x: center.x + size*0.2, y: rect.minY))
        context.addLine(to: CGPoint(x: center.x + size*0.2, y: rect.maxY))
        context.strokePath()
        
        // 音符头
        context.fillEllipse(in: CGRect(x: center.x - size*0.1, y: rect.minY, width: size*0.2, height: size*0.2))
        
        // 音符尾
        context.move(to: CGPoint(x: center.x + size*0.2, y: rect.minY))
        context.addCurve(to: CGPoint(x: center.x + size*0.4, y: rect.minY + size*0.2),
                        control1: CGPoint(x: center.x + size*0.3, y: rect.minY),
                        control2: CGPoint(x: center.x + size*0.4, y: rect.minY + size*0.1))
        context.strokePath()
    }
    
    private func drawCameraIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 相机主体
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fill(rect)
        
        // 镜头
        let lensRect = CGRect(x: center.x - size*0.2, y: center.y - size*0.2, width: size*0.4, height: size*0.4)
        context.setFillColor(UIColor.black.cgColor)
        context.fillEllipse(in: lensRect)
        
        // 镜头中心
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - size*0.1, y: center.y - size*0.1, width: size*0.2, height: size*0.2))
        
        // 闪光灯
        let flashRect = CGRect(x: rect.minX + size*0.1, y: rect.minY + size*0.1, width: size*0.15, height: size*0.1)
        context.setFillColor(UIColor.systemYellow.cgColor)
        context.fill(flashRect)
    }
    
    private func drawPhotoIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 相框
        context.setFillColor(UIColor.systemBrown.cgColor)
        context.fill(rect)
        
        // 照片
        let photoRect = CGRect(x: rect.minX + size*0.1, y: rect.minY + size*0.1, width: size*0.8, height: size*0.8)
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(photoRect)
        
        // 照片内容（简单的山景）
        context.setFillColor(UIColor.systemGreen.cgColor)
        context.fill(CGRect(x: photoRect.minX, y: photoRect.maxY - size*0.2, width: photoRect.width, height: size*0.2))
        
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(CGRect(x: photoRect.minX, y: photoRect.minY, width: photoRect.width, height: photoRect.height - size*0.2))
    }
    
    private func drawVideoPlayerIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let rect = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        
        // 播放器主体
        context.setFillColor(UIColor.black.cgColor)
        context.fill(rect)
        
        // 播放按钮（三角形）
        let triangleSize = size * 0.3
        let trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: center.x - triangleSize*0.3, y: center.y - triangleSize*0.5))
        trianglePath.addLine(to: CGPoint(x: center.x - triangleSize*0.3, y: center.y + triangleSize*0.5))
        trianglePath.addLine(to: CGPoint(x: center.x + triangleSize*0.7, y: center.y))
        trianglePath.closeSubpath()
        
        context.setFillColor(UIColor.white.cgColor)
        context.addPath(trianglePath)
        context.fillPath()
    }
    
    private func drawSettingsIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let radius = size * 0.4
        
        // 齿轮外圈
        context.setFillColor(UIColor.systemGray.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2))
        
        // 齿轮内圈
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - radius*0.6, y: center.y - radius*0.6, width: radius*1.2, height: radius*1.2))
        
        // 中心圆
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - radius*0.2, y: center.y - radius*0.2, width: radius*0.4, height: radius*0.4))
    }
    
    private func drawSearchIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let radius = size * 0.3
        
        // 放大镜外圈
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(size * 0.1)
        context.strokeEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2))
        
        // 放大镜手柄
        let handleLength = size * 0.3
        context.move(to: CGPoint(x: center.x + radius*0.7, y: center.y + radius*0.7))
        context.addLine(to: CGPoint(x: center.x + radius*0.7 + handleLength, y: center.y + radius*0.7 + handleLength))
        context.strokePath()
    }
    
    private func drawHeartIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        // 全新的爱心绘制方法 - 使用数学心形公式
        let heartSize = size * 1.17  // 增大爱心尺寸 (0.9 * 1.3 = 1.17)
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
            let actualX = center.x + x * scale
            let actualY = center.y + y * scale
            
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
    }
    
    private func drawStarIcon(in context: CGContext, center: CGPoint, size: CGFloat) {
        let radius = size * 0.4
        
        // 五角星
        context.setFillColor(UIColor.systemYellow.cgColor)
        
        let starPath = CGMutablePath()
        let outerRadius = radius
        let innerRadius = radius * 0.4
        
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5 - .pi / 2
            let currentRadius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * currentRadius
            let y = center.y + CGFloat(sin(angle)) * currentRadius
            
            if i == 0 {
                starPath.move(to: CGPoint(x: x, y: y))
            } else {
                starPath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        starPath.closeSubpath()
        
        context.addPath(starPath)
        context.fillPath()
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
