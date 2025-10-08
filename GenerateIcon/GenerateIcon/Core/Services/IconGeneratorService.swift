import Foundation
import SwiftUI
import UIKit
import Combine

// MARK: - 图标生成服务
class IconGeneratorService: ObservableObject {
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    
    // MARK: - 生成预览
    func generatePreview(
        iconContent: IconContentViewModel,
        previewConfig: PreviewConfigViewModel
    ) async throws -> UIImage {
        print("🔄 IconGeneratorService: generatePreview called with contentType=\(iconContent.contentType), presetType=\(iconContent.selectedPresetType.displayName)")
        print("🔄 IconGeneratorService: previewConfig size=\(previewConfig.previewSize)")
        
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
        
        let finalImage = try await renderThreeLayerIcon(
            iconContent: iconContent,
            previewConfig: previewConfig
        )
        
        await updateProgress(1.0)
        
        print("🔄 IconGeneratorService: generatePreview completed successfully, image size=\(finalImage.size)")
        return finalImage
    }
    
    // MARK: - 生成图标（兼容旧版本接口）
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
    
    // MARK: - 生成预览（兼容旧版本接口）
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
        let fileManager = FileManagerService()
        
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
    
    // MARK: - 渲染三层图标
    private func renderThreeLayerIcon(
        iconContent: IconContentViewModel,
        previewConfig: PreviewConfigViewModel
    ) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.renderIconWithThreeLayers(
                    iconContent: iconContent,
                    previewConfig: previewConfig
                )
                continuation.resume(returning: image)
            }
        }
    }
    
    private func renderIconWithThreeLayers(
        iconContent: IconContentViewModel,
        previewConfig: PreviewConfigViewModel
    ) -> UIImage {
        print("🔄 IconGeneratorService: renderIconWithThreeLayers STARTED!")
        
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false  // 支持透明度
        format.scale = 1.0    // 使用设备像素比例
        
        print("🔄 IconGeneratorService: renderIconWithThreeLayers - format.opaque=\(format.opaque)")
        print("🔄 IconGeneratorService: ViewA background=\(previewConfig.viewABackgroundColor)")
        print("🔄 IconGeneratorService: ViewB background=\(previewConfig.viewBBackgroundColor)")
        
        let renderer = UIGraphicsImageRenderer(size: previewConfig.previewSize, format: format)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置高质量渲染
            cgContext.setShouldAntialias(true)
            cgContext.setAllowsAntialiasing(true)
            cgContext.interpolationQuality = .high
            
            // 根据分辨率调整设置
            let scale = min(previewConfig.previewSize.width, previewConfig.previewSize.height) / 256.0
            
            // MARK: - ViewA: 最底图层
            drawViewA(in: cgContext, previewConfig: previewConfig, scale: scale)
            
            // MARK: - ViewB: 容器图层
            let viewBArea = drawViewB(in: cgContext, previewConfig: previewConfig, scale: scale)
            
            // MARK: - ViewC: 图标层
            drawViewC(in: cgContext, iconContent: iconContent, previewConfig: previewConfig, scale: scale, viewBArea: viewBArea)
        }
    }
    
    // MARK: - 绘制ViewA (最底图)
    private func drawViewA(in context: CGContext, previewConfig: PreviewConfigViewModel, scale: CGFloat) {
        let outerRect = CGRect(
            x: 0,
            y: 0,
            width: previewConfig.previewSize.width,
            height: previewConfig.previewSize.height
        )
        
        // 绘制ViewA背景
        if previewConfig.viewABackgroundColor != .clear {
            context.setFillColor(previewConfig.viewABackgroundColor.cgColor!)
            context.fill(outerRect)
        }
        
        // 绘制ViewA边框
        if previewConfig.viewABorderWidth > 0 && previewConfig.viewABorderColor != .clear {
            context.setStrokeColor(previewConfig.viewABorderColor.cgColor!)
            context.setLineWidth(previewConfig.viewABorderWidth * scale)
            context.stroke(outerRect)
        }
    }
    
    // MARK: - 绘制ViewB (容器图)
    private func drawViewB(in context: CGContext, previewConfig: PreviewConfigViewModel, scale: CGFloat) -> CGRect {
        let padding = previewConfig.viewAPadding * scale
        let viewBArea = CGRect(
            x: padding,
            y: padding,
            width: previewConfig.previewSize.width - padding * 2,
            height: previewConfig.previewSize.height - padding * 2
        )
        
        // 绘制ViewB背景
        if previewConfig.viewBBackgroundColor != .clear {
            context.setFillColor(previewConfig.viewBBackgroundColor.cgColor!)
            
            let cornerRadius = previewConfig.viewBCornerRadius * scale
            if cornerRadius > 0 {
                let path = UIBezierPath(roundedRect: viewBArea, cornerRadius: cornerRadius)
                context.addPath(path.cgPath)
                context.fillPath()
            } else {
                context.fill(viewBArea)
            }
        }
        
        // 绘制ViewB阴影
        if previewConfig.viewBShadowIntensity > 0 {
            context.setShadow(
                offset: CGSize(width: 0, height: previewConfig.viewBShadowIntensity * scale * 0.1),
                blur: previewConfig.viewBShadowIntensity * scale * 0.2,
                color: UIColor.black.withAlphaComponent(0.3).cgColor
            )
        }
        
        // 绘制ViewB边框
        if previewConfig.viewBBorderWidth > 0 && previewConfig.viewBBorderColor != .clear {
            context.setStrokeColor(previewConfig.viewBBorderColor.cgColor!)
            context.setLineWidth(previewConfig.viewBBorderWidth * scale)
            
            let cornerRadius = previewConfig.viewBCornerRadius * scale
            if cornerRadius > 0 {
                let path = UIBezierPath(roundedRect: viewBArea, cornerRadius: cornerRadius)
                context.addPath(path.cgPath)
                context.strokePath()
            } else {
                context.stroke(viewBArea)
            }
        }
        
        return viewBArea
    }
    
    // MARK: - 绘制ViewC (图标)
    private func drawViewC(
        in context: CGContext,
        iconContent: IconContentViewModel,
        previewConfig: PreviewConfigViewModel,
        scale: CGFloat,
        viewBArea: CGRect
    ) {
        print("🔄 IconGeneratorService: drawViewC called with contentType=\(iconContent.contentType), presetType=\(iconContent.selectedPresetType.displayName)")
        
        let padding = previewConfig.viewBPadding * scale
        let iconArea = CGRect(
            x: viewBArea.minX + padding,
            y: viewBArea.minY + padding,
            width: viewBArea.width - padding * 2,
            height: viewBArea.height - padding * 2
        )
        
        // 生成图标内容
        let iconImage: UIImage
        switch iconContent.contentType {
        case .preset:
            iconImage = generatePresetIcon(type: iconContent.selectedPresetType, size: iconArea.size)
        case .custom:
            if let customIcon = iconContent.customImage {
                iconImage = customIcon
            } else {
                iconImage = generatePresetIcon(type: .calculator, size: iconArea.size)
            }
        case .text:
            iconImage = generateTextIcon(config: iconContent.textConfig, size: iconArea.size)
        }
        
        // 计算图标在ViewC中的位置
        let iconRect = calculateIconRect(
            in: iconArea,
            iconSize: iconImage.size,
            scale: previewConfig.iconScale,
            rotation: previewConfig.iconRotation,
            opacity: previewConfig.iconOpacity
        )
        
        // 绘制图标
        iconImage.draw(in: iconRect)
    }
    
    // MARK: - 生成文字图标
    private func generateTextIcon(config: TextIconConfigViewModel, size: CGSize) -> UIImage {
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
            
            // 计算字体大小
            let fontSize = config.effectiveFontSize * (min(size.width, size.height) / 256.0)
            let font = UIFont(name: config.fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: config.uiFontWeight)
            
            // 设置文字属性
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: config.textColor.cgColor!
            ]
            
            // 计算文字位置
            let text = config.text.isEmpty ? "TXT" : config.text
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            // 绘制文字
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    // MARK: - 生成预设图标
    private func generatePresetIcon(type: IconType, size: CGSize) -> UIImage {
        print("🔄 IconGeneratorService: Generating preset icon for type=\(type.displayName), size=\(size)")
        
        // 使用专门的生成器
        let generator = getGenerator(for: type)
        
        // 创建默认设置
        let settings = IconSettings()
        
        // 同步调用生成器
        var result: UIImage?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                result = try await generator.generateIcon(size: size, settings: settings)
            } catch let generatorError {
                error = generatorError
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let error = error {
            print("🔄 IconGeneratorService: Generator failed, falling back to simple drawing: \(error)")
            // 如果生成器失败，回退到简单的绘制
            return generateSimpleIcon(type: type, size: size)
        }
        
        return result ?? generateSimpleIcon(type: type, size: size)
    }
    
    // MARK: - 生成简单图标（回退方案）
    private func generateSimpleIcon(type: IconType, size: CGSize) -> UIImage {
        print("🔄 IconGeneratorService: Generating simple icon for type=\(type.displayName), size=\(size)")
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
            
            // 根据图标类型绘制不同的图标
            drawPresetIconContent(in: cgContext, type: type, size: size)
        }
    }
    
    // MARK: - 绘制预设图标内容
    private func drawPresetIconContent(in context: CGContext, type: IconType, size: CGSize) {
        print("🔄 IconGeneratorService: Drawing preset icon content for type=\(type.displayName), size=\(size)")
        let centerX = size.width / 2
        let centerY = size.height / 2
        let iconSize = min(size.width, size.height) * 0.6
        
        context.setFillColor(UIColor.white.cgColor)
        
        switch type {
        case .calculator:
            // 绘制计算器图标
            print("🔄 IconGeneratorService: Drawing calculator icon")
            drawCalculator(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .heart:
            // 绘制心形图标
            print("🔄 IconGeneratorService: Drawing heart icon")
            drawHeart(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .star:
            // 绘制星形图标
            print("🔄 IconGeneratorService: Drawing star icon")
            drawStar(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .mouse:
            // 绘制鼠标图标
            print("🔄 IconGeneratorService: Drawing mouse icon")
            drawMouse(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .keyboard:
            // 绘制键盘图标
            print("🔄 IconGeneratorService: Drawing keyboard icon")
            drawKeyboard(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .monitor:
            // 绘制显示器图标
            print("🔄 IconGeneratorService: Drawing monitor icon")
            drawMonitor(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .location:
            // 绘制位置图标
            print("🔄 IconGeneratorService: Drawing location icon")
            drawLocation(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .document:
            // 绘制文档图标
            print("🔄 IconGeneratorService: Drawing document icon")
            drawDocument(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .folder:
            // 绘制文件夹图标
            print("🔄 IconGeneratorService: Drawing folder icon")
            drawFolder(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .phone:
            // 绘制电话图标
            print("🔄 IconGeneratorService: Drawing phone icon")
            drawPhone(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .email:
            // 绘制邮件图标
            print("🔄 IconGeneratorService: Drawing email icon")
            drawEmail(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .camera:
            // 绘制相机图标
            print("🔄 IconGeneratorService: Drawing camera icon")
            drawCamera(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .music:
            // 绘制音乐图标
            print("🔄 IconGeneratorService: Drawing music icon")
            drawMusic(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .settings:
            // 绘制设置图标
            print("🔄 IconGeneratorService: Drawing settings icon")
            drawSettings(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        case .search:
            // 绘制搜索图标
            print("🔄 IconGeneratorService: Drawing search icon")
            drawSearch(in: context, center: CGPoint(x: centerX, y: centerY), size: iconSize)
            
        default:
            // 默认绘制圆形
            print("🔄 IconGeneratorService: Drawing default circle icon")
            let circleRect = CGRect(
                x: centerX - iconSize/2,
                y: centerY - iconSize/2,
                width: iconSize,
                height: iconSize
            )
            context.fillEllipse(in: circleRect)
        }
    }
    
    // MARK: - 绘制计算器
    private func drawCalculator(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        let calculatorRect = CGRect(
            x: center.x - size/2,
            y: center.y - size/2,
            width: size,
            height: size
        )
        
        // 绘制计算器外框
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        context.fill(calculatorRect)
        context.stroke(calculatorRect)
        
        // 绘制屏幕
        let screenRect = CGRect(
            x: calculatorRect.minX + 8 * scale,
            y: calculatorRect.minY + 8 * scale,
            width: calculatorRect.width - 16 * scale,
            height: 20 * scale
        )
        context.setFillColor(UIColor.black.cgColor)
        context.fill(screenRect)
        
        // 绘制屏幕上的数字
        context.setFillColor(UIColor.white.cgColor)
        let numberText = "123"
        let font = UIFont.systemFont(ofSize: 8 * scale, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        let textSize = numberText.size(withAttributes: attributes)
        let textRect = CGRect(
            x: screenRect.maxX - textSize.width - 2 * scale,
            y: screenRect.minY + (screenRect.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        numberText.draw(in: textRect, withAttributes: attributes)
        
        // 绘制按钮
        let buttonSize = 12 * scale
        let buttonSpacing = 2 * scale
        let startX = calculatorRect.minX + 8 * scale
        let startY = screenRect.maxY + 8 * scale
        
        // 按钮颜色
        let numberButtonColor = UIColor.lightGray.cgColor
        let operatorButtonColor = UIColor.orange.cgColor
        
        // 绘制数字按钮 (1-9)
        for row in 0..<3 {
            for col in 0..<3 {
                let buttonRect = CGRect(
                    x: startX + CGFloat(col) * (buttonSize + buttonSpacing),
                    y: startY + CGFloat(row) * (buttonSize + buttonSpacing),
                    width: buttonSize,
                    height: buttonSize
                )
                
                context.setFillColor(numberButtonColor)
                context.fill(buttonRect)
                context.setStrokeColor(UIColor.black.cgColor)
                context.setLineWidth(1 * scale)
                context.stroke(buttonRect)
                
                // 绘制按钮数字
                let number = String(7 - row * 3 + col) // 7,8,9 -> 4,5,6 -> 1,2,3
                let buttonFont = UIFont.systemFont(ofSize: 6 * scale, weight: .bold)
                let buttonAttributes: [NSAttributedString.Key: Any] = [
                    .font: buttonFont,
                    .foregroundColor: UIColor.black
                ]
                let buttonTextSize = number.size(withAttributes: buttonAttributes)
                let buttonTextRect = CGRect(
                    x: buttonRect.minX + (buttonRect.width - buttonTextSize.width) / 2,
                    y: buttonRect.minY + (buttonRect.height - buttonTextSize.height) / 2,
                    width: buttonTextSize.width,
                    height: buttonTextSize.height
                )
                number.draw(in: buttonTextRect, withAttributes: buttonAttributes)
            }
        }
        
        // 绘制0按钮
        let zeroRect = CGRect(
            x: startX,
            y: startY + 3 * (buttonSize + buttonSpacing),
            width: buttonSize * 2 + buttonSpacing,
            height: buttonSize
        )
        context.setFillColor(numberButtonColor)
        context.fill(zeroRect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.stroke(zeroRect)
        
        let zeroFont = UIFont.systemFont(ofSize: 6 * scale, weight: .bold)
        let zeroAttributes: [NSAttributedString.Key: Any] = [
            .font: zeroFont,
            .foregroundColor: UIColor.black
        ]
        let zeroTextSize = "0".size(withAttributes: zeroAttributes)
        let zeroTextRect = CGRect(
            x: zeroRect.minX + (zeroRect.width - zeroTextSize.width) / 2,
            y: zeroRect.minY + (zeroRect.height - zeroTextSize.height) / 2,
            width: zeroTextSize.width,
            height: zeroTextSize.height
        )
        "0".draw(in: zeroTextRect, withAttributes: zeroAttributes)
        
        // 绘制运算符按钮
        let operators = ["+", "-", "×", "÷"]
        for (index, op) in operators.enumerated() {
            let opRect = CGRect(
                x: startX + 3 * (buttonSize + buttonSpacing),
                y: startY + CGFloat(index) * (buttonSize + buttonSpacing),
                width: buttonSize,
                height: buttonSize
            )
            
            context.setFillColor(operatorButtonColor)
            context.fill(opRect)
            context.setStrokeColor(UIColor.black.cgColor)
            context.stroke(opRect)
            
            // 绘制运算符
            let opFont = UIFont.systemFont(ofSize: 6 * scale, weight: .bold)
            let opAttributes: [NSAttributedString.Key: Any] = [
                .font: opFont,
                .foregroundColor: UIColor.white
            ]
            let opTextSize = op.size(withAttributes: opAttributes)
            let opTextRect = CGRect(
                x: opRect.minX + (opRect.width - opTextSize.width) / 2,
                y: opRect.minY + (opRect.height - opTextSize.height) / 2,
                width: opTextSize.width,
                height: opTextSize.height
            )
            op.draw(in: opTextRect, withAttributes: opAttributes)
        }
    }
    
    // MARK: - 绘制鼠标
    private func drawMouse(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 鼠标主体
        let mouseRect = CGRect(
            x: center.x - size * 0.4,
            y: center.y - size * 0.3,
            width: size * 0.8,
            height: size * 0.6
        )
        
        // 绘制鼠标主体
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        
        let mousePath = UIBezierPath(roundedRect: mouseRect, cornerRadius: 8 * scale)
        context.addPath(mousePath.cgPath)
        context.fillPath()
        context.addPath(mousePath.cgPath)
        context.strokePath()
        
        // 绘制滚轮
        let wheelRect = CGRect(
            x: center.x - 2 * scale,
            y: mouseRect.minY + 8 * scale,
            width: 4 * scale,
            height: 12 * scale
        )
        context.setFillColor(UIColor.black.cgColor)
        context.fill(wheelRect)
        
        // 绘制左右键分割线
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1 * scale)
        context.move(to: CGPoint(x: center.x, y: mouseRect.minY + 8 * scale))
        context.addLine(to: CGPoint(x: center.x, y: mouseRect.maxY - 8 * scale))
        context.strokePath()
        
        // 绘制鼠标线
        let cableLength = size * 0.8
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(3 * scale)
        context.move(to: CGPoint(x: mouseRect.maxX, y: mouseRect.minY + mouseRect.height * 0.3))
        
        // 绘制弯曲的鼠标线
        let controlPoint1 = CGPoint(x: mouseRect.maxX + cableLength * 0.3, y: mouseRect.minY)
        let controlPoint2 = CGPoint(x: mouseRect.maxX + cableLength * 0.7, y: mouseRect.minY - 10 * scale)
        let endPoint = CGPoint(x: mouseRect.maxX + cableLength, y: mouseRect.minY - 5 * scale)
        
        context.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
        context.strokePath()
    }
    
    // MARK: - 绘制键盘
    private func drawKeyboard(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 键盘主体
        let keyboardRect = CGRect(
            x: center.x - size * 0.5,
            y: center.y - size * 0.3,
            width: size,
            height: size * 0.6
        )
        
        // 绘制键盘主体
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        context.fill(keyboardRect)
        context.stroke(keyboardRect)
        
        // 绘制按键
        let keySize = 8 * scale
        let keySpacing = 2 * scale
        let startX = keyboardRect.minX + 8 * scale
        let startY = keyboardRect.minY + 8 * scale
        
        // 绘制字母键
        let letters = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        for (index, letter) in letters.enumerated() {
            let keyRect = CGRect(
                x: startX + CGFloat(index) * (keySize + keySpacing),
                y: startY,
                width: keySize,
                height: keySize
            )
            
            context.setFillColor(UIColor.lightGray.cgColor)
            context.fill(keyRect)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(1 * scale)
            context.stroke(keyRect)
            
            // 绘制字母
            let font = UIFont.systemFont(ofSize: 4 * scale, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black
            ]
            let textSize = letter.size(withAttributes: attributes)
            let textRect = CGRect(
                x: keyRect.minX + (keyRect.width - textSize.width) / 2,
                y: keyRect.minY + (keyRect.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            letter.draw(in: textRect, withAttributes: attributes)
        }
        
        // 绘制空格键
        let spaceRect = CGRect(
            x: startX + 2 * (keySize + keySpacing),
            y: startY + 2 * (keySize + keySpacing),
            width: 6 * (keySize + keySpacing),
            height: keySize
        )
        context.setFillColor(UIColor.lightGray.cgColor)
        context.fill(spaceRect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.stroke(spaceRect)
    }
    
    // MARK: - 绘制显示器
    private func drawMonitor(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 显示器屏幕
        let screenRect = CGRect(
            x: center.x - size * 0.4,
            y: center.y - size * 0.3,
            width: size * 0.8,
            height: size * 0.6
        )
        
        // 绘制屏幕
        context.setFillColor(UIColor.black.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(3 * scale)
        context.fill(screenRect)
        context.stroke(screenRect)
        
        // 绘制屏幕内容
        context.setFillColor(UIColor.green.cgColor)
        let contentRect = CGRect(
            x: screenRect.minX + 4 * scale,
            y: screenRect.minY + 4 * scale,
            width: screenRect.width - 8 * scale,
            height: screenRect.height - 8 * scale
        )
        context.fill(contentRect)
        
        // 绘制显示器底座
        let baseRect = CGRect(
            x: center.x - size * 0.2,
            y: screenRect.maxY,
            width: size * 0.4,
            height: size * 0.1
        )
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.fill(baseRect)
        context.stroke(baseRect)
        
        // 绘制支架
        let standRect = CGRect(
            x: center.x - size * 0.05,
            y: baseRect.maxY,
            width: size * 0.1,
            height: size * 0.15
        )
        context.fill(standRect)
        context.stroke(standRect)
    }
    
    // MARK: - 绘制位置图标
    private func drawLocation(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 绘制定位针
        let pinSize = size * 0.8
        let pinRect = CGRect(
            x: center.x - pinSize/2,
            y: center.y - pinSize/2,
            width: pinSize,
            height: pinSize
        )
        
        // 绘制定位针主体
        context.setFillColor(UIColor.red.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        
        let pinPath = UIBezierPath()
        pinPath.move(to: CGPoint(x: center.x, y: pinRect.minY))
        pinPath.addLine(to: CGPoint(x: pinRect.maxX - 8 * scale, y: pinRect.minY + pinSize * 0.3))
        pinPath.addLine(to: CGPoint(x: pinRect.maxX - 8 * scale, y: pinRect.maxY - 8 * scale))
        pinPath.addLine(to: CGPoint(x: pinRect.minX + 8 * scale, y: pinRect.maxY - 8 * scale))
        pinPath.addLine(to: CGPoint(x: pinRect.minX + 8 * scale, y: pinRect.minY + pinSize * 0.3))
        pinPath.close()
        
        context.addPath(pinPath.cgPath)
        context.fillPath()
        context.addPath(pinPath.cgPath)
        context.strokePath()
        
        // 绘制中心圆点
        let centerCircle = CGRect(
            x: center.x - 4 * scale,
            y: center.y - 4 * scale,
            width: 8 * scale,
            height: 8 * scale
        )
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: centerCircle)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokeEllipse(in: centerCircle)
    }
    
    // MARK: - 绘制文档
    private func drawDocument(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 文档主体
        let docRect = CGRect(
            x: center.x - size * 0.3,
            y: center.y - size * 0.4,
            width: size * 0.6,
            height: size * 0.8
        )
        
        // 绘制文档
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        context.fill(docRect)
        context.stroke(docRect)
        
        // 绘制折角
        let foldSize = size * 0.15
        let foldRect = CGRect(
            x: docRect.maxX - foldSize,
            y: docRect.minY,
            width: foldSize,
            height: foldSize
        )
        
        context.setFillColor(UIColor.lightGray.cgColor)
        context.fill(foldRect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.stroke(foldRect)
        
        // 绘制折角对角线
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1 * scale)
        context.move(to: CGPoint(x: foldRect.minX, y: foldRect.maxY))
        context.addLine(to: CGPoint(x: foldRect.maxX, y: foldRect.minY))
        context.strokePath()
        
        // 绘制文字行
        let lineHeight = 3 * scale
        let lineSpacing = 2 * scale
        let startY = docRect.minY + 8 * scale
        
        for i in 0..<4 {
            let lineRect = CGRect(
                x: docRect.minX + 4 * scale,
                y: startY + CGFloat(i) * (lineHeight + lineSpacing),
                width: docRect.width - 8 * scale,
                height: lineHeight
            )
            context.setFillColor(UIColor.black.cgColor)
            context.fill(lineRect)
        }
    }
    
    // MARK: - 绘制文件夹
    private func drawFolder(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 文件夹主体
        let folderRect = CGRect(
            x: center.x - size * 0.4,
            y: center.y - size * 0.3,
            width: size * 0.8,
            height: size * 0.6
        )
        
        // 绘制文件夹主体
        context.setFillColor(UIColor.yellow.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        context.fill(folderRect)
        context.stroke(folderRect)
        
        // 绘制文件夹标签
        let tabRect = CGRect(
            x: folderRect.minX + 8 * scale,
            y: folderRect.minY - 4 * scale,
            width: size * 0.3,
            height: 8 * scale
        )
        context.setFillColor(UIColor.yellow.cgColor)
        context.fill(tabRect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.stroke(tabRect)
        
        // 绘制文件夹内容线条
        let lineHeight = 2 * scale
        let lineSpacing = 3 * scale
        let startY = folderRect.minY + 8 * scale
        
        for i in 0..<3 {
            let lineRect = CGRect(
                x: folderRect.minX + 8 * scale,
                y: startY + CGFloat(i) * (lineHeight + lineSpacing),
                width: folderRect.width - 16 * scale,
                height: lineHeight
            )
            context.setFillColor(UIColor.black.cgColor)
            context.fill(lineRect)
        }
    }
    
    // MARK: - 绘制电话
    private func drawPhone(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 电话主体
        let phoneRect = CGRect(
            x: center.x - size * 0.25,
            y: center.y - size * 0.4,
            width: size * 0.5,
            height: size * 0.8
        )
        
        // 绘制电话主体
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        
        let phonePath = UIBezierPath(roundedRect: phoneRect, cornerRadius: 8 * scale)
        context.addPath(phonePath.cgPath)
        context.fillPath()
        context.addPath(phonePath.cgPath)
        context.strokePath()
        
        // 绘制屏幕
        let screenRect = CGRect(
            x: phoneRect.minX + 4 * scale,
            y: phoneRect.minY + 8 * scale,
            width: phoneRect.width - 8 * scale,
            height: phoneRect.height * 0.6
        )
        context.setFillColor(UIColor.black.cgColor)
        context.fill(screenRect)
        
        // 绘制数字键
        let keySize = 6 * scale
        let keySpacing = 2 * scale
        let startX = phoneRect.minX + 8 * scale
        let startY = screenRect.maxY + 4 * scale
        
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]
        for (index, number) in numbers.enumerated() {
            let row = index / 3
            let col = index % 3
            
            let keyRect = CGRect(
                x: startX + CGFloat(col) * (keySize + keySpacing),
                y: startY + CGFloat(row) * (keySize + keySpacing),
                width: keySize,
                height: keySize
            )
            
            context.setFillColor(UIColor.lightGray.cgColor)
            context.fill(keyRect)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(1 * scale)
            context.stroke(keyRect)
            
            // 绘制数字
            let font = UIFont.systemFont(ofSize: 4 * scale, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black
            ]
            let textSize = number.size(withAttributes: attributes)
            let textRect = CGRect(
                x: keyRect.minX + (keyRect.width - textSize.width) / 2,
                y: keyRect.minY + (keyRect.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            number.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    // MARK: - 绘制邮件
    private func drawEmail(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 信封主体
        let envelopeRect = CGRect(
            x: center.x - size * 0.4,
            y: center.y - size * 0.3,
            width: size * 0.8,
            height: size * 0.6
        )
        
        // 绘制信封
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        context.fill(envelopeRect)
        context.stroke(envelopeRect)
        
        // 绘制信封封口
        context.setFillColor(UIColor.lightGray.cgColor)
        let flapPath = UIBezierPath()
        flapPath.move(to: CGPoint(x: envelopeRect.minX, y: envelopeRect.minY))
        flapPath.addLine(to: CGPoint(x: envelopeRect.maxX, y: envelopeRect.minY))
        flapPath.addLine(to: CGPoint(x: center.x, y: envelopeRect.minY + envelopeRect.height * 0.3))
        flapPath.close()
        
        context.addPath(flapPath.cgPath)
        context.fillPath()
        context.setStrokeColor(UIColor.black.cgColor)
        context.addPath(flapPath.cgPath)
        context.strokePath()
        
        // 绘制邮票
        let stampRect = CGRect(
            x: envelopeRect.maxX - 12 * scale,
            y: envelopeRect.minY + 4 * scale,
            width: 8 * scale,
            height: 8 * scale
        )
        context.setFillColor(UIColor.red.cgColor)
        context.fill(stampRect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.stroke(stampRect)
    }
    
    // MARK: - 绘制相机
    private func drawCamera(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 相机主体
        let cameraRect = CGRect(
            x: center.x - size * 0.4,
            y: center.y - size * 0.3,
            width: size * 0.8,
            height: size * 0.6
        )
        
        // 绘制相机主体
        context.setFillColor(UIColor.black.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        context.fill(cameraRect)
        context.stroke(cameraRect)
        
        // 绘制镜头
        let lensRect = CGRect(
            x: center.x - size * 0.15,
            y: center.y - size * 0.15,
            width: size * 0.3,
            height: size * 0.3
        )
        context.setFillColor(UIColor.darkGray.cgColor)
        context.fillEllipse(in: lensRect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokeEllipse(in: lensRect)
        
        // 绘制镜头中心
        let centerRect = CGRect(
            x: center.x - size * 0.05,
            y: center.y - size * 0.05,
            width: size * 0.1,
            height: size * 0.1
        )
        context.setFillColor(UIColor.black.cgColor)
        context.fillEllipse(in: centerRect)
        
        // 绘制闪光灯
        let flashRect = CGRect(
            x: cameraRect.maxX - 8 * scale,
            y: cameraRect.minY + 4 * scale,
            width: 4 * scale,
            height: 4 * scale
        )
        context.setFillColor(UIColor.white.cgColor)
        context.fill(flashRect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.stroke(flashRect)
    }
    
    // MARK: - 绘制音乐
    private func drawMusic(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 绘制音符
        let noteSize = size * 0.8
        
        // 音符头部
        let headRect = CGRect(
            x: center.x - noteSize * 0.2,
            y: center.y - noteSize * 0.3,
            width: noteSize * 0.4,
            height: noteSize * 0.2
        )
        context.setFillColor(UIColor.black.cgColor)
        context.fillEllipse(in: headRect)
        
        // 音符杆
        let stemRect = CGRect(
            x: headRect.maxX - 2 * scale,
            y: headRect.minY,
            width: 4 * scale,
            height: noteSize * 0.6
        )
        context.fill(stemRect)
        
        // 音符旗
        let flagPath = UIBezierPath()
        flagPath.move(to: CGPoint(x: stemRect.maxX, y: stemRect.minY))
        flagPath.addCurve(
            to: CGPoint(x: stemRect.maxX + noteSize * 0.2, y: stemRect.minY + noteSize * 0.1),
            controlPoint1: CGPoint(x: stemRect.maxX + noteSize * 0.1, y: stemRect.minY - noteSize * 0.05),
            controlPoint2: CGPoint(x: stemRect.maxX + noteSize * 0.15, y: stemRect.minY + noteSize * 0.05)
        )
        flagPath.addCurve(
            to: CGPoint(x: stemRect.maxX, y: stemRect.minY + noteSize * 0.2),
            controlPoint1: CGPoint(x: stemRect.maxX + noteSize * 0.15, y: stemRect.minY + noteSize * 0.15),
            controlPoint2: CGPoint(x: stemRect.maxX + noteSize * 0.1, y: stemRect.minY + noteSize * 0.2)
        )
        flagPath.close()
        
        context.addPath(flagPath.cgPath)
        context.fillPath()
        
        // 绘制五线谱
        let staffY = center.y + noteSize * 0.2
        let staffWidth = noteSize * 0.8
        let staffStartX = center.x - staffWidth / 2
        
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1 * scale)
        
        for i in 0..<5 {
            let lineY = staffY + CGFloat(i) * 3 * scale
            context.move(to: CGPoint(x: staffStartX, y: lineY))
            context.addLine(to: CGPoint(x: staffStartX + staffWidth, y: lineY))
            context.strokePath()
        }
    }
    
    // MARK: - 绘制设置
    private func drawSettings(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 绘制齿轮
        let gearSize = size * 0.8
        let gearRect = CGRect(
            x: center.x - gearSize/2,
            y: center.y - gearSize/2,
            width: gearSize,
            height: gearSize
        )
        
        // 绘制齿轮主体
        context.setFillColor(UIColor.lightGray.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2 * scale)
        context.fillEllipse(in: gearRect)
        context.strokeEllipse(in: gearRect)
        
        // 绘制齿轮齿
        let toothCount = 8
        let toothLength = gearSize * 0.15
        let toothWidth = gearSize * 0.05
        
        for i in 0..<toothCount {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(toothCount)
            let toothX = center.x + cos(angle) * (gearSize/2 + toothLength/2)
            let toothY = center.y + sin(angle) * (gearSize/2 + toothLength/2)
            
            let toothRect = CGRect(
                x: toothX - toothWidth/2,
                y: toothY - toothLength/2,
                width: toothWidth,
                height: toothLength
            )
            context.fill(toothRect)
            context.stroke(toothRect)
        }
        
        // 绘制中心圆
        let centerCircle = CGRect(
            x: center.x - gearSize * 0.2,
            y: center.y - gearSize * 0.2,
            width: gearSize * 0.4,
            height: gearSize * 0.4
        )
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: centerCircle)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokeEllipse(in: centerCircle)
    }
    
    // MARK: - 绘制搜索
    private func drawSearch(in context: CGContext, center: CGPoint, size: CGFloat) {
        let scale = size / 100.0
        
        // 绘制放大镜
        let magnifierSize = size * 0.6
        let magnifierRect = CGRect(
            x: center.x - magnifierSize/2,
            y: center.y - magnifierSize/2,
            width: magnifierSize,
            height: magnifierSize
        )
        
        // 绘制放大镜边框
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(3 * scale)
        context.strokeEllipse(in: magnifierRect)
        
        // 绘制放大镜手柄
        let handleLength = magnifierSize * 0.4
        let handleStartX = magnifierRect.maxX - magnifierSize * 0.2
        let handleStartY = magnifierRect.maxY - magnifierSize * 0.2
        
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(4 * scale)
        context.move(to: CGPoint(x: handleStartX, y: handleStartY))
        context.addLine(to: CGPoint(x: handleStartX + handleLength, y: handleStartY + handleLength))
        context.strokePath()
        
        // 绘制搜索内容（小圆点）
        let dotSize = 2 * scale
        let dotSpacing = 4 * scale
        let startX = magnifierRect.minX + 8 * scale
        let startY = magnifierRect.minY + 8 * scale
        
        for i in 0..<3 {
            for j in 0..<3 {
                let dotRect = CGRect(
                    x: startX + CGFloat(j) * dotSpacing,
                    y: startY + CGFloat(i) * dotSpacing,
                    width: dotSize,
                    height: dotSize
                )
                context.setFillColor(UIColor.black.cgColor)
                context.fillEllipse(in: dotRect)
            }
        }
    }
    
    // MARK: - 绘制心形
    private func drawHeart(in context: CGContext, center: CGPoint, size: CGFloat) {
        let heartPath = UIBezierPath()
        let scale = size / 100.0
        
        heartPath.move(to: CGPoint(x: center.x, y: center.y + 20 * scale))
        heartPath.addCurve(
            to: CGPoint(x: center.x, y: center.y - 20 * scale),
            controlPoint1: CGPoint(x: center.x - 30 * scale, y: center.y - 10 * scale),
            controlPoint2: CGPoint(x: center.x, y: center.y - 30 * scale)
        )
        heartPath.addCurve(
            to: CGPoint(x: center.x, y: center.y + 20 * scale),
            controlPoint1: CGPoint(x: center.x, y: center.y - 30 * scale),
            controlPoint2: CGPoint(x: center.x + 30 * scale, y: center.y - 10 * scale)
        )
        heartPath.close()
        
        context.addPath(heartPath.cgPath)
        context.fillPath()
    }
    
    // MARK: - 绘制星形
    private func drawStar(in context: CGContext, center: CGPoint, size: CGFloat) {
        let starPath = UIBezierPath()
        let scale = size / 100.0
        let outerRadius = 40 * scale
        let innerRadius = 20 * scale
        
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5.0
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                starPath.move(to: CGPoint(x: x, y: y))
            } else {
                starPath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        starPath.close()
        
        context.addPath(starPath.cgPath)
        context.fillPath()
    }
    
    // MARK: - 计算图标位置
    private func calculateIconRect(
        in area: CGRect,
        iconSize: CGSize,
        scale: CGFloat,
        rotation: CGFloat,
        opacity: CGFloat
    ) -> CGRect {
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
    
    // MARK: - 更新进度
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            generationProgress = progress
        }
    }
    
    // MARK: - 获取生成器（兼容旧版本）
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
    
    // MARK: - 应用背景和效果（兼容旧版本）
    private func applyBackgroundAndEffects(
        icon: UIImage,
        size: CGSize,
        settings: IconSettings
    ) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let finalIcon = self.renderIconWithBackground(
                    icon: icon,
                    size: size,
                    settings: settings
                )
                continuation.resume(returning: finalIcon)
            }
        }
    }
    
    // MARK: - 渲染带背景的图标（兼容旧版本）
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
    
    // MARK: - 计算图标区域（兼容旧版本）
    private func calculateIconArea(size: CGSize, settings: IconSettings) -> CGRect {
        let padding = settings.backgroundAPadding
        return CGRect(
            x: padding,
            y: padding,
            width: size.width - padding * 2,
            height: size.height - padding * 2
        )
    }
    
    // MARK: - 绘制背景（兼容旧版本）
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
    
    // MARK: - 绘制阴影（兼容旧版本）
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
    
    // MARK: - 计算图标位置（兼容旧版本）
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
    
    // MARK: - 分辨率调整方法（兼容旧版本）
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
