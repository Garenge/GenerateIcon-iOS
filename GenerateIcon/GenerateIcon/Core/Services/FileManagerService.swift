import Foundation
import SwiftUI
import UIKit
import Combine
import UniformTypeIdentifiers
import ObjectiveC

// MARK: - 相册保存目标类
class PhotoLibrarySaveTarget: NSObject {
    private let completion: (Error?) -> Void
    
    init(completion: @escaping (Error?) -> Void) {
        self.completion = completion
        super.init()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("📸 PhotoLibrarySaveTarget: 收到保存回调")
        if let error = error {
            print("❌ PhotoLibrarySaveTarget: 保存失败: \(error.localizedDescription)")
        } else {
            print("✅ PhotoLibrarySaveTarget: 保存成功")
        }
        completion(error)
    }
}

// MARK: - 关联键
private struct AssociatedKeys {
    static var saveTarget = "saveTarget"
}

// MARK: - 文件管理服务
class FileManagerService: ObservableObject {
    @Published var savedIcons: [URL] = []
    
    private let documentsDirectory: URL
    private let iconsDirectory: URL
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        iconsDirectory = documentsDirectory.appendingPathComponent("GeneratedIcons")
        
        createIconsDirectoryIfNeeded()
        loadSavedIcons()
    }
    
    // MARK: - 保存图标
    func saveIcon(_ image: UIImage, name: String, size: CGSize) async throws -> URL? {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let url = try self.saveIconSync(image: image, name: name, size: size)
                    continuation.resume(returning: url)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - 生成iOS图标集
    func generateIOSIconSet(icon: UIImage, settings: IconSettings) async throws -> [URL] {
        var urls: [URL] = []
        let iosSizes = SizePreset.iosSizes
        
        for preset in iosSizes {
            let size = CGSize(width: preset.size, height: preset.size)
            let resizedIcon = try await resizeImage(icon, to: size)
            
            if let url = try await saveIcon(resizedIcon, name: preset.name, size: size) {
                urls.append(url)
            }
        }
        
        return urls
    }
    
    // MARK: - 创建ZIP文件
    func createZipFile(icons: [URL], name: String = "iOS_Icons") async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let zipURL = try self.createZipFileSync(icons: icons, name: name)
                    continuation.resume(returning: zipURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - 保存到相册
    func saveToPhotoLibrary(_ image: UIImage) async throws {
        print("📸 FileManagerService: 开始保存图片到相册")
        print("📸 FileManagerService: 图片尺寸: \(image.size)")
        print("📸 FileManagerService: 图片scale: \(image.scale)")
        
        // 检查图片是否有效
        guard !image.size.equalTo(.zero) else {
            print("❌ FileManagerService: 图片尺寸为0，无法保存")
            throw NSError(domain: "FileManagerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "图片尺寸无效"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            print("📸 FileManagerService: 创建PhotoLibrarySaveTarget")
            
            // 创建一个临时的目标对象来处理回调
            let target = PhotoLibrarySaveTarget { error in
                if let error = error {
                    print("❌ FileManagerService: 保存到相册失败: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    print("✅ FileManagerService: 保存到相册成功")
                    continuation.resume()
                }
            }
            
            // 保存目标对象的引用，防止被释放
            objc_setAssociatedObject(image, &AssociatedKeys.saveTarget, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            print("📸 FileManagerService: 调用UIImageWriteToSavedPhotosAlbum")
            UIImageWriteToSavedPhotosAlbum(image, target, #selector(PhotoLibrarySaveTarget.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    // MARK: - 获取保存的图标列表
    func getSavedIcons() throws -> [URL] {
        let contents = try FileManager.default.contentsOfDirectory(
            at: iconsDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )
        
        return contents.sorted { url1, url2 in
            let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate
            let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate
            return (date1 ?? Date.distantPast) > (date2 ?? Date.distantPast)
        }
    }
    
    // MARK: - 加载保存的图标
    private func loadSavedIcons() {
        do {
            savedIcons = try getSavedIcons()
        } catch {
            print("Failed to load saved icons: \(error)")
        }
    }
    
    // MARK: - 删除图标
    func deleteIcon(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    // MARK: - 私有方法
    private func createIconsDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: iconsDirectory.path) {
            try? FileManager.default.createDirectory(
                at: iconsDirectory,
                withIntermediateDirectories: true
            )
        }
    }
    
    private func saveIconSync(image: UIImage, name: String, size: CGSize) throws -> URL {
        guard let data = image.pngData() else {
            throw FileManagerError.imageDataConversionFailed
        }
        
        let fileName = "\(name)_\(Int(size.width))x\(Int(size.height)).png"
        let fileURL = iconsDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = UIGraphicsImageRenderer(size: size)
                let resizedImage = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: size))
                }
                continuation.resume(returning: resizedImage)
            }
        }
    }
    
    private func createZipFileSync(icons: [URL], name: String) throws -> URL {
        let zipURL = iconsDirectory.appendingPathComponent("\(name).zip")
        
        // 创建临时目录
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(
            at: tempDirectory,
            withIntermediateDirectories: true
        )
        
        // 复制文件到临时目录
        for iconURL in icons {
            let fileName = iconURL.lastPathComponent
            let destinationURL = tempDirectory.appendingPathComponent(fileName)
            try FileManager.default.copyItem(at: iconURL, to: destinationURL)
        }
        
        // 创建ZIP文件
        let coordinator = NSFileCoordinator()
        var error: NSError?
        
        coordinator.coordinate(readingItemAt: tempDirectory, options: [], error: &error) { url in
            do {
                let zipData = try self.createZipData(from: url)
                try zipData.write(to: zipURL)
            } catch {
                print("ZIP creation failed: \(error)")
            }
        }
        
        // 清理临时目录
        try? FileManager.default.removeItem(at: tempDirectory)
        
        if let error = error {
            throw error
        }
        
        return zipURL
    }
    
    private func createZipData(from directory: URL) throws -> Data {
        // 使用系统API创建ZIP文件
        let coordinator = NSFileCoordinator()
        var error: NSError?
        var zipData = Data()
        
        coordinator.coordinate(readingItemAt: directory, options: [], error: &error) { url in
            do {
                // 获取目录中的所有文件
                let fileURLs = try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )
                
                // 创建简单的ZIP格式（简化实现）
                zipData = try createSimpleZip(from: fileURLs)
            } catch {
                print("Error creating ZIP: \(error)")
            }
        }
        
        if let error = error {
            throw error
        }
        
        return zipData
    }
    
    private func createSimpleZip(from fileURLs: [URL]) throws -> Data {
        // 简化的ZIP实现，实际项目中建议使用第三方库
        var zipData = Data()
        
        for fileURL in fileURLs {
            let fileName = fileURL.lastPathComponent
            let fileData = try Data(contentsOf: fileURL)
            
            // 添加文件到ZIP（简化实现）
            zipData.append("PK\u{03}\u{04}".data(using: .ascii)!)
            zipData.append(fileName.data(using: .utf8)!)
            zipData.append(fileData)
        }
        
        return zipData
    }
}

// MARK: - 错误类型
enum FileManagerError: Error, LocalizedError {
    case directoryCreationFailed
    case imageDataConversionFailed
    case fileWriteFailed
    case zipCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed:
            return "无法创建目录"
        case .imageDataConversionFailed:
            return "图片数据转换失败"
        case .fileWriteFailed:
            return "文件写入失败"
        case .zipCreationFailed:
            return "ZIP文件创建失败"
        }
    }
}

// MARK: - 文件信息结构
struct IconFileInfo {
    let url: URL
    let name: String
    let size: CGSize
    let creationDate: Date
    let fileSize: Int64
    
    init(url: URL) throws {
        self.url = url
        self.name = url.lastPathComponent
        
        // 从文件名解析尺寸
        let components = name.components(separatedBy: "_")
        if components.count >= 2 {
            let sizeString = components.last?.replacingOccurrences(of: ".png", with: "")
            let sizeComponents = sizeString?.components(separatedBy: "x")
            if let sizeComponents = sizeComponents,
               sizeComponents.count == 2,
               let width = Int(sizeComponents[0]),
               let height = Int(sizeComponents[1]) {
                self.size = CGSize(width: width, height: height)
            } else {
                self.size = CGSize.zero
            }
        } else {
            self.size = CGSize.zero
        }
        
        // 获取文件属性
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        self.creationDate = attributes[.creationDate] as? Date ?? Date()
        self.fileSize = attributes[.size] as? Int64 ?? 0
    }
}
