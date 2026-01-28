//
//  UserType.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation

/// Represents different types of users for personalized nutrient recommendations.
/// Based on German DGE (Deutsche Gesellschaft für Ernährung) standards which provide
/// different recommendations for different demographic groups.
enum UserType: Codable, Hashable, Sendable {
    /// Adult male
    case male

    /// Adult female
    case female

    /// Child with associated age (0-17 years)
    /// The age is used to determine age-specific nutrient recommendations
    case child(age: Int)

    // MARK: - Properties

    /// Returns a localized description of the user type
    var localizedDescription: String {
        switch self {
        case .male:
            return NSLocalizedString("Adult Male", comment: "Adult Male user type")
        case .female:
            return NSLocalizedString("Adult Female", comment: "Adult Female user type")
        case .child(let age):
            return String(format: NSLocalizedString("Child (age %d)", comment: "Child user type with age"), age)
        }
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case type
        case age
    }

    enum TypeIdentifier: String, Codable {
        case male
        case female
        case child
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TypeIdentifier.self, forKey: .type)

        switch type {
        case .male:
            self = .male
        case .female:
            self = .female
        case .child:
            let age = try container.decode(Int.self, forKey: .age)
            self = .child(age: age)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .male:
            try container.encode(TypeIdentifier.male, forKey: .type)
        case .female:
            try container.encode(TypeIdentifier.female, forKey: .type)
        case .child(let age):
            try container.encode(TypeIdentifier.child, forKey: .type)
            try container.encode(age, forKey: .age)
        }
    }
}
