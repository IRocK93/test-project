

import Foundation

@MainActor class HealthService {
    private let storage: StorageService

    init(storage: StorageService = StorageService()) {
        self.storage = storage
    }

    func getAllHealthRecords() async -> [HealthRecord] {
        return await storage.getAllHealthRecords()
    }

    func save(_ healthRecord: HealthRecord) async -> Bool {
        return await storage.saveHealthRecord(healthRecord)
    }

    func delete(id: String) async -> Bool {
        return await storage.deleteHealthRecord(id: id)
    }

    func update(_ healthRecord: HealthRecord) async -> Bool {
        return await storage.updateHealthRecord(healthRecord)
    }

    func getHealthRecord(id: String) async -> HealthRecord? {
        return await storage.getHealthRecord(id: id)
    }
}

