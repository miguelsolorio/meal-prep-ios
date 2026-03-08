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

        // Collect all LD dicts from root object or root array
        var candidates: [[String: Any]] = []
        if let dict = json as? [String: Any] {
            candidates.append(dict)
            if let graph = dict["@graph"] as? [[String: Any]] {
                candidates.append(contentsOf: graph)
            }
        } else if let array = json as? [[String: Any]] {
            candidates = array
        }

        // Prefer @type == "Recipe"
        if let recipe = candidates.first(where: { isRecipeType($0) }) {
            return try JSONSerialization.data(withJSONObject: recipe)
        }

        // Fallback: @type == "Article" with articleBody containing INGREDIENTS/DIRECTIONS
        if let article = candidates.first(where: { isArticleType($0) }),
           let synthetic = try? extractFromArticle(article) {
            return synthetic
        }

        throw ParserError.noRecipeFound
    }

    private static func isRecipeType(_ dict: [String: Any]) -> Bool {
        guard let type_ = dict["@type"] else { return false }
        if let str = type_ as? String { return str == "Recipe" }
        if let arr = type_ as? [String] { return arr.contains("Recipe") }
        return false
    }

    private static func isArticleType(_ dict: [String: Any]) -> Bool {
        guard let type_ = dict["@type"] else { return false }
        let articleTypes = ["Article", "NewsArticle", "BlogPosting"]
        if let str = type_ as? String { return articleTypes.contains(str) }
        if let arr = type_ as? [String] { return arr.contains(where: { articleTypes.contains($0) }) }
        return false
    }

    /// Synthesise a Recipe-compatible dict from an Article LD block whose
    /// `articleBody` contains INGREDIENTS / DIRECTIONS sections.
    private static func extractFromArticle(_ dict: [String: Any]) throws -> Data {
        guard let body = dict["articleBody"] as? String,
              let headline = dict["headline"] as? String else {
            throw ParserError.noRecipeFound
        }

        let (ingredients, instructions) = parseArticleBody(body)
        guard !ingredients.isEmpty || !instructions.isEmpty else {
            throw ParserError.noRecipeFound
        }

        var recipe: [String: Any] = ["@type": "Recipe", "name": headline]
        if let image = dict["image"] { recipe["image"] = image }
        if let author = dict["author"] { recipe["author"] = author }
        if !ingredients.isEmpty { recipe["recipeIngredient"] = ingredients }
        if !instructions.isEmpty {
            recipe["recipeInstructions"] = instructions.map { ["text": $0] }
        }
        return try JSONSerialization.data(withJSONObject: recipe)
    }

    private static func parseArticleBody(_ body: String) -> ([String], [String]) {
        let upper = body.uppercased()
        guard let ingRange = upper.range(of: "INGREDIENTS"),
              let dirRange = upper.range(of: "DIRECTIONS"),
              ingRange.upperBound < dirRange.lowerBound else {
            return ([], [])
        }

        let ingredientsText = String(body[ingRange.upperBound..<dirRange.lowerBound])
        let instructionsText = String(body[dirRange.upperBound...])

        return (splitIngredients(ingredientsText), splitInstructions(instructionsText))
    }

    /// Split a run-together ingredient string into individual lines.
    /// Splits before digit/fraction characters and at lower→upper camelCase boundaries.
    private static func splitIngredients(_ text: String) -> [String] {
        // Insert a delimiter before quantity starters and before camelCase transitions
        let fractions = "½¼¾⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞"
        var result: [String] = []
        var current = ""

        let chars = Array(text)
        for i in chars.indices {
            let c = chars[i]
            let prev = i > 0 ? chars[i - 1] : nil

            let startsIngredient: Bool = {
                // Digit or fraction at a word boundary
                if c.isNumber || fractions.contains(c) {
                    return prev == nil || !prev!.isNumber
                }
                // camelCase boundary: prev is lowercase, current is uppercase
                if let p = prev, p.isLowercase, c.isUppercase { return true }
                return false
            }()

            if startsIngredient && !current.trimmingCharacters(in: .whitespaces).isEmpty {
                result.append(current.trimmingCharacters(in: .whitespaces))
                current = String(c)
            } else {
                current.append(c)
            }
        }
        if !current.trimmingCharacters(in: .whitespaces).isEmpty {
            result.append(current.trimmingCharacters(in: .whitespaces))
        }
        return result.filter { !$0.isEmpty }
    }

    /// Split a run-together instruction string into individual steps.
    /// Splits on ". CapitalLetter" boundaries and on temperature-unit boundaries (e.g. °FWord).
    private static func splitInstructions(_ text: String) -> [String] {
        var result: [String] = []
        var current = ""

        let chars = Array(text)
        for i in chars.indices {
            let c = chars[i]
            let prev = i > 0 ? chars[i - 1] : nil

            let startsStep: Bool = {
                guard c.isUppercase, let p = prev else { return false }
                // After sentence-ending punctuation
                if ".!?".contains(p) { return true }
                // After a temperature unit (e.g. °F → next word)
                if p.isUppercase,
                   i >= 2,
                   chars[i - 2] == "°" { return true }
                return false
            }()

            if startsStep && !current.trimmingCharacters(in: .whitespaces).isEmpty {
                result.append(current.trimmingCharacters(in: .whitespaces))
                current = String(c)
            } else {
                current.append(c)
            }
        }
        if !current.trimmingCharacters(in: .whitespaces).isEmpty {
            result.append(current.trimmingCharacters(in: .whitespaces))
        }
        // Drop trailing noise like "Shop …" product links
        return result.filter { $0.count > 10 }
    }
}
