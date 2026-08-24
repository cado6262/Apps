import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: state.fillWeekWithAI) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles").font(.system(size: 12, weight: .bold))
                                Text("KI planen").font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Theme.amber).cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 14)

                    ForEach(Array(state.week.enumerated()), id: \.element.id) { index, day in
                        WeekDayRow(day: day, dayNumber: index + 1,
                            onClear: {
                                state.week[index].recipe = nil
                                state.week[index].emoji  = nil
                            },
                            // Long-press gibt zufaelliges Rezept
                            onLongPress: {
                                let r = state.recipes.randomElement()
                                state.week[index].recipe = r?.name
                                state.week[index].emoji  = r?.emoji
                            }
                        )
                        .padding(.horizontal, 16).padding(.bottom, 8)
                    }

                    // Batch Cook Tipp
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BATCH COOK TIPP")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(Theme.green)
                        Text("Linsen-Dhal und Bolognese eignen sich ideal zum Einfrieren. Koche doppelte Menge und spare 3x Zeit pro Woche!")
                            .font(.system(size: 12)).foregroundColor(Theme.muted)
                    }
                    .padding(14)
                    .background(Theme.greenBg)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.green.opacity(0.2), lineWidth: 1))
                    .cornerRadius(14)
                    .padding(.horizontal, 16).padding(.top, 4).padding(.bottom, 20)

                    // Hinweis: Long Press
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill").font(.system(size: 11)).foregroundColor(Theme.muted)
                        Text("Langer Druck auf einen Tag = Zufallsrezept")
                            .font(.system(size: 11)).foregroundColor(Theme.muted)
                    }
                    .padding(.bottom, 12)
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Wochenplan")
        }
    }
}

private struct WeekDayRow: View {
    let day: WeekDay
    let dayNumber: Int
    let onClear: () -> Void
    let onLongPress: () -> Void
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(day.shortName).font(.system(size: 10, weight: .bold)).foregroundColor(Theme.muted)
                Text("\(dayNumber)").font(.system(size: 18, weight: .bold))
                    .foregroundColor(day.recipe != nil ? Theme.amber : Color(hex: "#CCCCCC"))
            }
            .frame(width: 32)

            if let recipe = day.recipe, let emoji = day.emoji {
                Text("\(emoji) \(recipe)")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.dark)
                Spacer()
                Button(action: onClear) {
                    Image(systemName: "xmark").font(.system(size: 13))
                        .foregroundColor(Color(hex: "#CCCCCC"))
                }
            } else {
                Text("Rezept waehlen...")
                    .font(.system(size: 13)).foregroundColor(Theme.muted.opacity(0.6))
                    .italic()
                Spacer()
                Text("...lang druecken")
                    .font(.system(size: 10)).foregroundColor(Theme.muted.opacity(0.5))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(day.recipe != nil ? Theme.white : Theme.cream)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(day.recipe != nil ? Theme.border : Color.clear, lineWidth: 1))
        .cornerRadius(14)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.5,
            pressing: { pressing in
                withAnimation { isPressed = pressing }
            },
            perform: onLongPress
        )
    }
}
