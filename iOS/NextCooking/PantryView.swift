import SwiftUI

// Eingebettet in KucheView
struct PantryContent: View {
    @EnvironmentObject var state: AppState
    @State private var search    = ""
    @State private var newName   = ""
    @State private var newAmount = ""
    @State private var editingItem: PantryItem?
    @FocusState private var nameActive: Bool

    var filtered: [PantryItem] {
        guard !search.isEmpty else { return state.pantry }
        return state.pantry.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }
    var specials: [PantryItem] { filtered.filter(\.isSpecial) }
    var regular:  [PantryItem] { filtered.filter { !$0.isSpecial } }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // Ablauf-Warnung
                if !state.expiringItems.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(hex: "#C4621A")).font(.system(size: 13))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("BALD ABLAUFEND")
                                .font(.system(size: 10, weight: .bold)).foregroundColor(Color(hex: "#C4621A"))
                            Text(state.expiringItems.map(\.name).joined(separator: ", "))
                                .font(.system(size: 11)).foregroundColor(Theme.muted)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(hex: "#FEF0E0"))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#C4621A").opacity(0.3), lineWidth: 1))
                    .cornerRadius(12)
                    .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 4)
                }

                // Suche
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(Theme.muted).font(.system(size: 14))
                    TextField("Suchen...", text: $search)
                        .font(.system(size: 14)).foregroundColor(Theme.dark)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Theme.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                .cornerRadius(12)
                .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 10)

                // Neue Zutat hinzufügen
                HStack(spacing: 8) {
                    TextField("Neue Zutat...", text: $newName)
                        .focused($nameActive)
                        .font(.system(size: 14)).foregroundColor(Theme.dark)
                        .onSubmit { addItem() }
                        .padding(10)
                        .background(Theme.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                        .cornerRadius(10)
                    TextField("Menge", text: $newAmount)
                        .font(.system(size: 14)).foregroundColor(Theme.dark)
                        .onSubmit { addItem() }
                        .padding(10)
                        .background(Theme.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                        .cornerRadius(10).frame(width: 90)
                    Button(action: addItem) {
                        Text("+").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            .frame(width: 44, height: 44).background(Theme.amber).cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 14)

                // Sonderzutaten
                if !specials.isEmpty {
                    PantrySection(title: "✦ SONDERZUTATEN", titleColor: Theme.special, items: specials,
                        onToggle: { toggle($0) }, onRemove: { remove($0) }, onEdit: { editingItem = $0 })
                    Spacer().frame(height: 6)
                }

                // Vorrat
                PantrySection(title: "VORRAT", titleColor: Theme.muted, items: regular,
                    onToggle: { toggle($0) }, onRemove: { remove($0) }, onEdit: { editingItem = $0 })
            }
        }
        .sheet(item: $editingItem) { item in
            PantryDateSheet(item: item) { updated in
                if let i = state.pantry.firstIndex(where: { $0.id == updated.id }) {
                    state.pantry[i] = updated
                }
            }
        }
    }

    private func addItem() {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        state.pantry.append(PantryItem(
            id: Int(Date().timeIntervalSince1970),
            name: newName.trimmingCharacters(in: .whitespaces),
            isSpecial: false,
            amount: newAmount.trimmingCharacters(in: .whitespaces).isEmpty ? "vorhanden" : newAmount
        ))
        newName = ""; newAmount = ""; nameActive = false
    }
    private func toggle(_ id: Int) {
        if let i = state.pantry.firstIndex(where: { $0.id == id }) { state.pantry[i].isSpecial.toggle() }
    }
    private func remove(_ id: Int) { state.pantry.removeAll { $0.id == id } }
}

// MARK: - Section
private struct PantrySection: View {
    let title: String
    let titleColor: Color
    let items: [PantryItem]
    let onToggle: (Int) -> Void
    let onRemove: (Int) -> Void
    let onEdit:   (PantryItem) -> Void

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 11, weight: .bold)).foregroundColor(titleColor)
                    .tracking(0.5).padding(.horizontal, 16)
                ForEach(items) { item in
                    PantryRow(item: item,
                        onToggle: { onToggle(item.id) },
                        onRemove: { onRemove(item.id) },
                        onEdit:   { onEdit(item) })
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 14)
        }
    }
}

// MARK: - Row
struct PantryRow: View {
    let item: PantryItem
    let onToggle: () -> Void
    let onRemove: () -> Void
    let onEdit:   () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.dark)
                        // Datum-Status Badge
                        if item.dateStatus != .none {
                            HStack(spacing: 3) {
                                Image(systemName: item.dateStatus.icon).font(.system(size: 9))
                                Text(item.dateStatus.label).font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(Color(hex: item.dateStatus.colorHex))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color(hex: item.dateStatus.colorHex).opacity(0.12))
                            .cornerRadius(8)
                        }
                    }
                    HStack(spacing: 6) {
                        Text(item.amount).font(.system(size: 11)).foregroundColor(Theme.muted)
                        if let s = item.dateSummary {
                            Text("· \(s)").font(.system(size: 10)).foregroundColor(Theme.muted.opacity(0.8))
                        }
                    }
                }
                Spacer()
                // Datum-Icon wenn leer (Einladung zum Eintragen)
                if item.dateStatus == .none {
                    Button(action: onEdit) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 14)).foregroundColor(Theme.muted.opacity(0.4))
                    }
                }
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
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(item.isSpecial ? Theme.special.opacity(0.27) : Theme.border, lineWidth: 1))
        .cornerRadius(12)
    }
}

// MARK: - Datum Sheet (alle Datumstypen, nicht nur MHD)
struct PantryDateSheet: View {
    @State var item: PantryItem
    @Environment(\.dismiss) private var dismiss
    let onSave: (PantryItem) -> Void

    @State private var hasBestBefore  = false
    @State private var hasOpenedOn    = false
    @State private var hasConsumeBy   = false
    @State private var hasPurchasedOn = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Zutat") {
                    TextField("Name", text: $item.name)
                    TextField("Menge", text: $item.amount)
                    Toggle("Sondervorrat — bald verbrauchen", isOn: $item.isSpecial).tint(Theme.special)
                }

                Section {
                    dateRow("Haltbar bis (ungeöffnet)", icon: "calendar", isOn: $hasBestBefore,
                            date: Binding(get: { item.bestBefore ?? Date() }, set: { item.bestBefore = $0 }))
                    dateRow("Geöffnet am", icon: "lock.open", isOn: $hasOpenedOn,
                            date: Binding(get: { item.openedOn ?? Date() }, set: { item.openedOn = $0 }))
                    dateRow("Verbrauchen bis (nach Öffnen)", icon: "timer", isOn: $hasConsumeBy,
                            date: Binding(get: { item.consumeBy ?? Date() }, set: { item.consumeBy = $0 }))
                    dateRow("Gekauft am", icon: "bag", isOn: $hasPurchasedOn,
                            date: Binding(get: { item.purchasedOn ?? Date() }, set: { item.purchasedOn = $0 }))
                } header: {
                    Text("Daten & Haltbarkeit")
                } footer: {
                    Text("Trage nur ein, was du weißt. Alle Felder sind optional.")
                        .font(.caption)
                }

                if item.dateStatus != .none {
                    Section("Status") {
                        HStack(spacing: 6) {
                            Image(systemName: item.dateStatus.icon)
                            Text(item.dateStatus.label)
                        }
                        .foregroundColor(Color(hex: item.dateStatus.colorHex))
                        .font(.system(size: 13, weight: .semibold))
                    }
                }
            }
            .navigationTitle("Zutat bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if !hasBestBefore  { item.bestBefore  = nil }
                        if !hasOpenedOn    { item.openedOn    = nil }
                        if !hasConsumeBy   { item.consumeBy   = nil }
                        if !hasPurchasedOn { item.purchasedOn = nil }
                        onSave(item); dismiss()
                    }.fontWeight(.bold)
                }
            }
            .onAppear {
                hasBestBefore  = item.bestBefore  != nil
                hasOpenedOn    = item.openedOn    != nil
                hasConsumeBy   = item.consumeBy   != nil
                hasPurchasedOn = item.purchasedOn != nil
            }
        }
    }

    @ViewBuilder
    private func dateRow(_ label: String, icon: String, isOn: Binding<Bool>, date: Binding<Date>) -> some View {
        Toggle(isOn: isOn) {
            Label(label, systemImage: icon)
        }
        .tint(Theme.amber)
        if isOn.wrappedValue {
            DatePicker("", selection: date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(.leading, 28)
        }
    }
}
