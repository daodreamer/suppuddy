//
//  ErrorBanner.swift
//  vitamin_calculator
//
//  Created by TDD on 2026-01-28.
//

import SwiftUI

/// 错误横幅提示视图
struct ErrorBanner: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .accessibilityLabel(String(localized: "error_icon", defaultValue: "Error"))

                Text(message)
                    .font(.subheadline)
                    .accessibilityLabel(message)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(String(localized: "dismiss", defaultValue: "Dismiss"))
            }
            .padding()
            .background(.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
        }
    }
}

// MARK: - Preview

#Preview("Error Banner Visible") {
    ErrorBanner(
        message: "Failed to save data",
        isPresented: .constant(true)
    )
}

#Preview("Error Banner Hidden") {
    ErrorBanner(
        message: "This should not be visible",
        isPresented: .constant(false)
    )
}

#Preview("Error Banner Interactive") {
    struct PreviewWrapper: View {
        @State private var isPresented = true

        var body: some View {
            VStack {
                ErrorBanner(
                    message: "Network connection failed",
                    isPresented: $isPresented
                )

                Button("Show Error") {
                    isPresented = true
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
