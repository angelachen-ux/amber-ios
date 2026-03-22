// DATA-02: Apple HealthKit Data Ingestion
// Ingest steps, workouts, sleep for behavioral signals in later sprints.
// Sprint 1: ingest only — data not yet used for suggestions.

import Foundation
import HealthKit
import SwiftData

@MainActor
final class HealthKitService: ObservableObject {
    @Published var isAuthorized = false
    @Published var lastSyncedAt: Date?

    private let store = HKHealthStore()

    // Types we request read access to
    private let readTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) { types.insert(steps) }
        if let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { types.insert(energy) }
        if let workouts = HKObjectType.workoutType() as HKObjectType? { types.insert(workouts) }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(sleep) }
        return types
    }()

    // MARK: - Availability & Authorization

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            return true
        } catch {
            return false
        }
    }

    // MARK: - Ingestion

    struct HealthSnapshot: Codable {
        var stepsLast30Days: Double
        var activeEnergyLast30Days: Double
        var workoutCountLast30Days: Int
        var avgSleepHoursLast7Days: Double
        var capturedAt: Date
    }

    func ingestSnapshot() async -> HealthSnapshot? {
        guard isAvailable else { return nil }
        let now = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        let sevenDaysAgo  = Calendar.current.date(byAdding: .day,  value: -7,  to: now)!

        async let steps   = sumQuantity(.stepCount, from: thirtyDaysAgo, to: now, unit: .count())
        async let energy  = sumQuantity(.activeEnergyBurned, from: thirtyDaysAgo, to: now, unit: .kilocalorie())
        async let workouts = countWorkouts(from: thirtyDaysAgo, to: now)
        async let sleep   = avgSleepHours(from: sevenDaysAgo, to: now)

        let (s, e, w, sl) = await (steps, energy, workouts, sleep)
        lastSyncedAt = now
        return HealthSnapshot(
            stepsLast30Days: s,
            activeEnergyLast30Days: e,
            workoutCountLast30Days: w,
            avgSleepHoursLast7Days: sl,
            capturedAt: now
        )
    }

    // MARK: - Helpers

    private func sumQuantity(
        _ identifier: HKQuantityTypeIdentifier,
        from start: Date,
        to end: Date,
        unit: HKUnit
    ) async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let value = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func countWorkouts(from start: Date, to end: Date) async -> Int {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                continuation.resume(returning: samples?.count ?? 0)
            }
            store.execute(query)
        }
    }

    private func avgSleepHours(from start: Date, to end: Date) async -> Double {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
                    continuation.resume(returning: 0)
                    return
                }
                // Only count asleep/core/deep/REM stages
                let asleepValues: Set<HKCategoryValueSleepAnalysis> = [.asleepUnspecified, .asleepCore, .asleepDeep, .asleepREM]
                let totalSeconds = samples
                    .filter { asleepValues.contains(HKCategoryValueSleepAnalysis(rawValue: $0.value)!) }
                    .map { $0.endDate.timeIntervalSince($0.startDate) }
                    .reduce(0, +)
                let days = max(1, Calendar.current.dateComponents([.day], from: start, to: end).day ?? 7)
                continuation.resume(returning: (totalSeconds / 3600) / Double(days))
            }
            store.execute(query)
        }
    }
}
