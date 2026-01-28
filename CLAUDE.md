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

## Recent Updates (Sprint 7)

### Sprint 7 Completed Features

**Phase 1: Performance Optimization**
- Startup performance < 1 second
- UI performance optimizations (LazyVStack, efficient queries)
- Memory management and leak prevention
- Database query optimization with FetchDescriptor

**Phase 2: Accessibility Features**
- VoiceOver support for all interactive elements
- Dynamic font support with @ScaledMetric
- Color contrast optimization (WCAG 2.1 compliant)
- Reduce motion support

**Phase 3: Localization**
- Full support for German, English, and Simplified Chinese
- Localized nutrient names using DGE standard terminology
- Date and number formatting with locale support
- String catalogs: `Localizable.xcstrings`

**Phase 4: App Branding**
- App icon designed and implemented
- Launch screen configured
- Support for light/dark mode variants

**Phase 5: Error Handling**
- Unified error handling with `AppError` enum
- Error UI components (`ErrorView`, `ErrorBanner`)
- Network error handling with `NetworkMonitor`
- Localized error messages

**Phase 6: Testing**
- 870+ automated tests with 99.66% pass rate
- Test coverage > 85%
- Integration tests for complete user workflows
- Performance tests (launch time, UI responsiveness)

### New ViewModels

- `DashboardViewModel` - Dashboard logic and nutrient calculations
- `SupplementListViewModel` - Supplement list management
- `SupplementFormViewModel` - Add/edit supplement forms
- `SupplementDetailViewModel` - Supplement detail view logic
- `BarcodeScannerViewModel` - Barcode scanning workflow
- `ProductSearchViewModel` - Product search with pagination
- `DataManagementViewModel` - Export/import data management
- `OnboardingViewModel` - First-time user onboarding
- `UserProfileViewModel` - User profile management
- `NutrientChartViewModel` - Nutrient visualization
- `IntakeRecordViewModel` - Intake record management
- `HistoryViewModel` - Historical data views
- `ScanHistoryViewModel` - Barcode scan history

### New Services

- `RecommendationService` - DGE recommendation queries
- `ProductLookupService` - Open Food Facts API integration
- `BarcodeScannerService` - Camera-based barcode scanning
- `DataExportService` - Export user data to JSON
- `DataImportService` - Import and validate JSON data
- `OnboardingService` - Onboarding workflow management
- `NutrientMappingService` - Map API nutrients to app nutrients
- `NetworkMonitor` - Network connectivity monitoring

### New Models

- `UserProfile` - User configuration with SwiftData
- `Supplement` - Supplement with nutrients relationship
- `SupplementNutrient` - Individual nutrient in supplement
- `IntakeRecord` - Daily intake tracking
- `ScanHistory` - Barcode scan history
- `ProductSearchResult` - Search result from API
- `ScannedProduct` - Product data from barcode scan
- `ExportData` - Export data structure
- `AppError` - Unified error types
- `OnboardingState` - Onboarding flow state

### Testing Patterns

All tests follow these patterns:

```swift
// Repository tests with in-memory storage
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(for: Supplement.self, configurations: config)
let context = ModelContext(container)
let repository = SupplementRepository(modelContext: context)

// ViewModel tests
let viewModel = DashboardViewModel(
    recommendationService: mockRecommendationService,
    supplementRepository: mockSupplementRepo
)

// Service tests with dependency injection
let service = ProductLookupService(
    api: mockAPI,
    historyRepository: mockHistoryRepo
)
```

### Key Files Added

**Services**:
- `Services/RecommendationService.swift`
- `Services/ProductLookupService.swift`
- `Services/DataExportService.swift`
- `Services/DataImportService.swift`
- `Services/OnboardingService.swift`
- `Services/NetworkMonitor.swift`

**ViewModels**:
- `ViewModels/DashboardViewModel.swift`
- `ViewModels/SupplementListViewModel.swift`
- `ViewModels/BarcodeScannerViewModel.swift`
- `ViewModels/ProductSearchViewModel.swift`

**Views**:
- `Views/DashboardView.swift`
- `Views/SupplementFormView.swift`
- `Views/BarcodeScannerView.swift`
- `Views/ErrorBanner.swift`
- `Views/DataManagement/DataManagementView.swift`

**Localization**:
- `Resources/Localizable.xcstrings` - String catalog for 3 languages
- `Models/NutrientType+Localization.swift` - Nutrient name localization

**Testing**:
- `Tests/IntegrationTests.swift` - Sprint 5 integration tests
- `Tests/Sprint6IntegrationTests.swift` - Sprint 6 integration tests
- `Tests/ErrorHandlingTests.swift` - Error handling tests
- `Tests/LocalizationTests.swift` - Localization tests
- 50+ test files covering all modules

## Common Development Tasks

### Adding a New Nutrient

1. Update `NutrientType` enum
2. Add DGE recommendation to `DGERecommendations.swift`
3. Add localized names to `Localizable.xcstrings`
4. Write tests first (TDD)
5. Update UI components if needed

### Adding a New User Type

1. Update `UserType` enum
2. Add recommendations to `DGERecommendations.swift`
3. Write tests for new user type
4. Update `RecommendationService` if needed

### Debugging Tips

- Use in-memory SwiftData for tests: `ModelConfiguration(isStoredInMemoryOnly: true)`
- Check test logs for SwiftData warnings
- Use `@MainActor` for ViewModels and SwiftData operations
- Network debugging: Check `ProductLookupService` mock data

## Project Statistics

- **Total Lines of Code**: ~15,000+
- **Total Test Cases**: 870+
- **Test Pass Rate**: 99.66%
- **Code Coverage**: > 85%
- **Supported Languages**: 3 (de, en, zh-Hans)
- **Supported Nutrients**: 23 (13 vitamins + 10 minerals)
- **iOS Minimum Version**: 17.0+
- **Swift Version**: 6.0+
