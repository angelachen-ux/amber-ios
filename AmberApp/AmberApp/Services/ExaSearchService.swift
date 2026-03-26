//
//  ExaSearchService.swift
//  Amber
//
//  Exa.ai people search — discovers people beyond your local contacts.
//  Uses category: "people" for optimized profile matching.
//

import Foundation
import Combine

// MARK: - Exa API Models

struct ExaSearchRequest: Codable {
    let query: String
    let category: String
    let type: String
    let numResults: Int
    let contents: ExaContents?

    struct ExaContents: Codable {
        let text: ExaText?
        let highlights: ExaHighlights?

        struct ExaText: Codable {
            let maxCharacters: Int
        }

        struct ExaHighlights: Codable {
            let maxCharacters: Int
        }
    }
}

struct ExaSearchResponse: Codable {
    let results: [ExaResult]?
    let requestId: String?

    struct ExaResult: Codable, Identifiable {
        let id: String
        let title: String?
        let url: String?
        let author: String?
        let text: String?
        let highlights: [String]?
        let publishedDate: String?
        let image: String?
    }
}

// MARK: - Parsed Person

struct ExaPerson: Identifiable {
    let id: String
    let name: String
    let title: String
    let snippet: String
    let profileURL: String?
    let imageURL: String?
    let source: String // "linkedin", "twitter", "personal", "other"
}

// MARK: - Service

@MainActor
class ExaSearchService: ObservableObject {
    @Published var results: [ExaPerson] = []
    @Published var isSearching: Bool = false
    @Published var error: String?

    private let apiKey = "fd6c5e81-a066-4db5-bd49-70095f51b5b2"
    private let baseURL = "https://api.exa.ai/search"

    private var currentTask: Task<Void, Never>?

    /// Search for people using Exa's people category.
    /// Debounced — call this on every keystroke; it cancels previous requests.
    func search(query: String) {
        currentTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            isSearching = false
            error = nil
            return
        }

        // Debounce 600ms
        currentTask = Task {
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }

            isSearching = true
            error = nil

            do {
                let people = try await performSearch(query: query)
                guard !Task.isCancelled else { return }
                results = people
                isSearching = false
            } catch is CancellationError {
                // Expected when user types fast
            } catch {
                guard !Task.isCancelled else { return }
                self.error = "Search unavailable"
                isSearching = false
                print("[Exa] Search error: \(error)")
            }
        }
    }

    func cancelSearch() {
        currentTask?.cancel()
        results = []
        isSearching = false
        error = nil
    }

    // MARK: - Private

    private func performSearch(query: String) async throws -> [ExaPerson] {
        guard let url = URL(string: baseURL) else { return [] }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = 10

        let body = ExaSearchRequest(
            query: query,
            category: "people",
            type: "auto",
            numResults: 8,
            contents: .init(
                text: .init(maxCharacters: 300),
                highlights: .init(maxCharacters: 150)
            )
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else { return [] }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("[Exa] API error \(httpResponse.statusCode): \(errorBody)")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(ExaSearchResponse.self, from: data)
        return parseResults(decoded.results ?? [])
    }

    private func parseResults(_ results: [ExaSearchResponse.ExaResult]) -> [ExaPerson] {
        results.compactMap { result in
            // Extract name from title or author
            let name = cleanName(result.author ?? result.title ?? "Unknown")
            guard name.count > 1, name != "Unknown" else { return nil }

            // Determine source from URL
            let urlStr = result.url ?? ""
            let source: String
            if urlStr.contains("linkedin") {
                source = "linkedin"
            } else if urlStr.contains("twitter") || urlStr.contains("x.com") {
                source = "twitter"
            } else {
                source = "web"
            }

            // Extract title/role from highlights or text
            let snippet = result.highlights?.first ?? result.text?.prefix(200).description ?? ""
            let title = extractTitle(from: snippet, name: name)

            return ExaPerson(
                id: result.id,
                name: name,
                title: title,
                snippet: String(snippet.prefix(120)),
                profileURL: result.url,
                imageURL: result.image,
                source: source
            )
        }
    }

    private func cleanName(_ raw: String) -> String {
        // Remove common suffixes like " - LinkedIn", " | About", etc.
        var name = raw
        for separator in [" - ", " | ", " – ", " — "] {
            if let range = name.range(of: separator) {
                name = String(name[name.startIndex..<range.lowerBound])
            }
        }
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractTitle(from text: String, name: String) -> String {
        // Try to find role-like phrases
        let roleKeywords = ["CEO", "CTO", "COO", "VP", "Director", "Manager", "Lead",
                          "Engineer", "Designer", "Founder", "Partner", "Professor",
                          "Student", "Researcher", "Analyst", "Consultant"]
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        for (i, word) in words.enumerated() {
            for keyword in roleKeywords {
                if word.contains(keyword) {
                    // Grab surrounding context
                    let start = max(0, i - 1)
                    let end = min(words.count, i + 4)
                    return words[start..<end].joined(separator: " ")
                }
            }
        }
        return ""
    }
}
