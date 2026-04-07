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

    // Codable mapping from AI JSON keys
    enum CodingKeys: String, CodingKey {
        case id, name, time, match, uses, emoji, desc
        case category = "cat"
        case isBatch  = "batch"
    }

    static let defaults: [Recipe] = [
        Recipe(id: 1, name: "Miso-Ramen mit Shiitake",    time: 35, match: 95, uses: ["Miso Paste","Fischsauce"], category: "Japanisch", emoji: "🍜", isBatch: false, desc: "Umami-reiche Brühe mit frischen Shiitake-Pilzen"),
        Recipe(id: 2, name: "Miso-Aubergine & Sesamreis", time: 40, match: 92, uses: ["Miso Paste"],               category: "Japanisch", emoji: "🍆", isBatch: true,  desc: "Glasierte Aubergine auf fluffigem Sesamreis"),
        Recipe(id: 3, name: "Linsen-Dhal mit Tamarinde",  time: 30, match: 88, uses: ["Linsen","Tamarinde"],       category: "Indisch",   emoji: "🍛", isBatch: true,  desc: "Cremiges Dhal mit würziger Tamarinden-Note"),
        Recipe(id: 4, name: "Sumach-Hähnchen auf Reis",   time: 45, match: 84, uses: ["Sumach"],                   category: "Arabisch",  emoji: "🍗", isBatch: false, desc: "Orientalisches Hähnchen mit Sumach-Würze"),
    ]
}

// MARK: - PantryItem
struct PantryItem: Identifiable {
    var id: Int
    var name: String
    var isSpecial: Bool
    var amount: String

    static let defaults: [PantryItem] = [
        PantryItem(id: 1,  name: "Miso Paste",  isSpecial: true,  amount: "200g"),
        PantryItem(id: 2,  name: "Fischsauce",  isSpecial: true,  amount: "300ml"),
        PantryItem(id: 3,  name: "Sumach",      isSpecial: true,  amount: "50g"),
        PantryItem(id: 4,  name: "Tamarinde",   isSpecial: true,  amount: "100g"),
        PantryItem(id: 5,  name: "Knoblauch",   isSpecial: false, amount: "1 Knolle"),
        PantryItem(id: 6,  name: "Olivenöl",    isSpecial: false, amount: "500ml"),
        PantryItem(id: 7,  name: "Pasta",       isSpecial: false, amount: "500g"),
        PantryItem(id: 8,  name: "Zwiebeln",    isSpecial: false, amount: "5 Stück"),
        PantryItem(id: 9,  name: "Linsen",      isSpecial: false, amount: "400g"),
        PantryItem(id: 10, name: "Tomaten",     isSpecial: false, amount: "4 Stück"),
    ]
}

// MARK: - ShoppingItem
struct ShoppingItem: Identifiable {
    var id: Int
    var name: String
    var amount: String
    var isDone: Bool
    var category: String

    static let defaults: [ShoppingItem] = [
        ShoppingItem(id: 1, name: "Ramen Nudeln",      amount: "200g",  isDone: false, category: "Nudeln"),
        ShoppingItem(id: 2, name: "Shiitake Pilze",    amount: "150g",  isDone: false, category: "Gemüse"),
        ShoppingItem(id: 3, name: "Frühlingszwiebeln", amount: "1 Bund",isDone: true,  category: "Gemüse"),
        ShoppingItem(id: 4, name: "Tofu",              amount: "400g",  isDone: false, category: "Protein"),
        ShoppingItem(id: 5, name: "Hähnchenbrust",     amount: "500g",  isDone: false, category: "Protein"),
        ShoppingItem(id: 6, name: "Kokosmilch",        amount: "400ml", isDone: false, category: "Konserven"),
    ]
}

// MARK: - WeekDay
struct WeekDay: Identifiable {
    var id: Int
    var shortName: String
    var recipe: String?
    var emoji: String?

    static let defaults: [WeekDay] = [
        WeekDay(id: 0, shortName: "Mo", recipe: "Linsen-Dhal",      emoji: "🍛"),
        WeekDay(id: 1, shortName: "Di", recipe: nil,                 emoji: nil),
        WeekDay(id: 2, shortName: "Mi", recipe: "Miso-Ramen",        emoji: "🍜"),
        WeekDay(id: 3, shortName: "Do", recipe: nil,                 emoji: nil),
        WeekDay(id: 4, shortName: "Fr", recipe: "Bolognese",         emoji: "🍝"),
        WeekDay(id: 5, shortName: "Sa", recipe: "Sumach-Hähnchen",   emoji: "🍗"),
        WeekDay(id: 6, shortName: "So", recipe: nil,                 emoji: nil),
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
        SocialPost(id: 1, initials: "LK", name: "Lena K.",    colorHex: "#E8901A", action: "kocht gerade",   dish: "Marokkanisches Lamm-Tajine",           emoji: "🫕", likes: 5, time: "10 Min", isFrozen: false, isInvite: false),
        SocialPost(id: 2, initials: "JM", name: "Jonas M.",   colorHex: "#3D7A1E", action: "hat eingefroren",dish: "Bolognese (8 Portionen)",              emoji: "🍝", likes: 3, time: "2 Std",  isFrozen: true,  isInvite: false),
        SocialPost(id: 3, initials: "MT", name: "Mia & Tom",  colorHex: "#C4621A", action: "laden ein",      dish: "Gemeinsam Kochen – Samstag Abend",     emoji: "🎉", likes: 0, time: "1 Tag",  isFrozen: false, isInvite: true),
        SocialPost(id: 4, initials: "SP", name: "Sarah P.",   colorHex: "#7B5EA7", action: "hat gekocht",    dish: "Pad Thai mit Erdnüssen",               emoji: "🍜", likes: 8, time: "3 Std",  isFrozen: false, isInvite: false),
    ]
}
