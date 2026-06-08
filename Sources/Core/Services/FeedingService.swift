

import Foundation

@MainActor class FeedingService {
    private let storage: StorageService

    init(storage: StorageService = StorageService()) {
        self.storage = storage
    }

    func getAllFeedings() async -> [FeedingLog] {
        return await storage.getAllFeedingLogs()
    }

    func save(_ feedingLog: FeedingLog) async -> Bool {
        return await storage.saveFeedingLog(feedingLog)
    }

    func delete(id: String) async -> Bool {
        return await storage.deleteFeedingLog(id: id)
    }

    func update(_ feedingLog: FeedingLog) async -> Bool {
        return await storage.updateFeedingLog(feedingLog)
    }

    func getFeedingLog(id: String) async -> FeedingLog? {
        return await storage.getFeedingLog(id: id)
    }
}

