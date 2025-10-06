# 🎨 GenerateIcon iOS

基于Web版本的图标生成器，开发iOS原生应用，提供更流畅的移动端体验和iOS特有的功能。

## 📱 项目概述

这是一个功能完整的iOS图标生成应用，支持多种图标类型生成、自定义设置、AI生成等功能。

## 🎯 核心功能

### ✅ 已实现功能
- **图标类型选择**：计算器、鼠标、键盘、显示器、定位、AI生成
- **自定义设置**：底图样式、颜色、圆角、阴影等
- **尺寸选择**：自定义尺寸、iOS专用尺寸
- **AI生成**：文字描述生成图标
- **文件管理**：保存、分享、相册集成

### 🚧 待实现功能
- 其他图标生成器（鼠标、键盘、显示器、定位）
- 网络AI服务集成
- 高级设置选项
- 性能优化

## 📁 项目结构

```
GenerateIcon-iOS/
├── App/                           # 应用入口
│   └── GenerateIconApp.swift
├── Core/                          # 核心功能
│   ├── Models/                    # 数据模型
│   │   ├── IconType.swift
│   │   └── IconSettings.swift
│   └── Services/                  # 服务层
│       ├── IconGeneratorService.swift
│       └── FileManagerService.swift
├── Features/                      # 功能模块
│   ├── IconGeneration/           # 图标生成
│   │   ├── Views/
│   │   │   ├── IconGeneratorView.swift
│   │   │   ├── SizeSelectionView.swift
│   │   │   └── SettingsPanelView.swift
│   │   └── ViewModels/
│   │       └── IconGeneratorViewModel.swift
│   └── AIGeneration/             # AI生成
│       └── Views/
│           └── AIGeneratorView.swift
├── Generators/                   # 图标生成器
│   ├── Calculator/
│   │   └── CalculatorIconGenerator.swift
│   └── AI/
│       └── AIIconGenerator.swift
├── iOS开发大纲.md                # 开发大纲
├── 项目创建指南.md               # 创建指南
└── README.md                     # 项目说明
```

## 🛠️ 技术栈

- **开发语言**：Swift 5.0+
- **UI框架**：SwiftUI + UIKit混合
- **架构模式**：MVVM + Combine
- **图形绘制**：Core Graphics + Core Animation
- **最低支持**：iOS 14.0+

## 🚀 快速开始

### 1. 创建Xcode项目
按照 `项目创建指南.md` 中的步骤创建Xcode项目。

### 2. 添加文件
将项目结构中的所有Swift文件添加到Xcode项目中。

### 3. 配置项目
- 设置Deployment Target为iOS 14.0
- 配置Info.plist权限（相册访问等）

### 4. 运行项目
在Xcode中运行项目，开始开发。

## 📋 开发检查清单

### 基础功能
- [x] 项目结构搭建
- [x] 数据模型定义
- [x] 基础UI组件
- [x] 图标生成服务
- [x] 文件管理服务
- [ ] 计算器图标生成器
- [ ] 其他图标生成器
- [ ] 设置面板功能
- [ ] 尺寸选择功能
- [ ] AI生成功能

### 高级功能
- [ ] 分享功能
- [ ] 相册集成
- [ ] 文件管理
- [ ] 性能优化
- [ ] 错误处理
- [ ] 单元测试
- [ ] UI测试

## 🎨 设计特点

- **iOS原生风格**：遵循iOS设计规范
- **响应式布局**：支持iPhone/iPad不同尺寸
- **暗色模式**：完整支持iOS暗色模式
- **无障碍支持**：VoiceOver和动态字体支持

## 📱 设备支持

- **iPhone**：所有尺寸（SE到Pro Max）
- **iPad**：所有尺寸（包括iPad Pro）
- **方向**：支持横屏和竖屏
- **系统**：iOS 14.0+

## 🔧 开发工具要求

- Xcode 14.0+
- iOS 14.0+ 模拟器
- Swift 5.0+
- macOS 12.0+

## 📦 发布计划

### 版本规划
- **v1.0.0**：基础图标生成功能
- **v1.1.0**：AI生成功能
- **v1.2.0**：高级设置选项
- **v1.3.0**：iPad优化
- **v2.0.0**：高级AI功能

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- 基于Web版本的图标生成器项目
- SwiftUI 提供现代化的UI框架
- Core Graphics 提供强大的图形绘制能力

## 📞 联系方式

- 项目链接: [https://github.com/Garenge/GenerateIcon-iOS](https://github.com/Garenge/GenerateIcon-iOS)
- 问题反馈: [Issues](https://github.com/Garenge/GenerateIcon-iOS/issues)

---

⭐ 如果这个项目对你有帮助，请给它一个星标！
