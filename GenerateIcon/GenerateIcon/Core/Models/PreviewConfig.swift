import Foundation
import SwiftUI
import Combine

// MARK: - 预览配置ViewModel - 临时兼容性类
class PreviewConfigViewModel: ObservableObject, Codable {
    // MARK: - ViewA 最底图配置
    @Published var viewABackgroundColor: Color = .white
    @Published var viewABorderColor: Color = .black
    @Published var viewACornerRadius: CGFloat = 10
    @Published var viewAPadding: CGFloat = 20
    @Published var viewABorderWidth: CGFloat = 2
    
    // MARK: - ViewB 容器图配置
    @Published var viewBBackgroundColor: Color = .clear
    @Published var viewBBorderColor: Color = .clear
    @Published var viewBCornerRadius: CGFloat = 40
    @Published var viewBPadding: CGFloat = 20
    @Published var viewBBorderWidth: CGFloat = 0
    @Published var viewBShadowIntensity: CGFloat = 20
    
    // MARK: - ViewC 图标配置（样式相关）
    @Published var iconScale: CGFloat = 1.0
    @Published var iconRotation: CGFloat = 0
    @Published var iconOpacity: CGFloat = 1.0
    
    // MARK: - 预览尺寸
    @Published var previewSize: CGSize = CGSize(width: 256, height: 256)
    
    // MARK: - Codable实现
    enum CodingKeys: String, CodingKey {
        case viewABackgroundColor, viewABorderColor, viewACornerRadius, viewAPadding, viewABorderWidth
        case viewBBackgroundColor, viewBBorderColor, viewBCornerRadius, viewBPadding, viewBBorderWidth, viewBShadowIntensity
        case iconScale, iconRotation, iconOpacity, previewSize
    }
    
    init() {
        // 默认初始化
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 解码颜色
        if let colorData = try? container.decode(ColorData.self, forKey: .viewABackgroundColor) {
            viewABackgroundColor = colorData.color
        }
        if let colorData = try? container.decode(ColorData.self, forKey: .viewABorderColor) {
            viewABorderColor = colorData.color
        }
        if let colorData = try? container.decode(ColorData.self, forKey: .viewBBackgroundColor) {
            viewBBackgroundColor = colorData.color
        }
        if let colorData = try? container.decode(ColorData.self, forKey: .viewBBorderColor) {
            viewBBorderColor = colorData.color
        }
        
        // 解码其他属性
        viewACornerRadius = try container.decodeIfPresent(CGFloat.self, forKey: .viewACornerRadius) ?? 10
        viewAPadding = try container.decodeIfPresent(CGFloat.self, forKey: .viewAPadding) ?? 20
        viewABorderWidth = try container.decodeIfPresent(CGFloat.self, forKey: .viewABorderWidth) ?? 2
        
        viewBCornerRadius = try container.decodeIfPresent(CGFloat.self, forKey: .viewBCornerRadius) ?? 40
        viewBPadding = try container.decodeIfPresent(CGFloat.self, forKey: .viewBPadding) ?? 20
        viewBBorderWidth = try container.decodeIfPresent(CGFloat.self, forKey: .viewBBorderWidth) ?? 0
        viewBShadowIntensity = try container.decodeIfPresent(CGFloat.self, forKey: .viewBShadowIntensity) ?? 20
        
        iconScale = try container.decodeIfPresent(CGFloat.self, forKey: .iconScale) ?? 1.0
        iconRotation = try container.decodeIfPresent(CGFloat.self, forKey: .iconRotation) ?? 0
        iconOpacity = try container.decodeIfPresent(CGFloat.self, forKey: .iconOpacity) ?? 1.0
        
        if let sizeData = try? container.decode(CGSize.self, forKey: .previewSize) {
            previewSize = sizeData
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // 编码颜色
        try container.encode(ColorData(color: viewABackgroundColor), forKey: .viewABackgroundColor)
        try container.encode(ColorData(color: viewABorderColor), forKey: .viewABorderColor)
        try container.encode(ColorData(color: viewBBackgroundColor), forKey: .viewBBackgroundColor)
        try container.encode(ColorData(color: viewBBorderColor), forKey: .viewBBorderColor)
        
        // 编码其他属性
        try container.encode(viewACornerRadius, forKey: .viewACornerRadius)
        try container.encode(viewAPadding, forKey: .viewAPadding)
        try container.encode(viewABorderWidth, forKey: .viewABorderWidth)
        
        try container.encode(viewBCornerRadius, forKey: .viewBCornerRadius)
        try container.encode(viewBPadding, forKey: .viewBPadding)
        try container.encode(viewBBorderWidth, forKey: .viewBBorderWidth)
        try container.encode(viewBShadowIntensity, forKey: .viewBShadowIntensity)
        
        try container.encode(iconScale, forKey: .iconScale)
        try container.encode(iconRotation, forKey: .iconRotation)
        try container.encode(iconOpacity, forKey: .iconOpacity)
        try container.encode(previewSize, forKey: .previewSize)
    }
    
    // MARK: - 方法
    func resetToDefaults() {
        // ViewA 默认设置
        viewABackgroundColor = .white
        viewABorderColor = .black
        viewACornerRadius = 10
        viewAPadding = 20
        viewABorderWidth = 2
        
        // ViewB 默认设置
        viewBBackgroundColor = .clear
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
}

// MARK: - 文字图标配置ViewModel
class TextIconConfigViewModel: ObservableObject, Codable {
    @Published var isEnabled: Bool = false
    @Published var text: String = ""
    @Published var fontSize: FontSize = .medium
    @Published var fontFamily: String = "Arial"
    @Published var textStyle: TextStyle = .bold
    @Published var textColor: Color = .white
    @Published var customFontSize: CGFloat? = nil
    @Published var maxLength: Int = 7
    @Published var textWrap: Bool = false
    
    // MARK: - 计算属性
    var effectiveFontSize: CGFloat {
        switch fontSize {
        case .small: return 160
        case .medium: return 260
        case .large: return 350
        case .custom: return customFontSize ?? 100
        }
    }
    
    var fontWeight: Font.Weight {
        switch textStyle {
        case .normal, .italic: return .regular
        case .bold, .boldItalic: return .bold
        }
    }
    
    var fontDesign: Font.Design {
        switch textStyle {
        case .normal, .bold: return .default
        case .italic, .boldItalic: return .serif
        }
    }
    
    var uiFontWeight: UIFont.Weight {
        switch textStyle {
        case .normal, .italic: return .regular
        case .bold, .boldItalic: return .bold
        }
    }
    
    // MARK: - Codable实现
    enum CodingKeys: String, CodingKey {
        case isEnabled, text, fontSize, fontFamily, textStyle, textColor, customFontSize, maxLength, textWrap
    }
    
    init() {
        // 默认初始化
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        fontSize = try container.decodeIfPresent(FontSize.self, forKey: .fontSize) ?? .medium
        fontFamily = try container.decodeIfPresent(String.self, forKey: .fontFamily) ?? "Arial"
        textStyle = try container.decodeIfPresent(TextStyle.self, forKey: .textStyle) ?? .bold
        customFontSize = try container.decodeIfPresent(CGFloat.self, forKey: .customFontSize)
        maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength) ?? 7
        textWrap = try container.decodeIfPresent(Bool.self, forKey: .textWrap) ?? false
        
        // 解码颜色
        if let colorData = try? container.decode(ColorData.self, forKey: .textColor) {
            textColor = colorData.color
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(text, forKey: .text)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(fontFamily, forKey: .fontFamily)
        try container.encode(textStyle, forKey: .textStyle)
        try container.encode(ColorData(color: textColor), forKey: .textColor)
        try container.encodeIfPresent(customFontSize, forKey: .customFontSize)
        try container.encode(maxLength, forKey: .maxLength)
        try container.encode(textWrap, forKey: .textWrap)
    }
    
    // MARK: - 方法
    func resetToDefaults() {
        isEnabled = false
        text = ""
        fontSize = .medium
        fontFamily = "Arial"
        textStyle = .bold
        textColor = .white
        customFontSize = nil
        maxLength = 7
        textWrap = false
    }
    
    func enableTextIcon() {
        isEnabled = true
        if text.isEmpty {
            text = "TXT"
        }
    }
    
    func disableTextIcon() {
        isEnabled = false
    }
}
