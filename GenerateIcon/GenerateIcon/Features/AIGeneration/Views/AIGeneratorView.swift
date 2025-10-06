import SwiftUI
import UIKit

// MARK: - AI生成器视图
struct AIGeneratorView: View {
    @Binding var settings: IconSettings
    let onGenerate: (String, AISettings) -> Void
    
    @State private var prompt = ""
    @State private var aiSettings = AISettings()
    @State private var showingTextSettings = false
    @State private var previewText = "MYAPP"
    @State private var previewIcon: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 提示词输入
                    promptInputSection
                    
                    // 示例标签
                    examplesSection
                    
                    // 文字设置模块
                    textSettingsSection
                    
                    // 操作按钮
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("🎨 AI图标生成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onTapGesture {
                // 点击空白处收起键盘
                hideKeyboard()
            }
            .onAppear {
                updatePreview()
            }
            .onChange(of: previewText) { _ in
                updatePreview()
            }
            .onChange(of: aiSettings.fontSize) { _ in
                updatePreview()
            }
            .onChange(of: aiSettings.customFontSize) { _ in
                updatePreview()
            }
            .onChange(of: aiSettings.fontFamily) { _ in
                updatePreview()
            }
            .onChange(of: aiSettings.textColor) { _ in
                updatePreview()
            }
        }
    }
    
    // MARK: - 提示词输入区域
    private var promptInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("描述你想要的图标：")
                .font(.headline)
            
            TextField("例如：一个蓝色的计算器图标", text: $prompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 44)
                .onChange(of: prompt) { _ in
                    updatePreviewText()
                }
            
            Text("💡 提示：输入图标描述，系统会根据关键词智能生成图标。支持中英文，包含颜色、类型等关键词效果更好")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - 示例标签区域
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 提示词示例：")
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(examplePrompts, id: \.self) { example in
                    Button(action: {
                        prompt = example
                        updatePreviewText()
                    }) {
                        Text(example)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
    
    // MARK: - 文字设置区域
    private var textSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingTextSettings.toggle()
                }
            }) {
                HStack {
                    Text("📝 文字设置")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: showingTextSettings ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            if showingTextSettings {
                VStack(spacing: 16) {
                    // 字体设置
                    fontSettings
                    
                    // 文字设置
                    textSettings
                    
                    // 实时预览
                    previewSection
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    // MARK: - 字体设置
    private var fontSettings: some View {
        VStack(spacing: 12) {
            // 字体大小
            HStack {
                Text("字体大小：")
                    .font(.subheadline)
                
                Spacer()
                
                Picker("字体大小", selection: $aiSettings.fontSize) {
                    ForEach(FontSize.allCases) { size in
                        Text(size.name).tag(size)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                                if aiSettings.fontSize == .custom {
                                    TextField("像素", value: Binding(
                                        get: { aiSettings.customFontSize ?? 100 },
                                        set: { aiSettings.customFontSize = CGFloat(Double($0 ?? 100)) }
                                    ), format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                }
            }
            
            // 字体类型
            HStack {
                Text("字体类型：")
                    .font(.subheadline)
                
                Spacer()
                
                Picker("字体类型", selection: $aiSettings.fontFamily) {
                    ForEach(fontFamilies, id: \.self) { family in
                        Text(family).tag(family)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // 文字样式
            HStack {
                Text("文字样式：")
                    .font(.subheadline)
                
                Spacer()
                
                Picker("文字样式", selection: $aiSettings.textStyle) {
                    ForEach(TextStyle.allCases) { style in
                        Text(style.name).tag(style)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
    
    // MARK: - 文字设置
    private var textSettings: some View {
        VStack(spacing: 12) {
            // 最大长度
            HStack {
                Text("最大长度：")
                    .font(.subheadline)
                
                Spacer()
                
                TextField("字符", value: $aiSettings.maxLength, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            // 文字换行
            HStack {
                Text("文字换行：")
                    .font(.subheadline)
                
                Spacer()
                
                Toggle("", isOn: $aiSettings.textWrap)
            }
            
            // 文字颜色
            HStack {
                Text("文字颜色：")
                    .font(.subheadline)
                
                Spacer()
                
                ColorPicker("", selection: Binding(
                    get: { aiSettings.textColor.color },
                    set: { aiSettings.textColor = ColorData(color: $0) }
                ))
                .frame(width: 30, height: 30)
            }
        }
    }
    
    // MARK: - 预览区域
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔍 实时预览")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            // 使用IconPreviewComponent来预览AI生成效果，确保与首页一致
            IconPreviewComponent(
                config: IconPreviewConfig(
                    iconType: .heart, // 使用一个默认图标类型
                    settings: IconSettings(), // 使用默认设置
                    isLoading: false,
                    customIcon: previewIcon, // 使用状态变量
                    previewSize: CGSize(width: 256, height: 256), // 与首页统一尺寸
                    showPreviewInfo: false
                )
            )
        }
    }
    
    // MARK: - 生成预览图标
    private func generatePreviewIcon() -> UIImage? {
        let size = CGSize(width: 256, height: 256)
        
        return UIGraphicsImageRenderer(size: size).image { context in
            let cgContext = context.cgContext
            
            // 创建渐变背景
            let colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!
            
            cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // 绘制文字
            let fontSize = aiSettings.fontSize == .custom ? (aiSettings.customFontSize ?? 100) : aiSettings.fontSize.size
            let font = UIFont(name: aiSettings.fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            
            let text = previewText.isEmpty ? "MYAPP" : previewText
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor(aiSettings.textColor.color),
                .strokeColor: UIColor.black,
                .strokeWidth: -2
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            // 添加阴影
            cgContext.setShadow(offset: CGSize(width: 2, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    // MARK: - 操作按钮
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button("取消") {
                dismiss()
            }
            .buttonStyle(.bordered)
            
            Button("🎨 生成图标") {
                onGenerate(prompt, aiSettings)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(prompt.isEmpty)
        }
    }
    
    // MARK: - 私有方法
    private func updatePreviewText() {
        if prompt.isEmpty {
            previewText = "MYAPP"
        } else {
            let words = prompt.components(separatedBy: .whitespaces)
            let firstWord = words.first?.uppercased() ?? "MYAPP"
            previewText = String(firstWord.prefix(aiSettings.maxLength))
        }
    }
    
    private func updatePreview() {
        previewIcon = generatePreviewIcon()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - 示例提示词
    private var examplePrompts: [String] {
        [
            "calculator icon, blue",
            "music icon, purple",
            "heart icon, red",
            "star icon, yellow",
            "gear icon, grey",
            "home icon, green",
            "camera icon, orange",
            "game icon, pink",
            "shopping icon, teal",
            "weather icon, cyan"
        ]
    }
    
    // MARK: - 字体家族
    private var fontFamilies: [String] {
        [
            "Arial",
            "Helvetica",
            "Georgia",
            "Times New Roman",
            "Courier New",
            "Verdana",
            "Impact",
            "Comic Sans MS"
        ]
    }
}

#Preview {
    AIGeneratorView(
        settings: .constant(IconSettings()),
        onGenerate: { _, _ in }
    )
}
