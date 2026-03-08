import Foundation

// MARK: - ScrapedRecipe

struct ScrapedRecipe: Sendable {
    let name: String
    let sourceURL: URL
    let imageURL: URL?
    let author: String
    let ingredients: [String]
    let instructions: [String]
    let rawDuration: String
    let servingsText: String
}

// MARK: - ScraperError

enum ScraperError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case noRecipeFound
    case parseError(Error)
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL you entered is not valid."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noRecipeFound:
            return "No recipe found on this page. Make sure it's a recipe URL."
        case .parseError:
            return "Could not parse the recipe data from this page."
        case .httpError(let code) where code == 401 || code == 403:
            return "Cookie expired — update it in Settings"
        case .httpError(let code):
            return "Server returned error \(code)"
        }
    }
}

// MARK: - RecipeScraper

actor RecipeScraper {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .never
        config.httpShouldSetCookies = false
        session = URLSession(configuration: config)
    }

    func scrape(url: URL, cookie: String) async throws -> ScrapedRecipe {
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw ScraperError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw ScraperError.httpError(http.statusCode)
        }

        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw ScraperError.parseError(NSError(domain: "RecipeScraper", code: -1))
        }

        let recipeData: Data
        do {
            recipeData = try HTMLParser.extractRecipeJSON(from: html)
        } catch HTMLParser.ParserError.noRecipeFound, HTMLParser.ParserError.noScriptTagFound {
            throw ScraperError.noRecipeFound
        } catch {
            throw ScraperError.parseError(error)
        }

        let ld: RecipeLD
        do {
            ld = try JSONDecoder().decode(RecipeLD.self, from: recipeData)
        } catch {
            throw ScraperError.parseError(error)
        }

        guard let name = ld.name, !name.isEmpty else {
            throw ScraperError.noRecipeFound
        }

        let imageURL: URL? = ld.image.flatMap { URL(string: $0.url) }

        return ScrapedRecipe(
            name: name,
            sourceURL: url,
            imageURL: imageURL,
            author: ld.author?.name ?? "",
            ingredients: ld.recipeIngredient ?? [],
            instructions: ld.recipeInstructions?.map(\.text).filter { !$0.isEmpty } ?? [],
            rawDuration: ld.effectiveDuration,
            servingsText: ld.recipeYield?.value ?? ""
        )
    }
}
