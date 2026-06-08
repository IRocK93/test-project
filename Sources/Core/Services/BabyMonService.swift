

import Foundation

@MainActor class BabyMonService {
    private let storage: StorageService

    init(storage: StorageService = StorageService()) {
        self.storage = storage
    }

    func getAllBabyMons() async -> [BabyMon] {
        return await storage.getAllBabyMons()
    }

    func save(_ babyMon: BabyMon) async -> Bool {
        return await storage.saveBabyMon(babyMon)
    }

    func delete(id: String) async -> Bool {
        return await storage.deleteBabyMon(id: id)
    }
}

