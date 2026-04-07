import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var recipes: [Recipe]    = Recipe.defaults
    @Published var pantry: [PantryItem] = PantryItem.defaults
    @Published var shopping: [ShoppingItem] = ShoppingItem.defaults
    @Published var week: [WeekDay]      = WeekDay.defaults
    @Published var likedPosts: Set<Int> = []
    @Published var isLoadingAI          = false

    // ── Rezept des Tages: ändert sich täglich ──
    var dailyRecipe: Recipe {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return recipes[(dayOfYear - 1) % recipes.count]
    }

    var specialItems: [PantryItem] { pantry.filter(\.isSpecial) }

    // ── Einkaufsliste ──
    func addToShopping(recipe: Recipe) {
        let item = ShoppingItem(
            id: Int(Date().timeIntervalSince1970),
            name: "Für: \(recipe.name)",
            amount: "",
            isDone: false,
            category: "Rezept"
        )
        shopping.insert(item, at: 0)
    }

    // ── KI-Vorschläge via Anthropic API ──
    // ⚠️ Ersetze YOUR_API_KEY_HERE mit deinem Anthropic API-Key
    // Besser: Key in Xcode unter Build Settings > User-Defined als ANTHROPIC_API_KEY ablegen
    func loadAIRecipes() async {
        isLoadingAI = true
        defer { isLoadingAI = false }

        let specials = pantry.filter(\.isSpecial).map(\.name).joined(separator: ", ")
        let all      = pantry.map(\.name).joined(separator: ", ")
        let prompt   = """
        Du bist Kochassistent für "Next Cooking". Mein Vorrat: \(all). \
        Sonderzutaten die verbraucht werden müssen: \(specials). \
        Erstelle 4 passende Rezeptvorschläge. \
        Antworte NUR mit einem JSON-Array, kein Markdown, kein Text: \
        [{"id":1,"name":"Rezeptname","time":30,"match":95,"uses":["Zutat1"],"cat":"Küche","emoji":"🍜","batch":false,"desc":"Beschreibung"}]. \
        Sonderzutaten in mind. 2 Vorschlägen. match=Vorratstreffer %, batch=true wenn einfrierbar.
        """

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("YOUR_API_KEY_HERE", forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01",        forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 900,
            "messages": [["role": "user", "content": prompt]]
        ]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else { return }
        req.httpBody = bodyData

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            if let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["content"] as? [[String: Any]],
               let text    = content.first?["text"] as? String {
                let cleaned = text
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```",     with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if let jsonData = cleaned.data(using: .utf8),
                   let parsed   = try? JSONDecoder().decode([Recipe].self, from: jsonData),
                   !parsed.isEmpty {
                    recipes = parsed
                }
            }
        } catch {
            print("AI Error: \(error)")
        }
    }

    // ── Wochenplan KI-Füllung ──
    func fillWeekWithAI() {
        week = week.enumerated().map { (i, day) in
            var d = day
            d.recipe = recipes[i % recipes.count].name
            d.emoji  = recipes[i % recipes.count].emoji
            return d
        }
    }
}
