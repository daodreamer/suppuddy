//
//  DynamicFontHelper.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 2: Dynamic font and spacing support
//

import SwiftUI

/// Provides scaled metrics for consistent spacing that adapts to dynamic type
struct ScaledSpacing {
    @ScaledMetric private var extraSmall: CGFloat = 4
    @ScaledMetric private var small: CGFloat = 8
    @ScaledMetric private var medium: CGFloat = 12
    @ScaledMetric private var large: CGFloat = 16
    @ScaledMetric private var extraLarge: CGFloat = 20
    @ScaledMetric private var xxLarge: CGFloat = 24
    @ScaledMetric private var xxxLarge: CGFloat = 32

    static let shared = ScaledSpacing()

    var xs: CGFloat { extraSmall }
    var sm: CGFloat { small }
    var md: CGFloat { medium }
    var lg: CGFloat { large }
    var xl: CGFloat { extraLarge }
    var xxl: CGFloat { xxLarge }
    var xxxl: CGFloat { xxxLarge }
}

/// Provides scaled sizes for UI elements that should adapt to dynamic type
struct ScaledSize {
    @ScaledMetric private var iconSmall: CGFloat = 20
    @ScaledMetric private var iconMedium: CGFloat = 24
    @ScaledMetric private var iconLarge: CGFloat = 32
    @ScaledMetric private var iconExtraLarge: CGFloat = 44

    @ScaledMetric private var buttonHeightMin: CGFloat = 44
    @ScaledMetric private var cardCornerRadius: CGFloat = 12
    @ScaledMetric private var progressRingSize: CGFloat = 60

    static let shared = ScaledSize()

    var icon: CGFloat { iconMedium }
    var iconSm: CGFloat { iconSmall }
    var iconLg: CGFloat { iconLarge }
    var iconXl: CGFloat { iconExtraLarge }

    var minButtonHeight: CGFloat { buttonHeightMin }
    var cornerRadius: CGFloat { cardCornerRadius }
    var progressRing: CGFloat { progressRingSize }
}

/// Extension to provide easy access to scaled spacing in views
extension View {
    func scaledSpacing(_ spacing: ScaledSpacing = .shared) -> ScaledSpacing {
        spacing
    }

    func scaledSize(_ size: ScaledSize = .shared) -> ScaledSize {
        size
    }
}

/// Dynamic Type Categories matching Apple's text styles
/// Use these instead of fixed font sizes for better accessibility
enum DynamicFontStyle {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption
    case caption2

    var font: Font {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption
        case .caption2: return .caption2
        }
    }
}

/// View modifier for minimum heights that adapt to dynamic type
struct MinHeightAdaptive: ViewModifier {
    @ScaledMetric private var minHeight: CGFloat

    init(minHeight: CGFloat = 44) {
        self._minHeight = ScaledMetric(wrappedValue: minHeight)
    }

    func body(content: Content) -> some View {
        content.frame(minHeight: minHeight)
    }
}

extension View {
    /// Applies a minimum height that adapts to dynamic type
    func minHeightAdaptive(_ minHeight: CGFloat = 44) -> some View {
        self.modifier(MinHeightAdaptive(minHeight: minHeight))
    }
}

/// Helper to check if the user is using a large accessibility text size
struct DynamicTypeSize {
    @Environment(\.dynamicTypeSize) var size

    var isAccessibilitySize: Bool {
        size >= .accessibility1
    }

    var isLargeSize: Bool {
        size >= .xxLarge
    }
}
