import SwiftUI

// MARK: - 设置面板视图
struct SettingsPanelView: View {
    @Binding var settings: IconSettings
    @Binding var isVisible: Bool
    var currentIconType: IconType = .calculator
    var onSettingsChanged: (() -> Void)? = nil
    // 传入的自定义图标（AI生成的图标）。若存在，则优先展示此图
    var customIcon: UIImage? = nil
    
    // 预览相关状态
    @State private var previewImage: UIImage?
    @State private var isGeneratingPreview = false
    @State private var previewTask: Task<Void, Never>?
    @State private var refreshTimer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 顶部区域：左侧标题 + 中间预览 + 右侧关闭按钮
            HStack(alignment: .top, spacing: 8) {
                // 左侧：标题区域（A和B两行）
                VStack(alignment: .leading, spacing: 8) {
                    // A: 底图设置标题
                    HStack {
                        Text("🎨 底图设置")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    
                    // B: 实时预览标题
                    HStack {
                        Text("📱 实时预览")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if isGeneratingPreview {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                // 中间：C图片预览区域
                previewSection
                
                // 右侧：关闭按钮
                VStack {
                    Button(action: {
                        isVisible = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                    Spacer()
                }
            }
            .frame(height: 150) // 限制HStack的高度
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // 底部：设置选项区域
            ScrollView {
                VStack(spacing: 16) {
                    // 图标外框设置
                    iconFrameSettings
                    
                    // 底图样式设置
                    backgroundStyleSettings
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .padding(.top, 22)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onChange(of: settings) { _ in
            // 设置变化时立即触发预览更新
            onSettingsChanged?()
            // 无论是否有自定义图标，都要生成预览（自定义图标需要与背景合成）
            generatePreview()
            // 发送全局通知，首页等位置可立即刷新
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
        .onChange(of: currentIconType) { _ in
            // 图标类型变化时立即刷新预览
            generatePreview()
            // 发送全局通知
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
        .onAppear {
            // 面板出现时生成初始预览
            generatePreview()
        }
        .onDisappear {
            // 面板消失时清理任务
            cleanupTasks()
            // 设置面板关闭时也广播刷新
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
    
    // MARK: - 预览区域
    private var previewSection: some View {
        VStack(spacing: 6) {
            // 预览图标区域 - 适中尺寸
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)

                if let previewImage = previewImage {
                    // 预览图片
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
                        .cornerRadius(6)
                } else if isGeneratingPreview {
                    // 生成中状态
                    VStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("生成中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                } else {
                    // 默认状态
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                        Text("暂无预览")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
            }
            
            // 预览说明
            Text("调整设置查看效果")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(8)
    }
    
    // MARK: - 图标外框设置
    private var iconFrameSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🖼️ 图标外框")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // 外框背景色
                ColorPickerSetting(
                    title: "外框背景色",
                    color: $settings.backgroundAColor
                )
                
                // 外框边框
                SliderSetting(
                    title: "外框边框",
                    value: $settings.backgroundABorderWidth,
                    range: 0...10,
                    unit: "px"
                )
                
                // 外框内边距
                SliderSetting(
                    title: "外框内边距",
                    value: $settings.backgroundAPadding,
                    range: 0...100,
                    unit: "px"
                )
            }
        }
    }
    
    // MARK: - 底图样式设置
    private var backgroundStyleSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎨 底图样式")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // 底图形状
                ShapePickerSetting(
                    title: "底图形状",
                    selection: $settings.backgroundShape
                )
                
                // 圆角大小
                SliderSetting(
                    title: "圆角大小",
                    value: $settings.cornerRadius,
                    range: 0...50,
                    unit: "px"
                )
                
                // 底图颜色
                ColorPickerSetting(
                    title: "底图颜色",
                    color: $settings.backgroundColor
                )
                
                // 内边距
                SliderSetting(
                    title: "内边距",
                    value: $settings.iconPadding,
                    range: 0...100,
                    unit: "px"
                )
                
                // 阴影强度
                SliderSetting(
                    title: "阴影强度",
                    value: $settings.shadowIntensity,
                    range: 0...30,
                    unit: "px"
                )
                
                // 底图边框
                SliderSetting(
                    title: "底图边框",
                    value: $settings.borderWidth,
                    range: 0...10,
                    unit: "px"
                )
                
                // 底图边框颜色
                ColorPickerSetting(
                    title: "底图边框颜色",
                    color: $settings.borderColor
                )
            }
        }
    }
    
    // MARK: - 预览相关方法
    private func refreshPreviewWithDelay() {
        // 取消之前的定时器
        refreshTimer?.invalidate()
        
        // 设置新的定时器，延迟0.3秒刷新
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            generatePreview()
        }
    }
    
    private func generatePreview() {
        // 取消之前的任务
        previewTask?.cancel()
        
        // 设置生成状态
        isGeneratingPreview = true
        
        // 生成预览
        previewTask = Task {
            await generatePreviewImage()
        }
    }
    
    @MainActor
    private func generatePreviewImage() async {
        do {
            let service = IconGeneratorService()
            let image: UIImage
            if let customIcon = customIcon {
                // 将自定义图标与当前设置组合，确保底图颜色等设置生效
                image = try await service.composePreview(
                    with: customIcon,
                    size: CGSize(width: 100, height: 100),
                    settings: settings
                )
            } else {
                // 使用当前选中的图标类型进行预览
                image = try await service.generatePreview(
                    type: currentIconType,
                    size: CGSize(width: 100, height: 100),
                    settings: settings
                )
            }
            
            // 检查任务是否被取消
            guard !Task.isCancelled else { return }
            
            previewImage = image
            isGeneratingPreview = false
        } catch {
            // 检查任务是否被取消
            guard !Task.isCancelled else { return }
            
            print("生成预览失败: \(error)")
            isGeneratingPreview = false
        }
    }
    
    private func cleanupTasks() {
        previewTask?.cancel()
        refreshTimer?.invalidate()
        previewTask = nil
        refreshTimer = nil
    }
}

// MARK: - 颜色选择器设置
struct ColorPickerSetting: View {
    let title: String
    @Binding var color: ColorData
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            ColorPicker("", selection: Binding(
                get: { color.color },
                set: { color = ColorData(color: $0) }
            ))
            .frame(width: 30, height: 30)
        }
    }
}

// MARK: - 滑块设置
struct SliderSetting: View {
    let title: String
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(Int(value))\(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $value, in: range)
                .accentColor(.blue)
        }
    }
}

// MARK: - 形状选择器设置
struct ShapePickerSetting: View {
    let title: String
    @Binding var selection: BackgroundShape
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
            
            Picker(title, selection: $selection) {
                ForEach(BackgroundShape.allCases) { shape in
                    Text(shape.name).tag(shape)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

#Preview {
    SettingsPanelView(
        settings: .constant(IconSettings()),
        isVisible: .constant(true),
        currentIconType: .calculator,
        onSettingsChanged: {
            print("Settings changed in preview")
        }
    )
    .frame(width: 300, height: 600)
}
