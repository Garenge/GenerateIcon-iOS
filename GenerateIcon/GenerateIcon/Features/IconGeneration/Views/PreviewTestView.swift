import SwiftUI

// MARK: - 新预览系统测试视图
struct NewPreviewTestView: View {
    @StateObject private var iconContent = IconContentViewModel()
    @StateObject private var previewConfig = PreviewConfigViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 预览区域
                    IconPreviewComponent(iconContent: iconContent, previewConfig: previewConfig)
                        .padding()
                    
                    // 图标内容配置
                    iconContentSettings
                    
                    // ViewA 配置
                    viewASettings
                    
                    // ViewB 配置
                    viewBSettings
                    
                    // ViewC 配置
                    viewCSettings
                    
                    // 重置按钮
                    Button("重置为默认设置") {
                        iconContent.clearAll()
                        previewConfig.resetToDefaults()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("新预览系统测试")
        }
    }
    
    // MARK: - 图标内容设置
    private var iconContentSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("图标内容设置")
                .font(.headline)
                .fontWeight(.bold)
            
            Picker("图标类型", selection: $iconContent.contentType) {
                ForEach(IconContentType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            switch iconContent.contentType {
            case .preset:
                Picker("预设图标", selection: $iconContent.selectedPresetType) {
                    ForEach(IconType.allCases) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
            case .custom:
                Text("自定义图标功能待实现")
                    .foregroundColor(.secondary)
                
            case .text:
                textIconSettings
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - 文字图标设置
    private var textIconSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("文字内容", text: $iconContent.textConfig.text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("字体大小", selection: $iconContent.textConfig.fontSize) {
                ForEach(FontSize.allCases) { size in
                    Text(size.rawValue.capitalized).tag(size)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            ColorPicker("文字颜色", selection: $iconContent.textConfig.textColor)
            
            Picker("文字样式", selection: $iconContent.textConfig.textStyle) {
                ForEach(TextStyle.allCases) { style in
                    Text(style.rawValue.capitalized).tag(style)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - ViewA 设置
    private var viewASettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ViewA - 最底图配置")
                .font(.headline)
                .fontWeight(.bold)
            
            Group {
                ColorPicker("背景颜色", selection: $previewConfig.viewABackgroundColor)
                ColorPicker("边框颜色", selection: $previewConfig.viewABorderColor)
                
                HStack {
                    Text("圆角半径: \(Int(previewConfig.viewACornerRadius))")
                    Slider(value: $previewConfig.viewACornerRadius, in: 0...50)
                }
                
                HStack {
                    Text("内边距: \(Int(previewConfig.viewAPadding))")
                    Slider(value: $previewConfig.viewAPadding, in: 0...50)
                }
                
                HStack {
                    Text("边框宽度: \(Int(previewConfig.viewABorderWidth))")
                    Slider(value: $previewConfig.viewABorderWidth, in: 0...10)
                }
            }
            .padding(.leading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - ViewB 设置
    private var viewBSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ViewB - 容器图配置")
                .font(.headline)
                .fontWeight(.bold)
            
            Group {
                ColorPicker("背景颜色", selection: $previewConfig.viewBBackgroundColor)
                ColorPicker("边框颜色", selection: $previewConfig.viewBBorderColor)
                
                HStack {
                    Text("圆角半径: \(Int(previewConfig.viewBCornerRadius))")
                    Slider(value: $previewConfig.viewBCornerRadius, in: 0...50)
                }
                
                HStack {
                    Text("内边距: \(Int(previewConfig.viewBPadding))")
                    Slider(value: $previewConfig.viewBPadding, in: 0...50)
                }
                
                HStack {
                    Text("边框宽度: \(Int(previewConfig.viewBBorderWidth))")
                    Slider(value: $previewConfig.viewBBorderWidth, in: 0...10)
                }
                
                HStack {
                    Text("阴影强度: \(Int(previewConfig.viewBShadowIntensity))")
                    Slider(value: $previewConfig.viewBShadowIntensity, in: 0...50)
                }
            }
            .padding(.leading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - ViewC 设置
    private var viewCSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ViewC - 图标样式配置")
                .font(.headline)
                .fontWeight(.bold)
            
            Group {
                HStack {
                    Text("图标缩放: \(String(format: "%.1f", previewConfig.iconScale))")
                    Slider(value: $previewConfig.iconScale, in: 0.5...2.0)
                }
                
                HStack {
                    Text("图标旋转: \(Int(previewConfig.iconRotation))°")
                    Slider(value: $previewConfig.iconRotation, in: 0...360)
                }
                
                HStack {
                    Text("图标透明度: \(String(format: "%.1f", previewConfig.iconOpacity))")
                    Slider(value: $previewConfig.iconOpacity, in: 0.1...1.0)
                }
            }
            .padding(.leading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NewPreviewTestView()
}
