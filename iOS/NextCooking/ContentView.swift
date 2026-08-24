import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Heute",   systemImage: "house.fill") }

            NutritionView()
                .tabItem { Label("Makros",  systemImage: "flame.fill") }

            KucheView()
                .tabItem { Label("Küche",   systemImage: "refrigerator.fill") }

            PlannerView()
                .tabItem { Label("Planer",  systemImage: "calendar") }

            SocialView()
                .tabItem { Label("Freunde", systemImage: "person.2.fill") }
        }
        .accentColor(Theme.amber)
    }
}
