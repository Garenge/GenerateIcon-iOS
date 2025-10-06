import SwiftUI

// MARK: - 设置面板视图
struct SettingsPanelView: View {
    @Binding var settings: IconSettings
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Text("🎨 底图设置")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    isVisible = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            
            ScrollView {
                VStack(spacing: 20) {
                    // 图标外框设置
                    iconFrameSettings
                    
                    // 底图样式设置
                    backgroundStyleSettings
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
        isVisible: .constant(true)
    )
    .frame(width: 300, height: 600)
}
