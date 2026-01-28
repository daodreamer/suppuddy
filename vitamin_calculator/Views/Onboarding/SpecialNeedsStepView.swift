//
//  SpecialNeedsStepView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.1
//

import SwiftUI

/// Special needs selection step in the onboarding flow.
/// Allows users to indicate pregnancy or breastfeeding status.
struct SpecialNeedsStepView: View {
    @Binding var specialNeeds: SpecialNeeds

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("特殊需求")
                        .font(.largeTitle)
                        .bold()

                    Text("您是否有特殊的营养需求？")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Special needs options
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(SpecialNeeds.allCases, id: \.self) { need in
                        SpecialNeedButton(
                            need: need,
                            isSelected: specialNeeds == need,
                            action: { specialNeeds = need }
                        )
                    }
                }
                .padding(.horizontal, 30)

                // Info text
                if specialNeeds != .none {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)

                            Text("我们将根据您的特殊需求调整推荐的营养素摄入量。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .padding(.horizontal, 30)
                }

                Spacer()
            }
        }
    }
}

/// Button for selecting a special need option.
struct SpecialNeedButton: View {
    let need: SpecialNeeds
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconForNeed(need))
                    .frame(width: 24)
                Text(need.rawValue)
                    .fontWeight(isSelected ? .semibold : .regular)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconForNeed(_ need: SpecialNeeds) -> String {
        switch need {
        case .none:
            return "checkmark.circle"
        case .pregnant:
            return "heart.circle.fill"
        case .breastfeeding:
            return "heart.circle.fill"
        case .pregnantAndBreastfeeding:
            return "heart.circle.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var needs = SpecialNeeds.none
    SpecialNeedsStepView(specialNeeds: $needs)
}
