# 🎨 GenerateIcon iOS 开发大纲

## 📱 项目概述

基于Web版本的图标生成器，开发iOS原生应用，提供更流畅的移动端体验和iOS特有的功能。

## 🎯 核心功能

### 1. 图标生成功能
- **预设图标类型**：
  - 🧮 计算器图标
  - 🖱️ 鼠标图标  
  - ⌨️ 键盘图标
  - 🖥️ 显示器图标
  - 📍 定位图标
  - 🎨 AI生成图标

### 2. 自定义设置
- **底图样式设置**：
  - 形状选择（圆形/圆角矩形/方形）
  - 圆角大小调节
  - 背景颜色选择
  - 内边距调节
  - 阴影强度调节
  - 边框设置

- **图标外框设置**：
  - 外框背景色
  - 外框边框宽度
  - 外框内边距

### 3. 尺寸选择
- **自定义尺寸**：16px - 2048px
- **预设尺寸**：24px, 32px, 64px, 128px, 1024px
- **iOS专用尺寸**：一键生成所有iOS应用图标尺寸

### 4. AI生成功能
- 文字描述生成图标
- 文字设置（字体、大小、颜色、样式）
- 实时预览

## 🏗️ 技术架构

### 开发环境
- **开发语言**：Swift 5.0+
- **最低支持**：iOS 14.0+
- **开发工具**：Xcode 14.0+
- **架构模式**：MVVM + Combine

### 核心技术栈
- **UI框架**：SwiftUI + UIKit混合
- **图形绘制**：Core Graphics + Core Animation
- **数据绑定**：Combine Framework
- **图片处理**：Core Image
- **文件管理**：FileManager + Document Picker

## 📁 项目结构

```
GenerateIcon-iOS/
├── GenerateIcon/
│   ├── App/
│   │   ├── GenerateIconApp.swift          # 应用入口
│   │   └── AppDelegate.swift              # 应用代理
│   ├── Core/
│   │   ├── Models/                        # 数据模型
│   │   │   ├── IconType.swift
│   │   │   ├── IconSettings.swift
│   │   │   ├── SizePreset.swift
│   │   │   └── AISettings.swift
│   │   ├── Services/                     # 服务层
│   │   │   ├── IconGeneratorService.swift
│   │   │   ├── AIService.swift
│   │   │   ├── FileManagerService.swift
│   │   │   └── SettingsService.swift
│   │   └── Utils/                        # 工具类
│   │       ├── ColorExtensions.swift
│   │       ├── ImageExtensions.swift
│   │       └── GeometryExtensions.swift
│   ├── Features/
│   │   ├── IconGeneration/               # 图标生成功能
│   │   │   ├── ViewModels/
│   │   │   │   ├── IconGeneratorViewModel.swift
│   │   │   │   └── SettingsViewModel.swift
│   │   │   ├── Views/
│   │   │   │   ├── IconGeneratorView.swift
│   │   │   │   ├── IconPreviewView.swift
│   │   │   │   ├── SettingsPanelView.swift
│   │   │   │   └── SizeSelectionView.swift
│   │   │   └── Components/
│   │   │       ├── IconTypeSelector.swift
│   │   │       ├── ColorPickerView.swift
│   │   │       ├── SliderControl.swift
│   │   │       └── SizeButton.swift
│   │   ├── AIGeneration/                 # AI生成功能
│   │   │   ├── ViewModels/
│   │   │   │   └── AIGeneratorViewModel.swift
│   │   │   ├── Views/
│   │   │   │   ├── AIGeneratorView.swift
│   │   │   │   ├── TextSettingsView.swift
│   │   │   │   └── AIPreviewView.swift
│   │   │   └── Components/
│   │   │       ├── PromptInputView.swift
│   │   │       ├── FontSelector.swift
│   │   │       └── TextPreviewCanvas.swift
│   │   └── Settings/                      # 设置功能
│   │       ├── ViewModels/
│   │       │   └── SettingsViewModel.swift
│   │       └── Views/
│   │           ├── SettingsView.swift
│   │           └── AboutView.swift
│   ├── Generators/                       # 图标生成器
│   │   ├── Base/
│   │   │   └── BaseIconGenerator.swift
│   │   ├── Calculator/
│   │   │   ├── CalculatorIconGenerator.swift
│   │   │   └── CalculatorIconRenderer.swift
│   │   ├── Mouse/
│   │   │   ├── MouseIconGenerator.swift
│   │   │   └── MouseIconRenderer.swift
│   │   ├── Keyboard/
│   │   │   ├── KeyboardIconGenerator.swift
│   │   │   └── KeyboardIconRenderer.swift
│   │   ├── Monitor/
│   │   │   ├── MonitorIconGenerator.swift
│   │   │   └── MonitorIconRenderer.swift
│   │   ├── Location/
│   │   │   ├── LocationIconGenerator.swift
│   │   │   └── LocationIconRenderer.swift
│   │   └── AI/
│   │       ├── AIIconGenerator.swift
│   │       └── AIIconRenderer.swift
│   └── Resources/
│       ├── Assets.xcassets/              # 图片资源
│       ├── Localizable.strings           # 本地化文件
│       └── Info.plist                    # 应用配置
├── GenerateIconTests/                    # 单元测试
│   ├── IconGeneratorTests.swift
│   ├── AIServiceTests.swift
│   └── FileManagerServiceTests.swift
├── GenerateIconUITests/                  # UI测试
│   └── GenerateIconUITests.swift
├── GenerateIcon.xcodeproj               # Xcode项目文件
└── README.md                            # 项目说明
```

## 🎨 UI/UX 设计

### 主界面布局
- **顶部导航**：应用标题 + 设置按钮
- **左侧面板**：图标类型选择（可折叠）
- **中央区域**：图标预览 + 生成按钮
- **右侧面板**：设置选项（可折叠）
- **底部**：尺寸选择和下载按钮

### 设计原则
- **iOS原生风格**：遵循iOS设计规范
- **响应式布局**：支持iPhone/iPad不同尺寸
- **暗色模式**：完整支持iOS暗色模式
- **无障碍支持**：VoiceOver和动态字体支持

## 🔧 核心功能实现

### 1. 图标生成引擎
```swift
// 基础生成器协议
protocol IconGenerator {
    func generateIcon(size: CGSize, settings: IconSettings) -> UIImage
    func generatePreview(size: CGSize, settings: IconSettings) -> UIImage
}

// 具体实现示例
class CalculatorIconGenerator: IconGenerator {
    func generateIcon(size: CGSize, settings: IconSettings) -> UIImage {
        // 使用Core Graphics绘制计算器图标
    }
}
```

### 2. 设置管理
```swift
// 设置数据模型
struct IconSettings: Codable {
    var backgroundShape: BackgroundShape
    var backgroundColor: Color
    var cornerRadius: CGFloat
    var iconPadding: CGFloat
    var shadowIntensity: CGFloat
    var borderWidth: CGFloat
    var borderColor: Color
}

// 设置服务
class SettingsService: ObservableObject {
    @Published var settings: IconSettings
    func saveSettings() { }
    func loadSettings() { }
}
```

### 3. AI生成功能
```swift
// AI服务接口
protocol AIService {
    func generateIcon(prompt: String, settings: AISettings) async throws -> UIImage
}

// 文字设置
struct AISettings {
    var fontSize: CGFloat
    var fontFamily: String
    var textColor: Color
    var maxLength: Int
    var textWrap: Bool
}
```

### 4. 文件管理
```swift
// 文件管理服务
class FileManagerService {
    func saveIcon(_ image: UIImage, name: String, size: CGSize) -> URL?
    func generateIOSIconSet(icon: UIImage) -> [URL]
    func createZipFile(icons: [URL]) -> URL?
}
```

## 📱 iOS特有功能

### 1. 原生分享
- 使用`UIActivityViewController`分享图标
- 支持AirDrop、邮件、消息等分享方式

### 2. 相册集成
- 自动保存到相册
- 相册权限管理

### 3. 文件应用集成
- 支持Files应用管理
- 支持iCloud同步

### 4. 快捷操作
- 3D Touch/Haptic Touch支持
- 主屏幕快捷操作

### 5. 通知支持
- 生成完成通知
- 进度提示

## 🧪 测试策略

### 单元测试
- 图标生成器测试
- 设置管理测试
- AI服务测试
- 文件管理测试

### UI测试
- 主要用户流程测试
- 不同设备尺寸测试
- 无障碍功能测试

### 性能测试
- 内存使用监控
- 生成速度测试
- 大尺寸图标处理测试

## 📦 发布计划

### 版本规划
- **v1.0.0**：基础图标生成功能
- **v1.1.0**：AI生成功能
- **v1.2.0**：高级设置选项
- **v1.3.0**：iPad优化
- **v2.0.0**：高级AI功能

### 发布渠道
- App Store发布
- TestFlight内测
- GitHub开源版本

## 🔄 开发流程

### 第一阶段：基础架构（1-2周）
1. 创建Xcode项目
2. 搭建基础架构
3. 实现基础UI框架
4. 创建数据模型

### 第二阶段：核心功能（2-3周）
1. 实现图标生成器
2. 实现设置管理
3. 实现预览功能
4. 基础测试

### 第三阶段：高级功能（2-3周）
1. AI生成功能
2. 文件管理
3. 分享功能
4. 性能优化

### 第四阶段：完善和发布（1-2周）
1. UI/UX优化
2. 全面测试
3. 性能调优
4. App Store准备

## 📋 开发检查清单

### 基础功能
- [ ] 图标类型选择
- [ ] 实时预览
- [ ] 设置面板
- [ ] 尺寸选择
- [ ] 图标生成
- [ ] 文件保存

### 高级功能
- [ ] AI生成
- [ ] 文字设置
- [ ] 分享功能
- [ ] 相册集成
- [ ] 文件管理

### 用户体验
- [ ] 响应式布局
- [ ] 暗色模式
- [ ] 无障碍支持
- [ ] 动画效果
- [ ] 错误处理

### 技术质量
- [ ] 代码规范
- [ ] 单元测试
- [ ] UI测试
- [ ] 性能优化
- [ ] 内存管理

## 🎯 成功指标

### 功能指标
- 支持5种以上图标类型
- 生成速度 < 2秒
- 支持16px-2048px尺寸范围
- 100% iOS设备兼容

### 用户体验指标
- 界面响应时间 < 100ms
- 内存使用 < 100MB
- 崩溃率 < 0.1%
- 用户满意度 > 4.5星

---

*此大纲将作为iOS版本开发的指导文档，可根据实际开发进度进行调整和细化。*
