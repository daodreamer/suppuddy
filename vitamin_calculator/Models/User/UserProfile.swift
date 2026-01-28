//
//  UserProfile.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//  Extended for Sprint 6 - Task 1.1
//

import Foundation
import SwiftData

/// Represents a user profile with demographic information for personalized nutrient recommendations.
/// Uses SwiftData for persistence.
@Model
final class UserProfile {
    // MARK: - Stored Properties

    /// The user's name
    var name: String

    /// Encoded user type data for SwiftData persistence
    @Attribute(.transformable(by: "NSSecureUnarchiveFromDataTransformer"))
    private var userTypeData: Data?

    /// The user's birth date (optional)
    var birthDate: Date?

    /// Encoded special needs data for SwiftData persistence
    @Attribute(.transformable(by: "NSSecureUnarchiveFromDataTransformer"))
    private var specialNeedsData: Data?

    /// Whether the user has completed the onboarding process
    var hasCompletedOnboarding: Bool

    /// Timestamp when the profile was created
    var createdAt: Date

    /// Timestamp when the profile was last updated
    var updatedAt: Date

    // MARK: - Computed Properties

    /// The user's demographic type (male, female, or child with age)
    /// Used to determine appropriate nutrient recommendations
    var userType: UserType {
        get {
            guard let data = userTypeData else {
                return .male // Default fallback
            }
            let decoder = JSONDecoder()
            guard let decoded = try? decoder.decode(UserType.self, from: data) else {
                return .male // Default fallback
            }
            return decoded
        }
        set {
            let encoder = JSONEncoder()
            userTypeData = try? encoder.encode(newValue)
        }
    }

    /// The user's special nutritional needs (pregnancy, breastfeeding, etc.)
    var specialNeeds: SpecialNeeds? {
        get {
            guard let data = specialNeedsData,
                  let decoded = try? JSONDecoder().decode(SpecialNeeds.self, from: data) else {
                return nil
            }
            return decoded
        }
        set {
            specialNeedsData = newValue.flatMap { try? JSONEncoder().encode($0) }
        }
    }

    /// Calculates the user's age based on birthDate
    /// - Returns: The calculated age in years, or nil if birthDate is not set
    var age: Int? {
        guard let birthDate = birthDate else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year
    }

    /// Determines the child age group for child users
    /// - Returns: The age group, or nil if user is not a child or age cannot be determined
    var childAgeGroup: ChildAgeGroup? {
        // First, try to determine age from birthDate
        if let calculatedAge = age {
            return ChildAgeGroup.from(age: calculatedAge)
        }

        // If no birthDate, try to use age from UserType.child
        if case .child(let childAge) = userType {
            return ChildAgeGroup.from(age: childAge)
        }

        return nil
    }

    // MARK: - Initialization

    /// Creates a new user profile
    /// - Parameters:
    ///   - name: The user's name
    ///   - userType: The user's demographic type
    init(name: String, userType: UserType) {
        self.name = name
        self.birthDate = nil
        self.hasCompletedOnboarding = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.userType = userType // This will trigger the setter
        self.specialNeeds = nil
    }
}
