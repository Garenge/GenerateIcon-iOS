import SwiftUI

/// HUD和Toast的ViewModifier
struct HUDToastModifier: ViewModifier {
    @StateObject private var hudToastManager = HUDToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            // HUD层
            HUDView(state: hudToastManager.hudState)
            
            // Toast层
            ToastView(state: hudToastManager.toastState)
        }
    }
}

/// 便捷扩展
extension View {
    /// 添加HUD和Toast支持
    func hudToast() -> some View {
        modifier(HUDToastModifier())
    }
}

/// HUD和Toast的便捷方法
extension View {
    /// 显示加载HUD
    func showLoadingHUD(message: String = "加载中...") {
        HUDToastManager.shared.showLoading(message: message)
    }
    
    /// 显示进度HUD
    func showProgressHUD(progress: Double, message: String = "处理中...") {
        HUDToastManager.shared.showProgress(progress: progress, message: message)
    }
    
    /// 显示成功HUD
    func showSuccessHUD(message: String = "操作成功") {
        HUDToastManager.shared.showSuccess(message: message)
    }
    
    /// 显示错误HUD
    func showErrorHUD(message: String = "操作失败") {
        HUDToastManager.shared.showError(message: message)
    }
    
    /// 隐藏HUD
    func hideHUD() {
        HUDToastManager.shared.hideHUD()
    }
    
    /// 显示Toast消息
    func showToast(message: String, type: ToastType = .info, duration: Double = 2.0) {
        HUDToastManager.shared.showToast(message: message, type: type, duration: duration)
    }
    
    /// 显示成功Toast
    func showSuccessToast(message: String, duration: Double = 2.0) {
        HUDToastManager.shared.showSuccessToast(message: message, duration: duration)
    }
    
    /// 显示错误Toast
    func showErrorToast(message: String, duration: Double = 3.0) {
        HUDToastManager.shared.showErrorToast(message: message, duration: duration)
    }
    
    /// 显示警告Toast
    func showWarningToast(message: String, duration: Double = 2.5) {
        HUDToastManager.shared.showWarningToast(message: message, duration: duration)
    }
    
    /// 隐藏Toast
    func hideToast() {
        HUDToastManager.shared.hideToast()
    }
}

/// 异步操作的HUD包装器
struct HUDAsyncOperation<Content: View>: View {
    let operation: () async throws -> Void
    let content: Content
    let loadingMessage: String
    let successMessage: String
    let errorMessage: String
    
    @State private var isRunning = false
    
    init(
        loadingMessage: String = "处理中...",
        successMessage: String = "操作成功",
        errorMessage: String = "操作失败",
        @ViewBuilder content: () -> Content,
        operation: @escaping () async throws -> Void
    ) {
        self.loadingMessage = loadingMessage
        self.successMessage = successMessage
        self.errorMessage = errorMessage
        self.content = content()
        self.operation = operation
    }
    
    var body: some View {
        content
            .disabled(isRunning)
            .onTapGesture {
                Task {
                    await performOperation()
                }
            }
    }
    
    private func performOperation() async {
        guard !isRunning else { return }
        
        isRunning = true
        HUDToastManager.shared.showLoading(message: loadingMessage)
        
        do {
            try await operation()
            HUDToastManager.shared.showSuccess(message: successMessage)
        } catch {
            HUDToastManager.shared.showError(message: errorMessage)
        }
        
        isRunning = false
    }
}

/// 进度操作的HUD包装器
struct HUDProgressOperation<Content: View>: View {
    let operation: (@escaping (Double) -> Void) async throws -> Void
    let content: Content
    let loadingMessage: String
    let successMessage: String
    let errorMessage: String
    
    @State private var isRunning = false
    @State private var progress: Double = 0
    
    init(
        loadingMessage: String = "处理中...",
        successMessage: String = "操作成功",
        errorMessage: String = "操作失败",
        @ViewBuilder content: () -> Content,
        operation: @escaping (@escaping (Double) -> Void) async throws -> Void
    ) {
        self.loadingMessage = loadingMessage
        self.successMessage = successMessage
        self.errorMessage = errorMessage
        self.content = content()
        self.operation = operation
    }
    
    var body: some View {
        content
            .disabled(isRunning)
            .onTapGesture {
                Task {
                    await performOperation()
                }
            }
    }
    
    private func performOperation() async {
        guard !isRunning else { return }
        
        isRunning = true
        progress = 0
        HUDToastManager.shared.showProgress(progress: progress, message: loadingMessage)
        
        do {
            try await operation { newProgress in
                DispatchQueue.main.async {
                    self.progress = newProgress
                    HUDToastManager.shared.showProgress(progress: newProgress, message: self.loadingMessage)
                }
            }
            HUDToastManager.shared.showSuccess(message: successMessage)
        } catch {
            HUDToastManager.shared.showError(message: errorMessage)
        }
        
        isRunning = false
    }
}
