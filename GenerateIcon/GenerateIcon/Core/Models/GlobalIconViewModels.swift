import Foundation
import SwiftUI
import Combine

// MARK: - 全局图标ViewModel管理器
class GlobalIconViewModels: ObservableObject {
    static let shared = GlobalIconViewModels()
    
    // MARK: - 统一的ViewModel实例
    @Published var iconGenerator: IconGeneratorViewModel
    
    // MARK: - 持久的兼容性实例
    @Published var iconContent: IconContentViewModel
    @Published var previewConfig: PreviewConfigViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.iconGenerator = IconGeneratorViewModel()
        self.iconContent = IconContentViewModel()
        self.previewConfig = PreviewConfigViewModel()
        
        print("🔄 GlobalIconViewModels: Initializing with iconGenerator objectId=\(ObjectIdentifier(iconGenerator))")
        print("🔄 GlobalIconViewModels: Initializing with iconContent objectId=\(ObjectIdentifier(iconContent))")
        print("🔄 GlobalIconViewModels: Initializing with previewConfig objectId=\(ObjectIdentifier(previewConfig))")
        print("🔄 GlobalIconViewModels: Initial iconGenerator contentType=\(iconGenerator.contentType), presetType=\(iconGenerator.selectedPresetType.displayName)")
        
        // 加载保存的设置
        loadSettings()
        
        // 先同步一次初始数据
        syncInitialData()
        
        setupBindings()
    }
    
    // MARK: - 同步初始数据
    private func syncInitialData() {
        print("🔄 GlobalIconViewModels: Syncing initial data")
        
        // 同步iconContent
        iconContent.contentType = iconGenerator.contentType
        iconContent.selectedPresetType = iconGenerator.selectedPresetType
        iconContent.customImage = iconGenerator.customImage
        // 手动同步textConfig的属性
        iconContent.textConfig.isEnabled = iconGenerator.textConfig.isEnabled
        iconContent.textConfig.text = iconGenerator.textConfig.text
        iconContent.textConfig.fontSize = iconGenerator.textConfig.fontSize
        iconContent.textConfig.fontFamily = iconGenerator.textConfig.fontFamily
        iconContent.textConfig.textStyle = iconGenerator.textConfig.textStyle
        iconContent.textConfig.textColor = iconGenerator.textConfig.textColor
        iconContent.textConfig.customFontSize = iconGenerator.textConfig.customFontSize
        iconContent.textConfig.maxLength = iconGenerator.textConfig.maxLength
        iconContent.textConfig.textWrap = iconGenerator.textConfig.textWrap
        
        // 同步previewConfig
        previewConfig.viewABackgroundColor = iconGenerator.viewABackgroundColor
        previewConfig.viewABorderColor = iconGenerator.viewABorderColor
        previewConfig.viewACornerRadius = iconGenerator.viewACornerRadius
        previewConfig.viewAPadding = iconGenerator.viewAPadding
        previewConfig.viewABorderWidth = iconGenerator.viewABorderWidth
        previewConfig.viewBBackgroundColor = iconGenerator.viewBBackgroundColor
        previewConfig.viewBBorderColor = iconGenerator.viewBBorderColor
        previewConfig.viewBCornerRadius = iconGenerator.viewBCornerRadius
        previewConfig.viewBPadding = iconGenerator.viewBPadding
        previewConfig.viewBBorderWidth = iconGenerator.viewBBorderWidth
        previewConfig.viewBShadowIntensity = iconGenerator.viewBShadowIntensity
        previewConfig.iconScale = iconGenerator.iconScale
        previewConfig.iconRotation = iconGenerator.iconRotation
        previewConfig.iconOpacity = iconGenerator.iconOpacity
        previewConfig.previewSize = iconGenerator.previewSize
        
        print("🔄 GlobalIconViewModels: Initial sync completed - iconContent contentType=\(iconContent.contentType), presetType=\(iconContent.selectedPresetType.displayName)")
        print("🔄 GlobalIconViewModels: Initial sync completed - previewConfig size=\(previewConfig.previewSize)")
    }
    
    // MARK: - 设置绑定
    private func setupBindings() {
        // 监听iconGenerator的变化，同步到iconContent
        iconGenerator.$contentType
            .assign(to: \.contentType, on: iconContent)
            .store(in: &cancellables)
        
        iconGenerator.$selectedPresetType
            .assign(to: \.selectedPresetType, on: iconContent)
            .store(in: &cancellables)
        
        iconGenerator.$customImage
            .assign(to: \.customImage, on: iconContent)
            .store(in: &cancellables)
        
        // textConfig 不能直接绑定，因为它是@Published属性
        // 我们通过监听textConfig的变化来同步
        iconGenerator.$textConfig
            .sink { [weak self] newTextConfig in
                // 手动同步textConfig的属性
                self?.iconContent.textConfig.isEnabled = newTextConfig.isEnabled
                self?.iconContent.textConfig.text = newTextConfig.text
                self?.iconContent.textConfig.fontSize = newTextConfig.fontSize
                self?.iconContent.textConfig.fontFamily = newTextConfig.fontFamily
                self?.iconContent.textConfig.textStyle = newTextConfig.textStyle
                self?.iconContent.textConfig.textColor = newTextConfig.textColor
                self?.iconContent.textConfig.customFontSize = newTextConfig.customFontSize
                self?.iconContent.textConfig.maxLength = newTextConfig.maxLength
                self?.iconContent.textConfig.textWrap = newTextConfig.textWrap
            }
            .store(in: &cancellables)
        
        // 监听iconGenerator的变化，同步到previewConfig
        iconGenerator.$viewABackgroundColor
            .assign(to: \.viewABackgroundColor, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewABorderColor
            .assign(to: \.viewABorderColor, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewACornerRadius
            .assign(to: \.viewACornerRadius, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewAPadding
            .assign(to: \.viewAPadding, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewABorderWidth
            .assign(to: \.viewABorderWidth, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewBBackgroundColor
            .assign(to: \.viewBBackgroundColor, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewBBorderColor
            .assign(to: \.viewBBorderColor, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewBCornerRadius
            .assign(to: \.viewBCornerRadius, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewBPadding
            .assign(to: \.viewBPadding, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewBBorderWidth
            .assign(to: \.viewBBorderWidth, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$viewBShadowIntensity
            .assign(to: \.viewBShadowIntensity, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$iconScale
            .assign(to: \.iconScale, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$iconRotation
            .assign(to: \.iconRotation, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$iconOpacity
            .assign(to: \.iconOpacity, on: previewConfig)
            .store(in: &cancellables)
        
        iconGenerator.$previewSize
            .assign(to: \.previewSize, on: previewConfig)
            .store(in: &cancellables)
        
        // 监听设置变化，自动保存（减少延迟，提高响应性）
        iconContent.$contentType
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: contentType变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        iconContent.$selectedPresetType
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: selectedPresetType变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        previewConfig.$viewABackgroundColor
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: viewABackgroundColor变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        previewConfig.$viewBBackgroundColor
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: viewBBackgroundColor变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        previewConfig.$viewBCornerRadius
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: viewBCornerRadius变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        previewConfig.$viewBPadding
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: viewBPadding变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        previewConfig.$iconScale
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: iconScale变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        previewConfig.$iconRotation
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: iconRotation变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        previewConfig.$iconOpacity
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: iconOpacity变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        // 监听textConfig的变化
        iconContent.textConfig.$isEnabled
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: textConfig.isEnabled变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        iconContent.textConfig.$text
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: textConfig.text变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        iconContent.textConfig.$fontSize
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: textConfig.fontSize变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        iconContent.textConfig.$textColor
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                print("💾 GlobalIconViewModels: textConfig.textColor变化，保存设置")
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        print("🔄 GlobalIconViewModels: Bindings setup completed")
    }
    
    // MARK: - 便捷方法
    func resetToDefaults() {
        iconGenerator.clearAll()
        iconGenerator.resetPreviewToDefaults()
    }
    
    func setPresetIcon(_ type: IconType) {
        iconGenerator.setPresetIcon(type)
        iconContent.setPresetIcon(type)
        print("🔄 GlobalIconViewModels: setPresetIcon - \(type.displayName)")
    }
    
    func setCustomIcon(_ image: UIImage?) {
        iconGenerator.setCustomIcon(image)
        iconContent.setCustomIcon(image)
        print("🔄 GlobalIconViewModels: setCustomIcon - \(image != nil ? "设置自定义图标" : "清除自定义图标")")
    }
    
    func setTextIcon(_ config: TextIconConfigViewModel) {
        iconGenerator.setTextIcon(config)
    }
    
    // MARK: - 设置管理
    private func loadSettings() {
        let settingsService = SettingsService()
        
        // 加载预览配置
        let savedPreviewConfig = settingsService.loadPreviewConfig()
        previewConfig = savedPreviewConfig
        
        // 加载图标内容配置
        let savedIconContent = settingsService.loadIconContent()
        iconContent = savedIconContent
        
        print("🔄 GlobalIconViewModels: Settings loaded - contentType=\(iconContent.contentType), presetType=\(iconContent.selectedPresetType.displayName)")
        
        // 将加载的设置同步到iconGenerator
        syncLoadedSettingsToIconGenerator()
    }
    
    // MARK: - 将加载的设置同步到iconGenerator
    private func syncLoadedSettingsToIconGenerator() {
        print("🔄 GlobalIconViewModels: 将加载的设置同步到iconGenerator")
        
        // 同步图标内容设置
        iconGenerator.contentType = iconContent.contentType
        iconGenerator.selectedPresetType = iconContent.selectedPresetType
        iconGenerator.customImage = iconContent.customImage
        
        // 同步文本配置
        iconGenerator.textConfig.isEnabled = iconContent.textConfig.isEnabled
        iconGenerator.textConfig.text = iconContent.textConfig.text
        iconGenerator.textConfig.fontSize = iconContent.textConfig.fontSize
        iconGenerator.textConfig.fontFamily = iconContent.textConfig.fontFamily
        iconGenerator.textConfig.textStyle = iconContent.textConfig.textStyle
        iconGenerator.textConfig.textColor = iconContent.textConfig.textColor
        iconGenerator.textConfig.customFontSize = iconContent.textConfig.customFontSize
        iconGenerator.textConfig.maxLength = iconContent.textConfig.maxLength
        iconGenerator.textConfig.textWrap = iconContent.textConfig.textWrap
        
        // 同步预览配置
        iconGenerator.viewABackgroundColor = previewConfig.viewABackgroundColor
        iconGenerator.viewABorderColor = previewConfig.viewABorderColor
        iconGenerator.viewACornerRadius = previewConfig.viewACornerRadius
        iconGenerator.viewAPadding = previewConfig.viewAPadding
        iconGenerator.viewABorderWidth = previewConfig.viewABorderWidth
        
        iconGenerator.viewBBackgroundColor = previewConfig.viewBBackgroundColor
        iconGenerator.viewBBorderColor = previewConfig.viewBBorderColor
        iconGenerator.viewBCornerRadius = previewConfig.viewBCornerRadius
        iconGenerator.viewBPadding = previewConfig.viewBPadding
        iconGenerator.viewBBorderWidth = previewConfig.viewBBorderWidth
        iconGenerator.viewBShadowIntensity = previewConfig.viewBShadowIntensity
        
        iconGenerator.iconScale = previewConfig.iconScale
        iconGenerator.iconRotation = previewConfig.iconRotation
        iconGenerator.iconOpacity = previewConfig.iconOpacity
        
        print("✅ GlobalIconViewModels: 设置同步完成 - contentType=\(iconGenerator.contentType), presetType=\(iconGenerator.selectedPresetType.displayName)")
    }
    
    func saveSettings() {
        print("💾 GlobalIconViewModels: 开始保存设置")
        let settingsService = SettingsService()
        
        // 保存预览配置
        print("💾 GlobalIconViewModels: 保存预览配置 - contentType: \(iconContent.contentType), presetType: \(iconContent.selectedPresetType)")
        settingsService.savePreviewConfig(previewConfig)
        
        // 保存图标内容配置
        print("💾 GlobalIconViewModels: 保存图标内容配置")
        settingsService.saveIconContent(iconContent)
        
        print("✅ GlobalIconViewModels: 设置保存完成")
    }
    
    func clearAllSettings() {
        let settingsService = SettingsService()
        settingsService.clearAllSettings()
        
        // 重置到默认值
        resetToDefaults()
        
        print("🔄 GlobalIconViewModels: All settings cleared")
    }
}

// MARK: - 环境值扩展
struct GlobalIconViewModelsKey: EnvironmentKey {
    static let defaultValue = GlobalIconViewModels.shared
}

extension EnvironmentValues {
    var globalIconViewModels: GlobalIconViewModels {
        get { self[GlobalIconViewModelsKey.self] }
        set { self[GlobalIconViewModelsKey.self] = newValue }
    }
}

// MARK: - View扩展
extension View {
    func withGlobalIconViewModels() -> some View {
        self.environmentObject(GlobalIconViewModels.shared)
    }
}
