import Foundation
import SwiftUI

// MARK: - 图标类型枚举
enum IconType: String, CaseIterable, Identifiable {
    // 基础图标
    case calculator = "calculator"
    case mouse = "mouse"
    case keyboard = "keyboard"
    case monitor = "monitor"
    case location = "location"
    
    // 办公图标
    case document = "document"
    case folder = "folder"
    case printer = "printer"
    case calendar = "calendar"
    
    // 通信图标
    case phone = "phone"
    case email = "email"
    case message = "message"
    case video = "video"
    
    // 媒体图标
    case music = "music"
    case camera = "camera"
    case photo = "photo"
    case videoPlayer = "videoPlayer"
    
    // 工具图标
    case settings = "settings"
    case search = "search"
    case heart = "heart"
    case star = "star"
    
    // AI生成
    case custom = "custom"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        // 基础图标
        case .calculator: return "计算器"
        case .mouse: return "鼠标"
        case .keyboard: return "键盘"
        case .monitor: return "显示器"
        case .location: return "定位"
        
        // 办公图标
        case .document: return "文档"
        case .folder: return "文件夹"
        case .printer: return "打印机"
        case .calendar: return "日历"
        
        // 通信图标
        case .phone: return "电话"
        case .email: return "邮件"
        case .message: return "消息"
        case .video: return "视频通话"
        
        // 媒体图标
        case .music: return "音乐"
        case .camera: return "相机"
        case .photo: return "相册"
        case .videoPlayer: return "视频播放器"
        
        // 工具图标
        case .settings: return "设置"
        case .search: return "搜索"
        case .heart: return "收藏"
        case .star: return "评分"
        
        // AI生成
        case .custom: return "AI生成"
        }
    }
    
    var emoji: String {
        switch self {
        // 基础图标
        case .calculator: return "🧮"
        case .mouse: return "🖱️"
        case .keyboard: return "⌨️"
        case .monitor: return "🖥️"
        case .location: return "📍"
        
        // 办公图标
        case .document: return "📄"
        case .folder: return "📁"
        case .printer: return "🖨️"
        case .calendar: return "📅"
        
        // 通信图标
        case .phone: return "📞"
        case .email: return "📧"
        case .message: return "💬"
        case .video: return "📹"
        
        // 媒体图标
        case .music: return "🎵"
        case .camera: return "📷"
        case .photo: return "🖼️"
        case .videoPlayer: return "▶️"
        
        // 工具图标
        case .settings: return "⚙️"
        case .search: return "🔍"
        case .heart: return "❤️"
        case .star: return "⭐"
        
        // AI生成
        case .custom: return "🎨"
        }
    }
    
    var description: String {
        switch self {
        case .calculator: return "点击按钮将生成一个1024x1024像素的计算器图标并自动下载"
        case .mouse: return "点击按钮将生成一个1024x1024像素的鼠标图标并自动下载"
        case .keyboard: return "点击按钮将生成一个1024x1024像素的键盘图标并自动下载"
        case .monitor: return "点击按钮将生成一个1024x1024像素的显示器图标并自动下载"
        case .location: return "点击按钮将生成一个1024x1024像素的定位图标并自动下载"
        case .document: return "点击按钮将生成一个1024x1024像素的文档图标并自动下载"
        case .folder: return "点击按钮将生成一个1024x1024像素的文件夹图标并自动下载"
        case .printer: return "点击按钮将生成一个1024x1024像素的打印机图标并自动下载"
        case .calendar: return "点击按钮将生成一个1024x1024像素的日历图标并自动下载"
        case .phone: return "点击按钮将生成一个1024x1024像素的电话图标并自动下载"
        case .email: return "点击按钮将生成一个1024x1024像素的邮件图标并自动下载"
        case .message: return "点击按钮将生成一个1024x1024像素的消息图标并自动下载"
        case .video: return "点击按钮将生成一个1024x1024像素的视频通话图标并自动下载"
        case .music: return "点击按钮将生成一个1024x1024像素的音乐图标并自动下载"
        case .camera: return "点击按钮将生成一个1024x1024像素的相机图标并自动下载"
        case .photo: return "点击按钮将生成一个1024x1024像素的相册图标并自动下载"
        case .videoPlayer: return "点击按钮将生成一个1024x1024像素的视频播放器图标并自动下载"
        case .settings: return "点击按钮将生成一个1024x1024像素的设置图标并自动下载"
        case .search: return "点击按钮将生成一个1024x1024像素的搜索图标并自动下载"
        case .heart: return "点击按钮将生成一个1024x1024像素的收藏图标并自动下载"
        case .star: return "点击按钮将生成一个1024x1024像素的评分图标并自动下载"
        case .custom: return "使用AI生成自定义图标，输入描述即可创建独特的图标"
        }
    }
    
    var displayName: String {
        return "\(emoji) \(name)"
    }
    
    var category: IconCategory {
        switch self {
        case .calculator, .mouse, .keyboard, .monitor, .location:
            return .basic
        case .document, .folder, .printer, .calendar:
            return .office
        case .phone, .email, .message, .video:
            return .communication
        case .music, .camera, .photo, .videoPlayer:
            return .media
        case .settings, .search, .heart, .star:
            return .tools
        case .custom:
            return .ai
        }
    }
}

// MARK: - 图标分类枚举
enum IconCategory: String, CaseIterable, Identifiable {
    case basic = "basic"
    case office = "office"
    case communication = "communication"
    case media = "media"
    case tools = "tools"
    case ai = "ai"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .basic: return "基础图标"
        case .office: return "办公图标"
        case .communication: return "通信图标"
        case .media: return "媒体图标"
        case .tools: return "工具图标"
        case .ai: return "AI生成"
        }
    }
    
    var iconTypes: [IconType] {
        IconType.allCases.filter { $0.category == self }
    }
}

// MARK: - 背景形状枚举
enum BackgroundShape: String, CaseIterable, Identifiable, Codable {
    case circle = "circle"
    case rounded = "rounded"
    case square = "square"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .circle: return "圆形"
        case .rounded: return "圆角矩形"
        case .square: return "方形"
        }
    }
}

// MARK: - 尺寸预设
struct SizePreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let size: CGFloat
    let description: String
    
    static let presets: [SizePreset] = [
        SizePreset(name: "24px", size: 24, description: "工具栏图标"),
        SizePreset(name: "32px", size: 32, description: "任务栏图标"),
        SizePreset(name: "64px", size: 64, description: "桌面图标"),
        SizePreset(name: "128px", size: 128, description: "应用商店图标"),
        SizePreset(name: "1024px", size: 1024, description: "高质量图标")
    ]
    
    static let iosSizes: [SizePreset] = [
        // iPhone 主屏幕
        SizePreset(name: "appIcon_60@2x.png", size: 120, description: "iPhone 主屏幕"),
        SizePreset(name: "appIcon_60@3x.png", size: 180, description: "iPhone 主屏幕"),
        
        // 设置 & 通知
        SizePreset(name: "appIcon_29.png", size: 29, description: "设置图标"),
        SizePreset(name: "appIcon_29@2x.png", size: 58, description: "设置图标"),
        SizePreset(name: "appIcon_29@3x.png", size: 87, description: "设置图标"),
        SizePreset(name: "appIcon_20.png", size: 20, description: "通知图标"),
        SizePreset(name: "appIcon_20@2x.png", size: 40, description: "通知图标"),
        SizePreset(name: "appIcon_20@3x.png", size: 60, description: "通知图标"),
        
        // Spotlight 搜索
        SizePreset(name: "appIcon_40.png", size: 40, description: "Spotlight 搜索"),
        SizePreset(name: "appIcon_40@2x.png", size: 80, description: "Spotlight 搜索"),
        SizePreset(name: "appIcon_40@3x.png", size: 120, description: "Spotlight 搜索"),
        
        // iPad
        SizePreset(name: "appIcon_76@2x.png", size: 152, description: "iPad 主屏幕"),
        SizePreset(name: "appIcon_83.5@2x.png", size: 167, description: "iPad Pro 主屏幕"),
        
        // App Store
        SizePreset(name: "appIcon_1024.png", size: 1024, description: "App Store")
    ]
}
