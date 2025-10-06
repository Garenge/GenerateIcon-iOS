import Foundation
import SwiftUI
import Combine

// MARK: - 图标生成视图模型
class IconGeneratorViewModel: ObservableObject {
    @Published var settings = IconSettings()
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var showingSaveConfirmation = false
    @Published var pendingImage: UIImage?
    @Published var lastGeneratedIcon: UIImage?
    @Published var errorMessage: String?
    
    private let iconGeneratorService = IconGeneratorService()
    private let fileManagerService = FileManagerService()
    private let settingsService = SettingsService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
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
                try await generateIOSIconSet(type: type, settings: settings)
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
            let image = try await aiService.generateIcon(prompt: prompt, settings: settings)
            
            await MainActor.run {
                self.lastGeneratedIcon = image
                self.isGenerating = false
            }
            
            // 保存到相册
            try await fileManagerService.saveToPhotoLibrary(image)
            
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
    
    // MARK: - 生成预览
    func generatePreview(
        type: IconType,
        size: CGSize
    ) async -> UIImage? {
        do {
            return try await iconGeneratorService.generatePreview(
                type: type,
                size: size,
                settings: settings
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
        settingsService.saveSettings(settings)
    }
    
    // MARK: - 加载设置
    func loadSettings() {
        settings = settingsService.loadSettings()
    }
    
    // MARK: - 重置设置
    func resetSettings() {
        settings = IconSettings()
        saveSettings()
    }
    
    // MARK: - 私有方法
    private func setupBindings() {
        // 监听设置变化，自动保存
        $settings
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
            settings: settings
        )
        
        await MainActor.run {
            self.lastGeneratedIcon = image
            self.pendingImage = image
            self.isGenerating = false
            self.showingSaveConfirmation = true
        }
    }
    
    func confirmSaveToPhotoLibrary() async {
        guard let image = pendingImage else { return }
        
        // 显示保存开始的Toast
        HUDToastManager.shared.showToast(message: "正在保存到相册...", type: .info, duration: 1.5)
        
        do {
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
    
    private func generateIOSIconSet(type: IconType, settings: IconSettings) async throws {
        // 显示生成图标集的HUD
        HUDToastManager.shared.showLoading(message: "正在生成iOS图标集...")
        
        let urls = try await iconGeneratorService.generateIOSIconSet(
            type: type,
            settings: settings
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
    
    func refreshPreview() {
        // 触发预览刷新
        print("🔄 IconGeneratorViewModel: Refreshing preview")
        objectWillChange.send()
        
        // 强制触发UI更新
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
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

// MARK: - 错误处理
extension IconGeneratorViewModel {
    func clearError() {
        errorMessage = nil
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
}
