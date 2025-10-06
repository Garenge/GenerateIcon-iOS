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
                                // 无论是AI模式还是预设模式，都打开选择器
                                showingIconSelector = true
                            }) {
                                HStack {
                                    Text(viewModel.isInAIMode ? "🎨 AI生成" : selectedIconType.displayName)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .background(viewModel.isInAIMode ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .foregroundColor(viewModel.isInAIMode ? .orange : .blue)
                        }
                        
                        // 预览区域
                        if let aiIcon = viewModel.lastGeneratedIcon {
                            IconPreviewComponent(
                                config: IconPreviewConfig(
                                    iconType: selectedIconType,
                                    settings: viewModel.settings,
                                    isLoading: viewModel.isGenerating,
                                    errorMessage: viewModel.errorMessage,
                                    customIcon: aiIcon,
                                    showRegenerateButton: true,
                                    onRegenerate: {
                                        showingAIModal = true
                                    },
                                    previewSize: CGSize(width: 256, height: 256),
                                    showPreviewInfo: true
                                )
                            )
                        } else {
                            IconPreviewComponent(
                                config: IconPreviewConfig(
                                    iconType: selectedIconType,
                                    settings: viewModel.settings,
                                    isLoading: viewModel.isGenerating,
                                    errorMessage: viewModel.errorMessage,
                                    previewSize: CGSize(width: 256, height: 256),
                                    showPreviewInfo: true
                                )
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

#Preview {
    IconGeneratorView()
}