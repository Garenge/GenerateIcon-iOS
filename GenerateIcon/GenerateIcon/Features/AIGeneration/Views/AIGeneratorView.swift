import SwiftUI
import UIKit

// MARK: - AI生成器视图
struct AIGeneratorView: View {
    @Binding var settings: IconSettings
    let onGenerate: (String, AISettings) -> Void
    
    @EnvironmentObject var globalViewModels: GlobalIconViewModels
    @State private var prompt = ""
    @State private var aiSettings = AISettings()
    @State private var showingTextSettings = false
    @State private var previewText = "MYAPP"
    @State private var aiPreviewIcon: UIImage?
    @State private var isGeneratingPreview = false
    
    @Environment(\.dismiss) private var dismiss
    
    // 便捷访问全局ViewModel
    private var iconContent: IconContentViewModel {
        globalViewModels.iconContent
    }
    
    private var previewConfig: PreviewConfigViewModel {
        globalViewModels.previewConfig
    }
    
    // 判断是否应该显示AI内容
    private var hasAIContent: Bool {
        !prompt.isEmpty || aiPreviewIcon != nil || isGeneratingPreview
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部预览区域 - 从最上方开始，左右和父视图一样
                previewSection
                
                Divider()
                
                // 下半部分：滚动视图包含输入和设置
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
            }
            .navigationTitle("🎨 AI图标生成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(Int(previewConfig.previewSize.width))x\(Int(previewConfig.previewSize.height))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                // 点击空白处收起键盘
                hideKeyboard()
            }
            .onAppear {
                updatePreviewText()
            }
            .onChange(of: aiSettings.maxLength) { _ in
                updatePreviewText()
                generateAIPreview()
            }
            .onChange(of: aiSettings.fontSize) { _ in
                generateAIPreview()
            }
            .onChange(of: aiSettings.customFontSize) { _ in
                generateAIPreview()
            }
            .onChange(of: aiSettings.fontFamily) { _ in
                generateAIPreview()
            }
            .onChange(of: aiSettings.textColor) { _ in
                generateAIPreview()
            }
            .onChange(of: aiSettings.textStyle) { _ in
                generateAIPreview()
            }
            .onChange(of: aiSettings.textWrap) { _ in
                generateAIPreview()
            }
        }
    }
    
    // MARK: - 预览区域
    private var previewSection: some View {
        ZStack {
            // 根据是否有AI预览来决定显示内容
            if hasAIContent {
                // AI模式：显示AI生成的图标
                if let aiPreviewIcon = aiPreviewIcon {
                    Image(uiImage: aiPreviewIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100, maxHeight: 100)
                        .cornerRadius(8)
                        .transition(.scale.combined(with: .opacity))
                } else if isGeneratingPreview {
                    // 生成中状态
                    VStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("AI生成中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(8)
                } else {
                    // AI模式但无预览：显示AI占位符
                    VStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                        Text("AI图标预览")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                // 预设模式：显示原来的SimpleIconPreview
                SimpleIconPreview(
                    iconContent: globalViewModels.iconContent,
                    previewConfig: globalViewModels.previewConfig
                )
                .frame(height: 120)
            }
        }
        .frame(height: 120)
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
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
                    generateAIPreview()
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
            let firstWord = words.first ?? "MYAPP"
            previewText = String(firstWord.prefix(aiSettings.maxLength))
        }
    }
    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - AI预览生成
    private func generateAIPreview() {
        // 如果提示词为空，清除预览
        guard !prompt.isEmpty else {
            aiPreviewIcon = nil
            isGeneratingPreview = false
            return
        }
        
        // 防抖：延迟生成，避免频繁调用
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒延迟
            
            // 检查是否被取消
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                isGeneratingPreview = true
            }
            
            do {
                // 1. 生成AI文字图标（透明背景）
                let aiService = LocalAIService()
                let aiIcon = try await aiService.generateIcon(prompt: prompt, settings: aiSettings)
                
                // 2. 临时设置AI图标到全局ViewModel，使其成为当前的自定义图标
                await MainActor.run {
                    globalViewModels.setCustomIcon(aiIcon)
                }
                
                // 3. 使用和首页完全相同的预览生成逻辑
                let iconGeneratorService = IconGeneratorService()
                let previewIcon = try await iconGeneratorService.generatePreview(
                    iconContent: iconContent,
                    previewConfig: previewConfig
                )
                
                await MainActor.run {
                    aiPreviewIcon = previewIcon
                    isGeneratingPreview = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingPreview = false
                }
                print("AI预览生成失败: \(error)")
            }
        }
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
    .environmentObject(GlobalIconViewModels.shared)
}
