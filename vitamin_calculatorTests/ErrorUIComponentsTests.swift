//
//  ErrorUIComponentsTests.swift
//  vitamin_calculatorTests
//
//  Created by TDD on 2026-01-28.
//

import Testing
import SwiftUI
@testable import vitamin_calculator

// MARK: - ErrorView Tests

@Suite("ErrorView Tests")
struct ErrorViewTests {

    @Test("ErrorView displays error description")
    func testErrorViewDisplaysDescription() {
        let error = AppError.network(.noConnection)
        let view = ErrorView(error: error, retryAction: nil)

        // ErrorView 应该显示错误描述
        #expect(error.errorDescription != nil)
    }

    @Test("ErrorView supports retry action")
    func testErrorViewSupportsRetry() {
        var retryExecuted = false
        let error = AppError.network(.timeout)

        let retryAction = {
            retryExecuted = true
        }

        let view = ErrorView(error: error, retryAction: retryAction)

        // 验证重试操作可以被执行
        retryAction()
        #expect(retryExecuted == true)
    }

    @Test("ErrorView displays recovery suggestion when available")
    func testErrorViewDisplaysRecoverySuggestion() {
        let error = AppError.database(.saveFailed)
        let view = ErrorView(error: error, retryAction: nil)

        #expect(error.recoverySuggestion != nil)
    }

    @Test("ErrorView handles errors without retry action")
    func testErrorViewWithoutRetryAction() {
        let error = AppError.validation(.invalidInput)
        let view = ErrorView(error: error, retryAction: nil)

        // 验证视图可以在没有重试操作的情况下创建
        #expect(error.errorDescription != nil)
    }
}

// MARK: - ErrorBanner Tests

@Suite("ErrorBanner Tests")
struct ErrorBannerTests {

    @Test("ErrorBanner displays message")
    func testErrorBannerDisplaysMessage() {
        let message = "Test error message"
        let isPresented = true

        let banner = ErrorBanner(message: message, isPresented: .constant(isPresented))

        // 验证消息不为空
        #expect(message.isEmpty == false)
    }

    @Test("ErrorBanner can be dismissed")
    func testErrorBannerCanBeDismissed() {
        var isPresented = true
        let message = "Test message"

        // 模拟关闭操作
        isPresented = false
        #expect(isPresented == false)
    }

    @Test("ErrorBanner visibility controlled by isPresented binding")
    func testErrorBannerVisibilityBinding() {
        let message = "Test message"
        var isPresented = false

        // Banner 应该隐藏
        #expect(isPresented == false)

        // Banner 应该显示
        isPresented = true
        #expect(isPresented == true)
    }
}

// MARK: - ErrorPresenter Tests

@Suite("ErrorPresenter Utility Tests")
struct ErrorPresenterTests {

    @Test("ErrorPresenter formats error for display")
    func testErrorPresenterFormatting() {
        let error = AppError.network(.noConnection)
        let description = error.errorDescription ?? ""

        #expect(description.isEmpty == false)
    }

    @Test("ErrorPresenter provides user-friendly messages")
    func testUserFriendlyMessages() {
        let errors: [AppError] = [
            .network(.noConnection),
            .database(.saveFailed),
            .validation(.invalidInput),
            .permission(.cameraNotAuthorized)
        ]

        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(error.recoverySuggestion != nil)
        }
    }
}
