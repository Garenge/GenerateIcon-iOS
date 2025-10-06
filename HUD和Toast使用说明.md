# HUD和Toast效果库使用说明

## 📱 功能概述

本库为iOS应用提供了完整的HUD（Heads-Up Display）和Toast消息提示功能，支持SwiftUI和UIKit混合使用。

## 🎯 主要特性

### HUD功能
- **加载指示器**：旋转的圆形进度指示器
- **进度条**：带百分比的圆形进度条
- **成功提示**：带成功图标的HUD
- **错误提示**：带错误图标的HUD
- **自动隐藏**：支持自动隐藏和手动隐藏

### Toast功能
- **多种类型**：信息、成功、错误、警告
- **自定义样式**：支持自定义颜色和图标
- **多种位置**：底部Toast、顶部Toast
- **自动消失**：可设置显示时长
- **手动关闭**：支持手动关闭按钮

## 🚀 快速开始

### 1. 基础使用

在需要显示HUD和Toast的视图中添加修饰符：

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        VStack {
            // 你的内容
        }
        .hudToast() // 添加HUD和Toast支持
    }
}
```

### 2. HUD使用示例

```swift
struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("显示加载HUD") {
                showLoadingHUD(message: "正在处理...")
            }
            
            Button("显示进度HUD") {
                showProgressHUD(progress: 0.6, message: "处理中...")
            }
            
            Button("显示成功HUD") {
                showSuccessHUD(message: "操作成功！")
            }
            
            Button("显示错误HUD") {
                showErrorHUD(message: "操作失败")
            }
            
            Button("隐藏HUD") {
                hideHUD()
            }
        }
        .hudToast()
    }
}
```

### 3. Toast使用示例

```swift
struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("显示信息Toast") {
                showToast(message: "这是一条信息", type: .info)
            }
            
            Button("显示成功Toast") {
                showSuccessToast(message: "操作成功完成！")
            }
            
            Button("显示错误Toast") {
                showErrorToast(message: "网络连接失败")
            }
            
            Button("显示警告Toast") {
                showWarningToast(message: "请注意保存文件")
            }
        }
        .hudToast()
    }
}
```

## 🔧 高级用法

### 1. 异步操作包装器

使用`HUDAsyncOperation`包装异步操作：

```swift
struct AsyncOperationView: View {
    var body: some View {
        HUDAsyncOperation(
            loadingMessage: "正在上传文件...",
            successMessage: "上传成功！",
            errorMessage: "上传失败，请重试"
        ) {
            Button("上传文件") {
                // 按钮内容
            }
        } operation: {
            // 异步操作
            try await uploadFile()
        }
        .hudToast()
    }
}
```

### 2. 进度操作包装器

使用`HUDProgressOperation`包装带进度的操作：

```swift
struct ProgressOperationView: View {
    var body: some View {
        HUDProgressOperation(
            loadingMessage: "正在处理...",
            successMessage: "处理完成！",
            errorMessage: "处理失败"
        ) {
            Button("开始处理") {
                // 按钮内容
            }
        } operation: { progressCallback in
            // 带进度的异步操作
            for i in 1...10 {
                try await Task.sleep(nanoseconds: 200_000_000)
                progressCallback(Double(i) / 10.0)
            }
        }
        .hudToast()
    }
}
```

### 3. 自定义Toast样式

使用`CustomToastView`创建自定义样式的Toast：

```swift
struct CustomToastExample: View {
    @State private var showToast = false
    
    var body: some View {
        VStack {
            Button("显示自定义Toast") {
                showToast = true
            }
            
            CustomToastView(
                message: "自定义Toast消息",
                type: .success,
                duration: 3.0,
                isVisible: $showToast
            )
        }
        .hudToast()
    }
}
```

### 4. 顶部Toast

使用`TopToastView`在顶部显示Toast：

```swift
struct TopToastExample: View {
    @State private var showTopToast = false
    
    var body: some View {
        VStack {
            Button("显示顶部Toast") {
                showTopToast = true
            }
            
            TopToastView(
                message: "顶部Toast消息",
                type: .warning,
                duration: 2.5,
                isVisible: $showTopToast
            )
        }
        .hudToast()
    }
}
```

## 🎨 自定义配置

### Toast类型配置

```swift
enum ToastType {
    case info      // 蓝色，信息图标
    case success   // 绿色，成功图标
    case error     // 红色，错误图标
    case warning   // 橙色，警告图标
}
```

### 自定义颜色和图标

可以通过修改`ToastType`枚举来自定义颜色和图标：

```swift
extension ToastType {
    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .info: return .blue
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        }
    }
}
```

## 📱 实际应用示例

### 在图标生成器中的应用

```swift
struct IconGeneratorView: View {
    var body: some View {
        VStack {
            // 生成按钮
            Button("生成图标") {
                Task {
                    showLoadingHUD(message: "正在生成图标...")
                    
                    // 模拟生成过程
                    for i in 1...10 {
                        try await Task.sleep(nanoseconds: 200_000_000)
                        showProgressHUD(progress: Double(i) / 10.0, message: "处理中... \(i * 10)%")
                    }
                    
                    showSuccessHUD(message: "图标生成成功！")
                }
            }
            
            // 保存按钮
            Button("保存到相册") {
                showSuccessToast(message: "已保存到相册")
            }
        }
        .hudToast()
    }
}
```

## 🔍 API参考

### HUDToastManager

主要的HUD和Toast管理器，提供以下方法：

#### HUD方法
- `showLoading(message:)` - 显示加载HUD
- `showProgress(progress:message:)` - 显示进度HUD
- `showSuccess(message:)` - 显示成功HUD
- `showError(message:)` - 显示错误HUD
- `hideHUD()` - 隐藏HUD

#### Toast方法
- `showToast(message:type:duration:)` - 显示Toast
- `showSuccessToast(message:duration:)` - 显示成功Toast
- `showErrorToast(message:duration:)` - 显示错误Toast
- `showWarningToast(message:duration:)` - 显示警告Toast
- `hideToast()` - 隐藏Toast

### View扩展方法

所有View都自动获得以下扩展方法：

- `showLoadingHUD(message:)`
- `showProgressHUD(progress:message:)`
- `showSuccessHUD(message:)`
- `showErrorHUD(message:)`
- `hideHUD()`
- `showToast(message:type:duration:)`
- `showSuccessToast(message:duration:)`
- `showErrorToast(message:duration:)`
- `showWarningToast(message:duration:)`
- `hideToast()`

## 🎯 最佳实践

1. **合理使用HUD**：HUD会阻塞用户交互，只在必要时使用
2. **Toast时长设置**：根据消息重要性设置合适的显示时长
3. **错误处理**：在异步操作中正确处理错误并显示相应的Toast
4. **用户体验**：避免频繁显示Toast，避免信息过载
5. **无障碍支持**：确保HUD和Toast支持VoiceOver等无障碍功能

## 🐛 故障排除

### 常见问题

1. **HUD不显示**：确保添加了`.hudToast()`修饰符
2. **Toast不显示**：检查消息内容是否为空
3. **动画不流畅**：确保在主线程中调用显示方法
4. **内存泄漏**：使用`@StateObject`而不是`@ObservedObject`

### 调试技巧

```swift
// 在控制台查看HUD状态
print("HUD State: \(HUDToastManager.shared.hudState)")
print("Toast State: \(HUDToastManager.shared.toastState)")
```

## 📄 许可证

MIT License - 可自由使用和修改
