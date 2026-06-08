import Foundation

@MainActor class Milestone {
    var id: String
    var babyMonId: String
    var title: String
    var date: Date
    var notes: String?
    
    init(id: String = UUID().uuidString, babyMonId: String, title: String, date: Date, notes: String? = nil) {
        self.id = id
        self.babyMonId = babyMonId
        self.title = title
        self.date = date
        self.notes = notes
    }
}