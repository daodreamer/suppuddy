//
//  CompleteStepView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.1
//

import SwiftUI

/// Completion step in the onboarding flow.
/// Congratulates user and provides final call-to-action.
struct CompleteStepView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Success icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 140, height: 140)

                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
            }

            // Title
            Text("全部完成！")
                .font(.largeTitle)
                .bold()

            // Description
            Text("您已经准备好开始追踪您的补剂和营养素了。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Next steps
            VStack(alignment: .leading, spacing: 15) {
                NextStepRow(
                    number: 1,
                    text: "添加您正在服用的补剂"
                )

                NextStepRow(
                    number: 2,
                    text: "查看您的营养摄入总览"
                )

                NextStepRow(
                    number: 3,
                    text: "设置提醒以保持按时服用"
                )
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)

            Spacer()

            // Encouragement
            Text("点击\"完成\"按钮开始使用")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/// Row displaying a numbered next step.
struct NextStepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            // Number badge
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 30, height: 30)

                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.body)
        }
    }
}

// MARK: - Preview

#Preview {
    CompleteStepView()
}
