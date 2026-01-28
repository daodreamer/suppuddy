//
//  WelcomeStepView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.1
//

import SwiftUI

/// Welcome step in the onboarding flow.
/// Displays app introduction and motivates user to continue setup.
struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App icon or logo
            Image(systemName: "pills.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.accentColor)
                .symbolRenderingMode(.hierarchical)

            // Title
            Text("欢迎使用维生素计算器")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)

            // Description
            Text("让我们设置您的个人资料，以便为您提供个性化的营养推荐值。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            // Features list
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "person.fill", text: "个性化推荐值")
                FeatureRow(icon: "chart.bar.fill", text: "追踪营养摄入")
                FeatureRow(icon: "bell.fill", text: "智能提醒功能")
                FeatureRow(icon: "doc.text.fill", text: "数据导出与分析")
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }
}

/// A row displaying a feature with icon and text.
struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)

            Text(text)
                .font(.body)
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeStepView()
}
