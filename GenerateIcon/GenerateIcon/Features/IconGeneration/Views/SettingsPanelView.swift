import SwiftUI

// MARK: - 设置面板视图
struct SettingsPanelView: View {
    @ObservedObject var iconContent: IconContentViewModel
    @ObservedObject var previewConfig: PreviewConfigViewModel
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部预览区域 - 和AI生成页面一致
            ZStack {
                // 预览图
                SimpleIconPreview()
                    .frame(height: 120)
                
                // 标题和关闭按钮 - 覆盖在预览图顶部
                VStack {
                    HStack {
                        Text("🎨 图标设置")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            isVisible = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer()
                }
            }
            .frame(height: 120)
            .background(Color(.systemBackground))
            
            Divider()
                .padding(.top, 10)
            
            // 设置选项区域
            ScrollView {
                VStack(spacing: 20) {
                    
                    // ViewA 设置
                    viewASettings
                    
                    // ViewB 设置
                    viewBSettings
                    
                    // ViewC 设置
                    viewCSettings
                    
                    // 重置按钮
                    Button("重置为默认设置") {
                        previewConfig.resetToDefaults()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .padding(.top, 22)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
    SettingsPanelView(
        iconContent: IconContentViewModel(),
        previewConfig: PreviewConfigViewModel(),
        isVisible: .constant(true)
    )
    .frame(width: 300, height: 600)
}
