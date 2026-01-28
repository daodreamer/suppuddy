//
//  PerformanceMonitorTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 1: Performance Optimization Tests
//

import Testing
@testable import vitamin_calculator

@Suite("Performance Monitor Tests")
struct PerformanceMonitorTests {

    @Test("PerformanceMonitor is a singleton")
    func testSingletonInstance() {
        let instance1 = PerformanceMonitor.shared
        let instance2 = PerformanceMonitor.shared

        #expect(instance1 === instance2)
    }

    @Test("PerformanceMonitor can measure synchronous operations")
    func testMeasureSyncOperation() {
        let monitor = PerformanceMonitor.shared
        var executed = false

        let result = monitor.measure("Test Operation") {
            executed = true
            return 42
        }

        #expect(executed == true)
        #expect(result == 42)
    }

    @Test("PerformanceMonitor can measure async operations")
    func testMeasureAsyncOperation() async {
        let monitor = PerformanceMonitor.shared
        var executed = false

        let result = await monitor.measureAsync("Async Test") {
            executed = true
            return "success"
        }

        #expect(executed == true)
        #expect(result == "success")
    }

    @Test("PerformanceMonitor handles throwing operations")
    func testMeasureThrowingOperation() {
        let monitor = PerformanceMonitor.shared

        enum TestError: Error {
            case testFailure
        }

        do {
            _ = try monitor.measure("Throwing Operation") {
                throw TestError.testFailure
            }
            Issue.record("Should have thrown an error")
        } catch {
            #expect(error is TestError)
        }
    }

    @Test("PerformanceMonitor begin and end methods work correctly")
    func testBeginEnd() {
        let monitor = PerformanceMonitor.shared

        let signpostID = monitor.begin("Manual Measurement")
        // Perform some work
        let _ = Array(0..<100).map { $0 * 2 }
        monitor.end("Manual Measurement", signpostID: signpostID)

        // Test passes if no crashes occur
        #expect(true)
    }

    @Test("PerformanceMonitor can emit events")
    func testEvent() {
        let monitor = PerformanceMonitor.shared

        // Emit event with message
        monitor.event("Test Event", message: "Test message")

        // Emit event without message
        monitor.event("Another Event")

        // Test passes if no crashes occur
        #expect(true)
    }
}
