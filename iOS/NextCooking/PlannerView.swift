import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var state: AppState
    @State private var selectedMealTypeName: String = "Hauptgericht"
    @State private var weekOffset = 0
    @State private var pickingFor: DayPick? = nil
    @State private var showAddMealType   = false
    @State private var newMealTypeName   = ""
    @State private var draggingMealType: String? = nil

    var selectedMealType: MealType {
        state.mealTypes.first { $0.name == selectedMealTypeName } ?? MealType.defaults[1]
    }

    var currentWeek: [WeekDay] { state.weekPlan(offset: weekOffset) }

    private func weekLabel(_ offset: Int) -> String {
        switch offset {
        case 0:  return "Diese Woche"
        case 1:  return "Nächste Woche"
        case -1: return "Letzte Woche"
        case 2...: return "in \(offset) Wochen"
        default: return "vor \(-offset) Wochen"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mealTypeTabs
                weekNavRow

                ScrollView {
                    VStack(spacing: 0) {
                        aiPlanButton
                        weekRows
                        batchTip
                        hintRow
                    }
                }
                .background(Theme.cream)
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Wochenplan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddMealType = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
            }
        }
        .sheet(item: $pickingFor) { pick in
            RecipePickerSheet(
                title: "\(currentWeek[pick.id].shortName) – \(selectedMealType.emoji) \(selectedMealType.name)"
            ) { name, emoji in
                state.setMeal(weekOffset: weekOffset, dayIndex: pick.id, typeName: selectedMealType.name, recipe: name, emoji: emoji)
            }
        }
        .alert("Neue Mahlzeit", isPresented: $showAddMealType) {
            TextField("Name (z.B. Mittagessen)", text: $newMealTypeName)
            Button("Hinzufügen") {
                let name = newMealTypeName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                let emoji = emojiForMealType(name)
                state.mealTypes.append(MealType(name: name, emoji: emoji))
                selectedMealTypeName = name
                newMealTypeName = ""
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Lege eine eigene Mahlzeit an — z.B. Snack, Mittagessen oder Pre-Workout.")
        }
    }

    private func emojiForMealType(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("frühstück") || lower.contains("breakfast") { return "🌅" }
        if lower.contains("mittag") || lower.contains("lunch")        { return "☀️" }
        if lower.contains("snack")                                     { return "🥨" }
        if lower.contains("abend") || lower.contains("dinner")        { return "🌙" }
        if lower.contains("sport") || lower.contains("workout")       { return "💪" }
        if lower.contains("dessert") || lower.contains("süß")         { return "🍮" }
        return "🍴"
    }

    // MARK: - Meal type chip row (drag-to-reorder)

    @ViewBuilder
    private var mealTypeTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(state.mealTypes) { mt in
                    let isSelected = selectedMealTypeName == mt.name
                    HStack(spacing: 5) {
                        Text(mt.emoji).font(.system(size: 13))
                        Text(mt.name).font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(isSelected ? Theme.amber : Theme.white)
                    .foregroundColor(isSelected ? .white : Theme.dark)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.clear : Theme.border, lineWidth: 1)
                    )
                    .onTapGesture { selectedMealTypeName = mt.name }
                    .onLongPressGesture(minimumDuration: 0.01, perform: {})
                    .onDrag {
                        draggingMealType = mt.name
                        return NSItemProvider(object: mt.name as NSString)
                    }
                    .onDrop(of: ["public.text"], delegate: MealTypeDropDelegate(
                        name: mt.name,
                        mealTypes: $state.mealTypes,
                        dragging: $draggingMealType
                    ))
                    .contextMenu {
                        if state.mealTypes.count > 1 {
                            Button(role: .destructive) {
                                state.mealTypes.removeAll { $0.name == mt.name }
                                if selectedMealTypeName == mt.name {
                                    selectedMealTypeName = state.mealTypes.first?.name ?? "Hauptgericht"
                                }
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(Theme.white)
        Divider()
    }

    // MARK: - Week navigation row

    @ViewBuilder
    private var weekNavRow: some View {
        HStack(spacing: 0) {
            Button {
                weekOffset -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.amber)
                    .padding(.horizontal, 20).padding(.vertical, 10)
            }
            Spacer()
            Text(weekLabel(weekOffset))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(weekOffset == 0 ? Theme.amber : Theme.dark)
            Spacer()
            Button {
                weekOffset += 1
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.amber)
                    .padding(.horizontal, 20).padding(.vertical, 10)
            }
        }
        .background(Theme.white)
        Divider()
    }

    // MARK: - KI planen button

    @ViewBuilder
    private var aiPlanButton: some View {
        HStack {
            Spacer()
            Button {
                Task { await state.loadAndFillWeekWithAI(mealType: selectedMealType, weekOffset: weekOffset) }
            } label: {
                HStack(spacing: 6) {
                    if state.isLoadingAI {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.75)
                    } else {
                        Image(systemName: "sparkles").font(.system(size: 12, weight: .bold))
                    }
                    Text(state.isLoadingAI ? "Plane…" : "KI planen")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(state.isLoadingAI ? Theme.amber.opacity(0.6) : Theme.amber)
                .cornerRadius(10)
            }
            .disabled(state.isLoadingAI)
        }
        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
    }

    // MARK: - Week rows

    @ViewBuilder
    private var weekRows: some View {
        ForEach(Array(currentWeek.enumerated()), id: \.element.id) { index, day in
            let meal = state.getMeal(weekOffset: weekOffset, dayIndex: index, typeName: selectedMealType.name)
            WeekDayRow(
                day: day,
                dayNumber: index + 1,
                recipeName:  meal?.recipe,
                recipeEmoji: meal?.emoji,
                onTap: { pickingFor = DayPick(id: index) },
                onClear: {
                    state.setMeal(weekOffset: weekOffset, dayIndex: index, typeName: selectedMealType.name, recipe: nil, emoji: nil)
                },
                onLongPress: {
                    if let r = state.recipes.randomElement() {
                        state.setMeal(weekOffset: weekOffset, dayIndex: index, typeName: selectedMealType.name, recipe: r.name, emoji: r.emoji)
                    }
                }
            )
            .padding(.horizontal, 16).padding(.bottom, 8)
        }
    }

    // MARK: - Batch tip

    @ViewBuilder
    private var batchTip: some View {
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
    }

    // MARK: - Hint row

    @ViewBuilder
    private var hintRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.tap.fill").font(.system(size: 11)).foregroundColor(Theme.muted)
            Text("Tippen = wählen  ·  Langer Druck = Zufallsrezept  ·  Tab halten = verschieben")
                .font(.system(size: 11)).foregroundColor(Theme.muted)
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Drag drop delegate for meal types
private struct MealTypeDropDelegate: DropDelegate {
    let name: String
    @Binding var mealTypes: [MealType]
    @Binding var dragging: String?

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging != name,
              let from = mealTypes.firstIndex(where: { $0.name == dragging }),
              let to   = mealTypes.firstIndex(where: { $0.name == name }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            mealTypes.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
}

// MARK: - DayPick
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
    let onSelect: (String, String) -> Void

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
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(Theme.muted)
                        TextField("Rezept suchen…", text: $search)
                    }
                }

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

                if !favorites.isEmpty && search.isEmpty {
                    favoritesSection
                }

                Section {
                    ForEach(filtered) { recipe in
                        recipeRow(recipe)
                    }
                } header: {
                    Text(search.isEmpty ? "KI-Vorschläge" : "Suchergebnis")
                }

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
