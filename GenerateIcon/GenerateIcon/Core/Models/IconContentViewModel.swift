import Foundation
import SwiftUI
import Combine

// MARK: - 图标内容ViewModel - 临时兼容性类
class IconContentViewModel: ObservableObject {
    // MARK: - 图标内容类型
    @Published var contentType: IconContentType = .preset
    @Published var selectedPresetType: IconType = .calculator
    @Published var customImage: UIImage?
    @Published var textConfig: TextIconConfigViewModel = TextIconConfigViewModel()
    
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
    
    // MARK: - 方法
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
}

// MARK: - 图标内容类型枚举
enum IconContentType: String, CaseIterable, Identifiable, Codable {
    case preset = "preset"
    case custom = "custom"
    case text = "text"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .preset: return "预设图标"
        case .custom: return "自定义图标"
        case .text: return "文字图标"
        }
    }
}