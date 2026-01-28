//
//  ErrorView.swift
//  vitamin_calculator
//
//  Created by TDD on 2026-01-28.
//

import SwiftUI

/// 错误提示视图
struct ErrorView: View {
    let error: AppError
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.red)
                .accessibilityLabel(String(localized: "error_icon", defaultValue: "Error"))

            Text(error.errorDescription ?? String(localized: "error_occurred", defaultValue: "An error occurred"))
                .font(.headline)
                .multilineTextAlignment(.center)
                .accessibilityLabel(error.errorDescription ?? "Error")

            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityHint(suggestion)
            }

            if let retry = retryAction {
                Button {
                    retry()
                } label: {
                    Text("retry", bundle: .main)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel(String(localized: "retry", defaultValue: "Retry"))
            }
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("Network Error with Retry") {
    ErrorView(
        error: .network(.noConnection),
        retryAction: {
            print("Retry tapped")
        }
    )
}

#Preview("Database Error without Retry") {
    ErrorView(
        error: .database(.saveFailed),
        retryAction: nil
    )
}

#Preview("Validation Error") {
    ErrorView(
        error: .validation(.invalidInput),
        retryAction: nil
    )
}
