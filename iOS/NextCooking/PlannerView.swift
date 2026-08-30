import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var state: AppState
    @State private var mealSegment = 1      // 0 = Frühstück, 1 = Hauptgericht
    @State private var pickingFor: DayPick? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // ── Mahlzeit-Tab ──
                    Picker("Mahlzeit", selection: $mealSegment) {
                        Text("🌅 Frühstück").tag(0)
                        Text("🍽 Hauptgericht").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 12)

                    // ── KI planen ──
                    HStack {
                        Spacer()
                        Button { state.fillWeekWithAI(meal: mealSegment) } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles").font(.system(size: 12, weight: .bold))
                                Text("KI planen").font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Theme.amber).cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 14)

                    // ── Wochentage ──
                    ForEach(Array(state.week.enumerated()), id: \.element.id) { index, day in
                        let isBreakfast = mealSegment == 0
                        WeekDayRow(
                            day: day,
                            dayNumber: index + 1,
                            recipeName:  isBreakfast ? day.breakfast      : day.recipe,
                            recipeEmoji: isBreakfast ? day.breakfastEmoji : day.emoji,
                            onTap: { pickingFor = DayPick(id: index) },
                            onClear: {
                                if isBreakfast {
                                    state.week[index].breakfast      = nil
                                    state.week[index].breakfastEmoji = nil
                                } else {
                                    state.week[index].recipe = nil
                                    state.week[index].emoji  = nil
                                }
                            },
                            onLongPress: {
                                let r = state.recipes.randomElement()
                                if isBreakfast {
                                    state.week[index].breakfast      = r?.name
                                    state.week[index].breakfastEmoji = r?.emoji
                                } else {
                                    state.week[index].recipe = r?.name
                                    state.week[index].emoji  = r?.emoji
                                }
                            }
                        )
                        .padding(.horizontal, 16).padding(.bottom, 8)
                    }

                    // Batch Cook Tipp
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BATCH COOK TIPP")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(Theme.green)
                        Text("Doppelte Menge kochen und einfrieren spart bis zu 3x Zeit pro Woche — ideal für Dhal, Suppen & Saucen.")
                            .font(.system(size: 12)).foregroundColor(Theme.muted)
                    }
                    .padding(14)
                    .background(Theme.greenBg)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.green.opacity(0.2), lineWidth: 1))
                    .cornerRadius(14)
                    .padding(.horizontal, 16).padding(.top, 4).padding(.bottom, 20)

                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill").font(.system(size: 11)).foregroundColor(Theme.muted)
                        Text("Tippen = wählen  ·  Langer Druck = Zufallsrezept")
                            .font(.system(size: 11)).foregroundColor(Theme.muted)
                    }
                    .padding(.bottom, 16)
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Wochenplan")
        }
        .sheet(item: $pickingFor) { pick in
            let isBreakfast = mealSegment == 0
            let label = isBreakfast ? "Frühstück" : "Hauptgericht"
            RecipePickerSheet(
                title: "\(state.week[pick.id].shortName) – \(label)"
            ) { name, emoji in
                if isBreakfast {
                    state.week[pick.id].breakfast      = name
                    state.week[pick.id].breakfastEmoji = emoji
                } else {
                    state.week[pick.id].recipe = name
                    state.week[pick.id].emoji  = emoji
                }
            }
        }
    }
}

// Identifier für den Rezept-Picker (Tag-Index)
struct DayPick: Identifiable { var id: Int }

// MARK: - Wochentag-Zeile
private struct WeekDayRow: View {
    let day: WeekDay
    let dayNumber: Int
    let recipeName: String?
    let recipeEmoji: String?
    let onTap: () -> Void
    let onClear: () -> Void
    let onLongPress: () -> Void
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(day.shortName).font(.system(size: 10, weight: .bold)).foregroundColor(Theme.muted)
                Text("\(dayNumber)").font(.system(size: 18, weight: .bold))
                    .foregroundColor(recipeName != nil ? Theme.amber : Color(hex: "#CCCCCC"))
            }
            .frame(width: 32)

            if let name = recipeName, let emoji = recipeEmoji {
                Text("\(emoji) \(name)")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.dark)
                Spacer()
                Button(action: onClear) {
                    Image(systemName: "xmark").font(.system(size: 13))
                        .foregroundColor(Color(hex: "#CCCCCC"))
                }
            } else {
                Text("Tippen zum Auswählen…")
                    .font(.system(size: 13)).foregroundColor(Theme.muted.opacity(0.6)).italic()
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11)).foregroundColor(Theme.muted.opacity(0.4))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(recipeName != nil ? Theme.white : Theme.cream)
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(recipeName != nil ? Theme.border : Color.clear, lineWidth: 1))
        .cornerRadius(14)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in onLongPress() }
        )
    }
}

// MARK: - Rezept-Picker Sheet
struct RecipePickerSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) var dismiss
    let title: String
    let onSelect: (String, String) -> Void   // name, emoji

    @State private var search            = ""
    @State private var showNewRecipe     = false
    @State private var editingUserRecipe: Recipe? = nil

    var favorites: [Recipe] { state.allRecipes.filter(\.isFavorite) }

    var filtered: [Recipe] {
        guard !search.isEmpty else { return state.allRecipes }
        return state.allRecipes.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    @ViewBuilder
    private var customRecipeContent: some View {
        Button {
            showNewRecipe = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill").foregroundColor(Theme.amber)
                Text("Neues Rezept anlegen").foregroundColor(Theme.amber)
                    .font(.system(size: 14))
            }
        }
    }

    @ViewBuilder
    private var favoritesSection: some View {
        Section {
            ForEach(favorites) { recipe in
                recipeRow(recipe)
            }
        } header: {
            HStack(spacing: 4) {
                Image(systemName: "heart.fill").foregroundColor(.red).font(.system(size: 11))
                Text("Favoriten").font(.system(size: 12, weight: .bold)).foregroundColor(.red)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Suche
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(Theme.muted)
                        TextField("Rezept suchen…", text: $search)
                    }
                }

                // Eigene Rezepte — immer oben
                if !state.userRecipes.isEmpty && search.isEmpty {
                    Section {
                        ForEach(state.userRecipes) { recipe in
                            recipeRow(recipe)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        editingUserRecipe = recipe
                                    } label: {
                                        Label("Bearbeiten", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    } header: {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill").font(.system(size: 11))
                            Text("Meine Rezepte")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.amber)
                    }
                }

                // Favoriten
                if !favorites.isEmpty && search.isEmpty {
                    favoritesSection
                }

                // KI-Vorschläge / Suchergebnis
                Section {
                    ForEach(filtered) { recipe in
                        recipeRow(recipe)
                    }
                } header: {
                    Text(search.isEmpty ? "KI-Vorschläge" : "Suchergebnis")
                }

                // Eigenes Rezept
                Section {
                    customRecipeContent
                } header: {
                    Text("Eigenes Rezept")
                } footer: {
                    Text("Eigene Rezepte werden zur Datenbank hinzugefügt und stehen überall zur Verfügung.")
                        .font(.caption)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
            .sheet(isPresented: $showNewRecipe) {
                RecipeEditSheet { saved in
                    state.userRecipes.insert(saved, at: 0)
                    onSelect(saved.name, saved.emoji)
                    dismiss()
                }
                .environmentObject(state)
            }
            .sheet(item: $editingUserRecipe) { recipe in
                RecipeEditSheet(existingRecipe: recipe)
                    .environmentObject(state)
            }
        }
    }

    @ViewBuilder
    private func recipeRow(_ recipe: Recipe) -> some View {
        HStack(spacing: 12) {
            Text(recipe.emoji).font(.system(size: 26))
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.dark)
                HStack(spacing: 4) {
                    Text("\(recipe.time) Min")
                    Text("·")
                    Text(recipe.category)
                }
                .font(.system(size: 11)).foregroundColor(Theme.muted)
            }
            Spacer()
            Button {
                state.toggleFavorite(recipeId: recipe.id)
            } label: {
                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(recipe.isFavorite ? .red : Color(hex: "#CCCCCC"))
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(recipe.name, recipe.emoji)
            dismiss()
        }
    }
}
