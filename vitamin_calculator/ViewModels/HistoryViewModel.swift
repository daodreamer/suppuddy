//
//  HistoryViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import SwiftData
import Observation

/// Represents the intake status for a specific date (for calendar display)
enum IntakeStatus: String, CaseIterable, Codable, Hashable, Sendable {
    /// No intake recorded for this date
    case none
    /// Some intake recorded but not complete
    case partial
    /// Complete intake for this date
    case complete
}

/// Format options for data export
enum ExportFormat: String, CaseIterable {
    case csv
    case json
}

/// ViewModel for the History view, managing historical intake records and calendar data.
@MainActor
@Observable
final class HistoryViewModel {

    // MARK: - Published Properties

    /// Currently selected date for viewing
    var selectedDate: Date = Date()

    /// Date range for filtering (optional)
    var dateRange: ClosedRange<Date>?

    /// Loaded intake records
    var records: [IntakeRecord] = []

    /// Daily summaries for the loaded period
    var dailySummaries: [DailyIntakeSummary] = []

    /// Calendar data showing intake status by date
    var calendarData: [Date: IntakeStatus] = [:]

    /// Loading state indicator
    var isLoading: Bool = false

    /// Error message if operation fails
    var errorMessage: String?

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let intakeRecordRepository: IntakeRecordRepository
    private let intakeService: IntakeService

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.intakeRecordRepository = IntakeRecordRepository(modelContext: modelContext)
        self.intakeService = IntakeService()
    }

    // MARK: - Public Methods

    /// Loads records for a specific date
    func loadRecords(for date: Date) async {
        isLoading = true
        errorMessage = nil

        do {
            records = try await intakeRecordRepository.getByDate(date)
            selectedDate = date
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Loads records for a date range
    func loadRecords(from startDate: Date, to endDate: Date) async {
        isLoading = true
        errorMessage = nil

        do {
            records = try await intakeRecordRepository.getByDateRange(from: startDate, to: endDate)
            dateRange = startDate...endDate
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Loads calendar data for a given month
    func loadCalendarData(for month: Date) async {
        isLoading = true
        errorMessage = nil

        do {
            let calendar = Calendar.current
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

            let monthRecords = try await intakeRecordRepository.getByDateRange(from: startOfMonth, to: endOfMonth)

            // Group records by date and determine status
            var data: [Date: IntakeStatus] = [:]
            var recordsByDate: [Date: [IntakeRecord]] = [:]

            for record in monthRecords {
                let dateKey = calendar.startOfDay(for: record.date)
                recordsByDate[dateKey, default: []].append(record)
            }

            for (date, dateRecords) in recordsByDate {
                // Simple logic: any records = partial, multiple records = complete
                data[date] = dateRecords.count > 1 ? .complete : .partial
            }

            calendarData = data
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Exports data to the specified format
    func exportData(format: ExportFormat) async -> URL? {
        // Implementation for export functionality
        // For now, return nil as placeholder
        return nil
    }
}
