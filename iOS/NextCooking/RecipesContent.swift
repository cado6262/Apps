import SwiftUI

struct RecipesContent: View {
    @EnvironmentObject var state: AppState
    @State private var showNewRecipe      = false
    @State private var editingRecipe: Recipe? = nil
    @State private var search             = ""
    @State private var segment            = 0       // 0 = Meine, 1 = KI-Vorschläge
    @State private var mealTypeFilter     = "Alle"  // "Alle" or a MealType.name
    @State private var draggingMealType: String? = nil

    var filteredUser: [Recipe] {
        var result = state.userRecipes
        if mealTypeFilter != "Alle" {
            result = result.filter { $0.mealTypes.isEmpty || $0.mealTypes.contains(mealTypeFilter) }
        }
        if !search.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(search) }
        }
        return result
    }

    var filteredAI: [Recipe] {
        var result = state.recipes
        if !search.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(search) }
        }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(Theme.muted).font(.system(size: 14))
                TextField("Rezept suchen…", text: $search)
                    .font(.system(size: 14)).foregroundColor(Theme.dark)
                if !search.isEmpty {
                    Button { search = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(Theme.muted)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Theme.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.top, 12).padding(.bottom, 8)

            Divider()

            // Segment: Meine / KI
            Picker("", selection: $segment) {
                Text("Meine Rezepte").tag(0)
                Text("KI-Vorschläge").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Theme.white)

            // Meal type filter chips (same as Planer)
            if segment == 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        mealChip("Alle", emoji: nil)
                        ForEach(state.mealTypes) { mt in
                            mealChip(mt.name, emoji: mt.emoji)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                }
                .background(Theme.white)
            }

            Divider()

            if segment == 0 {
                myRecipesList
            } else {
                aiRecipesList
            }
        }
        .sheet(isPresented: $showNewRecipe) {
            RecipeEditSheet()
                .environmentObject(state)
        }
        .sheet(item: $editingRecipe) { recipe in
            RecipeEditSheet(existingRecipe: recipe)
                .environmentObject(state)
        }
    }

    @ViewBuilder
    private func mealChip(_ name: String, emoji: String?) -> some View {
        let isSelected = mealTypeFilter == name
        HStack(spacing: 4) {
            if let e = emoji { Text(e).font(.system(size: 12)) }
            Text(name).font(.system(size: 12, weight: isSelected ? .semibold : .regular))
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(isSelected ? Theme.amber : Theme.white)
        .foregroundColor(isSelected ? .white : Theme.dark)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.clear : Theme.border, lineWidth: 1))
        .onTapGesture { mealTypeFilter = name }
    }

    // MARK: - My Recipes List

    @ViewBuilder
    private var myRecipesList: some View {
        if filteredUser.isEmpty {
            emptyMyRecipes
        } else {
            List {
                ForEach(filteredUser) { recipe in
                    recipeRow(recipe, isUser: true)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                state.userRecipes.removeAll { $0.id == recipe.id }
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                            Button {
                                editingRecipe = recipe
                            } label: {
                                Label("Bearbeiten", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                state.toggleFavorite(recipeId: recipe.id)
                            } label: {
                                Label(recipe.isFavorite ? "Entfernen" : "Favorit",
                                      systemImage: recipe.isFavorite ? "heart.slash" : "heart.fill")
                            }
                            .tint(.red)
                        }
                }
                .onMove { from, to in
                    state.userRecipes.move(fromOffsets: from, toOffset: to)
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if segment == 0 {
                        if search.isEmpty { EditButton() }
                        Button { showNewRecipe = true } label: {
                            Image(systemName: "plus").font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var emptyMyRecipes: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 60)
                Text("🍽").font(.system(size: 52))
                Text("Noch keine eigenen Rezepte")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.dark)
                Text("Lege deine Lieblingsrezepte mit Zutaten, Schritten und eigenem Foto an.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Button {
                    showNewRecipe = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Erstes Rezept anlegen")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.amber)
                    .cornerRadius(14)
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - AI Recipes List

    @ViewBuilder
    private var aiRecipesList: some View {
        List {
            ForEach(filteredAI) { recipe in
                recipeRow(recipe, isUser: false)
                    .swipeActions(edge: .leading) {
                        Button {
                            state.toggleFavorite(recipeId: recipe.id)
                        } label: {
                            Label(recipe.isFavorite ? "Entfernen" : "Favorit",
                                  systemImage: recipe.isFavorite ? "heart.slash" : "heart.fill")
                        }
                        .tint(.red)
                    }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Shared row

    @ViewBuilder
    private func recipeRow(_ recipe: Recipe, isUser: Bool) -> some View {
        HStack(spacing: 12) {
            if let data = recipe.photoData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable().scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.amber.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Text(recipe.emoji).font(.system(size: 28))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(recipe.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.dark)
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                    }
                }
                HStack(spacing: 4) {
                    Text("\(recipe.time) Min")
                    Text("·")
                    Text(recipe.category)
                    if recipe.isBatch {
                        Text("·")
                        Image(systemName: "snowflake").font(.system(size: 10))
                    }
                }
                .font(.system(size: 11))
                .foregroundColor(Theme.muted)

                if let k = recipe.kcal {
                    HStack(spacing: 4) {
                        Text("\(k) kcal")
                        if let p = recipe.protein { Text("· \(p)g E") }
                        if let f = recipe.fat     { Text("· \(f)g F") }
                        if let c = recipe.carbs   { Text("· \(c)g KH") }
                    }
                    .font(.system(size: 11))
                    .foregroundColor(Theme.amber)
                }
            }

            Spacer()

            if isUser {
                Button { editingRecipe = recipe } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.muted.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Add button

    private var addButton: some View {
        Button {
            showNewRecipe = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                Text("Neues Rezept")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.amber)
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Theme.cream.ignoresSafeArea(edges: .bottom))
    }
}
