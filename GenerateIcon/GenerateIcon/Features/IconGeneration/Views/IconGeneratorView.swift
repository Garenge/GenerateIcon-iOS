import SwiftUI
import UIKit

// MARK: - 图标生成主视图
struct IconGeneratorView: View {
    @EnvironmentObject var globalViewModels: GlobalIconViewModels
    @State private var showingSettings = false
    @State private var showingSizeSelection = false
    @State private var showingAIModal = false
    @State private var showingIconSelector = false
    @State private var showingSaveConfirmation = false
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var isSaving = false
    
    // 便捷访问全局ViewModel
    private var iconGenerator: IconGeneratorViewModel {
        globalViewModels.iconGenerator
    }
    
    // 使用全局状态作为选中的图标类型
    private var selectedIconType: IconType {
        iconGenerator.selectedPresetType
    }
    
    // MARK: - 保存到相册
    private func saveToPhotoLibrary() {
        guard !isSaving else { return }
        
        isSaving = true
        
        Task {
            do {
                // 生成当前配置的图标
                let service = IconGeneratorService()
                let image = try await service.generatePreview(
                    iconContent: globalViewModels.iconContent,
                    previewConfig: globalViewModels.previewConfig
                )
                
                // 保存到相册
                let fileManager = FileManagerService()
                try await fileManager.saveToPhotoLibrary(image)
                
                await MainActor.run {
                    saveAlertMessage = "图标已成功保存到相册！"
                    showingSaveAlert = true
                    isSaving = false
                }
            } catch {
                await MainActor.run {
                    saveAlertMessage = "保存失败：\(error.localizedDescription)"
                    showingSaveAlert = true
                    isSaving = false
                }
            }
        }
    }
    
    // MARK: - 打开相册
    private func openPhotoLibrary() {
        if let url = URL(string: "photos-redirect://") {
            UIApplication.shared.open(url)
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // 左侧：图标类型选择
                    if geometry.size.width > 800 {
                        IconTypeSelectorView(
                            selectedType: selectedIconType,
                            onAITap: { showingAIModal = true },
                            isInAIMode: iconGenerator.isInAIMode,
                            onExitAI: {
                                iconGenerator.clearAIIcon()
                                iconGenerator.refreshPreview()
                            },
                            onPresetSelected: { newType in
                                // 选择预设图标时更新全局状态并刷新预览
                                globalViewModels.setPresetIcon(newType)
                                print("🔄 IconGeneratorView: Preset icon changed to \(newType.displayName)")
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
                                    Text(iconGenerator.isInAIMode ? "🎨 AI生成" : selectedIconType.displayName)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .background(iconGenerator.isInAIMode ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .foregroundColor(iconGenerator.isInAIMode ? .orange : .blue)
                        }
                        
                        // 预览区域
                        IconPreviewComponent(iconContent: globalViewModels.iconContent, previewConfig: globalViewModels.previewConfig)
                            .frame(width: 256, height: 256)
                            .id("preview-\(iconGenerator.selectedPresetType.rawValue)-\(iconGenerator.contentType == .text ? "text" : "preset")-\(iconGenerator.isInAIMode ? "ai" : "preset")")
                        
                        // 生成按钮
                        Button(action: {
                            showingSaveConfirmation = true
                        }) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paintbrush.fill")
                                }
                                Text(isSaving ? "生成中..." : "生成并下载图标")
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
                        .disabled(isSaving)
                        
                        if iconGenerator.isGenerating {
                            ProgressView("生成中... \(Int(iconGenerator.generationProgress * 100))%")
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 右侧：设置面板
                    if geometry.size.width > 1000 {
                        SettingsPanelView(
                            iconContent: globalViewModels.iconContent,
                            previewConfig: globalViewModels.previewConfig,
                            isVisible: $showingSettings
                        )
                        .frame(width: 300)
                    }
                }
            }
            .navigationTitle("图标生成器")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // 打开相册
                        if let url = URL(string: "photos-redirect://") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsPanelView(
                    iconContent: globalViewModels.iconContent,
                    previewConfig: globalViewModels.previewConfig,
                    isVisible: $showingSettings
                )
            }
            .alert("确认保存", isPresented: $showingSaveConfirmation) {
                Button("取消", role: .cancel) { }
                Button("保存") {
                    saveToPhotoLibrary()
                }
            } message: {
                Text("是否将当前图标保存到相册？")
            }
            .alert("保存结果", isPresented: $showingSaveAlert) {
                Button("确定", role: .cancel) { }
                Button("打开相册") {
                    openPhotoLibrary()
                }
            } message: {
                Text(saveAlertMessage)
            }
        }
        .sheet(isPresented: $showingSizeSelection) {
            SizeSelectionView(
                iconType: selectedIconType,
                settings: IconSettings(), // 使用默认设置，因为现在设置已经整合到iconGenerator中
                onGenerate: { size, downloadType in
                    Task {
                        await iconGenerator.generateIcon(
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
                settings: Binding<IconSettings>(
                    get: { iconGenerator.getIconSettings() },
                    set: { iconGenerator.updateIconSettings($0) }
                ),
                onGenerate: { prompt, aiSettings in
                    Task {
                        await iconGenerator.generateAIIcon(
                            prompt: prompt,
                            settings: aiSettings
                        )
                        // Set the AI generated image as custom icon
                        if let aiImage = iconGenerator.lastGeneratedIcon {
                            globalViewModels.setCustomIcon(aiImage)
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $showingIconSelector) {
            IconSelectorView(
                selectedType: selectedIconType,
                onAITap: {
                    showingIconSelector = false
                    showingAIModal = true
                },
                isInAIMode: iconGenerator.isInAIMode,
                onExitAI: {
                    iconGenerator.clearAIIcon()
                    iconGenerator.refreshPreview()
                },
                onPresetSelected: { newType in
                    // 选择预设图标时更新全局状态并刷新预览
                    globalViewModels.setPresetIcon(newType)
                    print("🔄 IconGeneratorView: Preset icon changed to \(newType.displayName)")
                }
            )
        }
        .onAppear {
            iconGenerator.loadSettings()
        }
        .alert("保存到相册", isPresented: $globalViewModels.iconGenerator.showingSaveConfirmation) {
            Button("取消", role: .cancel) {
                iconGenerator.cancelSave()
            }
            Button("保存") {
                Task {
                    await iconGenerator.confirmSaveToPhotoLibrary()
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
    let selectedType: IconType
    let onAITap: () -> Void
    let isInAIMode: Bool
    let onExitAI: () -> Void
    let onPresetSelected: (IconType) -> Void // New closure for preset selection
    
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
                                        onTap: {
                                            onPresetSelected(type) // Call the new closure
                                        }
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