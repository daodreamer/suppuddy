//
//  AppError.swift
//  vitamin_calculator
//
//  Created by TDD on 2026-01-28.
//

import Foundation

// MARK: - AppError

/// 应用统一错误类型
enum AppError: LocalizedError {
    case network(NetworkError)
    case database(DatabaseError)
    case validation(ValidationError)
    case permission(PermissionError)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .database(let error):
            return error.localizedDescription
        case .validation(let error):
            return error.localizedDescription
        case .permission(let error):
            return error.localizedDescription
        case .unknown(let error):
            return String(localized: "error_unknown", defaultValue: "An unknown error occurred: \(error.localizedDescription)")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .network(let error):
            return error.recoverySuggestion
        case .database(let error):
            return error.recoverySuggestion
        case .validation(let error):
            return error.recoverySuggestion
        case .permission(let error):
            return error.recoverySuggestion
        case .unknown:
            return String(localized: "error_unknown_recovery", defaultValue: "Please try again or contact support.")
        }
    }
}

// MARK: - NetworkError

/// 网络相关错误
enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case serverError(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return String(localized: "error_no_connection", defaultValue: "No internet connection")
        case .timeout:
            return String(localized: "error_timeout", defaultValue: "Request timed out")
        case .serverError(let code):
            return String(localized: "error_server_error", defaultValue: "Server error (code: \(code))")
        case .invalidResponse:
            return String(localized: "error_invalid_response", defaultValue: "Invalid server response")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noConnection:
            return String(localized: "error_no_connection_recovery", defaultValue: "Please check your internet connection and try again.")
        case .timeout:
            return String(localized: "error_timeout_recovery", defaultValue: "Please try again later.")
        case .serverError:
            return String(localized: "error_server_error_recovery", defaultValue: "The server is experiencing issues. Please try again later.")
        case .invalidResponse:
            return String(localized: "error_invalid_response_recovery", defaultValue: "Please try again.")
        }
    }
}

// MARK: - DatabaseError

/// 数据库相关错误
enum DatabaseError: LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case migrationFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return String(localized: "error_save_failed", defaultValue: "Failed to save data")
        case .fetchFailed:
            return String(localized: "error_fetch_failed", defaultValue: "Failed to load data")
        case .deleteFailed:
            return String(localized: "error_delete_failed", defaultValue: "Failed to delete data")
        case .migrationFailed:
            return String(localized: "error_migration_failed", defaultValue: "Failed to migrate database")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .saveFailed:
            return String(localized: "error_save_failed_recovery", defaultValue: "Please try saving again.")
        case .fetchFailed:
            return String(localized: "error_fetch_failed_recovery", defaultValue: "Please restart the app and try again.")
        case .deleteFailed:
            return String(localized: "error_delete_failed_recovery", defaultValue: "Please try deleting again.")
        case .migrationFailed:
            return String(localized: "error_migration_failed_recovery", defaultValue: "Please reinstall the app.")
        }
    }
}

// MARK: - ValidationError

/// 数据验证相关错误
enum ValidationError: LocalizedError {
    case invalidInput
    case missingRequiredField(String)
    case invalidRange(String)

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return String(localized: "error_invalid_input", defaultValue: "Invalid input")
        case .missingRequiredField(let field):
            return String(localized: "error_missing_required_field", defaultValue: "Required field is missing: \(field)")
        case .invalidRange(let field):
            return String(localized: "error_invalid_range", defaultValue: "Invalid value for \(field)")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidInput:
            return String(localized: "error_invalid_input_recovery", defaultValue: "Please check your input and try again.")
        case .missingRequiredField:
            return String(localized: "error_missing_required_field_recovery", defaultValue: "Please fill in all required fields.")
        case .invalidRange:
            return String(localized: "error_invalid_range_recovery", defaultValue: "Please enter a valid value.")
        }
    }
}

// MARK: - PermissionError

/// 权限相关错误
enum PermissionError: LocalizedError {
    case cameraNotAuthorized
    case notificationNotAuthorized

    var errorDescription: String? {
        switch self {
        case .cameraNotAuthorized:
            return String(localized: "error_camera_not_authorized", defaultValue: "Camera access not authorized")
        case .notificationNotAuthorized:
            return String(localized: "error_notification_not_authorized", defaultValue: "Notification access not authorized")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .cameraNotAuthorized:
            return String(localized: "error_camera_not_authorized_recovery", defaultValue: "Please enable camera access in Settings.")
        case .notificationNotAuthorized:
            return String(localized: "error_notification_not_authorized_recovery", defaultValue: "Please enable notifications in Settings.")
        }
    }
}

// MARK: - ErrorHandler

/// 错误处理工具
struct ErrorHandler {
    /// 将任意错误转换为 AppError
    static func handle(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        // 可以在这里添加更多特定错误类型的转换
        // 例如：URLError -> NetworkError

        return .unknown(error)
    }
}
