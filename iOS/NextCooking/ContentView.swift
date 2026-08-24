import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState
    @State private var selectedTab = "home"

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Heute",      systemImage: "house.fill") }
                .tag("home")

            PantryView()
                .tabItem { Label("Vorrat",     systemImage: "archivebox.fill") }
                .tag("pantry")

            ShoppingView()
                .tabItem { Label("Einkauf",    systemImage: "cart.fill") }
                .tag("shopping")

            PlannerView()
                .tabItem { Label("Planer",     systemImage: "calendar") }
                .tag("planner")

            NutritionView()
                .tabItem { Label("Makros",     systemImage: "flame.fill") }
                .tag("nutrition")

            SocialView()
                .tabItem { Label("Freunde",    systemImage: "person.2.fill") }
                .tag("social")
        }
        .accentColor(Theme.amber)
    }
}
