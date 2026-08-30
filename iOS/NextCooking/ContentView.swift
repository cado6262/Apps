import SwiftUI

private struct TabDef {
    let icon: String
    let label: String
}

private let tabDefs: [String: TabDef] = [
    "Heute":   TabDef(icon: "house.fill",       label: "Heute"),
    "Makros":  TabDef(icon: "flame.fill",        label: "Makros"),
    "Küche":   TabDef(icon: "refrigerator.fill", label: "Küche"),
    "Planer":  TabDef(icon: "calendar",          label: "Planer"),
    "Freunde": TabDef(icon: "person.2.fill",     label: "Freunde"),
]

struct ContentView: View {
    @EnvironmentObject var state: AppState
    @State private var selectedTab  = "Heute"
    @State private var tabOrder: [String] = ["Heute", "Makros", "Küche", "Planer", "Freunde"]
    @State private var draggingTab: String? = nil

    var body: some View {
        Group {
            switch selectedTab {
            case "Makros":  NutritionView()
            case "Küche":   KucheView()
            case "Planer":  PlannerView()
            case "Freunde": SocialView()
            default:        HomeView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            customTabBar
        }
        .accentColor(Theme.amber)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabOrder, id: \.self) { tab in
                if let def = tabDefs[tab] {
                    VStack(spacing: 3) {
                        Image(systemName: def.icon)
                            .font(.system(size: 22))
                        Text(def.label)
                            .font(.system(size: 10, weight: selectedTab == tab ? .medium : .regular))
                    }
                    .foregroundColor(selectedTab == tab ? Theme.amber : Theme.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = tab }
                    .onDrag {
                        draggingTab = tab
                        return NSItemProvider(object: tab as NSString)
                    }
                    .onDrop(of: ["public.text"], delegate: BottomTabDropDelegate(
                        tab: tab, tabs: $tabOrder, dragging: $draggingTab
                    ))
                }
            }
        }
        .background(
            Theme.white
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) { Divider() }
    }
}

private struct BottomTabDropDelegate: DropDelegate {
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
