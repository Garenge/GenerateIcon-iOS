import SwiftUI

// MARK: - 简化图标预览组件 - 用于设置页面等
struct SimpleIconPreview: View {
    @ObservedObject var iconContent: IconContentViewModel
    @ObservedObject var previewConfig: PreviewConfigViewModel
    @State private var previewImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var currentTask: Task<Void, Never>?
    @State private var debounceTask: Task<Void, Never>?
    
    init(iconContent: IconContentViewModel, previewConfig: PreviewConfigViewModel) {
        self.iconContent = iconContent
        self.previewConfig = previewConfig
    }
    
    var body: some View {
        // 预览区域 - 居中显示
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 140, height: 140)
            
            if isLoading {
                // 加载状态
                ProgressView()
                    .scaleEffect(0.8)
            } else if let previewImage = previewImage {
                // 预览图片
                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(6)
            } else {
                // 默认状态
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    Text("暂无预览")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            generatePreview()
        }
        .onChange(of: previewConfig.viewACornerRadius) { _ in generatePreview() }
        .onChange(of: iconContent.contentType) { _ in generatePreview() }
        .onChange(of: iconContent.selectedPresetType) { _ in generatePreview() }
        .onChange(of: iconContent.customImage) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.isEnabled) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.text) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.fontSize) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.fontFamily) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.textStyle) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.textColor) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.customFontSize) { _ in generatePreview() }
        .onChange(of: previewConfig.viewABackgroundColor) { _ in generatePreview() }
        .onChange(of: previewConfig.viewABorderColor) { _ in generatePreview() }
        .onChange(of: previewConfig.viewACornerRadius) { newValue in 
            print("🔍 SimpleIconPreview - ViewA圆角半径变化: \(newValue)")
            generatePreview() 
        }
        .onChange(of: previewConfig.viewAPadding) { _ in generatePreview() }
        .onChange(of: previewConfig.viewABorderWidth) { _ in generatePreview() }
        .onChange(of: previewConfig.viewBBackgroundColor) { _ in generatePreview() }
        .onChange(of: previewConfig.viewBBorderColor) { _ in generatePreview() }
        .onChange(of: previewConfig.viewBCornerRadius) { _ in generatePreview() }
        .onChange(of: previewConfig.viewBPadding) { _ in generatePreview() }
        .onChange(of: previewConfig.viewBBorderWidth) { _ in generatePreview() }
        .onChange(of: previewConfig.viewBShadowIntensity) { _ in generatePreview() }
        .onChange(of: previewConfig.iconScale) { _ in generatePreview() }
        .onChange(of: previewConfig.iconRotation) { _ in generatePreview() }
        .onChange(of: previewConfig.iconOpacity) { _ in generatePreview() }
    }
    
    private func generatePreview() {
        // 取消之前的防抖任务
        debounceTask?.cancel()
        
        // 创建新的防抖任务
        debounceTask = Task {
            // 延迟300毫秒（防抖时间）
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            // 检查是否被取消
            guard !Task.isCancelled else { return }
            
            // 取消之前的预览生成任务
            currentTask?.cancel()
            
            // 创建新的预览生成任务
            currentTask = Task {
                await generatePreviewAsync()
            }
        }
    }
    
    @MainActor
    private func generatePreviewAsync() async {
        do {
            let service = IconGeneratorService()
            let image = try await service.generatePreview(
                iconContent: iconContent,
                previewConfig: previewConfig
            )
            
            guard !Task.isCancelled else { return }
            
            previewImage = image
            isLoading = false
        } catch {
            guard !Task.isCancelled else { return }
            
            print("生成预览失败: \(error)")
            isLoading = false
        }
    }
}

#Preview {
    SimpleIconPreview(
        iconContent: IconContentViewModel(),
        previewConfig: PreviewConfigViewModel()
    )
    .padding()
}
