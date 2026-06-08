import SwiftUI
import SwiftData// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// MARK: - Error Handling
enum StorageError: LocalizedError {
    case saveFailed(String)
    case deleteFailed(String)
    case fetchFailed(String)// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

    var errorDescription: String? {
        switch self {
        case .saveFailed(let message): return "Failed to save: \(message)"
        case .deleteFailed(let message): return "Failed to delete: \(message)"
        case .fetchFailed(let message): return "Failed to fetch: \(message)"
        }
    }
}// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// MARK: - StorageService
@MainActor
class StorageService: ObservableObject {// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

    /// Returns all baby mon profiles from SwiftData storage
    func getAllBabyMons() async -> [BabyMon] {
        let queryDescriptor = FetchDescriptor<BabyMon>()// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

        do {
            return try await ModelContext.shared.fetch(queryDescriptor)
        } catch {
            print("Failed to fetch BabyMon entries: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error.localizedDescription)
        }
    }// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

    /// Saves a baby mon profile - creates new or updates existing
    func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
        do {
            // Check if this babyMon already exists by trying to find it first
            let fetchDescriptor = FetchDescriptor<BabyMon>(predicate: #Predicate<BabyMon> { $0.id == babyMon.id })
            let existingMons = try await ModelContext.shared.fetch(fetchDescriptor)// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

            if !existingMons.isEmpty {
                // Update existing record - SwiftData @Model automatically tracks changes
                // Just save the context to persist changes
                try await ModelContext.shared.save()
                return true
            } else {
                // Create new record
                ModelContext.shared.insert(babyMon)
                try await ModelContext.shared.save()
                return true
            }
        } catch let error as StorageError {
            print("Storage save failed with StorageError: \(error.localizedDescription)")
            return false
        } catch {
            print("Failed to save BabyMon entry: \(error.localizedDescription)")
            throw StorageError.saveFailed(error.localizedDescription)
        }
    }// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

    /// Deletes a baby mon by ID - returns true if deleted, false otherwise
    func deleteBabyMon(id: String) async -> Bool {
        do {
            // First, try to find the record with this ID
            let fetchDescriptor = FetchDescriptor<BabyMon>(predicate: #Predicate<BabyMon> { $0.id.uuidString == id })
            let existingMons = try await ModelContext.shared.fetch(fetchDescriptor)// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

            if !existingMons.isEmpty {
                // Found and delete the record
                for mon in existingMons {
                    ModelContext.shared.delete(mon)
                }
                try await ModelContext.shared.save()
                print("Successfully deleted BabyMon with ID: \(id)")
                return true
            } else {
                // No record found with this ID, but don't throw - just return false
                print("No BabyMon found with ID: \(id) to delete")
                return false
            }
        } catch let error as StorageError {
            print("Storage delete failed with StorageError: \(error.localizedDescription)")
            return false
        } catch {
            print("Failed to delete BabyMon entry: \(error.localizedDescription)")
            throw StorageError.deleteFailed(error.localizedDescription)
        }
    }
}// Add save and delete methods for BabyMon
func saveBabyMon(_ babyMon: BabyMon) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Save logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

func deleteBabyMon(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        // Delete logic here - replace with actual implementation
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for Milestone
func getAllMilestones(forBabyMonId: String) async -> [Milestone] {
    return [] // Replace with actual implementation
}

func saveMilestone(_ milestone: Milestone) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteMilestone(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for FeedingLog
func getAllFeedingLogs(forBabyMonId: String) async -> [FeedingLog] {
    return [] // Replace with actual implementation
}

func saveFeedingLog(_ log: FeedingLog) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteFeedingLog(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

// Add CRUD methods for HealthRecord
func getAllHealthRecords(forBabyMonId: String) async -> [HealthRecord] {
    return [] // Replace with actual implementation
}

func saveHealthRecord(_ record: HealthRecord) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

func deleteHealthRecord(id: String) async -> Bool {
    return await withCheckedContinuation { continuation in
        continuation.resume(returning: true)
    }
}

