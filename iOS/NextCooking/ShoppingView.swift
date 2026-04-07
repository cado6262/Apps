import SwiftUI

struct ShoppingView: View {
    @EnvironmentObject var state: AppState
    @State private var newItem = ""

    var doneCount: Int { state.shopping.filter(\.isDone).count }
    var progress: Double { state.shopping.isEmpty ? 0 : Double(doneCount) / Double(state.shopping.count) }

    var uniqueCategories: [String] {
        var seen = Set<String>()
        return state.shopping.compactMap { seen.insert($0.category).inserted ? $0.category : nil }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Fortschrittsbalken
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Fortschritt").font(.system(size: 13, weight: .semibold)).foregroundColor(Theme.dark)
                            Spacer()
                            Text("\(doneCount) / \(state.shopping.count) erledigt")
                                .font(.system(size: 13)).foregroundColor(Theme.muted)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3).fill(Theme.border).frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Theme.green)
                                    .frame(width: geo.size.width * progress, height: 6)
                                    .animation(.spring(), value: progress)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(14)
                    .background(Theme.white)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Neue Zutat
                    HStack(spacing: 8) {
                        TextField("Zutat hinzufügen…", text: $newItem)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.dark)
                            .onSubmit { addItem() }
                            .padding(10)
                            .background(Theme.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                            .cornerRadius(10)
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

                    // Kategorien
                    ForEach(uniqueCategories, id: \.self) { cat in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(cat.uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.muted)
                                .tracking(0.5)
                                .padding(.horizontal, 16)

                            ForEach(state.shopping.filter { $0.category == cat }) { item in
                                ShoppingRowView(item: item,
                                    onToggle: { toggle(id: item.id) },
                                    onRemove: { remove(id: item.id) })
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 14)
                    }
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Einkaufsliste")
        }
    }

    private func addItem() {
        guard !newItem.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        state.shopping.append(ShoppingItem(
            id: Int(Date().timeIntervalSince1970),
            name: newItem.trimmingCharacters(in: .whitespaces),
            amount: "", isDone: false, category: "Sonstiges"
        ))
        newItem = ""
    }
    private func toggle(id: Int) {
        if let i = state.shopping.firstIndex(where: { $0.id == id }) { state.shopping[i].isDone.toggle() }
    }
    private func remove(id: Int) { state.shopping.removeAll { $0.id == id } }
}


struct ShoppingRowView: View {
    let item: ShoppingItem
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
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Theme.green)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.dark)
                    .strikethrough(item.isDone, color: Theme.muted)
                if !item.amount.isEmpty {
                    Text(item.amount)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.muted)
                }
            }
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#CCCCCC"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Theme.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
        .cornerRadius(12)
        .opacity(item.isDone ? 0.5 : 1)
        .animation(.easeInOut(duration: 0.15), value: item.isDone)
        .padding(.bottom, 6)
    }
}
