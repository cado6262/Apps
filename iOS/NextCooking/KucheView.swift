import SwiftUI

struct KucheView: View {
    @State private var segment = 0  // 0 = Vorrat, 1 = Einkauf

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("", selection: $segment) {
                    Text("Vorrat").tag(0)
                    Text("Einkaufsliste").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Theme.white)

                Divider()

                if segment == 0 {
                    PantryContent()
                } else {
                    ShoppingContent()
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Küche")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
