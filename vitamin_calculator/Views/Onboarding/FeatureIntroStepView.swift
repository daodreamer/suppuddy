//
//  FeatureIntroStepView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.1
//

import SwiftUI

/// Feature introduction step in the onboarding flow.
/// Showcases main app features to new users.
struct FeatureIntroStepView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("主要功能")
                        .font(.largeTitle)
                        .bold()

                    Text("这是您可以使用本应用做的事情：")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Features list
                VStack(spacing: 20) {
                    FeatureCard(
                        icon: "pills.fill",
                        color: .blue,
                        title: "补剂管理",
                        description: "记录和管理您正在服用的所有补剂产品"
                    )

                    FeatureCard(
                        icon: "chart.bar.xaxis",
                        color: .green,
                        title: "摄入追踪",
                        description: "自动计算您的每日营养素总摄入量"
                    )

                    FeatureCard(
                        icon: "checkmark.circle.fill",
                        color: .orange,
                        title: "推荐对比",
                        description: "查看您的摄入量与DGE推荐值的对比"
                    )

                    FeatureCard(
                        icon: "bell.badge.fill",
                        color: .purple,
                        title: "智能提醒",
                        description: "设置提醒，确保您按时服用补剂"
                    )

                    FeatureCard(
                        icon: "barcode.viewfinder",
                        color: .pink,
                        title: "扫描录入",
                        description: "扫描条形码快速添加产品信息"
                    )

                    FeatureCard(
                        icon: "square.and.arrow.up",
                        color: .cyan,
                        title: "数据导出",
                        description: "导出您的数据与医生或营养师分享"
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

/// Card displaying a single app feature with icon and description.
struct FeatureCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    FeatureIntroStepView()
}
