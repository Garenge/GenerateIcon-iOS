import SwiftUI

// MARK: - 预览组件
struct IconPreviewComponent: View {
    @ObservedObject var iconContent: IconContentViewModel
    @ObservedObject var previewConfig: PreviewConfigViewModel
    @State private var previewImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var currentTask: Task<Void, Never>?
    
    init(iconContent: IconContentViewModel, previewConfig: PreviewConfigViewModel) {
        self.iconContent = iconContent
        self.previewConfig = previewConfig
        print("🔄 IconPreviewComponent: Initialized with contentType=\(iconContent.contentType), presetType=\(iconContent.selectedPresetType.displayName)")
        print("🔄 IconPreviewComponent: PreviewConfig size=\(previewConfig.previewSize)")
        print("🔄 IconPreviewComponent: IconContent objectId=\(ObjectIdentifier(iconContent))")
        print("🔄 IconPreviewComponent: PreviewConfig objectId=\(ObjectIdentifier(previewConfig))")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 预览区域
            ZStack {
                // 背景 - 使用棋盘格图案来显示透明度
                CheckerboardBackground()
                    .frame(width: previewConfig.previewSize.width, height: previewConfig.previewSize.height)
                
                if isLoading {
                    // 加载状态
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("生成中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                } else if let previewImage = previewImage {
                    // 预览图片
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: previewConfig.previewSize.width * 0.8, height: previewConfig.previewSize.height * 0.8)
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
            
            // 预览信息
            VStack(spacing: 4) {
                Text("预览 (\(Int(previewConfig.previewSize.width))x\(Int(previewConfig.previewSize.height)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            print("🔄 IconPreviewComponent: onAppear triggered")
            print("🔄 IconPreviewComponent: iconContent contentType=\(iconContent.contentType), presetType=\(iconContent.selectedPresetType.displayName)")
            print("🔄 IconPreviewComponent: previewConfig size=\(previewConfig.previewSize)")
            generatePreview()
        }
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
        .onChange(of: iconContent.contentType) { newType in 
            print("🔄 IconPreviewComponent: Content type changed to \(newType)")
            generatePreview() 
        }
        .onChange(of: iconContent.selectedPresetType) { newType in 
            print("🔄 IconPreviewComponent: Preset type changed to \(newType.displayName)")
            generatePreview() 
        }
        .onChange(of: iconContent.customImage) { _ in 
            print("🔄 IconPreviewComponent: Custom image changed")
            generatePreview() 
        }
        .onChange(of: iconContent.textConfig.isEnabled) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.text) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.fontSize) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.textColor) { _ in generatePreview() }
        .onChange(of: iconContent.textConfig.customFontSize) { _ in generatePreview() }
    }
    
    private func generatePreview() {
        // 取消之前的任务
        currentTask?.cancel()
        
        print("🔄 IconPreviewComponent: Starting preview generation for \(iconContent.contentType) - \(iconContent.selectedPresetType.displayName)")
        
        isLoading = true
        previewImage = nil
        
        currentTask = Task {
            await generatePreviewAsync()
        }
    }
    
    @MainActor
    private func generatePreviewAsync() async {
        do {
            print("🔄 IconPreviewComponent: Calling IconGeneratorService.generatePreview")
            let service = IconGeneratorService()
            let image = try await service.generatePreview(
                iconContent: iconContent,
                previewConfig: previewConfig
            )
            
            guard !Task.isCancelled else { 
                print("🔄 IconPreviewComponent: Task was cancelled")
                return 
            }
            
            print("🔄 IconPreviewComponent: Preview generated successfully, image size=\(image.size)")
            previewImage = image
            isLoading = false
        } catch {
            guard !Task.isCancelled else { 
                print("🔄 IconPreviewComponent: Task was cancelled during error handling")
                return 
            }
            
            print("🔄 IconPreviewComponent: Preview generation failed: \(error)")
            isLoading = false
            
            // 创建一个测试图标作为后备
            print("🔄 IconPreviewComponent: Creating fallback test image")
            let testImage = createTestImage()
            previewImage = testImage
        }
    }
    
    // MARK: - 创建测试图标
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置背景色
            cgContext.setFillColor(UIColor.systemBlue.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: size))
            
            // 绘制一个简单的测试图标
            cgContext.setFillColor(UIColor.white.cgColor)
            let iconRect = CGRect(x: 64, y: 64, width: 128, height: 128)
            cgContext.fill(iconRect)
            
            // 绘制文字
            let text = "TEST"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.systemBlue
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

// MARK: - 棋盘格背景组件
struct CheckerboardBackground: View {
    let squareSize: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let columns = Int(width / squareSize) + 1
            let rows = Int(height / squareSize) + 1
            
            HStack(spacing: 0) {
                ForEach(0..<columns, id: \.self) { column in
                    VStack(spacing: 0) {
                        ForEach(0..<rows, id: \.self) { row in
                            Rectangle()
                                .fill((column + row) % 2 == 0 ? Color.white : Color.gray.opacity(0.3))
                                .frame(width: squareSize, height: squareSize)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let iconContent = IconContentViewModel()
    let previewConfig = PreviewConfigViewModel()
    return IconPreviewComponent(iconContent: iconContent, previewConfig: previewConfig)
        .padding()
}
