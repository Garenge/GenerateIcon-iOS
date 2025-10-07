import Foundation
import SwiftUI
import UIKit
import Combine

// MARK: - 图标生成服务
class IconGeneratorService: ObservableObject {
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    
    private let fileManager = FileManagerService()
    
    init() {
        // 初始化
    }
    
    // MARK: - 生成图标
    func generateIcon(
        type: IconType,
        size: CGSize,
        settings: IconSettings
    ) async throws -> UIImage {
        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
        }
        
        defer {
            Task { @MainActor in
                isGenerating = false
                generationProgress = 0.0
            }
        }
        
        // 模拟生成进度
        await updateProgress(0.2)
        
        let generator = getGenerator(for: type)
        let icon = try await generator.generateIcon(size: size, settings: settings)
        
        await updateProgress(0.8)
        
        // 应用背景和效果
        let finalIcon = try await applyBackgroundAndEffects(
            icon: icon,
            size: size,
            settings: settings
        )
        
        await updateProgress(1.0)
        
        return finalIcon
    }
    
    // MARK: - 生成预览
    func generatePreview(
        type: IconType,
        size: CGSize,
        settings: IconSettings
    ) async throws -> UIImage {
        print("🎨 Generating preview for type: \(type.name)")
        
        let generator = getGenerator(for: type)
        print("🎨 Generator created, calling generateIcon...")
        
        let icon = try await generator.generateIcon(size: size, settings: settings)
        print("🎨 Icon generated, applying background and effects...")
        
        let finalIcon = try await applyBackgroundAndEffects(
            icon: icon,
            size: size,
            settings: settings
        )
        
        print("🎨 Preview generation completed for type: \(type.name)")
        return finalIcon
    }

    // MARK: - 组合自定义图标与背景用于预览（例如AI生成的图片）
    func composePreview(
        with icon: UIImage,
        size: CGSize,
        settings: IconSettings
    ) async throws -> UIImage {
        return try await applyBackgroundAndEffects(
            icon: icon,
            size: size,
            settings: settings
        )
    }
    
    // MARK: - 生成iOS图标集
    func generateIOSIconSet(
        type: IconType,
        settings: IconSettings
    ) async throws -> [URL] {
        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
        }
        
        defer {
            Task { @MainActor in
                isGenerating = false
                generationProgress = 0.0
            }
        }
        
        var urls: [URL] = []
        let iosSizes = SizePreset.iosSizes
        
        for (index, preset) in iosSizes.enumerated() {
            let size = CGSize(width: preset.size, height: preset.size)
            let icon = try await generateIcon(type: type, size: size, settings: settings)
            
            if let url = try await fileManager.saveIcon(
                icon,
                name: preset.name,
                size: size
            ) {
                urls.append(url)
            }
            
            await updateProgress(Double(index + 1) / Double(iosSizes.count))
        }
        
        return urls
    }
    
    // MARK: - 私有方法
    private func getGenerator(for type: IconType) -> IconGenerator {
        print("🔧 Getting generator for type: \(type.name)")
        
        switch type {
        // 基础图标
        case .calculator:
            print("🔧 Using CalculatorIconGenerator")
            return CalculatorIconGenerator()
        case .mouse:
            print("🔧 Using MouseIconGenerator")
            return MouseIconGenerator()
        case .keyboard:
            print("🔧 Using KeyboardIconGenerator")
            return KeyboardIconGenerator()
        case .monitor:
            print("🔧 Using MonitorIconGenerator")
            return MonitorIconGenerator()
        case .location:
            print("🔧 Using LocationIconGenerator")
            return LocationIconGenerator()
        
        // 办公图标
        case .document, .folder, .printer, .calendar:
            print("🔧 Using DocumentIconGenerator for \(type.name)")
            return DocumentIconGenerator(iconType: type)
        
        // 通信图标
        case .phone, .email, .message, .video:
            print("🔧 Using CommunicationIconGenerator for \(type.name)")
            return CommunicationIconGenerator(iconType: type)
        
        // 媒体图标
        case .music, .camera, .photo, .videoPlayer:
            print("🔧 Using MediaIconGenerator for \(type.name)")
            return MediaIconGenerator(iconType: type)
        
        // 工具图标
        case .settings, .search, .heart, .star:
            print("🔧 Using ToolsIconGenerator for \(type.name)")
            return ToolsIconGenerator(iconType: type)
        
        // AI生成
        case .custom:
            print("🔧 Using AIIconGenerator")
            return AIIconGenerator()
        }
    }
    
    private func applyBackgroundAndEffects(
        icon: UIImage,
        size: CGSize,
        settings: IconSettings
    ) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let finalIcon = self.renderIconWithBackground(
                        icon: icon,
                        size: size,
                        settings: settings
                    )
                    continuation.resume(returning: finalIcon)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func renderIconWithBackground(
        icon: UIImage,
        size: CGSize,
        settings: IconSettings
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 根据分辨率调整设置
            let adjustedSettings = adjustSettingsForResolution(settings: settings, size: size)
            
            // 绘制外框背景
            if adjustedSettings.backgroundAPadding > 0 {
                let outerRect = CGRect(
                    x: 0,
                    y: 0,
                    width: size.width,
                    height: size.height
                )
                
                cgContext.setFillColor(adjustedSettings.backgroundAColor.color.cgColor!)
                cgContext.fill(outerRect)
            }
            
            // 计算图标区域
            let iconArea = calculateIconArea(size: size, settings: adjustedSettings)
            
            // 绘制底图
            drawBackground(
                in: cgContext,
                rect: iconArea,
                settings: adjustedSettings
            )
            
            // 绘制阴影
            if adjustedSettings.shadowIntensity > 0 {
                drawShadow(
                    in: cgContext,
                    rect: iconArea,
                    intensity: adjustedSettings.shadowIntensity
                )
            }
            
            // 绘制图标
            let iconRect = calculateIconRect(
                in: iconArea,
                iconSize: icon.size,
                padding: adjustedSettings.iconPadding
            )
            
            icon.draw(in: iconRect)
        }
    }
    
    private func calculateIconArea(size: CGSize, settings: IconSettings) -> CGRect {
        let padding = settings.backgroundAPadding
        return CGRect(
            x: padding,
            y: padding,
            width: size.width - padding * 2,
            height: size.height - padding * 2
        )
    }
    
    private func drawBackground(
        in context: CGContext,
        rect: CGRect,
        settings: IconSettings
    ) {
        context.setFillColor(settings.backgroundColor.color.cgColor!)
        
        switch settings.backgroundShape {
        case .circle:
            context.fillEllipse(in: rect)
        case .rounded:
            let path = UIBezierPath(
                roundedRect: rect,
                cornerRadius: settings.cornerRadius
            )
            context.addPath(path.cgPath)
            context.fillPath()
        case .square:
            context.fill(rect)
        }
        
        // 绘制边框
        if settings.borderWidth > 0 {
            context.setStrokeColor(settings.borderColor.color.cgColor!)
            context.setLineWidth(settings.borderWidth)
            
            switch settings.backgroundShape {
            case .circle:
                context.strokeEllipse(in: rect)
            case .rounded:
                let path = UIBezierPath(
                    roundedRect: rect,
                    cornerRadius: settings.cornerRadius
                )
                context.addPath(path.cgPath)
                context.strokePath()
            case .square:
                context.stroke(rect)
            }
        }
    }
    
    private func drawShadow(
        in context: CGContext,
        rect: CGRect,
        intensity: CGFloat
    ) {
        context.setShadow(
            offset: CGSize(width: 0, height: intensity * 0.1),
            blur: intensity * 0.2,
            color: UIColor.black.withAlphaComponent(0.3).cgColor
        )
    }
    
    private func calculateIconRect(
        in area: CGRect,
        iconSize: CGSize,
        padding: CGFloat
    ) -> CGRect {
        let availableWidth = area.width - padding * 2
        let availableHeight = area.height - padding * 2
        
        let scale = min(
            availableWidth / iconSize.width,
            availableHeight / iconSize.height
        )
        
        let scaledSize = CGSize(
            width: iconSize.width * scale,
            height: iconSize.height * scale
        )
        
        return CGRect(
            x: area.midX - scaledSize.width / 2,
            y: area.midY - scaledSize.height / 2,
            width: scaledSize.width,
            height: scaledSize.height
        )
    }
    
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            generationProgress = progress
        }
    }
    
    // MARK: - 分辨率调整方法
    private func adjustSettingsForResolution(settings: IconSettings, size: CGSize) -> IconSettings {
        // 计算缩放比例，以256x256为基准
        let baseSize: CGFloat = 256
        let scale = min(size.width, size.height) / baseSize
        
        var adjustedSettings = settings
        
        // 调整圆角半径
        adjustedSettings.cornerRadius = settings.cornerRadius * scale
        
        // 调整图标内边距
        adjustedSettings.iconPadding = settings.iconPadding * scale
        
        // 调整阴影强度
        adjustedSettings.shadowIntensity = settings.shadowIntensity * scale
        
        // 调整边框宽度
        adjustedSettings.borderWidth = settings.borderWidth * scale
        
        // 调整外框设置
        adjustedSettings.backgroundABorderWidth = settings.backgroundABorderWidth * scale
        adjustedSettings.backgroundAPadding = settings.backgroundAPadding * scale
        
        return adjustedSettings
    }
}

// MARK: - 图标生成器协议
protocol IconGenerator {
    func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage
}

// MARK: - 基础图标生成器
class BaseIconGenerator: IconGenerator {
    func generateIcon(size: CGSize, settings: IconSettings) async throws -> UIImage {
        throw IconGenerationError.notImplemented
    }
}

// MARK: - 错误类型
enum IconGenerationError: Error, LocalizedError {
    case notImplemented
    case invalidSize
    case generationFailed
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "图标生成器未实现"
        case .invalidSize:
            return "无效的图标尺寸"
        case .generationFailed:
            return "图标生成失败"
        }
    }
}
