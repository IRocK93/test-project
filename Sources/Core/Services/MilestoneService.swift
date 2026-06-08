

import Foundation

@MainActor class MilestoneService {
    private let storage: StorageService

    init(storage: StorageService = StorageService()) {
        self.storage = storage
    }

    func getAllMilestones() async -> [Milestone] {
        return await storage.getAllMilestones()
    }

    func save(_ milestone: Milestone) async -> Bool {
        return await storage.saveMilestone(milestone)
    }

    func delete(id: String) async -> Bool {
        return await storage.deleteMilestone(id: id)
    }

    func update(_ milestone: Milestone) async -> Bool {
        return await storage.updateMilestone(milestone)
    }

    func getMilestone(id: String) async -> Milestone? {
        return await storage.getMilestone(id: id)
    }
}

