//
//  RecommendationsListView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.4
//

import SwiftUI

/// View displaying personalized nutrient recommendations based on user profile.
/// Shows recommendations categorized by vitamins and minerals.
struct RecommendationsListView: View {
    let recommendations: [NutrientType: DailyRecommendation]
    let userProfile: UserProfile

    var body: some View {
        List {
            // Profile Summary
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("用户类型:")
                            .foregroundColor(.secondary)
                        Text(userProfile.userType.localizedDescription)
                            .fontWeight(.medium)
                    }

                    if let specialNeeds = userProfile.specialNeeds, specialNeeds != .none {
                        HStack {
                            Text("特殊需求:")
                                .foregroundColor(.secondary)
                            Text(specialNeeds.rawValue)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }

                    if let age = userProfile.age {
                        HStack {
                            Text("年龄:")
                                .foregroundColor(.secondary)
                            Text("\(age) 岁")
                                .fontWeight(.medium)
                        }
                    }
                }
                .font(.subheadline)
            }

            // Vitamins Section
            if !vitaminRecommendations.isEmpty {
                Section("维生素") {
                    ForEach(sortedVitamins, id: \.key) { nutrient, recommendation in
                        RecommendationRow(
                            nutrient: nutrient,
                            recommendation: recommendation
                        )
                    }
                }
            }

            // Minerals Section
            if !mineralRecommendations.isEmpty {
                Section("矿物质") {
                    ForEach(sortedMinerals, id: \.key) { nutrient, recommendation in
                        RecommendationRow(
                            nutrient: nutrient,
                            recommendation: recommendation
                        )
                    }
                }
            }

            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("这些推荐值基于德国营养学会(DGE)的官方标准。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("每日推荐值")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Computed Properties

    /// Recommendations filtered for vitamins
    private var vitaminRecommendations: [NutrientType: DailyRecommendation] {
        recommendations.filter { $0.key.isVitamin }
    }

    /// Recommendations filtered for minerals
    private var mineralRecommendations: [NutrientType: DailyRecommendation] {
        recommendations.filter { !$0.key.isVitamin }
    }

    /// Vitamins sorted by name
    private var sortedVitamins: [(key: NutrientType, value: DailyRecommendation)] {
        vitaminRecommendations.sorted { $0.key.localizedName < $1.key.localizedName }
    }

    /// Minerals sorted by name
    private var sortedMinerals: [(key: NutrientType, value: DailyRecommendation)] {
        mineralRecommendations.sorted { $0.key.localizedName < $1.key.localizedName }
    }
}

// MARK: - Recommendation Row

/// Row component displaying a single nutrient recommendation.
struct RecommendationRow: View {
    let nutrient: NutrientType
    let recommendation: DailyRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Nutrient name
            Text(nutrient.localizedName)
                .font(.headline)

            // Recommended amount
            HStack {
                Text("推荐值:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(formattedAmount(recommendation.recommendedAmount))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }

            // Upper limit (if exists)
            if let upperLimit = recommendation.upperLimit {
                HStack {
                    Text("最大安全摄入量:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(formattedAmount(upperLimit))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }

    /// Formats nutrient amount with appropriate unit
    private func formattedAmount(_ amount: Double) -> String {
        "\(Int(amount)) \(nutrient.unit)"
    }
}

// MARK: - Preview

#Preview("Male User") {
    let service = RecommendationService()
    let profile = UserProfile(name: "张三", userType: .male)
    let recommendations = service.getAllRecommendations(for: profile)
    let recommendationsDict = Dictionary(
        uniqueKeysWithValues: recommendations.map { ($0.nutrientType, $0) }
    )

    NavigationStack {
        RecommendationsListView(
            recommendations: recommendationsDict,
            userProfile: profile
        )
    }
}

