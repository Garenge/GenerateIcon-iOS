import Foundation
import SwiftUI

// MARK: - 图标设置数据模型
struct IconSettings: Codable, Equatable {
    // 底图样式设置
    var backgroundShape: BackgroundShape
    var backgroundColor: ColorData
    var cornerRadius: CGFloat
    var iconPadding: CGFloat
    var shadowIntensity: CGFloat
    var borderWidth: CGFloat
    var borderColor: ColorData
    
    // 图标外框设置
    var backgroundAColor: ColorData
    var backgroundABorderWidth: CGFloat
    var backgroundAPadding: CGFloat
    
    // 默认设置
    init() {
        self.backgroundShape = .rounded
        self.backgroundColor = ColorData(color: Color(red: 0.4, green: 0.49, blue: 0.92))
        self.cornerRadius = 40
        self.iconPadding = 20
        self.shadowIntensity = 20
        self.borderWidth = 0
        self.borderColor = ColorData(color: .black)
        
        self.backgroundAColor = ColorData(color: .white)
        self.backgroundABorderWidth = 0
        self.backgroundAPadding = 0
    }
}

// MARK: - 颜色数据包装器
struct ColorData: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - AI设置数据模型
struct AISettings: Codable, Equatable {
    var fontSize: FontSize
    var fontFamily: String
    var textStyle: TextStyle
    var maxLength: Int
    var textWrap: Bool
    var textColor: ColorData
    var customFontSize: CGFloat?
    
    init() {
        self.fontSize = .medium
        self.fontFamily = "Arial"
        self.textStyle = .bold
        self.maxLength = 7
        self.textWrap = false
        self.textColor = ColorData(color: .white)
        self.customFontSize = nil
    }
}

// MARK: - 字体大小枚举
enum FontSize: String, CaseIterable, Identifiable, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case custom = "custom"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .small: return "小"
        case .medium: return "中"
        case .large: return "大"
        case .custom: return "自定义"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .small: return 80
        case .medium: return 100
        case .large: return 120
        case .custom: return 100 // 默认值，实际使用customFontSize
        }
    }
}

// MARK: - 文字样式枚举
enum TextStyle: String, CaseIterable, Identifiable, Codable {
    case normal = "normal"
    case bold = "bold"
    case italic = "italic"
    case boldItalic = "bold italic"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .normal: return "普通"
        case .bold: return "粗体"
        case .italic: return "斜体"
        case .boldItalic: return "粗斜体"
        }
    }
    
    var weight: Font.Weight {
        switch self {
        case .normal, .italic: return .regular
        case .bold, .boldItalic: return .bold
        }
    }
    
    var design: Font.Design {
        switch self {
        case .normal, .bold: return .default
        case .italic, .boldItalic: return .serif
        }
    }
}

// MARK: - 下载类型枚举
enum DownloadType: String, CaseIterable, Identifiable, Codable {
    case custom = "custom"
    case ios = "ios"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .custom: return "自定义尺寸"
        case .ios: return "iOS应用图标"
        }
    }
}
