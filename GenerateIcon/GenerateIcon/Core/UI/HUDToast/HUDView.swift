import SwiftUI

/// HUD组件
struct HUDView: View {
    let state: HUDState
    
    var body: some View {
        if case .hidden = state {
            EmptyView()
        } else {
            ZStack {
                // 背景遮罩
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                // HUD内容
                VStack(spacing: 16) {
                    switch state {
                    case .loading(let message):
                        LoadingHUDView(message: message)
                    case .progress(let progress, let message):
                        ProgressHUDView(progress: progress, message: message)
                    case .success(let message):
                        SuccessHUDView(message: message)
                    case .error(let message):
                        ErrorHUDView(message: message)
                    case .hidden:
                        EmptyView()
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 40)
            }
            .animation(.easeInOut(duration: 0.3), value: state)
        }
    }
}

// MARK: - Loading HUD

struct LoadingHUDView: View {
    let message: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 旋转的加载指示器
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.accentColor, lineWidth: 3)
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            // 消息文本
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Progress HUD

struct ProgressHUDView: View {
    let progress: Double
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            // 进度环
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            // 消息文本
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Success HUD

struct SuccessHUDView: View {
    let message: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 成功图标
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            }
            .onAppear {
                isAnimating = true
            }
            
            // 消息文本
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Error HUD

struct ErrorHUDView: View {
    let message: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 错误图标
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.red)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            }
            .onAppear {
                isAnimating = true
            }
            
            // 消息文本
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HUDView(state: .loading(message: "正在生成图标..."))
        
        HUDView(state: .progress(progress: 0.6, message: "处理中..."))
        
        HUDView(state: .success(message: "图标生成成功！"))
        
        HUDView(state: .error(message: "生成失败，请重试"))
    }
    .background(Color.gray.opacity(0.1))
}
