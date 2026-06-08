import Foundation

@MainActor class HealthRecord {
    var id: String
    var babyMonId: String
    var type: String  // vaccination, visit
    var name: String
    var date: Date
    var notes: String?
    
    init(id: String = UUID().uuidString, babyMonId: String, type: String, name: String, date: Date, notes: String? = nil) {
        self.id = id
        self.babyMonId = babyMonId
        self.type = type
        self.name = name
        self.date = date
        self.notes = notes
    }
}