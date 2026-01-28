//
//  UserTypeStepView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.1
//

import SwiftUI

/// User type selection step in the onboarding flow.
/// Allows user to input their name and select demographic type.
struct UserTypeStepView: View {
    @Binding var userProfile: UserProfileDraft

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("关于您")
                        .font(.largeTitle)
                        .bold()

                    Text("告诉我们一些您的信息，以便我们提供准确的营养推荐。")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Form fields
                VStack(alignment: .leading, spacing: 20) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("姓名")
                            .font(.headline)
                        TextField("请输入您的姓名", text: $userProfile.name)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 4)
                    }

                    // User type selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("用户类型")
                            .font(.headline)

                        VStack(spacing: 12) {
                            UserTypeButton(
                                title: "成年男性",
                                icon: "person.fill",
                                isSelected: isUserType(.male),
                                action: { userProfile.userType = .male }
                            )

                            UserTypeButton(
                                title: "成年女性",
                                icon: "person.fill",
                                isSelected: isUserType(.female),
                                action: { userProfile.userType = .female }
                            )

                            UserTypeButton(
                                title: "儿童",
                                icon: "figure.child",
                                isSelected: isChildType,
                                action: {
                                    // Default to age 10 for children
                                    userProfile.userType = .child(age: 10)
                                }
                            )
                        }
                    }

                    // Birth date field (for children)
                    if isChildType {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("出生日期")
                                .font(.headline)
                            DatePicker(
                                "选择出生日期",
                                selection: Binding(
                                    get: { userProfile.birthDate ?? Date() },
                                    set: { userProfile.birthDate = $0 }
                                ),
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
            }
        }
    }

    // Helper to check if current type matches
    private func isUserType(_ type: UserType) -> Bool {
        switch (userProfile.userType, type) {
        case (.male, .male), (.female, .female):
            return true
        default:
            return false
        }
    }

    // Helper to check if child type is selected
    private var isChildType: Bool {
        if case .child = userProfile.userType {
            return true
        }
        return false
    }
}

/// Button for selecting user type with icon and selection state.
struct UserTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
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
}

// MARK: - Preview

#Preview {
    @Previewable @State var profile = UserProfileDraft()
    UserTypeStepView(userProfile: $profile)
}
