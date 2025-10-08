import SwiftUI

// MARK: - 简化图标预览组件 - 用于设置页面等
struct SimpleIconPreview: View {
    @EnvironmentObject var globalViewModels: GlobalIconViewModels
    @State private var previewImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var currentTask: Task<Void, Never>?
    
    private var iconContent: IconContentViewModel {
        globalViewModels.iconContent
    }
    
    private var previewConfig: PreviewConfigViewModel {
        globalViewModels.previewConfig
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 预览标题
            Text("图标预览")
                .font(.headline)
                .fontWeight(.semibold)
            
            // 预览区域
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                if isLoading {
                    // 加载状态
                    ProgressView()
                        .scaleEffect(0.8)
                } else if let previewImage = previewImage {
                    // 预览图片
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
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
            
            // 预览信息
            VStack(spacing: 2) {
                Text("\(Int(previewConfig.previewSize.width))x\(Int(previewConfig.previewSize.height))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(iconContent.contentType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            generatePreview()
        }
        .onChange(of: iconContent.contentType) { _ in generatePreview() }
        .onChange(of: iconContent.selectedPresetType) { _ in generatePreview() }
        .onChange(of: iconContent.customImage) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.isEnabled) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.text) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.fontSize) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.textColor) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.customFontSize) { _ in generatePreview() }
        .onChange(of: previewConfig.viewABackgroundColor) { _ in generatePreview() }
        .onChange(of: previewConfig.viewABorderColor) { _ in generatePreview() }
        .onChange(of: previewConfig.viewACornerRadius) { _ in generatePreview() }
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
        // 取消之前的任务
        currentTask?.cancel()
        
        isLoading = true
        previewImage = nil
        
        currentTask = Task {
            await generatePreviewAsync()
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
    SimpleIconPreview()
        .withGlobalIconViewModels()
        .padding()
}
