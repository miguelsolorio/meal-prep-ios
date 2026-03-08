import Foundation

// MARK: - RecipeLD Decodable types

struct RecipeLD: Decodable {
    let name: String?
    let author: RecipeLDAuthor?
    let image: RecipeLDImage?
    let recipeIngredient: [String]?
    let recipeInstructions: [RecipeLDInstruction]?
    let totalTime: String?
    let cookTime: String?
    let prepTime: String?
    let recipeYield: RecipeLDYield?

    var effectiveDuration: String {
        totalTime ?? cookTime ?? prepTime ?? ""
    }
}

struct RecipeLDAuthor: Decodable {
    let name: String

    init(from decoder: Decoder) throws {
        // Can be a single object {"name":"..."} or an array
        if let container = try? decoder.singleValueContainer(),
           let str = try? container.decode(String.self) {
            name = str
            return
        }
        if var arr = try? decoder.unkeyedContainer(),
           let first = try? arr.decode(AuthorObject.self) {
            name = first.name
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    }

    private enum CodingKeys: String, CodingKey { case name }
    private struct AuthorObject: Decodable { let name: String }
}

struct RecipeLDImage: Decodable {
    let url: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // String
        if let str = try? container.decode(String.self) {
            url = str
            return
        }
        // Array of strings
        if let arr = try? container.decode([String].self), let first = arr.first {
            url = first
            return
        }
        // Object with url key
        struct ImageObject: Decodable { let url: String }
        if let obj = try? container.decode(ImageObject.self) {
            url = obj.url
            return
        }
        // Array of objects
        if let arr = try? container.decode([ImageObject].self), let first = arr.first {
            url = first.url
            return
        }
        url = ""
    }
}

struct RecipeLDInstruction: Decodable {
    let text: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            text = str
            return
        }
        struct InstructionObject: Decodable { let text: String }
        if let obj = try? container.decode(InstructionObject.self) {
            text = obj.text
            return
        }
        text = ""
    }
}

struct RecipeLDYield: Decodable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            value = str
            return
        }
        if let arr = try? container.decode([String].self) {
            value = arr.first ?? ""
            return
        }
        value = ""
    }
}

// MARK: - HTMLParser

enum HTMLParser {
    enum ParserError: Error {
        case noScriptTagFound
        case noRecipeFound
    }

    static func extractRecipeJSON(from html: String) throws -> Data {
        // Extract all ld+json script blocks
        let pattern = #"<script[^>]*type=["']application/ld\+json["'][^>]*>([\s\S]*?)</script>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            throw ParserError.noScriptTagFound
        }

        let nsHTML = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsHTML.length))

        guard !matches.isEmpty else { throw ParserError.noScriptTagFound }

        for match in matches {
            guard let range = Range(match.range(at: 1), in: html) else { continue }
            let jsonString = String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let data = jsonString.data(using: .utf8) else { continue }

            if let recipeData = try? extractRecipe(from: data) {
                return recipeData
            }
        }

        throw ParserError.noRecipeFound
    }

    private static func extractRecipe(from data: Data) throws -> Data {
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            throw ParserError.noRecipeFound
        }

        // Variant 1: root dict with @type == "Recipe"
        if let dict = json as? [String: Any] {
            if isRecipeType(dict) {
                return try JSONSerialization.data(withJSONObject: dict)
            }
            // Variant 2: root dict with @graph array
            if let graph = dict["@graph"] as? [[String: Any]],
               let recipe = graph.first(where: { isRecipeType($0) }) {
                return try JSONSerialization.data(withJSONObject: recipe)
            }
        }

        // Variant 3: root array
        if let array = json as? [[String: Any]],
           let recipe = array.first(where: { isRecipeType($0) }) {
            return try JSONSerialization.data(withJSONObject: recipe)
        }

        throw ParserError.noRecipeFound
    }

    private static func isRecipeType(_ dict: [String: Any]) -> Bool {
        guard let type_ = dict["@type"] else { return false }
        if let str = type_ as? String { return str == "Recipe" }
        if let arr = type_ as? [String] { return arr.contains("Recipe") }
        return false
    }
}
