import SwiftUI

struct KucheView: View {
    @State private var selectedTab  = "Vorrat"
    @State private var tabOrder: [String] = ["Vorrat", "Einkaufsliste", "Rezepte"]
    @State private var draggingTab: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom drag-to-reorder tab bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tabOrder, id: \.self) { tab in
                            Text(tabLabel(tab))
                                .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .regular))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(selectedTab == tab ? Theme.amber : Theme.cream)
                                .foregroundColor(selectedTab == tab ? .white : Theme.dark)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selectedTab == tab ? Color.clear : Theme.border, lineWidth: 1)
                                )
                                .opacity(draggingTab == tab ? 0.45 : 1.0)
                                .animation(.easeInOut(duration: 0.15), value: draggingTab)
                                .onTapGesture { selectedTab = tab }
                                .onDrag {
                                    draggingTab = tab
                                    return NSItemProvider(object: tab as NSString)
                                }
                                .onDrop(of: ["public.text"], delegate: KucheTabDropDelegate(
                                    tab: tab,
                                    tabs: $tabOrder,
                                    dragging: $draggingTab
                                ))
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                }
                .background(Theme.white)

                Divider()

                switch selectedTab {
                case "Einkaufsliste": ShoppingContent()
                case "Rezepte":       RecipesContent()
                default:              PantryContent()
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Küche")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func tabLabel(_ tab: String) -> String {
        switch tab {
        case "Vorrat":       return "Vorrat"
        case "Einkaufsliste": return "Einkaufsliste"
        case "Rezepte":      return "Rezepte"
        default:             return tab
        }
    }
}

// MARK: - Drop delegate for Küche tabs
private struct KucheTabDropDelegate: DropDelegate {
    let tab: String
    @Binding var tabs: [String]
    @Binding var dragging: String?

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging != tab,
              let from = tabs.firstIndex(of: dragging),
              let to   = tabs.firstIndex(of: tab) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            tabs.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
