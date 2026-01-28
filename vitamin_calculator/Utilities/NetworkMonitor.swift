//
//  NetworkMonitor.swift
//  vitamin_calculator
//
//  Created by TDD on 2026-01-28.
//

import Foundation
import Network

/// 网络状态监控器
@Observable
final class NetworkMonitor {
    /// 网络是否连接
    var isConnected = true

    /// 网络路径监控器
    private let monitor = NWPathMonitor()

    /// 监控队列
    private let queue = DispatchQueue(label: "com.vitamin_calculator.networkmonitor")

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    /// 开始监控网络状态
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    /// 停止监控网络状态
    private func stopMonitoring() {
        monitor.cancel()
    }
}
