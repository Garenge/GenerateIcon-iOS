import Foundation
import SwiftUI
import Combine

// MARK: - 预览配置ViewModel - 临时兼容性类
class PreviewConfigViewModel: ObservableObject {
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
class TextIconConfigViewModel: ObservableObject {
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
