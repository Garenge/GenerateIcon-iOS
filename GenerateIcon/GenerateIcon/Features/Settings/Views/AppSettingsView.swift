import SwiftUI

// MARK: - 应用设置页面
struct AppSettingsView: View {
    @EnvironmentObject var globalViewModels: GlobalIconViewModels
    @Environment(\.dismiss) var dismiss
    
    private var iconContent: IconContentViewModel {
        globalViewModels.iconContent
    }
    
    private var previewConfig: PreviewConfigViewModel {
        globalViewModels.previewConfig
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 图标预览区域
                    VStack(spacing: 16) {
                        Text("当前图标设置")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        SimpleIconPreview()
                        
                        // 快速操作按钮
                        HStack(spacing: 12) {
                            Button("重置为默认") {
                                globalViewModels.resetToDefaults()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("切换到文字图标") {
                                iconContent.textConfig.enableTextIcon()
                                globalViewModels.setTextIcon(iconContent.textConfig)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("切换到预设图标") {
                                globalViewModels.setPresetIcon(.calculator)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 图标内容设置
                    VStack(alignment: .leading, spacing: 16) {
                        Text("图标内容")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Picker("图标类型", selection: Binding(
                            get: { iconContent.contentType },
                            set: { iconContent.contentType = $0 }
                        )) {
                            ForEach(IconContentType.allCases) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch iconContent.contentType {
                        case .preset:
                            presetIconSettings
                        case .custom:
                            customIconSettings
                        case .text:
                            textIconSettings
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 样式设置
                    VStack(alignment: .leading, spacing: 16) {
                        Text("样式设置")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        // ViewA 设置
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ViewA - 最底图")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ColorPicker("背景颜色", selection: Binding(
                                get: { previewConfig.viewABackgroundColor },
                                set: { previewConfig.viewABackgroundColor = $0 }
                            ))
                            ColorPicker("边框颜色", selection: Binding(
                                get: { previewConfig.viewABorderColor },
                                set: { previewConfig.viewABorderColor = $0 }
                            ))
                            
                            HStack {
                                Text("圆角半径: \(Int(previewConfig.viewACornerRadius))")
                                Slider(value: Binding(
                                    get: { previewConfig.viewACornerRadius },
                                    set: { previewConfig.viewACornerRadius = $0 }
                                ), in: 0...50)
                            }
                            
                            HStack {
                                Text("内边距: \(Int(previewConfig.viewAPadding))")
                                Slider(value: Binding(
                                    get: { previewConfig.viewAPadding },
                                    set: { previewConfig.viewAPadding = $0 }
                                ), in: 0...50)
                            }
                        }
                        
                        Divider()
                        
                        // ViewB 设置
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ViewB - 容器图")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ColorPicker("背景颜色", selection: Binding(
                                get: { previewConfig.viewBBackgroundColor },
                                set: { previewConfig.viewBBackgroundColor = $0 }
                            ))
                            ColorPicker("边框颜色", selection: Binding(
                                get: { previewConfig.viewBBorderColor },
                                set: { previewConfig.viewBBorderColor = $0 }
                            ))
                            
                            HStack {
                                Text("圆角半径: \(Int(previewConfig.viewBCornerRadius))")
                                Slider(value: Binding(
                                    get: { previewConfig.viewBCornerRadius },
                                    set: { previewConfig.viewBCornerRadius = $0 }
                                ), in: 0...50)
                            }
                            
                            HStack {
                                Text("内边距: \(Int(previewConfig.viewBPadding))")
                                Slider(value: Binding(
                                    get: { previewConfig.viewBPadding },
                                    set: { previewConfig.viewBPadding = $0 }
                                ), in: 0...50)
                            }
                            
                            HStack {
                                Text("阴影强度: \(Int(previewConfig.viewBShadowIntensity))")
                                Slider(value: Binding(
                                    get: { previewConfig.viewBShadowIntensity },
                                    set: { previewConfig.viewBShadowIntensity = $0 }
                                ), in: 0...50)
                            }
                        }
                        
                        Divider()
                        
                        // ViewC 设置
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ViewC - 图标样式")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Text("图标缩放: \(String(format: "%.1f", previewConfig.iconScale))")
                                Slider(value: Binding(
                                    get: { previewConfig.iconScale },
                                    set: { previewConfig.iconScale = $0 }
                                ), in: 0.5...2.0)
                            }
                            
                            HStack {
                                Text("图标旋转: \(Int(previewConfig.iconRotation))°")
                                Slider(value: Binding(
                                    get: { previewConfig.iconRotation },
                                    set: { previewConfig.iconRotation = $0 }
                                ), in: 0...360)
                            }
                            
                            HStack {
                                Text("图标透明度: \(String(format: "%.1f", previewConfig.iconOpacity))")
                                Slider(value: Binding(
                                    get: { previewConfig.iconOpacity },
                                    set: { previewConfig.iconOpacity = $0 }
                                ), in: 0.1...1.0)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("应用设置")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 预设图标设置
    private var presetIconSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("预设图标", selection: Binding(
                get: { iconContent.selectedPresetType },
                set: { iconContent.selectedPresetType = $0 }
            )) {
                ForEach(IconType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    // MARK: - 自定义图标设置
    private var customIconSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("自定义图标功能")
                .foregroundColor(.secondary)
            Text("请使用AI生成或从相册选择图片")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - 文字图标设置
    private var textIconSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("文字内容", text: Binding(
                get: { iconContent.textConfig.text },
                set: { iconContent.textConfig.text = $0 }
            ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("字体大小", selection: Binding(
                get: { iconContent.textConfig.fontSize },
                set: { iconContent.textConfig.fontSize = $0 }
            )) {
                ForEach(FontSize.allCases) { size in
                    Text(size.rawValue.capitalized).tag(size)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            ColorPicker("文字颜色", selection: Binding(
                get: { iconContent.textConfig.textColor },
                set: { iconContent.textConfig.textColor = $0 }
            ))
            
            Picker("文字样式", selection: Binding(
                get: { iconContent.textConfig.textStyle },
                set: { iconContent.textConfig.textStyle = $0 }
            )) {
                ForEach(TextStyle.allCases) { style in
                    Text(style.rawValue.capitalized).tag(style)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

#Preview {
    AppSettingsView()
        .withGlobalIconViewModels()
}
