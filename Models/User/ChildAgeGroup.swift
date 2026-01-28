//
//  ChildAgeGroup.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 1.1
//

import Foundation

/// Represents age groups for children according to DGE recommendations.
/// Each age group has different nutrient recommendations.
enum ChildAgeGroup: String, Codable, CaseIterable, Sendable {
    /// Ages 1-3 years
    case age1to3 = "1-3岁"

    /// Ages 4-6 years
    case age4to6 = "4-6岁"

    /// Ages 7-9 years
    case age7to9 = "7-9岁"

    /// Ages 10-12 years
    case age10to12 = "10-12岁"

    /// Ages 13-14 years
    case age13to14 = "13-14岁"

    /// Ages 15-18 years
    case age15to18 = "15-18岁"

    // MARK: - Properties

    /// Returns the age range for this age group
    var ageRange: ClosedRange<Int> {
        switch self {
        case .age1to3:
            return 1...3
        case .age4to6:
            return 4...6
        case .age7to9:
            return 7...9
        case .age10to12:
            return 10...12
        case .age13to14:
            return 13...14
        case .age15to18:
            return 15...18
        }
    }

    // MARK: - Factory Methods

    /// Creates a ChildAgeGroup from an age value
    /// - Parameter age: The child's age
    /// - Returns: The corresponding age group, or nil if age is out of range
    static func from(age: Int) -> ChildAgeGroup? {
        for ageGroup in ChildAgeGroup.allCases {
            if ageGroup.ageRange.contains(age) {
                return ageGroup
            }
        }
        return nil
    }
}
