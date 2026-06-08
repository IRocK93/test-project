import Foundation
import SwiftData

@Model
class BabyMon {
    var id: UUID = .init()
    var name: String
    var ageInMonths: Int
    var lastFeedingDate: Date?
    var notes: String = ""

    init(name: String, ageInMonths: Int) {
        self.name = name
        self.ageInMonths = ageInMonths
    }
}
