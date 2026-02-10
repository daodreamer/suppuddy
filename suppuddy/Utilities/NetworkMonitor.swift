//
//  NetworkMonitor.swift
//  suppuddy
//
//  Created by TDD on 2026-01-28.
//  Updated: Swift 6.2 optimization - replaced GCD with AsyncStream
//

import Foundation
import Network

/// Network connectivity monitor using modern Swift Concurrency (AsyncStream).
/// Replaces the previous GCD DispatchQueue callback pattern.
@Observable
final class NetworkMonitor {
    /// Whether the network is currently connected
    var isConnected = true

    /// The underlying NWPathMonitor
    private let monitor = NWPathMonitor()

    /// Task managing the async monitoring loop
    private nonisolated(unsafe) var monitoringTask: Task<Void, Never>?

    init() {
        startMonitoring()
    }

    deinit {
        monitoringTask?.cancel()
        monitor.cancel()
    }

    /// Starts monitoring network connectivity using AsyncStream
    private func startMonitoring() {
        let monitor = self.monitor
        let stream = AsyncStream<NWPath.Status> { continuation in
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status)
            }
            continuation.onTermination = { @Sendable _ in
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue(label: "com.suppuddy.networkmonitor"))
        }

        monitoringTask = Task { [weak self] in
            for await status in stream {
                guard !Task.isCancelled else { break }
                self?.isConnected = status == .satisfied
            }
        }
    }
}
