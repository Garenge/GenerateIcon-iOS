import Foundation

// 全局通知名称集中管理
extension Notification.Name {
    // 设置变更或设置页关闭时发出，通知所有预览强制刷新
    static let settingsDidChange = Notification.Name("SettingsDidChange")
}


