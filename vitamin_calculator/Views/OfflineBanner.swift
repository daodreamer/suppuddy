//
//  OfflineBanner.swift
//  vitamin_calculator
//
//  Created by TDD on 2026-01-28.
//

import SwiftUI

/// 离线状态提示横幅
struct OfflineBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundStyle(.orange)
                .accessibilityLabel(String(localized: "offline_icon", defaultValue: "Offline"))

            Text("offline_message", bundle: .main)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview("Offline Banner") {
    OfflineBanner()
}

#Preview("Offline Banner in View") {
    VStack {
        OfflineBanner()

        Spacer()

        Text("Main Content")
            .font(.title)
    }
}
