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
        iconContent.textConfig = iconGenerator.textConfig
        
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
        
        iconGenerator.$textConfig
            .assign(to: \.textConfig, on: iconContent)
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
        
        print("🔄 GlobalIconViewModels: Bindings setup completed")
    }
    
    // MARK: - 便捷方法
    func resetToDefaults() {
        iconGenerator.clearAll()
        iconGenerator.resetPreviewToDefaults()
    }
    
    func setPresetIcon(_ type: IconType) {
        iconGenerator.setPresetIcon(type)
    }
    
    func setCustomIcon(_ image: UIImage?) {
        iconGenerator.setCustomIcon(image)
    }
    
    func setTextIcon(_ config: TextIconConfigViewModel) {
        iconGenerator.setTextIcon(config)
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
