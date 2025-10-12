import SwiftUI

// MARK: - 尺寸选择视图
struct SizeSelectionView: View {
    let iconType: IconType
    let settings: IconSettings
    let onGenerate: (CGSize, DownloadType) -> Void
    
    @State private var selectedDownloadType: DownloadType = .custom
    @State private var selectedSize: CGFloat = 1024
    @State private var customSize: String = "1024"
    @State private var showingCustomSize = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 下载类型选择
                Picker("下载类型", selection: $selectedDownloadType) {
                    ForEach(DownloadType.allCases) { type in
                        Text(type.name).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedDownloadType == .custom {
                    customSizeContent
                } else {
                    iosSizeContent
                }
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 16) {
                    Button("取消") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Button(selectedDownloadType == .ios ? "生成并分享" : "生成并保存") {
                        let size = selectedDownloadType == .custom ? 
                            CGSize(width: selectedSize, height: selectedSize) : 
                            CGSize.zero
                        
                        // 显示开始生成的Toast
                        if selectedDownloadType == .ios {
                            HUDToastManager.shared.showToast(message: "开始生成iOS图标集...", type: .info, duration: 1.5)
                        } else {
                            HUDToastManager.shared.showToast(message: "开始生成 \(Int(selectedSize))px 图标...", type: .info, duration: 1.5)
                        }
                        
                        onGenerate(size, selectedDownloadType)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("选择尺寸")
            .navigationBarTitleDisplayMode(.inline)
        }
        .hudToast() // 添加HUD和Toast支持
    }
    
    // MARK: - 自定义尺寸内容
    private var customSizeContent: some View {
        VStack(spacing: 20) {
            Text("📏 选择尺寸")
                .font(.headline)
            
            // 预设尺寸
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(SizePreset.presets) { preset in
                    Button(action: {
                        selectedSize = preset.size
                        customSize = String(Int(preset.size))
                        
                        // 显示选择提示
                        HUDToastManager.shared.showToast(message: "已选择 \(preset.name)", type: .info, duration: 1.0)
                    }) {
                        VStack {
                            Text(preset.name)
                                .font(.headline)
                            Text(preset.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedSize == preset.size ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedSize == preset.size ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            
            // 自定义尺寸输入
            VStack(alignment: .leading, spacing: 8) {
                Text("自定义尺寸")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    TextField("输入尺寸", text: $customSize)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: customSize) { value in
                            if let size = Double(value) {
                                selectedSize = CGFloat(size)
                            }
                        }
                    
                    Text("px")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // 当前尺寸显示
            Text("当前尺寸: \(Int(selectedSize))px")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("💡 常用尺寸: 24px(工具栏), 32px(任务栏), 64px(桌面), 128px(应用商店), 1024px(高质量)")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - iOS尺寸内容
    private var iosSizeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📱 一键下载所有iOS应用图标尺寸")
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Text("包含iPhone、iPad所需的所有规格，自动压缩为ZIP文件")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(iosSizeCategories, id: \.title) { category in
                        iosSizeCategory(category)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func iosSizeCategory(_ category: IOSSizeCategory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(category.sizes) { size in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(size.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text("\(Int(size.size))×\(Int(size.size))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
    }
    
    // MARK: - iOS尺寸分类
    private var iosSizeCategories: [IOSSizeCategory] {
        let sizes = SizePreset.iosSizes
        
        return [
            IOSSizeCategory(
                title: "📱 iPhone 主屏幕",
                sizes: sizes.filter { $0.name.contains("60@") }
            ),
            IOSSizeCategory(
                title: "⚙️ 设置 & 通知",
                sizes: sizes.filter { $0.name.contains("29") || $0.name.contains("20") }
            ),
            IOSSizeCategory(
                title: "🔍 Spotlight 搜索",
                sizes: sizes.filter { $0.name.contains("40") }
            ),
            IOSSizeCategory(
                title: "📱 iPad",
                sizes: sizes.filter { $0.name.contains("76") || $0.name.contains("83.5") }
            ),
            IOSSizeCategory(
                title: "🏪 App Store",
                sizes: sizes.filter { $0.name.contains("1024") }
            )
        ]
    }
}

// MARK: - iOS尺寸分类结构
struct IOSSizeCategory {
    let title: String
    let sizes: [SizePreset]
}

#Preview {
    SizeSelectionView(
        iconType: .calculator,
        settings: IconSettings(),
        onGenerate: { _, _ in }
    )
}
