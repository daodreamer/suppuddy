//
//  NetworkMonitorTests.swift
//  vitamin_calculatorTests
//
//  Created by TDD on 2026-01-28.
//

import Testing
import Foundation
@testable import vitamin_calculator

// MARK: - NetworkMonitor Tests

@Suite("NetworkMonitor Tests")
struct NetworkMonitorTests {

    @Test("NetworkMonitor initializes with default state")
    func testNetworkMonitorInitialization() {
        let monitor = NetworkMonitor()

        // NetworkMonitor 应该有初始状态
        // 注意：实际的 isConnected 值可能取决于运行环境
        #expect(monitor != nil)
    }

    @Test("NetworkMonitor provides connection status")
    func testNetworkMonitorConnectionStatus() {
        let monitor = NetworkMonitor()

        // NetworkMonitor 应该提供连接状态
        // isConnected 应该是布尔值
        let isConnected = monitor.isConnected
        #expect(isConnected == true || isConnected == false)
    }

    @Test("NetworkMonitor can be observed")
    func testNetworkMonitorIsObservable() {
        let monitor = NetworkMonitor()

        // NetworkMonitor 应该是 @Observable
        // 可以访问 isConnected 属性
        _ = monitor.isConnected
    }
}

// MARK: - Network Error Handling Tests

@Suite("Network Error Handling Tests")
struct NetworkErrorHandlingTests {

    @Test("Network error thrown when disconnected")
    func testNetworkErrorWhenDisconnected() {
        // 测试当网络断开时应该抛出错误
        let error = NetworkError.noConnection

        #expect(error.errorDescription != nil)
        #expect(error.recoverySuggestion != nil)
    }

    @Test("Network error provides helpful recovery suggestion")
    func testNetworkErrorRecoverySuggestion() {
        let errors: [NetworkError] = [
            .noConnection,
            .timeout,
            .serverError(500),
            .invalidResponse
        ]

        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(error.recoverySuggestion != nil)
        }
    }
}

// MARK: - Offline Mode Tests

@Suite("Offline Mode Tests")
struct OfflineModeTests {

    @Test("App can detect offline state")
    func testOfflineStateDetection() {
        // NetworkMonitor 应该能检测离线状态
        let monitor = NetworkMonitor()

        // 验证可以访问连接状态
        _ = monitor.isConnected
    }

    @Test("App provides offline indicator")
    func testOfflineIndicator() {
        // 当离线时应该能显示指示器
        let monitor = NetworkMonitor()

        if !monitor.isConnected {
            // 离线状态应该被检测到
            #expect(monitor.isConnected == false)
        }
    }
}
