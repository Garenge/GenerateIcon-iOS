import SwiftUI
import UIKit

// MARK: - 历史记录视图
struct HistoryListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSegment = 0 // 0: 所有文件, 1: 图片, 2: ZIP
    @State private var files: [HistoryFile] = []
    @State private var selectedFiles: Set<URL> = []
    @State private var isEditMode = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var fileToShare: URL?
    @State private var isLoading = true
    
    private let fileManager = FileManagerService()
    
    // 过滤后的文件列表
    private var filteredFiles: [HistoryFile] {
        switch selectedSegment {
        case 1: // 图片
            return files.filter { $0.fileType == .image }
        case 2: // ZIP
            return files.filter { $0.fileType == .zip }
        default: // 全部
            return files
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // SegmentControl
                Picker("文件类型", selection: $selectedSegment) {
                    Text("全部").tag(0)
                    Text("图片").tag(1)
                    Text("ZIP").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 文件列表
                if isLoading {
                    ProgressView("加载中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredFiles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(getEmptyStateTitle())
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(getEmptyStateMessage())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredFiles) { file in
                            HistoryFileRow(
                                file: file,
                                isSelected: selectedFiles.contains(file.url),
                                isEditMode: isEditMode
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isEditMode {
                                    toggleSelection(file.url)
                                } else {
                                    shareFile(file.url)
                                }
                            }
                        }
                        .onDelete(perform: deleteFiles)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("生成历史")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditMode {
                        Button("取消") {
                            withAnimation {
                                isEditMode = false
                                selectedFiles.removeAll()
                            }
                        }
                    } else {
                        Button("关闭") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation {
                                isEditMode.toggle()
                                if !isEditMode {
                                    selectedFiles.removeAll()
                                }
                            }
                        }) {
                            Text(isEditMode ? "完成" : "编辑")
                        }
                        
                        if isEditMode && !selectedFiles.isEmpty {
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadFiles()
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteSelectedFiles()
                }
            } message: {
                Text("确定要删除选中的 \(selectedFiles.count) 个文件吗？")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let fileToShare = fileToShare {
                    ShareSheet(activityItems: [fileToShare])
                }
            }
        }
    }
    
    // MARK: - 获取空状态标题
    private func getEmptyStateTitle() -> String {
        if files.isEmpty {
            return "暂无历史记录"
        }
        switch selectedSegment {
        case 1: return "暂无图片记录"
        case 2: return "暂无ZIP记录"
        default: return "暂无历史记录"
        }
    }
    
    // MARK: - 获取空状态消息
    private func getEmptyStateMessage() -> String {
        if files.isEmpty {
            return "生成和保存的文件会显示在这里"
        }
        switch selectedSegment {
        case 1: return "还没有保存过图片文件"
        case 2: return "还没有生成过ZIP压缩包"
        default: return "生成和保存的文件会显示在这里"
        }
    }
    
    // MARK: - 加载文件列表
    private func loadFiles() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let urls = try fileManager.getHistoryFiles()
                let historyFiles = urls.map { HistoryFile(url: $0) }
                
                DispatchQueue.main.async {
                    self.files = historyFiles
                    self.isLoading = false
                }
            } catch {
                print("❌ 加载历史文件失败: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - 刷新文件列表
    private func refreshFiles() {
        loadFiles()
    }
    
    // MARK: - 切换选择
    private func toggleSelection(_ url: URL) {
        if selectedFiles.contains(url) {
            selectedFiles.remove(url)
        } else {
            selectedFiles.insert(url)
        }
    }
    
    // MARK: - 分享文件
    private func shareFile(_ url: URL) {
        fileToShare = url
        showingShareSheet = true
    }
    
    // MARK: - 删除文件
    private func deleteFiles(offsets: IndexSet) {
        let filesToDelete = offsets.map { filteredFiles[$0].url }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try fileManager.deleteHistoryFiles(at: Array(filesToDelete))
                DispatchQueue.main.async {
                    loadFiles()
                }
            } catch {
                print("❌ 删除文件失败: \(error)")
            }
        }
    }
    
    // MARK: - 删除选中的文件
    private func deleteSelectedFiles() {
        let filesToDelete = Array(selectedFiles)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try fileManager.deleteHistoryFiles(at: filesToDelete)
                DispatchQueue.main.async {
                    loadFiles()
                    withAnimation {
                        isEditMode = false
                        selectedFiles.removeAll()
                    }
                }
            } catch {
                print("❌ 删除文件失败: \(error)")
            }
        }
    }
}

// MARK: - 历史文件数据模型
struct HistoryFile: Identifiable {
    let id = UUID()
    let url: URL
    
    var fileName: String {
        url.lastPathComponent
    }
    
    var fileType: FileType {
        if fileName.hasSuffix(".zip") {
            return .zip
        } else if fileName.hasSuffix(".png") || fileName.hasSuffix(".jpg") || fileName.hasSuffix(".jpeg") {
            return .image
        }
        return .unknown
    }
    
    var sizeString: String {
        if let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize {
            return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
        }
        return "未知"
    }
    
    var dateString: String {
        if let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.string(from: date)
        }
        return "未知"
    }
}

enum FileType {
    case image
    case zip
    case unknown
}

// MARK: - 历史文件行视图
struct HistoryFileRow: View {
    let file: HistoryFile
    let isSelected: Bool
    let isEditMode: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 选择框
            if isEditMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
            }
            
            // 文件图标
            Image(systemName: file.fileType == .zip ? "doc.zipper" : "photo")
                .font(.title2)
                .foregroundColor(file.fileType == .zip ? .orange : .blue)
                .frame(width: 40, height: 40)
            
            // 文件信息
            VStack(alignment: .leading, spacing: 4) {
                Text(file.fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(file.dateString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(file.sizeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 标识
            if file.fileType == .zip {
                Text("压缩包")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 分享 Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HistoryListView()
}

