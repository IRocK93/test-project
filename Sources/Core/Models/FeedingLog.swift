import Foundation

@MainActor class FeedingLog {
    var id: String
    var babyMonId: String
    var type: String  // breastmilk, formula, solid
    var amount: Double?
    var notes: String?
    var timestamp: Date
    
    init(id: String = UUID().uuidString, babyMonId: String, type: String, amount: Double? = nil, notes: String? = nil, timestamp: Date = Date()) {
        self.id = id
        self.babyMonId = babyMonId
        self.type = type
        self.amount = amount
        self.notes = notes
        self.timestamp = timestamp
    }
}