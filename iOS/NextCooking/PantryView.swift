import SwiftUI

struct PantryView: View {
    @EnvironmentObject var state: AppState
    @State private var search      = ""
    @State private var newName     = ""
    @State private var newAmount   = ""
    @State private var editingItem: PantryItem?
    @FocusState private var focusedField: Field?
    enum Field { case name, amount }

    var filtered: [PantryItem] {
        guard !search.isEmpty else { return state.pantry }
        return state.pantry.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }
    var specials: [PantryItem] { filtered.filter(\.isSpecial) }
    var regular:  [PantryItem] { filtered.filter { !$0.isSpecial } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // Ablauf-Warnung
                    let expiring = state.pantry.filter { $0.mhdStatus == .critical || $0.mhdStatus == .expired }
                    if !expiring.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color(hex: "#C4621A"))
                                .font(.system(size: 14))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("BALD ABLAUFEND")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(hex: "#C4621A"))
                                Text(expiring.map(\.name).joined(separator: ", "))
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.muted)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color(hex: "#FEF0E0"))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#C4621A").opacity(0.3), lineWidth: 1))
                        .cornerRadius(12)
                        .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 4)
                    }

                    // Suchleiste
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(Theme.muted).font(.system(size: 14))
                        TextField("Suchen...", text: $search)
                            .font(.system(size: 14)).foregroundColor(Theme.dark)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Theme.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                    .cornerRadius(12)
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 12)

                    // Neue Zutat
                    HStack(spacing: 8) {
                        TextField("Neue Zutat...", text: $newName)
                            .font(.system(size: 14)).foregroundColor(Theme.dark)
                            .focused($focusedField, equals: .name)
                            .onSubmit { focusedField = .amount }
                            .padding(10)
                            .background(Theme.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                            .cornerRadius(10)
                        TextField("Menge", text: $newAmount)
                            .font(.system(size: 14)).foregroundColor(Theme.dark)
                            .focused($focusedField, equals: .amount)
                            .onSubmit { addItem() }
                            .padding(10)
                            .background(Theme.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                            .cornerRadius(10)
                            .frame(width: 90)
                        Button(action: addItem) {
                            Text("+").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                .frame(width: 44, height: 44).background(Theme.amber).cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 16)

                    // Sonderzutaten
                    if !specials.isEmpty {
                        sectionHeader("SONDERZUTATEN - werden gezielt verbraucht", color: Theme.special)
                        ForEach(specials) { item in
                            PantryRowView(item: item,
                                onToggle: { toggle(id: item.id) },
                                onRemove: { remove(id: item.id) },
                                onEdit:   { editingItem = item })
                            .padding(.horizontal, 16).padding(.bottom, 8)
                        }
                        Spacer().frame(height: 8)
                    }

                    // Normaler Vorrat
                    sectionHeader("VORRAT", color: Theme.muted)
                    if regular.isEmpty && search.isEmpty {
                        Text("Noch keine normalen Zutaten. Fuge welche hinzu")
                            .font(.system(size: 13)).foregroundColor(Theme.muted)
                            .multilineTextAlignment(.center).padding(.vertical, 20).padding(.horizontal, 16)
                    } else {
                        ForEach(regular) { item in
                            PantryRowView(item: item,
                                onToggle: { toggle(id: item.id) },
                                onRemove: { remove(id: item.id) },
                                onEdit:   { editingItem = item })
                            .padding(.horizontal, 16).padding(.bottom, 8)
                        }
                    }
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Mein Vorrat")
            .sheet(item: $editingItem) { item in
                PantryEditSheet(item: item) { updated in
                    if let i = state.pantry.firstIndex(where: { $0.id == updated.id }) {
                        state.pantry[i] = updated
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(_ text: String, color: Color) -> some View {
        Text(text).font(.system(size: 11, weight: .bold)).foregroundColor(color)
            .tracking(0.5).frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16).padding(.bottom, 8)
    }

    private func addItem() {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        state.pantry.append(PantryItem(
            id: Int(Date().timeIntervalSince1970),
            name: newName.trimmingCharacters(in: .whitespaces),
            isSpecial: false,
            amount: newAmount.trimmingCharacters(in: .whitespaces).isEmpty ? "vorhanden" : newAmount
        ))
        newName = ""; newAmount = ""; focusedField = nil
    }
    private func toggle(id: Int) {
        if let i = state.pantry.firstIndex(where: { $0.id == id }) { state.pantry[i].isSpecial.toggle() }
    }
    private func remove(id: Int) { state.pantry.removeAll { $0.id == id } }
}

// MARK: - Pantry Row
struct PantryRowView: View {
    let item: PantryItem
    let onToggle: () -> Void
    let onRemove: () -> Void
    let onEdit:   () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.dark)
                        // MHD-Badge
                        if item.mhdStatus != .none {
                            HStack(spacing: 3) {
                                Image(systemName: item.mhdStatus.icon)
                                    .font(.system(size: 9))
                                Text(item.mhdStatus.label)
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(Color(hex: item.mhdStatus.colorHex))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color(hex: item.mhdStatus.colorHex).opacity(0.12))
                            .cornerRadius(8)
                        }
                    }
                    HStack(spacing: 6) {
                        Text(item.amount)
                            .font(.system(size: 11)).foregroundColor(Theme.muted)
                        if let summary = item.mhdSummary {
                            Text("· \(summary)")
                                .font(.system(size: 10)).foregroundColor(Theme.muted)
                        }
                    }
                }
                Spacer()
                Button(action: onToggle) {
                    Text("✦").font(.system(size: 18))
                        .foregroundColor(item.isSpecial ? Theme.special : Color(hex: "#CCCCCC"))
                }
                Button(action: onRemove) {
                    Image(systemName: "xmark").font(.system(size: 12))
                        .foregroundColor(Color(hex: "#CCCCCC"))
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(item.isSpecial ? Theme.specialBg : Theme.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(item.isSpecial ? Theme.special.opacity(0.27) : Theme.border, lineWidth: 1))
        .cornerRadius(12)
    }
}

// MARK: - Edit Sheet
struct PantryEditSheet: View {
    @State var item: PantryItem
    @Environment(\.dismiss) private var dismiss
    let onSave: (PantryItem) -> Void

    @State private var hasBestBefore = false
    @State private var hasOpenedOn   = false
    @State private var hasConsumeBy  = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Zutat") {
                    TextField("Name", text: $item.name)
                    TextField("Menge", text: $item.amount)
                    Toggle("Sondervorrat (bald verbrauchen)", isOn: $item.isSpecial)
                        .tint(Theme.special)
                }

                Section("Haltbarkeit & Daten") {
                    Toggle("MHD angeben", isOn: $hasBestBefore)
                        .tint(Theme.amber)
                    if hasBestBefore {
                        DatePicker("Mindesthaltbarkeitsdatum",
                            selection: Binding(get: { item.bestBefore ?? Date() },
                                               set: { item.bestBefore = $0 }),
                            displayedComponents: .date)
                        .datePickerStyle(.compact)
                    }

                    Toggle("Geoeffnet am", isOn: $hasOpenedOn)
                        .tint(Theme.amber)
                    if hasOpenedOn {
                        DatePicker("Geoeffnet am",
                            selection: Binding(get: { item.openedOn ?? Date() },
                                               set: { item.openedOn = $0 }),
                            displayedComponents: .date)
                        .datePickerStyle(.compact)
                    }

                    Toggle("Verbrauchen bis", isOn: $hasConsumeBy)
                        .tint(Theme.amber)
                    if hasConsumeBy {
                        DatePicker("Verbrauchen bis",
                            selection: Binding(get: { item.consumeBy ?? Date() },
                                               set: { item.consumeBy = $0 }),
                            displayedComponents: .date)
                        .datePickerStyle(.compact)
                    }
                }

                if item.mhdStatus != .none {
                    Section("Status") {
                        HStack {
                            Image(systemName: item.mhdStatus.icon)
                            Text(item.mhdStatus.label)
                        }
                        .foregroundColor(Color(hex: item.mhdStatus.colorHex))
                        .font(.system(size: 13, weight: .semibold))
                    }
                }
            }
            .navigationTitle("Zutat bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if !hasBestBefore { item.bestBefore = nil }
                        if !hasOpenedOn   { item.openedOn   = nil }
                        if !hasConsumeBy  { item.consumeBy  = nil }
                        onSave(item)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                hasBestBefore = item.bestBefore != nil
                hasOpenedOn   = item.openedOn   != nil
                hasConsumeBy  = item.consumeBy  != nil
            }
        }
    }
}
