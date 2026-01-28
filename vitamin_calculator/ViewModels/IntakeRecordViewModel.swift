//
//  IntakeRecordViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import SwiftData
import Observation

/// ViewModel for the Intake Record view, managing supplement selection and recording.
@MainActor
@Observable
final class IntakeRecordViewModel {

    // MARK: - Published Properties

    /// Available active supplements for recording
    var availableSupplements: [Supplement] = []

    /// Today's intake records
    var todayRecords: [IntakeRecord] = []

    /// Currently selected supplement for recording
    var selectedSupplement: Supplement?

    /// Selected time of day for recording
    var selectedTimeOfDay: TimeOfDay = .morning

    /// Number of servings to record
    var servingsToRecord: Int = 1

    /// Loading state indicator
    var isLoading: Bool = false

    /// Error message if operation fails
    var errorMessage: String?

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let intakeService: IntakeService
    private let intakeRecordRepository: IntakeRecordRepository
    private let supplementRepository: SupplementRepository

    // MARK: - Initialization

    /// Creates a new intake record view model
    /// - Parameters:
    ///   - modelContext: The SwiftData model context
    ///   - intakeService: The intake service for business logic
    init(modelContext: ModelContext, intakeService: IntakeService) {
        self.modelContext = modelContext
        self.intakeService = intakeService
        self.intakeRecordRepository = IntakeRecordRepository(modelContext: modelContext)
        self.supplementRepository = SupplementRepository(modelContext: modelContext)
    }

    // MARK: - Public Methods

    /// Loads available supplements and today's records
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load active supplements
            availableSupplements = try await supplementRepository.getActive()

            // Load today's records
            todayRecords = try await intakeRecordRepository.getByDate(Date())

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Records an intake for the selected supplement
    func recordIntake() async {
        guard let supplement = selectedSupplement else {
            errorMessage = "请选择一个补剂"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let record = intakeService.recordIntake(
                supplement: supplement,
                servings: servingsToRecord,
                timeOfDay: selectedTimeOfDay,
                date: Date()
            )

            try await intakeRecordRepository.save(record)

            // Reset selection
            selectedSupplement = nil
            servingsToRecord = 1

            // Reload today's records
            todayRecords = try await intakeRecordRepository.getByDate(Date())

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Deletes an intake record
    /// - Parameter record: The record to delete
    func deleteRecord(_ record: IntakeRecord) async {
        isLoading = true
        errorMessage = nil

        do {
            try await intakeRecordRepository.delete(record)

            // Reload today's records
            todayRecords = try await intakeRecordRepository.getByDate(Date())

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Undoes the last recorded intake
    func undoLastRecord() async {
        guard let lastRecord = todayRecords.last else { return }
        await deleteRecord(lastRecord)
    }
}
