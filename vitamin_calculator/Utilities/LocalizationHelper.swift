//
//  LocalizationHelper.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//

import Foundation

/// Helper class for localized date and number formatting
/// Supports German (de), English (en), and Simplified Chinese (zh-Hans)
enum LocalizationHelper {

    // MARK: - Measurement Units

    enum MeasurementUnit {
        case milligrams
        case micrograms

        var symbol: String {
            switch self {
            case .milligrams:
                return "mg"
            case .micrograms:
                return "μg"
            }
        }
    }

    // MARK: - Date Formatting

    /// Returns a date formatter configured for the specified locale
    /// - Parameter locale: The locale to use for formatting (defaults to current)
    /// - Returns: A configured DateFormatter
    static func dateFormatter(for locale: Locale = .current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    /// Formats a date using the specified style and locale
    /// - Parameters:
    ///   - date: The date to format
    ///   - style: The date style to use
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: Formatted date string
    static func formatDate(
        _ date: Date,
        style: DateFormatter.Style = .medium,
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Formats a date using a relative style (e.g., "Today", "Yesterday")
    /// - Parameters:
    ///   - date: The date to format
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: Formatted relative date string
    static func formatRelativeDate(_ date: Date, locale: Locale = .current) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .full

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return NSLocalizedString("today", comment: "Today")
        } else if calendar.isDateInYesterday(date) {
            return NSLocalizedString("yesterday", comment: "Yesterday")
        } else {
            return formatDate(date, style: .medium, locale: locale)
        }
    }

    // MARK: - Number Formatting

    /// Returns a number formatter configured for the specified locale
    /// - Parameters:
    ///   - decimals: Number of decimal places (default: 2)
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: A configured NumberFormatter
    static func numberFormatter(decimals: Int = 2, locale: Locale = .current) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimals
        return formatter
    }

    /// Formats a number with the specified decimal places and locale
    /// - Parameters:
    ///   - number: The number to format
    ///   - decimals: Number of decimal places (default: 2)
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: Formatted number string
    static func formatNumber(
        _ number: Double,
        decimals: Int = 2,
        locale: Locale = .current
    ) -> String {
        let formatter = numberFormatter(decimals: decimals, locale: locale)
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    // MARK: - Measurement Formatting

    /// Formats a measurement value with its unit
    /// - Parameters:
    ///   - amount: The numeric amount
    ///   - unit: The measurement unit
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: Formatted measurement string (e.g., "100 mg")
    static func formatMeasurement(
        _ amount: Double,
        unit: MeasurementUnit,
        locale: Locale = .current
    ) -> String {
        let formattedNumber = formatNumber(amount, decimals: 1, locale: locale)
        return "\(formattedNumber) \(unit.symbol)"
    }

    /// Formats a measurement using the Measurement API for proper localization
    /// - Parameters:
    ///   - value: The numeric value
    ///   - unitMass: The UnitMass to use
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: Formatted measurement string
    static func formatMeasurementWithUnit(
        _ value: Double,
        unitMass: UnitMass,
        locale: Locale = .current
    ) -> String {
        let measurement = Measurement(value: value, unit: unitMass)
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        return formatter.string(from: measurement)
    }

    // MARK: - Plural Forms

    /// Returns a pluralized string based on count
    /// - Parameters:
    ///   - count: The count to determine singular/plural
    ///   - key: The base localization key
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: Localized pluralized string
    static func pluralizedString(
        count: Int,
        key: String,
        locale: Locale = .current
    ) -> String {
        // For this implementation, we'll use a simple approach
        // In production, you'd use .stringsdict files for proper plural handling
        let pluralKey = count == 1 ? "\(key)_singular" : "\(key)_plural"
        let localizedString = NSLocalizedString(pluralKey, comment: "")

        // If the key doesn't exist, fall back to the base key
        if localizedString == pluralKey {
            let baseString = NSLocalizedString(key, comment: "")
            return "\(count) \(baseString)"
        }

        return localizedString.replacingOccurrences(of: "%d", with: "\(count)")
    }

    /// Formats a nutrient count with proper pluralization
    /// - Parameters:
    ///   - count: The number of nutrients
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: Formatted string like "3 nutrients" or "1 nutrient"
    static func formatNutrientCount(_ count: Int, locale: Locale = .current) -> String {
        let key = "nutrient_count"
        let format = NSLocalizedString(key, comment: "Number of nutrients")

        // If format string contains %d or similar, use it
        if format.contains("%") {
            return String(format: format, count)
        }

        // Otherwise, simple concatenation
        let nutrientWord = NSLocalizedString("nutrients", comment: "Nutrients")
        return "\(count) \(nutrientWord)"
    }

    /// Formats a serving count with proper pluralization
    /// - Parameters:
    ///   - count: The number of servings
    ///   - locale: The locale to use (defaults to current)
    /// - Returns: Formatted string like "2.5 servings" or "1 serving"
    static func formatServingCount(_ count: Double, locale: Locale = .current) -> String {
        let formattedNumber = formatNumber(count, decimals: 1, locale: locale)
        let servingKey = count == 1.0 ? "serving_singular" : "serving_plural"
        let serving = NSLocalizedString(servingKey, comment: "Serving")

        // If translation doesn't exist, fall back to base key
        if serving == servingKey {
            let baseSe = NSLocalizedString("serving", comment: "Serving")
            return "\(formattedNumber) \(baseSe)"
        }

        return "\(formattedNumber) \(serving)"
    }

    // MARK: - Utility Methods

    /// Gets the current user's locale from system settings
    /// - Returns: The current Locale
    static var currentLocale: Locale {
        return Locale.current
    }

    /// Checks if the current locale uses metric system
    /// - Returns: true if metric, false otherwise
    static var usesMetricSystem: Bool {
        if #available(iOS 16.0, macOS 13.0, *) {
            return currentLocale.measurementSystem == .metric
        } else {
            return currentLocale.usesMetricSystem
        }
    }
}

// MARK: - DateFormatter Style Extension

extension DateFormatter.Style {
    /// Returns the appropriate style name for logging/debugging
    var name: String {
        switch self {
        case .none: return "none"
        case .short: return "short"
        case .medium: return "medium"
        case .long: return "long"
        case .full: return "full"
        @unknown default: return "unknown"
        }
    }
}
