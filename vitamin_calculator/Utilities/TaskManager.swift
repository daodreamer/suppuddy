//
//  TaskManager.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 1: Memory Optimization - Task Management
//

import Foundation

/// Manages async tasks and ensures proper cleanup
/// Sprint 7 Phase 1: Added to prevent memory leaks from uncancelled tasks
@MainActor
final class TaskManager {
    private var tasks: [String: Task<Void, Never>] = [:]

    /// Stores a task with an identifier
    /// - Parameters:
    ///   - id: Unique identifier for the task
    ///   - task: The task to store
    func store(_ task: Task<Void, Never>, id: String) {
        // Cancel existing task with same id if any
        cancel(id: id)
        tasks[id] = task
    }

    /// Cancels a specific task by id
    /// - Parameter id: The task identifier
    func cancel(id: String) {
        tasks[id]?.cancel()
        tasks[id] = nil
    }

    /// Cancels all managed tasks
    func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }

    deinit {
        // Cancel all tasks synchronously during deinitialization
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

// MARK: - View Extension for Task Management

import SwiftUI

extension View {
    /// Cancels tasks when the view disappears
    /// Sprint 7 Phase 1: Helper to prevent memory leaks
    func cancelTasksOnDisappear(_ taskManager: TaskManager) -> some View {
        self.onDisappear {
            taskManager.cancelAll()
        }
    }
}
