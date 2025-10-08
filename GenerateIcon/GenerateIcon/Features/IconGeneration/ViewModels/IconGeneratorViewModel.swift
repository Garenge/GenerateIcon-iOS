import Foundation
import SwiftUI
import Combine

// MARK: - 统一的图标生成ViewModel
class IconGeneratorViewModel: ObservableObject {
    // MARK: - 核心状态
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var showingSaveConfirmation = false
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
    @Published var viewAPadding: CGFloat = 0
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
        viewAPadding = 0
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
        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
            errorMessage = nil
        }
        
        // 显示开始生成的Toast
        HUDToastManager.shared.showToast(message: "开始生成图标...", type: .info, duration: 1.5)
        
        do {
            if downloadType == .ios {
                try await generateIOSIconSet(type: type)
            } else {
                try await generateSingleIcon(type: type, size: size)
            }
        } catch {
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
        let image = try await iconGeneratorService.generateIcon(
            type: type,
            size: size,
            settings: createIconSettings()
        )
        
        await MainActor.run {
            self.lastGeneratedIcon = image
            self.pendingImage = image
            self.isGenerating = false
            self.showingSaveConfirmation = true
        }
    }
    
    func confirmSaveToPhotoLibrary() async {
        // 显示保存开始的Toast
        HUDToastManager.shared.showToast(message: "正在保存到相册...", type: .info, duration: 1.5)
        
        do {
            let image: UIImage
            
            if isInAIMode, let aiIcon = lastGeneratedIcon {
                // AI模式：保存AI图+当前背景设置的合成图（ViewA+ViewB+ViewC）
                image = try await iconGeneratorService.composePreview(
                    with: aiIcon,
                    size: CGSize(width: 1024, height: 1024), // 高分辨率保存
                    settings: createIconSettings() // 使用当前的背景设置
                )
            } else if let pendingImage = pendingImage {
                // 预设模式：保存预设图+当前背景设置的合成图（ViewA+ViewB+ViewC）
                image = try await iconGeneratorService.composePreview(
                    with: pendingImage,
                    size: CGSize(width: 1024, height: 1024), // 高分辨率保存
                    settings: createIconSettings() // 使用当前的背景设置
                )
            } else {
                // 兜底：生成当前预设图+背景设置的合成图
                let presetIcon = try await iconGeneratorService.generateIcon(
                    type: selectedPresetType,
                    size: CGSize(width: 1024, height: 1024),
                    settings: IconSettings() // 生成纯预设图
                )
                image = try await iconGeneratorService.composePreview(
                    with: presetIcon,
                    size: CGSize(width: 1024, height: 1024),
                    settings: createIconSettings() // 应用当前背景设置
                )
            }
            
            try await fileManagerService.saveToPhotoLibrary(image)
            await MainActor.run {
                self.showingSaveConfirmation = false
                self.pendingImage = nil
            }
            // 显示成功Toast
            HUDToastManager.shared.showSuccessToast(message: "图标已保存到相册！")
        } catch {
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
        
        // 隐藏HUD并显示成功Toast
        HUDToastManager.shared.hideHUD()
        HUDToastManager.shared.showSuccessToast(message: "iOS图标集生成完成！")
        
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
}
