import SwiftUI

// Eingebettet in KucheView
struct ShoppingContent: View {
    @EnvironmentObject var state: AppState
    @State private var newItem          = ""
    @State private var filterStoreId: UUID? = nil
    @State private var expandedRecipes: Set<Int> = []
    @State private var showBasics       = false
    @State private var showStorePicker  = false   // Dialog: Markt für neuen Artikel
    @State private var showAddStore     = false   // Alert: neuen Supermarkt anlegen
    @State private var newStoreName     = ""

    var doneCount: Int { state.shopping.filter(\.isDone).count }
    var progress: Double {
        state.shopping.isEmpty ? 0 : Double(doneCount) / Double(state.shopping.count)
    }

    // Nur Artikel für den aktiven Markt — bei "Alle" (nil) alle anzeigen
    var filteredStandalone: [ShoppingItem] {
        let base = state.standaloneItems
        let filtered = filterStoreId == nil ? base : base.filter { $0.storeId == filterStoreId }
        // nach Gängen des aktiven Markts sortieren
        guard let store = state.selectedSupermarket else { return filtered }
        return filtered.sorted {
            let ai = store.aisles.firstIndex(of: $0.aisle) ?? 999
            let bi = store.aisles.firstIndex(of: $1.aisle) ?? 999
            return ai < bi
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // ── Supermarkt-Tabs ──
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        storeTab(id: nil, name: "Alle")
                        ForEach(state.supermarkets) { store in
                            storeTab(id: store.id, name: store.name)
                                .contextMenu {
                                    Button(role: .destructive) { deleteStore(store) } label: {
                                        Label("Löschen", systemImage: "trash")
                                    }
                                }
                        }
                        // Neuen Supermarkt hinzufügen
                        Button { showAddStore = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.amber)
                                .padding(.horizontal, 12).padding(.vertical, 7)
                                .background(Theme.amberBg)
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(Theme.amber.opacity(0.4), lineWidth: 1))
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 4)
                }
                .padding(.top, 12).padding(.bottom, 12)

                // Fortschritt
                VStack(spacing: 8) {
                    HStack {
                        Text("Fortschritt").font(.system(size: 13, weight: .semibold)).foregroundColor(Theme.dark)
                        Spacer()
                        Text("\(doneCount) / \(state.shopping.count) erledigt")
                            .font(.system(size: 13)).foregroundColor(Theme.muted)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Theme.border).frame(height: 6)
                            RoundedRectangle(cornerRadius: 3).fill(Theme.green)
                                .frame(width: geo.size.width * progress, height: 6)
                                .animation(.spring(), value: progress)
                        }
                    }.frame(height: 6)
                }
                .padding(14)
                .background(Theme.white)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                .cornerRadius(14)
                .padding(.horizontal, 16).padding(.bottom, 12)

                // Neue Zutat — "+" öffnet Markt-Auswahl
                HStack(spacing: 8) {
                    TextField("Artikel hinzufügen...", text: $newItem)
                        .font(.system(size: 14)).foregroundColor(Theme.dark)
                        .onSubmit { triggerAdd() }
                        .padding(10)
                        .background(Theme.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                        .cornerRadius(10)
                    Button(action: triggerAdd) {
                        Text("+").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            .frame(width: 44, height: 44).background(Theme.amber).cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 16)

                // ── Rezept-Sektionen (aufklappbar) ──
                if !state.recipeGroups.isEmpty {
                    sectionHeader("REZEPTE")
                    ForEach(state.recipeGroups, id: \.id) { group in
                        RecipeShoppingSection(
                            group: group,
                            isExpanded: expandedRecipes.contains(group.id),
                            onToggleExpand: {
                                if expandedRecipes.contains(group.id) { expandedRecipes.remove(group.id) }
                                else { expandedRecipes.insert(group.id) }
                            },
                            onToggleItem: { toggleItem($0) },
                            onRemoveRecipe: { state.removeRecipeFromShopping(recipeId: group.id) }
                        )
                        .padding(.horizontal, 16).padding(.bottom, 8)
                    }
                    Spacer().frame(height: 4)
                }

                // ── Einzelartikel (gefiltert + nach Gang sortiert) ──
                let standalone = filteredStandalone
                if !standalone.isEmpty {
                    HStack {
                        sectionHeader("ARTIKEL")
                        Spacer()
                        if filterStoreId != nil {
                            Text("nur \(state.supermarkets.first { $0.id == filterStoreId }?.name ?? "")")
                                .font(.system(size: 10)).foregroundColor(Theme.amber)
                                .padding(.trailing, 16)
                        }
                    }
                    let aisles = standalone.map(\.aisle).uniqueOrdered()
                    ForEach(aisles, id: \.self) { aisle in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(aisle.uppercased())
                                .font(.system(size: 10, weight: .bold)).foregroundColor(Theme.muted.opacity(0.7))
                                .tracking(0.5).padding(.horizontal, 16)
                            ForEach(standalone.filter { $0.aisle == aisle }) { item in
                                let storeName = item.storeId.flatMap { sid in
                                    state.supermarkets.first { $0.id == sid }?.name
                                }
                                ShoppingRow(item: item, storeName: storeName,
                                    onToggle: { toggleItem(item.id) },
                                    onRemove: { removeItem(item.id) })
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                } else if filterStoreId != nil {
                    // Leer-Zustand wenn Filter aktiv
                    let name = state.supermarkets.first { $0.id == filterStoreId }?.name ?? "diesem Markt"
                    VStack(spacing: 8) {
                        Image(systemName: "cart").font(.system(size: 28)).foregroundColor(Theme.muted.opacity(0.4))
                        Text("Keine Artikel für \(name)")
                            .font(.system(size: 13)).foregroundColor(Theme.muted)
                        Text("Tippe einen Artikel ein und wähle \(name) als Markt")
                            .font(.system(size: 11)).foregroundColor(Theme.muted.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 32).padding(.horizontal, 32)
                }

                // ── Basics prüfen ──
                BasicsPruefenSection(isExpanded: $showBasics)
                    .padding(.horizontal, 16).padding(.bottom, 20)
            }
        }
        // Dialog: Für welchen Supermarkt?
        .confirmationDialog("Für welchen Supermarkt?", isPresented: $showStorePicker, titleVisibility: .visible) {
            ForEach(state.supermarkets) { store in
                Button(store.name) { addItemToStore(storeId: store.id) }
            }
            Button("Kein bestimmter Markt") { addItemToStore(storeId: nil) }
            Button("Abbrechen", role: .cancel) { }
        }
        // Alert: Neuen Supermarkt anlegen
        .alert("Neuer Supermarkt", isPresented: $showAddStore) {
            TextField("Name (z.B. Aldi)", text: $newStoreName)
            Button("Hinzufügen") { addStore() }
            Button("Abbrechen", role: .cancel) { newStoreName = "" }
        }
    }

    // MARK: - Store Tab
    @ViewBuilder
    private func storeTab(id: UUID?, name: String) -> some View {
        let isActive = filterStoreId == id
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                filterStoreId = id
                if let id { state.selectedSupermarketId = id }
            }
        } label: {
            Text(name)
                .font(.system(size: 13, weight: isActive ? .bold : .regular))
                .foregroundColor(isActive ? .white : Theme.dark)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isActive ? Theme.amber : Theme.white)
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(isActive ? Theme.amber : Theme.border, lineWidth: 1))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(.system(size: 11, weight: .bold)).foregroundColor(Theme.muted)
            .tracking(0.5).frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16).padding(.bottom, 8)
    }

    // MARK: - Actions
    private func triggerAdd() {
        guard !newItem.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if state.supermarkets.isEmpty {
            addItemToStore(storeId: nil)
        } else {
            showStorePicker = true
        }
    }

    private func addItemToStore(storeId: UUID?) {
        state.shopping.append(ShoppingItem(
            id: Int(Date().timeIntervalSince1970),
            name: newItem.trimmingCharacters(in: .whitespaces),
            amount: "", isDone: false, aisle: "Sonstiges",
            storeId: storeId
        ))
        newItem = ""
    }

    private func addStore() {
        let trimmed = newStoreName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let store = Supermarket(name: trimmed, aisles: Supermarket.defaultAisles)
        state.supermarkets.append(store)
        state.selectedSupermarketId = store.id
        filterStoreId = store.id
        newStoreName = ""
    }

    private func deleteStore(_ store: Supermarket) {
        state.supermarkets.removeAll { $0.id == store.id }
        if filterStoreId == store.id { filterStoreId = nil }
        if state.selectedSupermarketId == store.id {
            state.selectedSupermarketId = state.supermarkets.first?.id
        }
    }

    private func toggleItem(_ id: Int) {
        if let i = state.shopping.firstIndex(where: { $0.id == id }) { state.shopping[i].isDone.toggle() }
    }
    private func removeItem(_ id: Int) { state.shopping.removeAll { $0.id == id } }
}

// MARK: - Aufklappbare Rezept-Sektion
private struct RecipeShoppingSection: View {
    let group: (id: Int, name: String, emoji: String, items: [ShoppingItem])
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onToggleItem: (Int) -> Void
    let onRemoveRecipe: () -> Void

    var doneCount: Int { group.items.filter(\.isDone).count }
    var allDone:   Bool { doneCount == group.items.count }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggleExpand) {
                HStack(spacing: 10) {
                    Text(group.emoji).font(.system(size: 22))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.name)
                            .font(.system(size: 14, weight: .bold)).foregroundColor(Theme.dark)
                        Text("\(doneCount)/\(group.items.count) erledigt")
                            .font(.system(size: 11)).foregroundColor(Theme.muted)
                    }
                    Spacer()
                    if allDone {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.green).font(.system(size: 18))
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12)).foregroundColor(Theme.muted)
                    Button(action: onRemoveRecipe) {
                        Image(systemName: "xmark").font(.system(size: 12)).foregroundColor(Color(hex: "#CCCCCC"))
                    }
                    .padding(.leading, 4)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .background(allDone ? Theme.greenBg : Theme.amberBg)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(group.items) { item in
                        HStack(spacing: 12) {
                            Button { onToggleItem(item.id) } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(item.isDone ? Theme.green : Color(hex: "#DDDDDD"), lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                    if item.isDone {
                                        RoundedRectangle(cornerRadius: 6).fill(Theme.green).frame(width: 22, height: 22)
                                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                                    }
                                }
                            }
                            Text(item.name)
                                .font(.system(size: 14)).foregroundColor(Theme.dark)
                                .strikethrough(item.isDone, color: Theme.muted)
                            Spacer()
                            if !item.amount.isEmpty {
                                Text(item.amount).font(.system(size: 12)).foregroundColor(Theme.muted)
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .opacity(item.isDone ? 0.5 : 1)
                        Divider().padding(.leading, 48)
                    }
                }
                .background(Theme.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

// MARK: - Einfache Shopping-Zeile
struct ShoppingRow: View {
    let item: ShoppingItem
    let storeName: String?
    let onToggle: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(item.isDone ? Theme.green : Color(hex: "#DDDDDD"), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if item.isDone {
                        RoundedRectangle(cornerRadius: 7).fill(Theme.green).frame(width: 24, height: 24)
                        Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.system(size: 14, weight: .medium)).foregroundColor(Theme.dark)
                    .strikethrough(item.isDone, color: Theme.muted)
                HStack(spacing: 6) {
                    if !item.amount.isEmpty {
                        Text(item.amount).font(.system(size: 11)).foregroundColor(Theme.muted)
                    }
                    if let s = storeName {
                        Text(s)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Theme.amber)
                            .padding(.horizontal, 5).padding(.vertical, 1)
                            .background(Theme.amberBg)
                            .cornerRadius(5)
                    }
                }
            }
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "xmark").font(.system(size: 12)).foregroundColor(Color(hex: "#CCCCCC"))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Theme.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
        .cornerRadius(12)
        .opacity(item.isDone ? 0.5 : 1)
        .padding(.bottom, 6)
    }
}

// MARK: - Basics prüfen
private struct BasicsPruefenSection: View {
    @EnvironmentObject var state: AppState
    @Binding var isExpanded: Bool
    @State private var newBasic = ""

    var body: some View {
        VStack(spacing: 0) {
            Button { withAnimation { isExpanded.toggle() } } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal").font(.system(size: 16)).foregroundColor(Theme.muted)
                    Text("Basics prüfen")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.dark)
                    Spacer()
                    Text("Grundzutaten zuhause?")
                        .font(.system(size: 11)).foregroundColor(Theme.muted)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11)).foregroundColor(Theme.muted)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Theme.white)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach($state.basics) { $basic in
                        HStack(spacing: 12) {
                            Button { basic.isAvailable.toggle() } label: {
                                ZStack {
                                    Circle().stroke(basic.isAvailable ? Theme.green : Color(hex: "#DDDDDD"), lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                    if basic.isAvailable {
                                        Circle().fill(Theme.green).frame(width: 22, height: 22)
                                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                                    }
                                }
                            }
                            Text(basic.name).font(.system(size: 14)).foregroundColor(Theme.dark)
                            Spacer()
                            if !basic.isAvailable {
                                Text("fehlt").font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "#CC3333"))
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .opacity(basic.isAvailable ? 0.6 : 1)
                        Divider().padding(.leading, 48)
                    }
                    HStack(spacing: 8) {
                        TextField("Basic hinzufügen...", text: $newBasic)
                            .font(.system(size: 13)).foregroundColor(Theme.dark)
                            .onSubmit { addBasic() }
                        Button(action: addBasic) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20)).foregroundColor(Theme.amber)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                }
                .background(Theme.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
    }

    private func addBasic() {
        guard !newBasic.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        state.basics.append(BasicItem(name: newBasic.trimmingCharacters(in: .whitespaces)))
        newBasic = ""
    }
}

// MARK: - Array helper (lokal)
private extension Array where Element == ShoppingItem {
    func uniqueAisles() -> [String] {
        var seen = Set<String>()
        return compactMap { seen.insert($0.aisle).inserted ? $0.aisle : nil }
    }
}
