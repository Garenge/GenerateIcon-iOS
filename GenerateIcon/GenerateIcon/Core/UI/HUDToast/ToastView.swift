import SwiftUI

/// Toast组件
struct ToastView: View {
    let state: ToastState
    
    var body: some View {
        if case .hidden = state {
            EmptyView()
        } else {
            if case .visible(let message, let type, let duration) = state {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // 图标
                        Image(systemName: type.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(type.color)
                        
                        // 消息文本
                        Text(message)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50) // 距离底部安全区域
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: state)
            }
        }
    }
}

/// 自定义Toast样式
struct CustomToastView: View {
    let message: String
    let type: ToastType
    let duration: Double
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // 图标
                    Image(systemName: type.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(type.color)
                    
                    // 消息文本
                    Text(message)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(type.color.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isVisible)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}

/// 顶部Toast样式
struct TopToastView: View {
    let message: String
    let type: ToastType
    let duration: Double
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            VStack {
                HStack(spacing: 12) {
                    // 图标
                    Image(systemName: type.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(type.color)
                    
                    // 消息文本
                    Text(message)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer(minLength: 0)
                    
                    // 关闭按钮
                    Button(action: {
                        withAnimation {
                            isVisible = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(type.color.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                .padding(.top, 50) // 距离顶部安全区域
                
                Spacer()
            }
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isVisible)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ToastView(state: .visible(message: "这是一条信息提示", type: .info, duration: 2.0))
        
        ToastView(state: .visible(message: "操作成功完成！", type: .success, duration: 2.0))
        
        ToastView(state: .visible(message: "发生错误，请检查网络连接", type: .error, duration: 3.0))
        
        ToastView(state: .visible(message: "请注意这个警告信息", type: .warning, duration: 2.5))
    }
    .background(Color.gray.opacity(0.1))
}
