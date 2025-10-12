import Foundation
import SwiftUI
import Combine

// MARK: - 统一的图标生成ViewModel
class IconGeneratorViewModel: ObservableObject {
    // MARK: - 核心状态
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var showingSaveConfirmation = false
    @Published var showingOpenPhotoLibraryAlert = false
    @Published var pendingImage: UIImage?
    @Published var lastGeneratedIcon: UIImage?
    @Published var errorMessage: String?
    
    // MARK: - 图标内容状态（整合自IconContentViewModel）
    @Published var contentType: IconContentType = .preset
    @Published var selectedPresetType: IconType = .calculator
    @Published var customImage: UIImage?
    @Published var textConfig: TextIconConfigViewModel = TextIconConfigViewModel()
    
    // MARK: - 预览配置状态（整合自PreviewConfigViewModel）
    @Published var viewABackgroundColor: Color = .clear
    @Published var viewABorderColor: Color = .clear
    @Published var viewACornerRadius: CGFloat = 0
    @Published var viewAPadding: CGFloat = 20
    @Published var viewABorderWidth: CGFloat = 0
    
    @Published var viewBBackgroundColor: Color = Color(red: 0.4, green: 0.49, blue: 0.92)
    @Published var viewBBorderColor: Color = .clear
    @Published var viewBCornerRadius: CGFloat = 40
    @Published var viewBPadding: CGFloat = 20
    @Published var viewBBorderWidth: CGFloat = 0
    @Published var viewBShadowIntensity: CGFloat = 20
    
    @Published var iconScale: CGFloat = 1.0
    @Published var iconRotation: CGFloat = 0
    @Published var iconOpacity: CGFloat = 1.0
    @Published var previewSize: CGSize = CGSize(width: 256, height: 256)
    
    // MARK: - 服务依赖
    private let iconGeneratorService = IconGeneratorService()
    private let fileManagerService = FileManagerService()
    private let settingsService = SettingsService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    // MARK: - 计算属性
    var currentIconImage: UIImage? {
        switch contentType {
        case .preset:
            return nil // 预设图标由生成服务处理
        case .custom:
            return customImage
        case .text:
            return nil // 文字图标由生成服务处理
        }
    }
    
    var isUsingPresetIcon: Bool {
        contentType == .preset
    }
    
    var isUsingCustomIcon: Bool {
        contentType == .custom && customImage != nil
    }
    
    var isUsingTextIcon: Bool {
        contentType == .text && textConfig.isEnabled
    }
    
    var isInAIMode: Bool {
        contentType == .custom && customImage != nil
    }
    
    // MARK: - 图标内容管理方法
    func setPresetIcon(_ type: IconType) {
        contentType = .preset
        selectedPresetType = type
        customImage = nil
        textConfig.disableTextIcon()
    }
    
    func setCustomIcon(_ image: UIImage?) {
        contentType = .custom
        customImage = image
        textConfig.disableTextIcon()
    }
    
    func setTextIcon(_ config: TextIconConfigViewModel) {
        contentType = .text
        textConfig = config
        customImage = nil
    }
    
    func clearAll() {
        contentType = .preset
        selectedPresetType = .calculator
        customImage = nil
        textConfig.resetToDefaults()
    }
    
    // MARK: - 预览配置管理方法
    func resetPreviewToDefaults() {
        // ViewA 默认设置
        viewABackgroundColor = .clear
        viewABorderColor = .clear
        viewACornerRadius = 0
        viewAPadding = 20
        viewABorderWidth = 0
        
        // ViewB 默认设置
        viewBBackgroundColor = Color(red: 0.4, green: 0.49, blue: 0.92)
        viewBBorderColor = .clear
        viewBCornerRadius = 40
        viewBPadding = 20
        viewBBorderWidth = 0
        viewBShadowIntensity = 20
        
        // ViewC 默认设置
        iconScale = 1.0
        iconRotation = 0
        iconOpacity = 1.0
    }
    
    // MARK: - 生成图标
    func generateIcon(
        type: IconType,
        size: CGSize,
        downloadType: DownloadType
    ) async {
        print("🔄 IconGeneratorViewModel: generateIcon开始 - type: \(type), size: \(size), downloadType: \(downloadType)")
        
        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
            errorMessage = nil
        }
        
        // 显示开始生成的Toast
        HUDToastManager.shared.showToast(message: "开始生成图标...", type: .info, duration: 1.5)
        
        do {
            if downloadType == .ios {
                print("🔄 IconGeneratorViewModel: 生成iOS图标集")
                try await generateIOSIconSet(type: type)
            } else {
                print("🔄 IconGeneratorViewModel: 生成单图")
                try await generateSingleIcon(type: type, size: size)
            }
        } catch {
            print("❌ IconGeneratorViewModel: 生成失败: \(error)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isGenerating = false
            }
            // 显示错误Toast
            HUDToastManager.shared.showErrorToast(message: "生成失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 生成AI图标
    func generateAIIcon(
        prompt: String,
        settings: AISettings
    ) async {
        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
            errorMessage = nil
        }
        
        // 显示AI生成开始的Toast
        HUDToastManager.shared.showToast(message: "AI正在生成图标...", type: .info, duration: 2.0)
        
        do {
            let aiService = LocalAIService()
            let aiIcon = try await aiService.generateIcon(prompt: prompt, settings: settings)
            
            await MainActor.run {
                self.lastGeneratedIcon = aiIcon
                self.isGenerating = false
            }
            
            // 生成完整的ViewA+ViewB+ViewC合成图标并保存到相册（AI图+当前背景设置）
            let finalIcon = try await iconGeneratorService.composePreview(
                with: aiIcon,
                size: CGSize(width: 1024, height: 1024), // 高分辨率保存
                settings: self.createIconSettings() // 使用当前的背景设置
            )
            try await fileManagerService.saveToPhotoLibrary(finalIcon)
            
            // 显示成功Toast
            HUDToastManager.shared.showSuccessToast(message: "AI图标生成并保存成功！")
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isGenerating = false
            }
            // 显示错误Toast
            HUDToastManager.shared.showErrorToast(message: "AI生成失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 清除AI图标
    func clearAIIcon() {
        lastGeneratedIcon = nil
        if contentType == .custom {
            contentType = .preset
            customImage = nil
        }
    }
    
    // MARK: - 生成预览
    func generatePreview(
        type: IconType,
        size: CGSize
    ) async -> UIImage? {
        do {
            return try await iconGeneratorService.generatePreview(
                type: type,
                size: size,
                settings: createIconSettings()
            )
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    // MARK: - 保存设置
    func saveSettings() {
        settingsService.saveSettings(createIconSettings())
    }
    
    // MARK: - 加载设置
    func loadSettings() {
        let settings = settingsService.loadSettings()
        applyIconSettings(settings)
    }
    
    // MARK: - 重置设置
    func resetSettings() {
        resetPreviewToDefaults()
        saveSettings()
    }
    
    // MARK: - 刷新预览
    func refreshPreview() {
        // 触发预览刷新
        print("🔄 IconGeneratorViewModel: Refreshing preview")
        
        // 立即触发UI更新
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    // MARK: - 私有方法
    private func setupBindings() {
        // 监听设置变化，自动保存
        Publishers.MergeMany(
            $viewACornerRadius,
            $viewAPadding,
            $viewABorderWidth,
            $viewBCornerRadius,
            $viewBPadding,
            $viewBBorderWidth,
            $viewBShadowIntensity,
            $iconScale,
            $iconRotation,
            $iconOpacity
        )
        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.saveSettings()
        }
        .store(in: &cancellables)
        
        // 监听颜色变化
        Publishers.MergeMany(
            $viewABackgroundColor,
            $viewABorderColor,
            $viewBBackgroundColor,
            $viewBBorderColor
        )
        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.saveSettings()
        }
        .store(in: &cancellables)
    }
    
    private func generateSingleIcon(type: IconType, size: CGSize) async throws {
        print("🔄 IconGeneratorViewModel: generateSingleIcon开始 - type: \(type), size: \(size)")
        
        let image = try await iconGeneratorService.generateIcon(
            type: type,
            size: size,
            settings: createIconSettings()
        )
        
        print("🔄 IconGeneratorViewModel: 图标生成完成，尺寸: \(image.size), scale: \(image.scale)")
        
        await MainActor.run {
            self.lastGeneratedIcon = image
            self.pendingImage = image
            self.isGenerating = false
            // 不显示确认弹窗，直接保存到相册
            self.showingSaveConfirmation = false
        }
        
        // 显示生成成功的Toast
        HUDToastManager.shared.showSuccessToast(message: "图标生成完成！")
        
        // 直接调用保存到相册
        print("🔄 IconGeneratorViewModel: 开始直接保存到相册")
        await confirmSaveToPhotoLibrary()
    }
    
    func confirmSaveToPhotoLibrary() async {
        print("🔄 IconGeneratorViewModel: 开始保存到相册流程")
        print("🔄 IconGeneratorViewModel: 当前contentType: \(contentType)")
        print("🔄 IconGeneratorViewModel: 当前selectedPresetType: \(selectedPresetType)")
        print("🔄 IconGeneratorViewModel: isInAIMode: \(isInAIMode)")
        print("🔄 IconGeneratorViewModel: lastGeneratedIcon: \(lastGeneratedIcon != nil ? "有" : "无")")
        
        // 显示保存开始的Toast
        HUDToastManager.shared.showToast(message: "正在保存到相册...", type: .info, duration: 1.5)
        
        do {
            let image: UIImage
            
            // 使用新的三层渲染方法，确保图标等比例放大到1024x1024
            let highResSize = CGSize(width: 1024, height: 1024)
            print("🔄 IconGeneratorViewModel: 目标尺寸: \(highResSize)")
            
            // 获取GlobalIconViewModels中的最新设置
            let globalViewModels = GlobalIconViewModels.shared
            let currentPreviewConfig = globalViewModels.previewConfig
            let currentIconContent = globalViewModels.iconContent
            
            print("🔄 IconGeneratorViewModel: 使用最新设置 - contentType: \(currentIconContent.contentType), presetType: \(currentIconContent.selectedPresetType)")
            print("🔄 IconGeneratorViewModel: 最新背景颜色 - viewA: \(currentPreviewConfig.viewABackgroundColor), viewB: \(currentPreviewConfig.viewBBackgroundColor)")
            print("🔄 IconGeneratorViewModel: 最新图标设置 - scale: \(currentPreviewConfig.iconScale), rotation: \(currentPreviewConfig.iconRotation), opacity: \(currentPreviewConfig.iconOpacity)")
            print("🔄 IconGeneratorViewModel: 最新文本设置 - text: '\(currentIconContent.textConfig.text)', color: \(currentIconContent.textConfig.textColor)")
            
            // 确保使用最新设置
            print("🔄 IconGeneratorViewModel: 同步最新设置到当前ViewModel")
            self.contentType = currentIconContent.contentType
            self.selectedPresetType = currentIconContent.selectedPresetType
            self.customImage = currentIconContent.customImage
            self.textConfig = currentIconContent.textConfig
            
            self.viewABackgroundColor = currentPreviewConfig.viewABackgroundColor
            self.viewABorderColor = currentPreviewConfig.viewABorderColor
            self.viewACornerRadius = currentPreviewConfig.viewACornerRadius
            self.viewAPadding = currentPreviewConfig.viewAPadding
            self.viewABorderWidth = currentPreviewConfig.viewABorderWidth
            
            self.viewBBackgroundColor = currentPreviewConfig.viewBBackgroundColor
            self.viewBBorderColor = currentPreviewConfig.viewBBorderColor
            self.viewBCornerRadius = currentPreviewConfig.viewBCornerRadius
            self.viewBPadding = currentPreviewConfig.viewBPadding
            self.viewBBorderWidth = currentPreviewConfig.viewBBorderWidth
            self.viewBShadowIntensity = currentPreviewConfig.viewBShadowIntensity
            
            self.iconScale = currentPreviewConfig.iconScale
            self.iconRotation = currentPreviewConfig.iconRotation
            self.iconOpacity = currentPreviewConfig.iconOpacity
            
            // 强制等待一小段时间，确保所有异步更新完成
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
            print("🔄 IconGeneratorViewModel: 等待异步更新完成")
            
            // 强制保存设置，确保最新设置已保存
            globalViewModels.saveSettings()
            print("🔄 IconGeneratorViewModel: 强制保存设置完成")
            
            // 直接使用GlobalIconViewModels中的对象，确保数据一致性
            let highResPreviewConfig = currentPreviewConfig
            highResPreviewConfig.previewSize = highResSize
            
            let highResIconContent = currentIconContent
            
            // 如果是AI模式，使用AI生成的图标
            if isInAIMode, let aiIcon = lastGeneratedIcon {
                print("🔄 IconGeneratorViewModel: 使用AI生成的图标")
                highResIconContent.customImage = aiIcon
                highResIconContent.contentType = .custom
            }
            
            print("🔄 IconGeneratorViewModel: 开始生成高分辨率图标")
            print("🔄 IconGeneratorViewModel: 高分辨率图标内容 - contentType: \(highResIconContent.contentType), presetType: \(highResIconContent.selectedPresetType)")
            print("🔄 IconGeneratorViewModel: 高分辨率预览配置 - viewA背景: \(highResPreviewConfig.viewABackgroundColor), viewB背景: \(highResPreviewConfig.viewBBackgroundColor)")
            print("🔄 IconGeneratorViewModel: 高分辨率图标设置 - scale: \(highResPreviewConfig.iconScale), rotation: \(highResPreviewConfig.iconRotation), opacity: \(highResPreviewConfig.iconOpacity)")
            print("🔄 IconGeneratorViewModel: 高分辨率文本设置 - text: '\(highResIconContent.textConfig.text)', color: \(highResIconContent.textConfig.textColor)")
            
            // 生成高分辨率图标
            image = try await iconGeneratorService.generatePreview(
                iconContent: highResIconContent,
                previewConfig: highResPreviewConfig
            )
            
            print("🔄 IconGeneratorViewModel: 图标生成完成，尺寸: \(image.size), scale: \(image.scale)")
            
            print("🔄 IconGeneratorViewModel: 开始保存到相册")
            try await fileManagerService.saveToPhotoLibrary(image)
            
            await MainActor.run {
                self.showingSaveConfirmation = false
                self.pendingImage = nil
                self.showingOpenPhotoLibraryAlert = true
            }
            // 显示保存成功Toast
            HUDToastManager.shared.showSuccessToast(message: "图标已保存到相册！")
        } catch {
            print("❌ IconGeneratorViewModel: 保存到相册失败: \(error)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            // 显示错误Toast
            HUDToastManager.shared.showErrorToast(message: "保存失败：\(error.localizedDescription)")
        }
    }
    
    func cancelSave() {
        showingSaveConfirmation = false
        pendingImage = nil
    }
    
    func openPhotoLibrary() {
        if let url = URL(string: "photos-redirect://") {
            UIApplication.shared.open(url)
        }
    }
    
    private func generateIOSIconSet(type: IconType) async throws {
        // 显示生成图标集的HUD
        HUDToastManager.shared.showLoading(message: "正在生成iOS图标集...")
        
        let urls = try await iconGeneratorService.generateIOSIconSet(
            type: type,
            settings: createIconSettings()
        )
        
        // 更新进度并显示压缩包生成
        HUDToastManager.shared.showProgress(progress: 0.7, message: "正在创建压缩包...")
        
        // 创建ZIP文件
        let zipURL = try await fileManagerService.createZipFile(icons: urls)
        
        await MainActor.run {
            self.isGenerating = false
        }
        
        // 隐藏HUD并显示压缩成功Toast
        HUDToastManager.shared.hideHUD()
        HUDToastManager.shared.showSuccessToast(message: "压缩完成！正在弹出系统分享...")
        
        // 分享ZIP文件
        await shareFile(url: zipURL)
    }
    
    private func shareFile(url: URL) async {
        await MainActor.run {
            // 使用UIActivityViewController分享文件
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                let activityViewController = UIActivityViewController(
                    activityItems: [url],
                    applicationActivities: nil
                )
                
                // 为iPad设置popover
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = window
                    popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                // 添加分享完成回调
                activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                    DispatchQueue.main.async {
                        if completed {
                            HUDToastManager.shared.showSuccessToast(message: "文件分享成功！")
                        } else if let error = error {
                            HUDToastManager.shared.showErrorToast(message: "分享失败：\(error.localizedDescription)")
                        }
                    }
                }
                
                rootViewController.present(activityViewController, animated: true)
            }
        }
    }
    
    // MARK: - 辅助方法
    private func createIconSettings() -> IconSettings {
        var settings = IconSettings()
        
        // 应用当前预览配置到IconSettings
        settings.backgroundColor = ColorData(color: viewBBackgroundColor)
        settings.cornerRadius = viewBCornerRadius
        settings.iconPadding = viewBPadding
        settings.shadowIntensity = viewBShadowIntensity
        settings.borderWidth = viewBBorderWidth
        settings.borderColor = ColorData(color: viewBBorderColor)
        
        settings.backgroundAColor = ColorData(color: viewABackgroundColor)
        settings.backgroundABorderWidth = viewABorderWidth
        settings.backgroundAPadding = viewAPadding
        
        return settings
    }
    
    private func applyIconSettings(_ settings: IconSettings) {
        viewBBackgroundColor = settings.backgroundColor.color
        viewBCornerRadius = settings.cornerRadius
        viewBPadding = settings.iconPadding
        viewBShadowIntensity = settings.shadowIntensity
        viewBBorderWidth = settings.borderWidth
        viewBBorderColor = settings.borderColor.color
        
        viewABackgroundColor = settings.backgroundAColor.color
        viewABorderWidth = settings.backgroundABorderWidth
        viewAPadding = settings.backgroundAPadding
    }
    
    // MARK: - 公开方法（用于绑定）
    func getIconSettings() -> IconSettings {
        return createIconSettings()
    }
    
    func updateIconSettings(_ settings: IconSettings) {
        applyIconSettings(settings)
    }
}

// MARK: - 错误处理
extension IconGeneratorViewModel {
    func clearError() {
        errorMessage = nil
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
}

// MARK: - 设置服务
class SettingsService: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "IconSettings"
    private let previewConfigKey = "PreviewConfig"
    private let iconContentKey = "IconContent"
    
    func saveSettings(_ settings: IconSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: settingsKey)
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    func loadSettings() -> IconSettings {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            return IconSettings()
        }
        
        do {
            return try JSONDecoder().decode(IconSettings.self, from: data)
        } catch {
            print("Failed to load settings: \(error)")
            return IconSettings()
        }
    }
    
    // MARK: - 保存预览配置
    func savePreviewConfig(_ config: PreviewConfigViewModel) {
        do {
            let data = try JSONEncoder().encode(config)
            userDefaults.set(data, forKey: previewConfigKey)
            print("💾 SettingsService: 预览配置保存成功")
        } catch {
            print("❌ SettingsService: 预览配置保存失败: \(error)")
        }
    }
    
    func loadPreviewConfig() -> PreviewConfigViewModel {
        guard let data = userDefaults.data(forKey: previewConfigKey) else {
            print("💾 SettingsService: 没有找到保存的预览配置，使用默认值")
            return PreviewConfigViewModel()
        }
        
        do {
            let config = try JSONDecoder().decode(PreviewConfigViewModel.self, from: data)
            print("💾 SettingsService: 预览配置加载成功")
            return config
        } catch {
            print("❌ SettingsService: 预览配置加载失败: \(error)")
            return PreviewConfigViewModel()
        }
    }
    
    // MARK: - 保存图标内容配置
    func saveIconContent(_ content: IconContentViewModel) {
        do {
            let data = try JSONEncoder().encode(content)
            userDefaults.set(data, forKey: iconContentKey)
            print("💾 SettingsService: 图标内容配置保存成功 - contentType: \(content.contentType), presetType: \(content.selectedPresetType)")
        } catch {
            print("❌ SettingsService: 图标内容配置保存失败: \(error)")
        }
    }
    
    func loadIconContent() -> IconContentViewModel {
        guard let data = userDefaults.data(forKey: iconContentKey) else {
            print("💾 SettingsService: 没有找到保存的图标内容配置，使用默认值")
            return IconContentViewModel()
        }
        
        do {
            let content = try JSONDecoder().decode(IconContentViewModel.self, from: data)
            print("💾 SettingsService: 图标内容配置加载成功 - contentType: \(content.contentType), presetType: \(content.selectedPresetType)")
            return content
        } catch {
            print("❌ SettingsService: 图标内容配置加载失败: \(error)")
            return IconContentViewModel()
        }
    }
    
    // MARK: - 清除所有设置
    func clearAllSettings() {
        userDefaults.removeObject(forKey: settingsKey)
        userDefaults.removeObject(forKey: previewConfigKey)
        userDefaults.removeObject(forKey: iconContentKey)
    }
}
