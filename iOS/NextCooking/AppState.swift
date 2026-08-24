import Foundation
import SwiftUI
import HealthKit

@MainActor
class AppState: ObservableObject {
    @Published var recipes: [Recipe]         = Recipe.defaults
    @Published var pantry: [PantryItem]      = PantryItem.defaults
    @Published var shopping: [ShoppingItem]  = ShoppingItem.defaults
    @Published var week: [WeekDay]           = WeekDay.defaults
    @Published var likedPosts: Set<Int>      = []
    @Published var isLoadingAI               = false
    @Published var isLoadingNutritionAI      = false
    @Published var nutritionGoal             = NutritionGoal()
    @Published var todayKcal: Double         = 0
    @Published var todayProtein: Double      = 0
    @Published var todayFat: Double          = 0
    @Published var todayCarbs: Double        = 0
    @Published var healthKitAuthorized       = false

    private let healthStore = HKHealthStore()

    // MARK: - Daily Recipe
    var dailyRecipe: Recipe {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return recipes[(dayOfYear - 1) % recipes.count]
    }

    var specialItems: [PantryItem]  { pantry.filter(\.isSpecial) }
    var expiringItems: [PantryItem] { pantry.filter { $0.mhdStatus == .critical || $0.mhdStatus == .expired } }

    // MARK: - Shopping
    func addToShopping(recipe: Recipe) {
        let item = ShoppingItem(
            id: Int(Date().timeIntervalSince1970),
            name: "Fuer: \(recipe.name)",
            amount: "", isDone: false, category: "Rezept"
        )
        shopping.insert(item, at: 0)
    }

    // MARK: - Planner
    func fillWeekWithAI() {
        week = week.enumerated().map { (i, day) in
            var d = day
            d.recipe = recipes[i % recipes.count].name
            d.emoji  = recipes[i % recipes.count].emoji
            return d
        }
    }

    // MARK: - AI: Vorrat-basierte Rezepte
    func loadAIRecipes() async {
        isLoadingAI = true
        defer { isLoadingAI = false }

        let specials     = pantry.filter(\.isSpecial).map(\.name).joined(separator: ", ")
        let all          = pantry.map(\.name).joined(separator: ", ")
        let expiringHints = pantry.compactMap { item -> String? in
            guard let hint = item.aiHint else { return nil }
            return "\(item.name) (\(hint))"
        }.joined(separator: "; ")

        let expiringLine = expiringHints.isEmpty ? "" :
            " Zutaten mit nahendem MHD (PRIORITAET): \(expiringHints)."

        let prompt = """
        Du bist Kochassistent fuer "Next Cooking". Vorrat: \(all). \
        Sonderzutaten: \(specials).\(expiringLine) \
        Erstelle 4 Rezeptvorschlaege, priorisiere Zutaten mit nahendem MHD. \
        Antworte NUR mit JSON-Array: \
        [{"id":1,"name":"Name","time":30,"match":95,"uses":["Zutat1"],"cat":"Kueche","emoji":"🍜","batch":false,"desc":"Beschreibung","kcal":450,"protein":28,"fat":12,"carbs":55}]. \
        match=Vorratstreffer %, batch=true wenn einfrierbar.
        """
        await callAnthropicAPI(prompt: prompt, updateRecipes: true)
    }

    // MARK: - AI: Makro-basierte Rezepte
    func loadNutritionAIRecipes() async {
        isLoadingNutritionAI = true
        defer { isLoadingNutritionAI = false }

        let remaining = NutritionGoal(
            kcal:    max(0, nutritionGoal.kcal    - Int(todayKcal)),
            protein: max(0, nutritionGoal.protein - Int(todayProtein)),
            fat:     max(0, nutritionGoal.fat     - Int(todayFat)),
            carbs:   max(0, nutritionGoal.carbs   - Int(todayCarbs))
        )
        let all = pantry.map(\.name).joined(separator: ", ")

        let prompt = """
        Du bist Ernaehrungsassistent fuer "Next Cooking". \
        Tagesziel: \(nutritionGoal.kcal) kcal, \(nutritionGoal.protein)g Eiweiss, \
        \(nutritionGoal.fat)g Fett, \(nutritionGoal.carbs)g Kohlenhydrate. \
        Bereits gegessen heute: \(Int(todayKcal)) kcal, \(Int(todayProtein))g Eiweiss, \
        \(Int(todayFat))g Fett, \(Int(todayCarbs))g Kohlenhydrate. \
        Noch verfuegbar: \(remaining.kcal) kcal, \(remaining.protein)g Eiweiss, \
        \(remaining.fat)g Fett, \(remaining.carbs)g KH. \
        Vorrat: \(all). \
        Schlage 4 Rezepte vor, die die verbleibenden Makros moeglichst gut treffen. \
        Antworte NUR mit JSON-Array: \
        [{"id":1,"name":"Name","time":30,"match":85,"uses":["Zutat1"],"cat":"Kueche","emoji":"🥗","batch":false,"desc":"Beschreibung","kcal":420,"protein":35,"fat":14,"carbs":40}].
        """
        await callAnthropicAPI(prompt: prompt, updateRecipes: true)
    }

    // MARK: - Shared API call
    private func callAnthropicAPI(prompt: String, updateRecipes: Bool) async {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // WICHTIG: Ersetze mit deinem Anthropic API-Key
        req.setValue("YOUR_API_KEY_HERE", forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01",        forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1200,
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
                   !parsed.isEmpty, updateRecipes {
                    recipes = parsed
                }
            }
        } catch {
            print("API Error: \(error)")
        }
    }

    // MARK: - HealthKit
    // Benoetigt in Info.plist:
    //   NSHealthShareUsageDescription = "Zum Importieren deiner Tagesmakros"
    func requestHealthKitAccess() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types: Set<HKObjectType> = [
            HKQuantityType(.dietaryEnergyConsumed),
            HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryFatTotal),
            HKQuantityType(.dietaryCarbohydrates),
        ]
        do {
            try await healthStore.requestAuthorization(toShare: [], read: types)
            healthKitAuthorized = true
            await loadTodayMacrosFromHealth()
        } catch {
            print("HealthKit error: \(error)")
        }
    }

    func loadTodayMacrosFromHealth() async {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate  = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())

        async let kcal    = sumHealthSamples(type: .dietaryEnergyConsumed,  unit: .kilocalorie(),        predicate: predicate)
        async let protein = sumHealthSamples(type: .dietaryProtein,          unit: .gram(),               predicate: predicate)
        async let fat     = sumHealthSamples(type: .dietaryFatTotal,         unit: .gram(),               predicate: predicate)
        async let carbs   = sumHealthSamples(type: .dietaryCarbohydrates,    unit: .gram(),               predicate: predicate)

        todayKcal    = await kcal
        todayProtein = await protein
        todayFat     = await fat
        todayCarbs   = await carbs
    }

    private func sumHealthSamples(type identifier: HKQuantityTypeIdentifier, unit: HKUnit, predicate: NSPredicate) async -> Double {
        await withCheckedContinuation { cont in
            let query = HKStatisticsQuery(quantityType: HKQuantityType(identifier), quantitySamplePredicate: predicate) { _, stats, _ in
                cont.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            healthStore.execute(query)
        }
    }
}
