import SwiftUI

// MARK: - 文字图标设置组件
struct TextIconSettingsView: View {
    @ObservedObject var textConfig: TextIconConfigViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("文字内容", text: $textConfig.text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("字体大小", selection: $textConfig.fontSize) {
                ForEach(FontSize.allCases) { size in
                    Text(size.rawValue.capitalized).tag(size)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            ColorPicker("文字颜色", selection: $textConfig.textColor)
            
            Picker("文字样式", selection: $textConfig.textStyle) {
                ForEach(TextStyle.allCases) { style in
                    Text(style.rawValue.capitalized).tag(style)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

#Preview {
    TextIconSettingsView(textConfig: TextIconConfigViewModel())
}
