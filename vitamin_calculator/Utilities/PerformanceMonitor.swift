//
//  PerformanceMonitor.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 1: Performance Optimization
//

import Foundation
import os.signpost

/// Performance monitoring utility for measuring critical app operations
@available(iOS 17.0, *)
final class PerformanceMonitor {
    // MARK: - Singleton

    static let shared = PerformanceMonitor()

    // MARK: - Properties

    private let subsystem = "com.vitamin_calculator.performance"
    private let log: OSLog

    // MARK: - Initialization

    private init() {
        self.log = OSLog(subsystem: subsystem, category: "performance")
    }

    // MARK: - Signpost Methods

    /// Begins a performance measurement interval
    /// - Parameter name: The name of the operation being measured
    /// - Returns: An OSSignpostID for ending the interval
    func begin(_ name: StaticString) -> OSSignpostID {
        let signpostID = OSSignpostID(log: log)
        os_signpost(.begin, log: log, name: name, signpostID: signpostID)
        return signpostID
    }

    /// Ends a performance measurement interval
    /// - Parameters:
    ///   - name: The name of the operation (must match the begin call)
    ///   - signpostID: The ID returned from the begin call
    func end(_ name: StaticString, signpostID: OSSignpostID) {
        os_signpost(.end, log: log, name: name, signpostID: signpostID)
    }

    /// Emits an event marker for a specific point in time
    /// - Parameters:
    ///   - name: The name of the event
    ///   - message: Optional message describing the event
    func event(_ name: StaticString, message: String = "") {
        os_signpost(.event, log: log, name: name, "%{public}s", message)
    }
}

// MARK: - Convenience Extensions

extension PerformanceMonitor {
    /// Measures the execution time of a closure
    /// - Parameters:
    ///   - name: The name of the operation
    ///   - operation: The closure to execute and measure
    func measure<T>(_ name: StaticString, operation: () throws -> T) rethrows -> T {
        let signpostID = begin(name)
        defer { end(name, signpostID: signpostID) }
        return try operation()
    }

    /// Measures the execution time of an async closure
    /// - Parameters:
    ///   - name: The name of the operation
    ///   - operation: The async closure to execute and measure
    func measureAsync<T>(_ name: StaticString, operation: () async throws -> T) async rethrows -> T {
        let signpostID = begin(name)
        defer { end(name, signpostID: signpostID) }
        return try await operation()
    }
}
