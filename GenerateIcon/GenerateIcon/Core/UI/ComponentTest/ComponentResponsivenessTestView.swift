import SwiftUI

/// 组件响应性测试视图
struct ComponentResponsivenessTestView: View {
    @State private var testIconType: IconType = .heart
    @State private var testSettings = IconSettings()
    @State private var testText = "测试文字"
    @State private var testFontSize: CGFloat = 100
    @State private var testFontName = "Arial"
    @State private var testTextColor: Color = .white
    @State private var testBackgroundColor: Color = .blue
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("组件响应性测试")
                    .font(.title)
                    .fontWeight(.bold)
                
                // 图标预览组件测试
                VStack(alignment: .leading, spacing: 12) {
                    Text("图标预览组件测试")
                        .font(.headline)
                    
                    IconPreviewComponent(
                        iconContent: IconContentViewModel(),
                        previewConfig: PreviewConfigViewModel()
                    )
                    
                    // 控制按钮
                    HStack {
                        Button("切换图标") {
                            testIconType = testIconType == .heart ? .star : .heart
                        }
                        .buttonStyle(.bordered)
                        
                        Button("调整圆角") {
                            testSettings.cornerRadius = testSettings.cornerRadius == 8 ? 16 : 8
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 文字预览组件测试
                VStack(alignment: .leading, spacing: 12) {
                    Text("文字预览组件测试")
                        .font(.headline)
                    
                    TextPreviewComponent(
                        config: TextPreviewConfig(
                            text: testText,
                            fontSize: testFontSize,
                            fontName: testFontName,
                            textColor: testTextColor,
                            backgroundColor: testBackgroundColor,
                            previewSize: CGSize(width: 150, height: 150),
                            showPreviewInfo: true
                        )
                    )
                    
                    // 控制按钮
                    VStack(spacing: 8) {
                        HStack {
                            Button("改变文字") {
                                testText = testText == "测试文字" ? "Hello World" : "测试文字"
                            }
                            .buttonStyle(.bordered)
                            
                            Button("改变字体") {
                                testFontName = testFontName == "Arial" ? "Helvetica" : "Arial"
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        HStack {
                            Button("改变颜色") {
                                testTextColor = testTextColor == .white ? .black : .white
                            }
                            .buttonStyle(.bordered)
                            
                            Button("改变背景") {
                                testBackgroundColor = testBackgroundColor == .blue ? .red : .blue
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        HStack {
                            Button("改变大小") {
                                testFontSize = testFontSize == 100 ? 150 : 100
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 当前状态显示
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前状态")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("图标类型: \(testIconType.displayName)")
                        Text("圆角: \(Int(testSettings.cornerRadius))")
                        Text("文字: \(testText)")
                        Text("字体: \(testFontName)")
                        Text("字体大小: \(Int(testFontSize))")
                        Text("文字颜色: \(testTextColor == .white ? "白色" : "黑色")")
                        Text("背景颜色: \(testBackgroundColor == .blue ? "蓝色" : "红色")")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

#Preview {
    ComponentResponsivenessTestView()
}
