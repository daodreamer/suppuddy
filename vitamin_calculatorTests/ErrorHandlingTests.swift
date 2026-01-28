//
//  ErrorHandlingTests.swift
//  vitamin_calculatorTests
//
//  Created by TDD on 2026-01-28.
//

import Testing
@testable import vitamin_calculator

// MARK: - AppError Tests

@Suite("AppError Tests")
struct AppErrorTests {

    @Test("AppError.network provides localized error description")
    func testNetworkErrorDescription() {
        let error = AppError.network(.noConnection)
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("AppError.database provides localized error description")
    func testDatabaseErrorDescription() {
        let error = AppError.database(.saveFailed)
        #expect(error.errorDescription != nil)
    }

    @Test("AppError.validation provides localized error description")
    func testValidationErrorDescription() {
        let error = AppError.validation(.invalidInput)
        #expect(error.errorDescription != nil)
    }

    @Test("AppError.unknown wraps other errors")
    func testUnknownError() {
        struct CustomError: Error {}
        let customError = CustomError()
        let appError = AppError.unknown(customError)

        #expect(appError.errorDescription != nil)
    }

    @Test("AppError provides recovery suggestion")
    func testRecoverySuggestion() {
        let error = AppError.network(.noConnection)
        #expect(error.recoverySuggestion != nil)
    }
}

// MARK: - NetworkError Tests

@Suite("NetworkError Tests")
struct NetworkErrorTests {

    @Test("NetworkError.noConnection has localized description")
    func testNoConnectionDescription() {
        let error = NetworkError.noConnection
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("NetworkError.timeout has localized description")
    func testTimeoutDescription() {
        let error = NetworkError.timeout
        #expect(error.errorDescription != nil)
    }

    @Test("NetworkError.serverError includes status code")
    func testServerErrorWithStatusCode() {
        let error = NetworkError.serverError(500)
        #expect(error.errorDescription != nil)
    }

    @Test("NetworkError.invalidResponse has localized description")
    func testInvalidResponseDescription() {
        let error = NetworkError.invalidResponse
        #expect(error.errorDescription != nil)
    }
}

// MARK: - DatabaseError Tests

@Suite("DatabaseError Tests")
struct DatabaseErrorTests {

    @Test("DatabaseError.saveFailed has localized description")
    func testSaveFailedDescription() {
        let error = DatabaseError.saveFailed
        #expect(error.errorDescription != nil)
    }

    @Test("DatabaseError.fetchFailed has localized description")
    func testFetchFailedDescription() {
        let error = DatabaseError.fetchFailed
        #expect(error.errorDescription != nil)
    }

    @Test("DatabaseError.deleteFailed has localized description")
    func testDeleteFailedDescription() {
        let error = DatabaseError.deleteFailed
        #expect(error.errorDescription != nil)
    }

    @Test("DatabaseError.migrationFailed has localized description")
    func testMigrationFailedDescription() {
        let error = DatabaseError.migrationFailed
        #expect(error.errorDescription != nil)
    }
}

// MARK: - ValidationError Tests

@Suite("ValidationError Tests")
struct ValidationErrorTests {

    @Test("ValidationError.invalidInput has localized description")
    func testInvalidInputDescription() {
        let error = ValidationError.invalidInput
        #expect(error.errorDescription != nil)
    }

    @Test("ValidationError.missingRequiredField has localized description")
    func testMissingRequiredFieldDescription() {
        let error = ValidationError.missingRequiredField("name")
        #expect(error.errorDescription != nil)
    }

    @Test("ValidationError.invalidRange includes field name")
    func testInvalidRangeWithFieldName() {
        let error = ValidationError.invalidRange("age")
        #expect(error.errorDescription != nil)
    }
}

// MARK: - PermissionError Tests

@Suite("PermissionError Tests")
struct PermissionErrorTests {

    @Test("PermissionError.cameraNotAuthorized has localized description")
    func testCameraNotAuthorizedDescription() {
        let error = PermissionError.cameraNotAuthorized
        #expect(error.errorDescription != nil)
    }

    @Test("PermissionError.notificationNotAuthorized has localized description")
    func testNotificationNotAuthorizedDescription() {
        let error = PermissionError.notificationNotAuthorized
        #expect(error.errorDescription != nil)
    }
}

// MARK: - ErrorHandler Tests

@Suite("ErrorHandler Tests")
struct ErrorHandlerTests {

    @Test("ErrorHandler converts AppError to AppError")
    func testHandleAppError() {
        let originalError = AppError.network(.noConnection)
        let handledError = ErrorHandler.handle(originalError)

        if case .network(.noConnection) = handledError {
            // Success
        } else {
            Issue.record("Expected network error but got \(handledError)")
        }
    }

    @Test("ErrorHandler converts unknown error to AppError.unknown")
    func testHandleUnknownError() {
        struct CustomError: Error {}
        let customError = CustomError()
        let handledError = ErrorHandler.handle(customError)

        if case .unknown = handledError {
            // Success
        } else {
            Issue.record("Expected unknown error but got \(handledError)")
        }
    }

    @Test("ErrorHandler provides consistent error handling")
    func testConsistentErrorHandling() {
        let errors: [Error] = [
            AppError.network(.timeout),
            AppError.database(.saveFailed),
            AppError.validation(.invalidInput)
        ]

        for error in errors {
            let handled = ErrorHandler.handle(error)
            #expect(handled.errorDescription != nil)
        }
    }
}
