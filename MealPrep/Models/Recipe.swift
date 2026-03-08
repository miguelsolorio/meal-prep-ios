import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var name: String
    var sourceURL: URL
    var imageURL: URL?
    var author: String
    var ingredients: [String]
    var instructions: [String]
    var rawDuration: String        // ISO 8601 e.g. "PT1H30M"
    var servingsText: String
    var dateAdded: Date

    init(
        id: UUID = UUID(),
        name: String,
        sourceURL: URL,
        imageURL: URL? = nil,
        author: String = "",
        ingredients: [String] = [],
        instructions: [String] = [],
        rawDuration: String = "",
        servingsText: String = "",
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.sourceURL = sourceURL
        self.imageURL = imageURL
        self.author = author
        self.ingredients = ingredients
        self.instructions = instructions
        self.rawDuration = rawDuration
        self.servingsText = servingsText
        self.dateAdded = dateAdded
    }

    var displayDuration: String {
        ISO8601DurationParser.parse(rawDuration)
    }

    var totalCookMinutes: Int {
        ISO8601DurationParser.totalMinutes(rawDuration)
    }
}
