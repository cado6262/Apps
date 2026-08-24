import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var state: AppState
    @State private var showGoalEditor = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // ── Import-Banner (HealthKit) ──
                    HealthImportBanner()
                        .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 20)

                    // ── Heute gegessen ──
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HEUTE GEGESSEN")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(Theme.muted).tracking(0.5)
                        MacroRingRow()
                    }
                    .padding(.horizontal, 16).padding(.bottom, 20)

                    // ── Tagesziele ──
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("MEINE TAGESZIELE")
                                .font(.system(size: 11, weight: .bold)).foregroundColor(Theme.muted).tracking(0.5)
                            Spacer()
                            Button { showGoalEditor = true } label: {
                                Text("Anpassen")
                                    .font(.system(size: 12, weight: .semibold)).foregroundColor(Theme.amber)
                            }
                        }
                        GoalProgressGrid()
                    }
                    .padding(.horizontal, 16).padding(.bottom, 20)

                    // ── Rezeptvorschlag nach Makros ──
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("REZEPT NACH MAKROS")
                                .font(.system(size: 11, weight: .bold)).foregroundColor(Theme.muted).tracking(0.5)
                            Text("KI schlaegt Rezepte vor, die deine verbleibenden Makros treffen")
                                .font(.system(size: 12)).foregroundColor(Theme.muted)
                        }
                        Button {
                            Task { await state.loadNutritionAIRecipes() }
                        } label: {
                            HStack(spacing: 10) {
                                if state.isLoadingNutritionAI {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.8)
                                } else {
                                    Image(systemName: "sparkles").font(.system(size: 15, weight: .bold))
                                }
                                Text(state.isLoadingNutritionAI ? "KI rechnet..." : "Passendes Rezept vorschlagen")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(state.isLoadingNutritionAI ? Theme.muted : Theme.dark)
                            .cornerRadius(14)
                        }
                        .disabled(state.isLoadingNutritionAI)

                        if !state.recipes.isEmpty {
                            Text("Zuletzt vorgeschlagen:")
                                .font(.system(size: 11)).foregroundColor(Theme.muted)
                            ForEach(state.recipes.prefix(2)) { recipe in
                                NutritionRecipeRow(recipe: recipe) {
                                    state.addToShopping(recipe: recipe)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 20)

                    // ── App-Import Info ──
                    AppImportInfo()
                        .padding(.horizontal, 16).padding(.bottom, 30)
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Makros & Ernaehrung")
            .sheet(isPresented: $showGoalEditor) { GoalEditorSheet() }
        }
    }
}

// MARK: - HealthKit Import Banner
private struct HealthImportBanner: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: state.healthKitAuthorized ? "heart.fill" : "heart")
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "#FF375F"))
            VStack(alignment: .leading, spacing: 3) {
                Text(state.healthKitAuthorized ? "Apple Health verbunden" : "Apple Health verbinden")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(Theme.dark)
                Text(state.healthKitAuthorized
                    ? "Makros werden automatisch importiert"
                    : "Importiere Makros aus MacroFactor, Yazio, MyFitnessPal")
                    .font(.system(size: 11)).foregroundColor(Theme.muted)
            }
            Spacer()
            if !state.healthKitAuthorized {
                Button {
                    Task { await state.requestHealthKitAccess() }
                } label: {
                    Text("Verbinden")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color(hex: "#FF375F")).cornerRadius(10)
                }
            } else {
                Button {
                    Task { await state.loadTodayMacrosFromHealth() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#FF375F"))
                }
            }
        }
        .padding(14)
        .background(Theme.white)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#FF375F").opacity(0.2), lineWidth: 1))
        .cornerRadius(14)
    }
}

// MARK: - Macro Ring Row
private struct MacroRingRow: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack(spacing: 12) {
            MacroRing(
                value: state.todayKcal,
                goal: Double(state.nutritionGoal.kcal),
                label: "kcal", unit: "",
                color: Color(hex: "#E8901A"))
            MacroBar(label: "Eiweiss", value: state.todayProtein,  goal: Double(state.nutritionGoal.protein), unit: "g", color: Color(hex: "#3D7A1E"))
            MacroBar(label: "Fett",    value: state.todayFat,      goal: Double(state.nutritionGoal.fat),     unit: "g", color: Color(hex: "#7B5EA7"))
            MacroBar(label: "KH",      value: state.todayCarbs,    goal: Double(state.nutritionGoal.carbs),   unit: "g", color: Color(hex: "#4B9CD3"))
        }
        .padding(14)
        .background(Theme.white)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
        .cornerRadius(14)
    }
}

private struct MacroRing: View {
    let value: Double; let goal: Double; let label: String; let unit: String; let color: Color
    var progress: Double { min(value / max(goal, 1), 1.0) }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().stroke(color.opacity(0.15), lineWidth: 6).frame(width: 56, height: 56)
                Circle().trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 56, height: 56)
                    .animation(.spring(), value: progress)
                VStack(spacing: 0) {
                    Text("\(Int(value))").font(.system(size: 13, weight: .bold)).foregroundColor(Theme.dark)
                    Text(label).font(.system(size: 8)).foregroundColor(Theme.muted)
                }
            }
            Text("/ \(Int(goal))\(unit)").font(.system(size: 9)).foregroundColor(Theme.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MacroBar: View {
    let label: String; let value: Double; let goal: Double; let unit: String; let color: Color
    var progress: Double { min(value / max(goal, 1), 1.0) }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Int(value))g").font(.system(size: 14, weight: .bold)).foregroundColor(Theme.dark)
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4).fill(color.opacity(0.12)).frame(width: geo.size.width)
                    RoundedRectangle(cornerRadius: 4).fill(color)
                        .frame(width: geo.size.width, height: geo.size.height * progress)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 44)
            Text(label).font(.system(size: 9)).foregroundColor(Theme.muted)
            Text("/ \(Int(goal))g").font(.system(size: 8)).foregroundColor(Theme.muted.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Goal Progress Grid
private struct GoalProgressGrid: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 8) {
            GoalRow(label: "Kalorien",     value: Int(state.todayKcal),    goal: state.nutritionGoal.kcal,    unit: "kcal", color: Color(hex: "#E8901A"))
            GoalRow(label: "Eiweiss",      value: Int(state.todayProtein), goal: state.nutritionGoal.protein, unit: "g",    color: Color(hex: "#3D7A1E"))
            GoalRow(label: "Fett",         value: Int(state.todayFat),     goal: state.nutritionGoal.fat,     unit: "g",    color: Color(hex: "#7B5EA7"))
            GoalRow(label: "Kohlenhydrate",value: Int(state.todayCarbs),   goal: state.nutritionGoal.carbs,   unit: "g",    color: Color(hex: "#4B9CD3"))
        }
        .padding(14)
        .background(Theme.white)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
        .cornerRadius(14)
    }
}

private struct GoalRow: View {
    let label: String; let value: Int; let goal: Int; let unit: String; let color: Color
    var progress: Double { min(Double(value) / Double(max(goal, 1)), 1.0) }
    var remaining: Int { max(0, goal - value) }

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text(label).font(.system(size: 13, weight: .medium)).foregroundColor(Theme.dark)
                Spacer()
                Text("\(value) / \(goal) \(unit)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(progress >= 1 ? color : Theme.muted)
                if remaining > 0 {
                    Text("noch \(remaining)\(unit)")
                        .font(.system(size: 10)).foregroundColor(Theme.muted.opacity(0.7))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(color.opacity(0.12)).frame(height: 5)
                    RoundedRectangle(cornerRadius: 3).fill(color)
                        .frame(width: geo.size.width * progress, height: 5)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 5)
        }
    }
}

// MARK: - Goal Editor Sheet
struct GoalEditorSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var kcal    = ""
    @State private var protein = ""
    @State private var fat     = ""
    @State private var carbs   = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Tagesziele anpassen") {
                    HStack {
                        Text("Kalorien")
                        Spacer()
                        TextField("2000", text: $kcal).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("kcal").foregroundColor(Theme.muted)
                    }
                    HStack {
                        Text("Eiweiss")
                        Spacer()
                        TextField("150", text: $protein).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("g").foregroundColor(Theme.muted)
                    }
                    HStack {
                        Text("Fett")
                        Spacer()
                        TextField("65", text: $fat).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("g").foregroundColor(Theme.muted)
                    }
                    HStack {
                        Text("Kohlenhydrate")
                        Spacer()
                        TextField("200", text: $carbs).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("g").foregroundColor(Theme.muted)
                    }
                }

                Section {
                    Button("Empfehlung: 2000 kcal / 150g E / 65g F / 200g KH") {
                        kcal = "2000"; protein = "150"; fat = "65"; carbs = "200"
                    }
                    .foregroundColor(Theme.amber)
                }
            }
            .navigationTitle("Tagesziele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if let k = Int(kcal)    { state.nutritionGoal.kcal    = k }
                        if let p = Int(protein) { state.nutritionGoal.protein = p }
                        if let f = Int(fat)     { state.nutritionGoal.fat     = f }
                        if let c = Int(carbs)   { state.nutritionGoal.carbs   = c }
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                kcal    = "\(state.nutritionGoal.kcal)"
                protein = "\(state.nutritionGoal.protein)"
                fat     = "\(state.nutritionGoal.fat)"
                carbs   = "\(state.nutritionGoal.carbs)"
            }
        }
    }
}

// MARK: - Nutrition Recipe Row
private struct NutritionRecipeRow: View {
    let recipe: Recipe
    let onShop: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(recipe.emoji).font(.system(size: 30))
            VStack(alignment: .leading, spacing: 3) {
                Text(recipe.name).font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.dark)
                if let kcal = recipe.kcal, let protein = recipe.protein, let fat = recipe.fat, let carbs = recipe.carbs {
                    HStack(spacing: 8) {
                        MacroChip(label: "\(kcal) kcal", color: Color(hex: "#E8901A"))
                        MacroChip(label: "\(protein)g E",  color: Color(hex: "#3D7A1E"))
                        MacroChip(label: "\(fat)g F",      color: Color(hex: "#7B5EA7"))
                        MacroChip(label: "\(carbs)g KH",   color: Color(hex: "#4B9CD3"))
                    }
                }
            }
            Spacer()
            Button(action: onShop) {
                Text("+").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    .frame(width: 30, height: 30).background(Theme.amber).cornerRadius(8)
            }
        }
        .padding(12)
        .background(Theme.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
        .cornerRadius(12)
    }
}

private struct MacroChip: View {
    let label: String; let color: Color
    var body: some View {
        Text(label).font(.system(size: 9, weight: .bold)).foregroundColor(color)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.12)).cornerRadius(6)
    }
}

// MARK: - App Import Info
private struct AppImportInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("APP-IMPORT").font(.system(size: 11, weight: .bold)).foregroundColor(Theme.muted).tracking(0.5)
            Text("MacroFactor, Yazio und MyFitnessPal synchronisieren automatisch mit Apple Health. Aktiviere die Health-Synchronisation in der jeweiligen App:")
                .font(.system(size: 12)).foregroundColor(Theme.muted).lineSpacing(2)
            VStack(alignment: .leading, spacing: 6) {
                AppImportStep(app: "MacroFactor", step: "Einstellungen > Gesundheit & Fitness > Apple Health aktivieren")
                AppImportStep(app: "Yazio",       step: "Profil > Verbundene Apps > Apple Health")
                AppImportStep(app: "MyFitnessPal",step: "Mehr > Apps & Gerate > Apple Health")
            }
        }
        .padding(14)
        .background(Theme.white)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
        .cornerRadius(14)
    }
}

private struct AppImportStep: View {
    let app: String; let step: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("·").foregroundColor(Theme.amber).font(.system(size: 14, weight: .bold))
            VStack(alignment: .leading, spacing: 1) {
                Text(app).font(.system(size: 12, weight: .bold)).foregroundColor(Theme.dark)
                Text(step).font(.system(size: 11)).foregroundColor(Theme.muted)
            }
        }
    }
}
