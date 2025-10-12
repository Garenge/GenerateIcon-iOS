//
//  GenerateIconApp.swift
//  GenerateIcon
//
//  Created by Garenge on 2025/10/6.
//

import SwiftUI

@main
struct GenerateIconApp: App {
    @State private var isAppReady = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isAppReady {
                    ContentView()
                        .withGlobalIconViewModels()
                } else {
                    // 启动画面或加载画面
                    LaunchScreenView()
                }
            }
            .onAppear {
                // 延迟2秒后显示主界面
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isAppReady = true
                    }
                }
            }
        }
    }
}

// MARK: - 启动画面
struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // 背景色
            Color(red: 0.4, green: 0.49, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 应用图标或Logo
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // 应用名称
                Text("GenerateIcon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 加载指示器
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
    }
}
