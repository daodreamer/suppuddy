# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

This is a native iOS/SwiftUI project. Use Xcode or `xcodebuild` from the command line.

```bash
# Build the project
xcodebuild -scheme vitamin_calculator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run all tests
xcodebuild -scheme vitamin_calculator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# Run a specific test file
xcodebuild -scheme vitamin_calculator -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:vitamin_calculatorTests/NutrientTypeTests test

# Run a specific test method
xcodebuild -scheme vitamin_calculator -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:vitamin_calculatorTests/NutrientTypeTests/testHasVitaminA test
```

## Architecture

**Tech Stack**: iOS 17+, Swift 6, SwiftUI, SwiftData, Swift Testing framework

**Pattern**: MVVM + Repository Pattern with Dependency Injection

### Layer Structure

```
Views (SwiftUI) → ViewModels (@Observable) → Services → Repositories → SwiftData
                                           ↓
                                    Data (Static DGE values)
```

- **Models**: SwiftData `@Model` classes for persistence (UserProfile, etc.) and plain structs/enums (NutrientType, DailyRecommendation)
- **Services**: Business logic layer (e.g., `RecommendationService` wraps DGE data access)
- **Repositories**: Data access layer with `ModelContext` injection for testability
- **Data**: Static reference data (`DGERecommendations` provides German DGE nutrient values)

### Key Domain Concepts

- **NutrientType**: Enum of 23 nutrients (13 vitamins + 10 minerals) with localized names and units
- **UserType**: Male, Female, or Child(age: Int) - determines DGE recommended values
- **DailyRecommendation**: Links nutrient + user type → recommended amount + upper limit

## TDD Workflow

This project follows strict TDD (Red-Green-Refactor). Always write failing tests first.

### Swift Testing Patterns

```swift
import Testing
@testable import vitamin_calculator

@Suite("Feature Tests")
struct FeatureTests {
    @Test("Descriptive test name explaining behavior")
    func testSomething() {
        // Arrange
        let input = ...

        // Act
        let result = ...

        // Assert
        #expect(result == expected)
    }
}
```

### SwiftData Testing

Always use in-memory storage for tests:

```swift
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(for: UserProfile.self, configurations: config)
let context = ModelContext(container)
```

## Project-Specific Notes

- Nutrient values use μg (micrograms) or mg (milligrams) - check `NutrientType.unit`
- DGE data source: https://www.dge.de/wissenschaft/referenzwerte/
- Child recommendations use 6 age brackets: 1-3, 4-6, 7-9, 10-12, 13-14, 15-18
