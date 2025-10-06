import SwiftUI

/// 图标预览配置
struct IconPreviewConfig {
    /// 图标类型
    let iconType: IconType
    
    /// 图标设置
    let settings: IconSettings
    
    /// 是否显示加载状态
    let isLoading: Bool
    
    /// 错误信息
    let errorMessage: String?
    
    /// 自定义图标（AI生成的图标）
    let customIcon: UIImage?
    
    /// 是否显示重新生成按钮
    let showRegenerateButton: Bool
    
    /// 重新生成回调
    let onRegenerate: (() -> Void)?
    
    /// 预览尺寸
    let previewSize: CGSize
    
    /// 是否显示预览信息
    let showPreviewInfo: Bool
    
    /// 初始化方法
    init(
        iconType: IconType,
        settings: IconSettings = IconSettings(),
        isLoading: Bool = false,
        errorMessage: String? = nil,
        customIcon: UIImage? = nil,
        showRegenerateButton: Bool = false,
        onRegenerate: (() -> Void)? = nil,
        previewSize: CGSize = CGSize(width: 256, height: 256),
        showPreviewInfo: Bool = true
    ) {
        self.iconType = iconType
        self.settings = settings
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.customIcon = customIcon
        self.showRegenerateButton = showRegenerateButton
        self.onRegenerate = onRegenerate
        self.previewSize = previewSize
        self.showPreviewInfo = showPreviewInfo
    }
}
