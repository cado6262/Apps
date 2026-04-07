import SwiftUI

struct PantryView: View {
    @EnvironmentObject var state: AppState
    @State private var search = ""
    @State private var newName = ""
    @State private var newAmount = ""
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
                    // Suchleiste
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.muted)
                            .font(.system(size: 14))
                        TextField("Suchen…", text: $search)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.dark)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Theme.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // Neue Zutat
                    HStack(spacing: 8) {
                        TextField("Neue Zutat…", text: $newName)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.dark)
                            .focused($focusedField, equals: .name)
                            .onSubmit { focusedField = .amount }
                            .padding(10)
                            .background(Theme.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                            .cornerRadius(10)
                            .frame(minWidth: 0, maxWidth: .infinity, idealWidth: 200)

                        TextField("Menge", text: $newAmount)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.dark)
                            .focused($focusedField, equals: .amount)
                            .onSubmit { addItem() }
                            .padding(10)
                            .background(Theme.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                            .cornerRadius(10)
                            .frame(width: 90)

                        Button(action: addItem) {
                            Text("+")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Theme.amber)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // Sonderzutaten
                    if !specials.isEmpty {
                        SectionHeader(text: "✦ SONDERZUTATEN · werden gezielt verbraucht", color: Theme.special)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        ForEach(specials) { item in
                            PantryRowView(item: item,
                                onToggle: { toggle(id: item.id) },
                                onRemove: { remove(id: item.id) })
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                        Spacer().frame(height: 8)
                    }

                    // Normaler Vorrat
                    SectionHeader(text: "VORRAT", color: Theme.muted)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    if regular.isEmpty && search.isEmpty {
                        Text("Noch keine normalen Zutaten. Füge welche hinzu ↑")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.muted)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                    } else {
                        ForEach(regular) { item in
                            PantryRowView(item: item,
                                onToggle: { toggle(id: item.id) },
                                onRemove: { remove(id: item.id) })
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                    }
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Mein Vorrat")
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
        newName = ""; newAmount = ""
        focusedField = nil
    }

    private func toggle(id: Int) {
        if let i = state.pantry.firstIndex(where: { $0.id == id }) {
            state.pantry[i].isSpecial.toggle()
        }
    }

    private func remove(id: Int) {
        state.pantry.removeAll { $0.id == id }
    }
}

struct PantryRowView: View {
    let item: PantryItem
    let onToggle: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.dark)
                Text(item.amount)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.muted)
            }
            Spacer()
            Button(action: onToggle) {
                Text("✦")
                    .font(.system(size: 18))
                    .foregroundColor(item.isSpecial ? Theme.special : Color(hex: "#CCCCCC"))
            }
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#CCCCCC"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(item.isSpecial ? Theme.specialBg : Theme.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.isSpecial ? Theme.special.opacity(0.27) : Theme.border, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

private struct SectionHeader: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(color)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
