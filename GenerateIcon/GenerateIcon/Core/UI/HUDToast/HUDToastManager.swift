import SwiftUI
import Combine

/// HUD和Toast管理器
@MainActor
class HUDToastManager: ObservableObject {
    static let shared = HUDToastManager()
    
    @Published var hudState: HUDState = .hidden
    @Published var toastState: ToastState = .hidden
    
    private init() {}
    
    // MARK: - HUD Methods
    
    /// 显示加载HUD
    func showLoading(message: String = "加载中...") {
        hudState = .loading(message: message)
    }
    
    /// 显示进度HUD
    func showProgress(progress: Double, message: String = "处理中...") {
        hudState = .progress(progress: progress, message: message)
    }
    
    /// 显示成功HUD
    func showSuccess(message: String = "操作成功") {
        hudState = .success(message: message)
        
        // 2秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hideHUD()
        }
    }
    
    /// 显示错误HUD
    func showError(message: String = "操作失败") {
        hudState = .error(message: message)
        
        // 3秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.hideHUD()
        }
    }
    
    /// 隐藏HUD
    func hideHUD() {
        hudState = .hidden
    }
    
    // MARK: - Toast Methods
    
    /// 显示Toast消息
    func showToast(message: String, type: ToastType = .info, duration: Double = 2.0) {
        toastState = .visible(message: message, type: type, duration: duration)
        
        // 自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hideToast()
        }
    }
    
    /// 显示成功Toast
    func showSuccessToast(message: String, duration: Double = 2.0) {
        showToast(message: message, type: .success, duration: duration)
    }
    
    /// 显示错误Toast
    func showErrorToast(message: String, duration: Double = 3.0) {
        showToast(message: message, type: .error, duration: duration)
    }
    
    /// 显示警告Toast
    func showWarningToast(message: String, duration: Double = 2.5) {
        showToast(message: message, type: .warning, duration: duration)
    }
    
    /// 隐藏Toast
    func hideToast() {
        toastState = .hidden
    }
}

// MARK: - HUD State

enum HUDState: Equatable {
    case hidden
    case loading(message: String)
    case progress(progress: Double, message: String)
    case success(message: String)
    case error(message: String)
}

// MARK: - Toast State

enum ToastState: Equatable {
    case hidden
    case visible(message: String, type: ToastType, duration: Double)
}

// MARK: - Toast Type

enum ToastType: Equatable {
    case info
    case success
    case error
    case warning
    
    var icon: String {
        switch self {
        case .info:
            return "info.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .info:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        case .warning:
            return .orange
        }
    }
}
