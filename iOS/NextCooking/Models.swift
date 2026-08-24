import Foundation

// MARK: - Recipe
struct Recipe: Identifiable, Codable {
    var id: Int
    var name: String
    var time: Int
    var match: Int
    var uses: [String]
    var category: String
    var emoji: String
    var isBatch: Bool
    var desc: String
    var kcal: Int?
    var protein: Int?
    var fat: Int?
    var carbs: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, time, match, uses, emoji, desc, kcal, protein, fat, carbs
        case category = "cat"
        case isBatch  = "batch"
    }

    static let defaults: [Recipe] = [
        Recipe(id: 1, name: "Miso-Ramen mit Shiitake",    time: 35, match: 95, uses: ["Miso Paste","Fischsauce"], category: "Japanisch", emoji: "🍜", isBatch: false, desc: "Umami-reiche Brühe mit frischen Shiitake-Pilzen"),
        Recipe(id: 2, name: "Miso-Aubergine & Sesamreis", time: 40, match: 92, uses: ["Miso Paste"],               category: "Japanisch", emoji: "🍆", isBatch: true,  desc: "Glasierte Aubergine auf fluffigem Sesamreis"),
        Recipe(id: 3, name: "Linsen-Dhal mit Tamarinde",  time: 30, match: 88, uses: ["Linsen","Tamarinde"],       category: "Indisch",   emoji: "🍛", isBatch: true,  desc: "Cremiges Dhal mit würziger Tamarinden-Note"),
        Recipe(id: 4, name: "Sumach-Haehnchen auf Reis",  time: 45, match: 84, uses: ["Sumach"],                   category: "Arabisch",  emoji: "🍗", isBatch: false, desc: "Orientalisches Haehnchen mit Sumach-Wuerze"),
    ]
}

// MARK: - MHD Status
enum MHDStatus {
    case none, ok, warning, critical, expired

    var colorHex: String {
        switch self {
        case .none:     return "#CCCCCC"
        case .ok:       return "#3D7A1E"
        case .warning:  return "#E8901A"
        case .critical: return "#C4621A"
        case .expired:  return "#CC3333"
        }
    }

    var label: String {
        switch self {
        case .none:     return ""
        case .ok:       return "MHD ok"
        case .warning:  return "bald ablaufend"
        case .critical: return "dringend verbrauchen"
        case .expired:  return "abgelaufen"
        }
    }

    var icon: String {
        switch self {
        case .none:     return ""
        case .ok:       return "checkmark.circle.fill"
        case .warning:  return "exclamationmark.circle.fill"
        case .critical: return "exclamationmark.triangle.fill"
        case .expired:  return "xmark.circle.fill"
        }
    }
}

// MARK: - PantryItem
struct PantryItem: Identifiable {
    var id: Int
    var name: String
    var isSpecial: Bool
    var amount: String
    var bestBefore: Date?
    var openedOn: Date?
    var consumeBy: Date?

    var mhdStatus: MHDStatus {
        let referenceDate = consumeBy ?? bestBefore
        guard let date = referenceDate else { return .none }
        let days = Calendar.current.dateComponents([.day],
            from: Calendar.current.startOfDay(for: Date()),
            to:   Calendar.current.startOfDay(for: date)).day ?? 0
        if days < 0  { return .expired }
        if days <= 2 { return .critical }
        if days <= 7 { return .warning }
        return .ok
    }

    var mhdSummary: String? {
        var parts: [String] = []
        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yy"
        if let bb = bestBefore { parts.append("MHD \(fmt.string(from: bb))") }
        if let oo = openedOn   { parts.append("geoeffnet \(fmt.string(from: oo))") }
        if let cb = consumeBy  { parts.append("bis \(fmt.string(from: cb))") }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    var aiHint: String? {
        guard mhdStatus != .none else { return nil }
        let fmt = DateFormatter(); fmt.dateFormat = "dd.MM.yy"
        var hints: [String] = []
        if let bb = bestBefore { hints.append("MHD: \(fmt.string(from: bb))") }
        if let cb = consumeBy  { hints.append("verbrauchen bis: \(fmt.string(from: cb))") }
        switch mhdStatus {
        case .expired:  hints.append("ABGELAUFEN")
        case .critical: hints.append("DRINGEND")
        default: break
        }
        return hints.joined(separator: ", ")
    }

    static func daysFromNow(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: Date())!
    }

    static let defaults: [PantryItem] = [
        PantryItem(id: 1,  name: "Miso Paste",  isSpecial: true,  amount: "200g",    bestBefore: daysFromNow(5),  openedOn: daysFromNow(-10), consumeBy: daysFromNow(5)),
        PantryItem(id: 2,  name: "Fischsauce",  isSpecial: true,  amount: "300ml"),
        PantryItem(id: 3,  name: "Sumach",      isSpecial: true,  amount: "50g"),
        PantryItem(id: 4,  name: "Tamarinde",   isSpecial: true,  amount: "100g",    bestBefore: daysFromNow(2)),
        PantryItem(id: 5,  name: "Knoblauch",   isSpecial: false, amount: "1 Knolle"),
        PantryItem(id: 6,  name: "Olivenoel",   isSpecial: false, amount: "500ml"),
        PantryItem(id: 7,  name: "Pasta",       isSpecial: false, amount: "500g"),
        PantryItem(id: 8,  name: "Zwiebeln",    isSpecial: false, amount: "5 Stueck"),
        PantryItem(id: 9,  name: "Linsen",      isSpecial: false, amount: "400g"),
        PantryItem(id: 10, name: "Tomaten",     isSpecial: false, amount: "4 Stueck", bestBefore: daysFromNow(-1)),
    ]
}

// MARK: - NutritionGoal
struct NutritionGoal {
    var kcal: Int    = 2000
    var protein: Int = 150
    var fat: Int     = 65
    var carbs: Int   = 200
}

// MARK: - ShoppingItem
struct ShoppingItem: Identifiable {
    var id: Int
    var name: String
    var amount: String
    var isDone: Bool
    var category: String

    static let defaults: [ShoppingItem] = [
        ShoppingItem(id: 1, name: "Ramen Nudeln",      amount: "200g",   isDone: false, category: "Nudeln"),
        ShoppingItem(id: 2, name: "Shiitake Pilze",    amount: "150g",   isDone: false, category: "Gemuese"),
        ShoppingItem(id: 3, name: "Fruehlungszwiebeln",amount: "1 Bund", isDone: true,  category: "Gemuese"),
        ShoppingItem(id: 4, name: "Tofu",              amount: "400g",   isDone: false, category: "Protein"),
        ShoppingItem(id: 5, name: "Haehnchenbrust",    amount: "500g",   isDone: false, category: "Protein"),
        ShoppingItem(id: 6, name: "Kokosmilch",        amount: "400ml",  isDone: false, category: "Konserven"),
    ]
}

// MARK: - WeekDay
struct WeekDay: Identifiable {
    var id: Int
    var shortName: String
    var recipe: String?
    var emoji: String?

    static let defaults: [WeekDay] = [
        WeekDay(id: 0, shortName: "Mo", recipe: "Linsen-Dhal",    emoji: "🍛"),
        WeekDay(id: 1, shortName: "Di", recipe: nil,               emoji: nil),
        WeekDay(id: 2, shortName: "Mi", recipe: "Miso-Ramen",      emoji: "🍜"),
        WeekDay(id: 3, shortName: "Do", recipe: nil,               emoji: nil),
        WeekDay(id: 4, shortName: "Fr", recipe: "Bolognese",       emoji: "🍝"),
        WeekDay(id: 5, shortName: "Sa", recipe: "Sumach-Haehnchen",emoji: "🍗"),
        WeekDay(id: 6, shortName: "So", recipe: nil,               emoji: nil),
    ]
}

// MARK: - SocialPost
struct SocialPost: Identifiable {
    var id: Int
    var initials: String
    var name: String
    var colorHex: String
    var action: String
    var dish: String
    var emoji: String
    var likes: Int
    var time: String
    var isFrozen: Bool
    var isInvite: Bool

    static let all: [SocialPost] = [
        SocialPost(id: 1, initials: "LK", name: "Lena K.",   colorHex: "#E8901A", action: "kocht gerade",    dish: "Marokkanisches Lamm-Tajine",       emoji: "🫕", likes: 5, time: "10 Min", isFrozen: false, isInvite: false),
        SocialPost(id: 2, initials: "JM", name: "Jonas M.",  colorHex: "#3D7A1E", action: "hat eingefroren", dish: "Bolognese (8 Portionen)",          emoji: "🍝", likes: 3, time: "2 Std",  isFrozen: true,  isInvite: false),
        SocialPost(id: 3, initials: "MT", name: "Mia & Tom", colorHex: "#C4621A", action: "laden ein",       dish: "Gemeinsam Kochen Samstag Abend",   emoji: "🎉", likes: 0, time: "1 Tag",  isFrozen: false, isInvite: true),
        SocialPost(id: 4, initials: "SP", name: "Sarah P.",  colorHex: "#7B5EA7", action: "hat gekocht",     dish: "Pad Thai mit Erdnuessen",          emoji: "🍜", likes: 8, time: "3 Std",  isFrozen: false, isInvite: false),
    ]
}
