import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @State private var navigateToShopping = false

    var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Guten Morgen 👋" }
        if h < 17 { return "Guten Mittag 👋" }
        return "Guten Abend 👋"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Begrüßung ──
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.muted)
                        Text("Was kochen wir heute?")
                            .font(.system(size: 23, weight: .heavy))
                            .foregroundColor(Theme.dark)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    // ── Rezept des Tages ──
                    RecipeOfTheDayCard(recipe: state.dailyRecipe) {
                        state.addToShopping(recipe: state.dailyRecipe)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // ── Sonderzutaten-Hinweis ──
                    if !state.specialItems.isEmpty {
                        HStack(spacing: 10) {
                            Text("✦")
                                .font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SONDERZUTATEN — BALD VERBRAUCHEN")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Theme.special)
                                    .tracking(0.5)
                                Text(state.specialItems.map(\.name).joined(separator: " · "))
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.muted)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Theme.specialBg)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.special.opacity(0.2), lineWidth: 1))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 18)
                    }

                    // ── KI Vorschläge Header ──
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PASSEND ZU DEINEM VORRAT")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.muted)
                                .tracking(0.5)
                            Text("KI-Vorschläge")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.dark)
                        }
                        Spacer()
                        Button {
                            Task { await state.loadAIRecipes() }
                        } label: {
                            HStack(spacing: 6) {
                                if state.isLoadingAI {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.75)
                                } else {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                Text(state.isLoadingAI ? "Lädt…" : "Neu laden")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(state.isLoadingAI ? Theme.muted : Theme.dark)
                            .cornerRadius(12)
                        }
                        .disabled(state.isLoadingAI)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // ── Recipe Cards ──
                    ForEach(Array(state.recipes.enumerated()), id: \.element.id) { index, recipe in
                        RecipeCardView(recipe: recipe, isTopPick: index == 0) {
                            state.addToShopping(recipe: recipe)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                    }

                    Spacer(minLength: 20)
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Next Cooking")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Rezept des Tages Card
struct RecipeOfTheDayCard: View {
    let recipe: Recipe
    let onShop: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header-Streifen
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.amber)
                Text("REZEPT DES TAGES")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(Theme.amber)
                    .tracking(1.2)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color(hex: "#2A1A07"))

            // Hero-Body
            VStack(spacing: 0) {
                Text(recipe.emoji)
                    .font(.system(size: 64))
                    .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
                    .padding(.bottom, 14)

                // Badges
                HStack(spacing: 6) {
                    CategoryBadge(text: recipe.category.uppercased(), fg: Theme.amber, bg: Theme.amber.opacity(0.18))
                    if recipe.isBatch {
                        CategoryBadge(text: "❄ BATCH COOK", fg: Color(hex: "#6FCF4A"), bg: Color(hex: "#6FCF4A").opacity(0.15))
                    }
                }
                .padding(.bottom, 10)

                Text(recipe.name)
                    .font(.system(size: 21, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)

                Text(recipe.desc)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 18)

                // Stats row
                HStack(spacing: 0) {
                    StatCell(value: "\(recipe.time)", label: "MINUTEN", color: .white)
                    Divider().frame(height: 36).background(.white.opacity(0.12))
                    StatCell(value: "\(recipe.match)%", label: "VORRAT",
                             color: recipe.match > 90 ? Color(hex: "#6FCF4A") : Theme.amber)
                    if !recipe.uses.isEmpty {
                        Divider().frame(height: 36).background(.white.opacity(0.12))
                        StatCell(value: "\(recipe.uses.count)", label: "SPEZIAL", color: Color(hex: "#FFB347"))
                    }
                }
                .padding(.bottom, 18)

                // Sonderzutaten-Chips
                if !recipe.uses.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(recipe.uses, id: \.self) { u in
                            Text("✦ \(u)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "#FFB347"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#FFB347").opacity(0.15))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.bottom, 18)
                }

                // CTA Buttons
                HStack(spacing: 10) {
                    Button(action: onShop) {
                        Text("+ Einkaufsliste")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Theme.amber)
                            .cornerRadius(12)
                    }
                    Button {} label: {
                        Text("Rezept ansehen →")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(.white.opacity(0.1))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#2E1F0A"), Color(hex: "#3D2910")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.dark.opacity(0.15), radius: 28, y: 6)
    }
}

private struct StatCell: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CategoryBadge: View {
    let text: String
    let fg: Color
    let bg: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(bg)
            .cornerRadius(20)
    }
}

// MARK: - Compact Recipe Card (KI-Vorschläge)
struct RecipeCardView: View {
    let recipe: Recipe
    let isTopPick: Bool
    let onShop: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top row
            HStack(alignment: .top, spacing: 12) {
                Text(recipe.emoji)
                    .font(.system(size: 38))
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        CategoryBadge(text: recipe.category.uppercased(), fg: Theme.muted, bg: Color(hex: "#F0EBE2"))
                        if recipe.isBatch {
                            CategoryBadge(text: "❄ BATCH", fg: Theme.green, bg: Theme.greenBg)
                        }
                        if isTopPick {
                            CategoryBadge(text: "★ TOP PICK", fg: Theme.amber, bg: Theme.amberBg)
                        }
                    }
                    Text(recipe.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.dark)
                    Text(recipe.desc)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.muted)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 13)
            .padding(.bottom, 8)

            // Match bar
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Vorratstreffer")
                            .font(.system(size: 10))
                            .foregroundColor(Theme.muted)
                        Spacer()
                        Text("\(recipe.match)%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(recipe.match > 90 ? Theme.green : Theme.amber)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Theme.border).frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(recipe.match > 90 ? Theme.green : Theme.amber)
                                .frame(width: geo.size.width * CGFloat(recipe.match) / 100, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text("\(recipe.time) Min")
                        .font(.system(size: 11))
                }
                .foregroundColor(Theme.muted)
                .fixedSize()
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 8)

            // Sonderzutaten
            if !recipe.uses.isEmpty {
                HStack(spacing: 5) {
                    ForEach(recipe.uses, id: \.self) { u in
                        Text("✦ \(u)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Theme.special)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Theme.specialBg)
                            .cornerRadius(20)
                    }
                    Spacer()
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 8)
            }

            // Buttons
            HStack(spacing: 8) {
                Button(action: onShop) {
                    Text("+ Einkaufsliste")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(Theme.amber)
                        .cornerRadius(9)
                }
                Button {} label: {
                    Text("Rezept →")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.muted)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 13)
                        .background(Color(hex: "#F0EBE2"))
                        .cornerRadius(9)
                }
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 13)
        }
        .background(Theme.white)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
    }
}
