import Foundation
import SwiftUI
#if canImport(HealthKit)
import HealthKit
#endif

@MainActor
class AppState: ObservableObject {
    @Published var recipes: [Recipe]             = Recipe.defaults  // KI-Vorschläge
    @Published var userRecipes: [Recipe]         = []               // eigene Rezepte, nie überschrieben
    @Published var pantry: [PantryItem]          = PantryItem.defaults
    @Published var shopping: [ShoppingItem]      = ShoppingItem.defaults
    @Published var basics: [BasicItem]           = BasicItem.defaults
    @Published var week: [WeekDay]               = WeekDay.defaults
    @Published var supermarkets: [Supermarket]   = Supermarket.defaults
    @Published var selectedSupermarketId: UUID?  = Supermarket.defaults.first?.id
    @Published var mealTypes: [MealType]          = MealType.defaults
    @Published var likedPosts: Set<Int>          = []
    @Published var isLoadingAI                   = false
    @Published var isLoadingNutritionAI          = false
    @Published var nutritionGoal                 = NutritionGoal()
    @Published var todayKcal: Double             = 0
    @Published var todayProtein: Double          = 0
    @Published var todayFat: Double              = 0
    @Published var todayCarbs: Double            = 0
    @Published var healthKitAuthorized           = false

    #if canImport(HealthKit)
    private let healthStore = HKHealthStore()
    #endif

    var selectedSupermarket: Supermarket? {
        supermarkets.first { $0.id == selectedSupermarketId }
    }

    // MARK: - Computed
    var allRecipes: [Recipe] { userRecipes + recipes }  // eigene zuerst

    var dailyRecipe: Recipe {
        let pool = allRecipes.isEmpty ? Recipe.defaults : allRecipes
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return pool[(dayOfYear - 1) % pool.count]
    }

    var specialItems: [PantryItem]  { pantry.filter(\.isSpecial) }
    var expiringItems: [PantryItem] { pantry.filter { $0.dateStatus == .critical || $0.dateStatus == .expired } }

    // Einkaufsliste: nach Gang des gewählten Supermarkts sortiert
    var sortedShopping: [ShoppingItem] {
        guard let store = selectedSupermarket else { return shopping }
        let aisleOrder = store.aisles
        return shopping.sorted {
            let ai = aisleOrder.firstIndex(of: $0.aisle) ?? 999
            let bi = aisleOrder.firstIndex(of: $1.aisle) ?? 999
            return ai < bi
        }
    }

    // Rezepte gruppiert (für aufklappbare Sektionen)
    var recipeGroups: [(id: Int, name: String, emoji: String, items: [ShoppingItem])] {
        let recipeItems = shopping.filter { $0.recipeId != nil }
        let ids = recipeItems.compactMap { $0.recipeId }.uniqueOrdered()
        return ids.compactMap { rid in
            let items = recipeItems.filter { $0.recipeId == rid }
            guard let first = items.first,
                  let name = first.recipeName,
                  let emoji = first.recipeEmoji else { return nil }
            return (id: rid, name: name, emoji: emoji, items: items)
        }
    }

    // Standalone-Items (kein Rezept)
    var standaloneItems: [ShoppingItem] {
        shopping.filter { $0.recipeId == nil && !$0.isBasic }
    }

    // MARK: - Shopping
    func addToShopping(recipe: Recipe) {
        let base = Int(Date().timeIntervalSince1970)
        let ingredients = [
            (recipe.uses.first ?? "Zutaten", "nach Bedarf")
        ]
        for (i, (name, amount)) in ingredients.enumerated() {
            let item = ShoppingItem(
                id: base + i,
                name: name,
                amount: amount,
                isDone: false,
                aisle: "Sonstiges",
                recipeId: recipe.id,
                recipeName: recipe.name,
                recipeEmoji: recipe.emoji
            )
            shopping.insert(item, at: 0)
        }
    }

    func removeRecipeFromShopping(recipeId: Int) {
        shopping.removeAll { $0.recipeId == recipeId }
    }

    // MARK: - Planner helpers
    func getMeal(dayIndex: Int, typeName: String) -> (recipe: String, emoji: String)? {
        guard week.indices.contains(dayIndex) else { return nil }
        let day = week[dayIndex]
        switch typeName {
        case "Hauptgericht":
            guard let r = day.recipe, let e = day.emoji else { return nil }
            return (r, e)
        case "Frühstück":
            guard let r = day.breakfast, let e = day.breakfastEmoji else { return nil }
            return (r, e)
        default:
            guard let m = day.customMeals[typeName] else { return nil }
            return (m.recipe, m.emoji)
        }
    }

    func setMeal(dayIndex: Int, typeName: String, recipe: String?, emoji: String?) {
        guard week.indices.contains(dayIndex) else { return }
        switch typeName {
        case "Hauptgericht":
            week[dayIndex].recipe = recipe
            week[dayIndex].emoji  = emoji
        case "Frühstück":
            week[dayIndex].breakfast      = recipe
            week[dayIndex].breakfastEmoji = emoji
        default:
            if let r = recipe, let e = emoji {
                week[dayIndex].customMeals[typeName] = WeekMealEntry(recipe: r, emoji: e)
            } else {
                week[dayIndex].customMeals.removeValue(forKey: typeName)
            }
        }
    }

    func fillWeekWithAI(mealTypeName: String) {
        guard !recipes.isEmpty else { return }
        for i in week.indices {
            let r = recipes[i % recipes.count]
            setMeal(dayIndex: i, typeName: mealTypeName, recipe: r.name, emoji: r.emoji)
        }
    }

    func toggleFavorite(recipeId: Int) {
        if let i = userRecipes.firstIndex(where: { $0.id == recipeId }) {
            userRecipes[i].isFavorite.toggle()
        } else if let i = recipes.firstIndex(where: { $0.id == recipeId }) {
            recipes[i].isFavorite.toggle()
        }
    }

    // MARK: - AI: Vorrat-basierte Rezepte
    func loadAIRecipes() async {
        isLoadingAI = true
        defer { isLoadingAI = false }

        let specials = pantry.filter(\.isSpecial).map(\.name).joined(separator: ", ")
        let all = pantry.map(\.name).joined(separator: ", ")
        let expiringHints = pantry.compactMap { item -> String? in
            guard let hint = item.aiHint else { return nil }
            return "\(item.name) (\(hint))"
        }.joined(separator: "; ")
        let expiringLine = expiringHints.isEmpty ? "" : " Priorität: \(expiringHints)."

        let prompt = """
        Kochassistent "Next Cooking". Vorrat: \(all). Sonderzutaten: \(specials).\(expiringLine) \
        4 Rezeptvorschläge, priorisiere ablaufende Zutaten. \
        NUR JSON: [{"id":1,"name":"Name","time":30,"match":95,"uses":["Zutat"],"cat":"Küche","emoji":"🍜","batch":false,"desc":"Beschreibung","kcal":450,"protein":28,"fat":12,"carbs":55}]
        """
        await callAnthropicAPI(prompt: prompt)
    }

    // MARK: - AI: Makro-basierte Rezepte
    func loadNutritionAIRecipes() async {
        isLoadingNutritionAI = true
        defer { isLoadingNutritionAI = false }

        let rem = NutritionGoal(
            kcal:    max(0, nutritionGoal.kcal    - Int(todayKcal)),
            protein: max(0, nutritionGoal.protein - Int(todayProtein)),
            fat:     max(0, nutritionGoal.fat     - Int(todayFat)),
            carbs:   max(0, nutritionGoal.carbs   - Int(todayCarbs))
        )
        let all = pantry.map(\.name).joined(separator: ", ")
        let prompt = """
        Ernährungsassistent. Tagesziel: \(nutritionGoal.kcal) kcal / \(nutritionGoal.protein)g E / \(nutritionGoal.fat)g F / \(nutritionGoal.carbs)g KH. \
        Heute: \(Int(todayKcal)) kcal / \(Int(todayProtein))g E / \(Int(todayFat))g F / \(Int(todayCarbs))g KH. \
        Noch verfügbar: \(rem.kcal) kcal / \(rem.protein)g E / \(rem.fat)g F / \(rem.carbs)g KH. \
        Vorrat: \(all). 4 Rezepte die verbleibende Makros treffen. \
        NUR JSON: [{"id":1,"name":"Name","time":30,"match":85,"uses":["Zutat"],"cat":"Küche","emoji":"🥗","batch":false,"desc":"Beschreibung","kcal":420,"protein":35,"fat":14,"carbs":40}]
        """
        await callAnthropicAPI(prompt: prompt)
    }

    private func callAnthropicAPI(prompt: String) async {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("YOUR_API_KEY_HERE", forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01",        forHTTPHeaderField: "anthropic-version")
        let body: [String: Any] = ["model": "claude-sonnet-4-20250514", "max_tokens": 1200,
                                   "messages": [["role": "user", "content": prompt]]]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else { return }
        req.httpBody = bodyData
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["content"] as? [[String: Any]],
               let text = content.first?["text"] as? String {
                let cleaned = text.replacingOccurrences(of: "```json", with: "")
                                  .replacingOccurrences(of: "```", with: "")
                                  .trimmingCharacters(in: .whitespacesAndNewlines)
                if let jsonData = cleaned.data(using: .utf8),
                   let parsed = try? JSONDecoder().decode([Recipe].self, from: jsonData),
                   !parsed.isEmpty { recipes = parsed }
            }
        } catch { print("API Error: \(error)") }
    }

    // MARK: - HealthKit (nur iOS / Apple Silicon Mac)
    func requestHealthKitAccess() async {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types: Set<HKObjectType> = [
            HKQuantityType(.dietaryEnergyConsumed), HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryFatTotal), HKQuantityType(.dietaryCarbohydrates),
        ]
        do {
            try await healthStore.requestAuthorization(toShare: [], read: types)
            healthKitAuthorized = true
            await loadTodayMacrosFromHealth()
        } catch { print("HealthKit: \(error)") }
        #endif
    }

    func loadTodayMacrosFromHealth() async {
        #if canImport(HealthKit)
        let start = Calendar.current.startOfDay(for: Date())
        let pred  = HKQuery.predicateForSamples(withStart: start, end: Date())
        async let a = sumHealth(.dietaryEnergyConsumed, .kilocalorie(), pred)
        async let b = sumHealth(.dietaryProtein, .gram(), pred)
        async let c = sumHealth(.dietaryFatTotal, .gram(), pred)
        async let d = sumHealth(.dietaryCarbohydrates, .gram(), pred)
        todayKcal = await a; todayProtein = await b; todayFat = await c; todayCarbs = await d
        #endif
    }

    #if canImport(HealthKit)
    private func sumHealth(_ id: HKQuantityTypeIdentifier, _ unit: HKUnit, _ pred: NSPredicate) async -> Double {
        await withCheckedContinuation { cont in
            let q = HKStatisticsQuery(quantityType: HKQuantityType(id), quantitySamplePredicate: pred) { _, s, _ in
                cont.resume(returning: s?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            healthStore.execute(q)
        }
    }
    #endif
}

// MARK: - Array helper
extension Array where Element: Hashable {
    func uniqueOrdered() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
