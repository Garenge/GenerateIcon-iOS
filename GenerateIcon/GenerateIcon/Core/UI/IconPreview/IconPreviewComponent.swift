import SwiftUI

/// 封装的图标预览组件
struct IconPreviewComponent: View {
    let config: IconPreviewConfig
    
    @State private var previewImage: UIImage?
    @State private var currentIconType: IconType?
    @State private var currentTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 16) {
            // 图标预览区域
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: config.previewSize.width, height: config.previewSize.height)
                
                if config.isLoading {
                    // 加载状态
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("生成中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                } else if let errorMessage = config.errorMessage {
                    // 错误状态
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        Text("生成失败")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else if let previewImage = previewImage {
                    // 预设图标
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: config.previewSize.width * 0.8, height: config.previewSize.height * 0.8)
                        .cornerRadius(8)
                } else {
                    // 默认状态
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("暂无预览")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // 重新生成按钮（AI图标时显示）
            if config.customIcon != nil && config.showRegenerateButton {
                Button(action: {
                    config.onRegenerate?()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("重新生成")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                }
            }
            
            // 预览信息
            if config.showPreviewInfo {
                VStack(spacing: 4) {
                    Text("预览 (\(Int(config.previewSize.width))x\(Int(config.previewSize.height)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("点击按钮将生成一个1024x1024像素的\(config.iconType.displayName)图标并自动下载")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            loadPreview()
        }
        .onChange(of: config.iconType) { newType in
            loadPreview()
        }
        .onChange(of: config.settings) { _ in
            loadPreview()
        }
        // 订阅设置变更全局通知，立即重载预览
        .onReceive(NotificationCenter.default.publisher(for: .settingsDidChange)) { _ in
            loadPreview()
        }
    }
    
    private func loadPreview() {
        // 取消之前的任务
        currentTask?.cancel()
        
        // 设置当前图标类型
        currentIconType = config.iconType
        
        // 清除之前的预览
        previewImage = nil
        
        // 生成预览
        let expectedType = config.iconType
        currentTask = Task {
            await generatePreview(targetIconType: expectedType)
        }
    }
    
    @MainActor
    private func generatePreview(targetIconType: IconType) async {
        
        do {
            let service = IconGeneratorService()
            let image: UIImage
            if let custom = config.customIcon {
                // 组合自定义(透明文字)图与当前设置的背景/圆角等，保证与设置一致
                image = try await service.composePreview(
                    with: custom,
                    size: config.previewSize,
                    settings: config.settings
                )
            } else {
                image = try await service.generatePreview(
                    type: targetIconType,
                    size: config.previewSize,
                    settings: config.settings
                )
            }
            
            // 检查任务是否被取消或图标类型是否已改变
            guard !Task.isCancelled && config.iconType == targetIconType else { return }
            
            previewImage = image
        } catch {
            // 检查任务是否被取消或图标类型是否已改变
            guard !Task.isCancelled && config.iconType == targetIconType else { return }
            
            print("生成预览失败: \(error)")
        }
    }
}

#Preview {
    IconPreviewComponent(
        config: IconPreviewConfig(
            iconType: .heart,
            settings: IconSettings(),
            isLoading: false,
            showPreviewInfo: true
        )
    )
    .padding()
}
