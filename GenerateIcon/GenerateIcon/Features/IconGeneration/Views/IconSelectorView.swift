import SwiftUI

// MARK: - 图标选择器视图
struct IconSelectorView: View {
    @Binding var selectedType: IconType
    let onAITap: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var hasScrolled = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(IconCategory.allCases) { category in
                            if category != .ai {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(category.name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                        ForEach(category.iconTypes) { type in
                                            IconTypeCard(
                                                type: type,
                                                isSelected: selectedType == type,
                                                onTap: {
                                                    print("🎯 Selected icon type: \(type.name)")
                                                    selectedType = type
                                                    dismiss()
                                                }
                                            )
                                            .id(type.id)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .id(category.id)
                            }
                        }
                    
                        // AI生成按钮
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI生成")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            Button(action: {
                                onAITap()
                            }) {
                                HStack {
                                    Text("🎨 AI生成")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                                        )
                                )
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    // 延迟滚动，确保视图已经渲染完成
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if !hasScrolled {
                            // 首先尝试滚动到选中的图标
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(selectedType.id, anchor: .center)
                            }
                            
                            // 如果选中的图标不在当前分类中，滚动到对应的分类
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(selectedType.category.id, anchor: .top)
                                }
                            }
                            hasScrolled = true
                        }
                    }
                }
            }
            .navigationTitle("选择图标类型")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 图标类型卡片
struct IconTypeCard: View {
    let type: IconType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(type.emoji)
                    .font(.system(size: 40))
                
                Text(type.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    IconSelectorView(
        selectedType: .constant(.calculator),
        onAITap: { }
    )
}