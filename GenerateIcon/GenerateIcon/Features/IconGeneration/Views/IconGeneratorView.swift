import SwiftUI

// MARK: - 图标生成主视图
struct IconGeneratorView: View {
    @StateObject private var viewModel = IconGeneratorViewModel()
    @State private var selectedIconType: IconType = .calculator
    @State private var showingSettings = false
    @State private var showingSizeSelection = false
    @State private var showingAIModal = false
    @State private var showingIconSelector = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // 左侧：图标类型选择
                    if geometry.size.width > 800 {
                        IconTypeSelectorView(
                            selectedType: $selectedIconType,
                            onAITap: { showingAIModal = true },
                            isInAIMode: viewModel.isInAIMode,
                            onExitAI: {
                                viewModel.clearAIIcon()
                                viewModel.refreshPreview()
                            }
                        )
                        .frame(width: 200)
                    }
                    
                    // 中央：预览和生成
                    VStack(spacing: 20) {
                        // 图标选择按钮（小屏设备）
                        if geometry.size.width <= 800 {
                            Button(action: {
                                if viewModel.isInAIMode {
                                    // AI模式下点击按钮，直接退出AI模式，显示原先的预设图标
                                    viewModel.clearAIIcon()
                                    viewModel.refreshPreview()
                                } else {
                                    // 预设模式下点击按钮，打开选择器
                                    showingIconSelector = true
                                }
                            }) {
                                HStack {
                                    Text(viewModel.isInAIMode ? "🎨 AI生成" : selectedIconType.displayName)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: viewModel.isInAIMode ? "xmark.circle" : "chevron.down")
                                }
                                .padding()
                                .background(viewModel.isInAIMode ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .foregroundColor(viewModel.isInAIMode ? .orange : .blue)
                        }
                        
                        // 预览区域
                        if let aiIcon = viewModel.lastGeneratedIcon {
                            VStack(spacing: 12) {
                                Text("🎨 AI生成的图标")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                        .frame(width: 256, height: 256)
                                    
                                    Image(uiImage: aiIcon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 240, height: 240)
                                        .cornerRadius(12)
                                        .animation(.easeInOut(duration: 0.3), value: aiIcon)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                
                                Text("AI生成结果")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("重新生成") {
                                    showingAIModal = true
                                }
                                .buttonStyle(.bordered)
                            }
                        } else {
                            IconPreviewView(
                                iconType: selectedIconType,
                                settings: viewModel.settings
                            )
                        }
                        
                        // 生成按钮
                        Button(action: {
                            showingSizeSelection = true
                        }) {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                Text("生成并下载图标")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isGenerating)
                        
                        if viewModel.isGenerating {
                            ProgressView("生成中... \(Int(viewModel.generationProgress * 100))%")
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 右侧：设置面板
                    if geometry.size.width > 1000 {
                        SettingsPanelView(
                            settings: $viewModel.settings,
                            isVisible: $showingSettings
                        )
                        .frame(width: 300)
                    }
                }
            }
            .navigationTitle("图标生成器")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsPanelView(
                    settings: $viewModel.settings,
                    isVisible: $showingSettings
                )
            }
        }
        .sheet(isPresented: $showingSizeSelection) {
            SizeSelectionView(
                iconType: selectedIconType,
                settings: viewModel.settings,
                onGenerate: { size, downloadType in
                    Task {
                        await viewModel.generateIcon(
                            type: selectedIconType,
                            size: size,
                            downloadType: downloadType
                        )
                    }
                }
            )
        }
        .sheet(isPresented: $showingAIModal) {
            AIGeneratorView(
                settings: $viewModel.settings,
                onGenerate: { prompt, aiSettings in
                    Task {
                        await viewModel.generateAIIcon(
                            prompt: prompt,
                            settings: aiSettings
                        )
                    }
                }
            )
        }
        .sheet(isPresented: $showingIconSelector) {
            IconSelectorView(
                selectedType: $selectedIconType,
                onAITap: { 
                    showingIconSelector = false
                    showingAIModal = true
                },
                isInAIMode: viewModel.isInAIMode,
                onExitAI: {
                    viewModel.clearAIIcon()
                    viewModel.refreshPreview()
                },
                onPresetSelected: {
                    // 选择预设图标时刷新预览
                    viewModel.refreshPreview()
                }
            )
        }
        .onChange(of: selectedIconType) { newType in
            // 图标类型改变时刷新预览
            print("🔄 IconGeneratorView: Icon type changed to: \(newType.name)")
            // 清除AI生成的图标，切换到预设图标预览
            viewModel.clearAIIcon()
            // 立即触发UI更新，不延迟
            viewModel.refreshPreview()
        }
        .onAppear {
            viewModel.loadSettings()
        }
        .alert("保存到相册", isPresented: $viewModel.showingSaveConfirmation) {
            Button("取消", role: .cancel) {
                viewModel.cancelSave()
            }
            Button("保存") {
                Task {
                    await viewModel.confirmSaveToPhotoLibrary()
                }
            }
        } message: {
            Text("是否将生成的图标保存到相册？")
        }
        .hudToast() // 添加HUD和Toast支持
    }
}

// MARK: - 图标类型选择器
struct IconTypeSelectorView: View {
    @Binding var selectedType: IconType
    let onAITap: () -> Void
    let isInAIMode: Bool
    let onExitAI: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("图标类型")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // 图标分类
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(iconCategories) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 6) {
                                ForEach(category.iconTypes) { type in
                                    IconTypeButton(
                                        type: type,
                                        isSelected: selectedType == type,
                                        onTap: { selectedType = type }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            
            // AI生成分类
            VStack(alignment: .leading, spacing: 8) {
                Text("AI生成")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                LazyVStack(spacing: 6) {
                    Button(action: {
                        if isInAIMode {
                            onExitAI()
                        } else {
                            onAITap()
                        }
                    }) {
                        HStack {
                            Text("🎨 AI生成")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: isInAIMode ? "xmark.circle" : "sparkles")
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var iconCategories: [IconCategory] {
        [.basic, .office, .communication, .media, .tools]
    }
}

// MARK: - 图标类型按钮
struct IconTypeButton: View {
    let type: IconType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .foregroundColor(.primary)
    }
}

// MARK: - 预览视图
struct IconPreviewView: View {
    let iconType: IconType
    let settings: IconSettings
    @State private var previewImage: UIImage?
    @State private var isLoading = false
    @State private var previewTask: Task<Void, Never>?
    @State private var currentIconType: IconType?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(iconType.emoji) \(iconType.name)图标")
                .font(.title2)
                .fontWeight(.semibold)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(width: 256, height: 256)
                
                if isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("生成预览中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if let image = previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240)
                        .cornerRadius(12)
                        .animation(.easeInOut(duration: 0.3), value: previewImage)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("点击生成预览")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            
            Text("预览 (256x256)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(iconType.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .onAppear {
            currentIconType = iconType
            loadPreview()
        }
        .onChange(of: iconType) { newType in
            print("🔄 IconPreviewView: iconType changed from \(currentIconType?.name ?? "nil") to \(newType.name)")
            
            // 立即取消之前的任务
            previewTask?.cancel()
            
            // 更新当前图标类型
            currentIconType = newType
            
            // 强制清除之前的预览图片
            self.previewImage = nil
            self.isLoading = true
            
            // 立即开始加载新预览
            loadPreview()
        }
        .onChange(of: settings) { _ in
            // 延迟加载，避免频繁更新
            debouncedLoadPreview()
        }
        .onDisappear {
            previewTask?.cancel()
        }
    }
    
    private func loadPreview() {
        previewTask?.cancel()
        isLoading = true
        
        // 获取当前要加载的图标类型，避免异步任务中的状态不一致
        let targetIconType = currentIconType ?? iconType
        print("🔄 Loading preview for: \(targetIconType.name)")
        
        previewTask = Task {
            do {
                // 在任务开始时再次检查是否被取消
                if Task.isCancelled {
                    print("🚫 Preview task cancelled before starting for: \(targetIconType.name)")
                    return
                }
                
                let service = IconGeneratorService()
                let image = try await service.generatePreview(
                    type: targetIconType,
                    size: CGSize(width: 256, height: 256),
                    settings: settings
                )
                
                // 在更新UI前检查任务是否被取消和图标类型是否仍然匹配
                if !Task.isCancelled && currentIconType == targetIconType {
                    await MainActor.run {
                        print("✅ Preview loaded for: \(targetIconType.name)")
                        self.previewImage = image
                        self.isLoading = false
                    }
                } else {
                    print("🚫 Preview task cancelled or icon type changed for: \(targetIconType.name)")
                }
            } catch {
                // 在更新UI前检查任务是否被取消和图标类型是否仍然匹配
                if !Task.isCancelled && currentIconType == targetIconType {
                    await MainActor.run {
                        print("❌ Preview failed for: \(targetIconType.name), error: \(error)")
                        self.isLoading = false
                        // 如果预览生成失败，显示默认图标
                        self.previewImage = createDefaultIcon(for: targetIconType)
                    }
                } else {
                    print("🚫 Preview error handling cancelled for: \(targetIconType.name)")
                }
            }
        }
    }
    
    private func createDefaultIcon(for type: IconType) -> UIImage {
        let size = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 设置背景
            cgContext.setFillColor(UIColor.systemBlue.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: size))
            
            // 绘制图标
            cgContext.setFillColor(UIColor.white.cgColor)
            let iconRect = CGRect(x: 64, y: 64, width: 128, height: 128)
            cgContext.fill(iconRect)
            
            // 绘制图标文字
            let text = type.emoji
            let font = UIFont.systemFont(ofSize: 64)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black
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
    
    private func debouncedLoadPreview() {
        previewTask?.cancel()
        
        // 获取当前要加载的图标类型
        let targetIconType = currentIconType ?? iconType
        
        previewTask = Task {
            // 延迟500ms，避免频繁更新
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // 检查任务是否被取消和图标类型是否仍然匹配
            if !Task.isCancelled && currentIconType == targetIconType {
                loadPreview()
            } else {
                print("🚫 Debounced preview cancelled for: \(targetIconType.name)")
            }
        }
    }
}

#Preview {
    IconGeneratorView()
}
