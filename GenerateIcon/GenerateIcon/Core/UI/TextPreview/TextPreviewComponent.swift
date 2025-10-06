import SwiftUI

/// 文字设置预览配置
struct TextPreviewConfig {
    /// 文字内容
    let text: String
    
    /// 字体大小
    let fontSize: CGFloat
    
    /// 字体名称
    let fontName: String
    
    /// 文字颜色
    let textColor: Color
    
    /// 背景颜色
    let backgroundColor: Color
    
    /// 预览尺寸
    let previewSize: CGSize
    
    /// 是否显示预览信息
    let showPreviewInfo: Bool
    
    /// 初始化方法
    init(
        text: String,
        fontSize: CGFloat = 100,
        fontName: String = "Arial",
        textColor: Color = .white,
        backgroundColor: Color = .blue,
        previewSize: CGSize = CGSize(width: 256, height: 256),
        showPreviewInfo: Bool = true
    ) {
        self.text = text
        self.fontSize = fontSize
        self.fontName = fontName
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.previewSize = previewSize
        self.showPreviewInfo = showPreviewInfo
    }
}

/// 文字设置预览组件
struct TextPreviewComponent: View {
    let config: TextPreviewConfig
    
    var body: some View {
        VStack(spacing: 16) {
            // 文字预览区域
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: config.previewSize.width, height: config.previewSize.height)
                
                // 文字预览
                ZStack {
                    // 背景色
                    RoundedRectangle(cornerRadius: 8)
                        .fill(config.backgroundColor)
                        .frame(width: config.previewSize.width * 0.8, height: config.previewSize.height * 0.8)
                    
                    // 文字
                    Text(config.text.isEmpty ? "示例文字" : config.text)
                        .font(.custom(config.fontName, size: config.fontSize * 0.3)) // 缩放字体大小
                        .foregroundColor(config.textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding()
                }
            }
            
            // 预览信息
            if config.showPreviewInfo {
                VStack(spacing: 4) {
                    Text("文字预览 (\(Int(config.previewSize.width))x\(Int(config.previewSize.height)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("字体: \(config.fontName), 大小: \(Int(config.fontSize))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onChange(of: config.text) { _ in
            // 文字内容改变时的处理（如果需要的话）
        }
        .onChange(of: config.fontSize) { _ in
            // 字体大小改变时的处理（如果需要的话）
        }
        .onChange(of: config.fontName) { _ in
            // 字体名称改变时的处理（如果需要的话）
        }
        .onChange(of: config.textColor) { _ in
            // 文字颜色改变时的处理（如果需要的话）
        }
        .onChange(of: config.backgroundColor) { _ in
            // 背景颜色改变时的处理（如果需要的话）
        }
    }
}

#Preview {
    TextPreviewComponent(
        config: TextPreviewConfig(
            text: "AI生成",
            fontSize: 100,
            fontName: "Arial",
            textColor: .white,
            backgroundColor: .blue
        )
    )
    .padding()
}
