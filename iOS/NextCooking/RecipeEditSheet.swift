import SwiftUI
import PhotosUI

// MARK: - RecipeEditSheet
struct RecipeEditSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) var dismiss

    var existingRecipe: Recipe?
    var onSave: ((Recipe) -> Void)?

    @State private var name        = ""
    @State private var emoji       = "🍽"
    @State private var time        = "30"
    @State private var category    = "Eigenes"
    @State private var desc        = ""
    @State private var isBatch     = false
    @State private var kcalStr     = ""
    @State private var proteinStr  = ""
    @State private var fatStr      = ""
    @State private var carbsStr    = ""
    @State private var steps: [String]       = [""]
    @State private var ingredients: [String] = [""]
    @State private var photoData: Data?      = nil
    @State private var selectedMealTypes: [String] = []

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showCamera = false
    @State private var showDeleteConfirm = false

    private var isEdit: Bool { existingRecipe != nil }

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                basicSection
                ingredientsSection
                stepsSection
                mealTypeSection
                nutritionSection
                if isEdit { deleteSection }
            }
            .navigationTitle(isEdit ? "Rezept bearbeiten" : "Neues Rezept")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPickerView { image in
                    if let img = image { photoData = img.jpegData(compressionQuality: 0.8) }
                }
            }
            .confirmationDialog("Rezept löschen?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Löschen", role: .destructive) {
                    if let r = existingRecipe {
                        state.userRecipes.removeAll { $0.id == r.id }
                    }
                    dismiss()
                }
            }
        }
        .onAppear { loadExisting() }
    }

    // MARK: - Sections

    @ViewBuilder
    private var photoSection: some View {
        Section {
            ZStack {
                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable().scaledToFill()
                        .frame(maxWidth: .infinity).frame(height: 200)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Theme.cream)
                        .frame(height: 200)
                    VStack(spacing: 8) {
                        Text(emoji).font(.system(size: 60))
                        Text("Foto hinzufügen").font(.system(size: 13)).foregroundColor(Theme.muted)
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .contentShape(Rectangle())

            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Mediathek", systemImage: "photo.on.rectangle")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                }
                .onChange(of: selectedPhoto) { _, item in
                    Task {
                        if let data = try? await item?.loadTransferable(type: Data.self) {
                            photoData = data
                        }
                    }
                }

                Divider().frame(height: 28)

                Button {
                    showCamera = true
                } label: {
                    Label("Kamera", systemImage: "camera")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                }

                if photoData != nil {
                    Divider().frame(height: 28)
                    Button(role: .destructive) {
                        photoData = nil
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                    }
                }
            }
            .buttonStyle(.borderless)
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private var basicSection: some View {
        Section {
            HStack(spacing: 10) {
                TextField("🍽", text: $emoji)
                    .frame(width: 52)
                    .font(.system(size: 28))
                    .multilineTextAlignment(.center)
                TextField("Rezeptname", text: $name)
                    .font(.system(size: 15, weight: .semibold))
            }
            HStack {
                Image(systemName: "clock").foregroundColor(Theme.muted).font(.system(size: 13))
                TextField("30", text: $time)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                Text("Minuten").foregroundColor(Theme.muted).font(.system(size: 13))
            }
            HStack {
                Image(systemName: "fork.knife").foregroundColor(Theme.muted).font(.system(size: 13))
                TextField("Küche (z.B. Italienisch)", text: $category)
                    .font(.system(size: 14))
            }
            HStack(alignment: .top) {
                Image(systemName: "text.alignleft").foregroundColor(Theme.muted).font(.system(size: 13)).padding(.top, 2)
                TextField("Kurzbeschreibung", text: $desc, axis: .vertical)
                    .font(.system(size: 14))
                    .lineLimit(2...5)
            }
            Toggle(isOn: $isBatch) {
                Label("Batch Cook (einfrierbar)", systemImage: "snowflake")
                    .font(.system(size: 14))
            }
        } header: {
            Text("Grundinfos")
        }
    }

    @ViewBuilder
    private var ingredientsSection: some View {
        Section {
            ForEach(ingredients.indices, id: \.self) { i in
                HStack(spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5))
                        .foregroundColor(Theme.amber)
                    TextField("z.B. 200g Pasta", text: $ingredients[i])
                        .font(.system(size: 14))
                    if ingredients.count > 1 {
                        Button {
                            ingredients.remove(at: i)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red.opacity(0.7))
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            Button {
                ingredients.append("")
            } label: {
                Label("Zutat hinzufügen", systemImage: "plus.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.amber)
            }
        } header: {
            Text("Zutaten")
        }
    }

    @ViewBuilder
    private var stepsSection: some View {
        Section {
            ForEach(steps.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(i + 1)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.amber)
                        .frame(width: 22, height: 22)
                        .background(Theme.amber.opacity(0.12))
                        .clipShape(Circle())
                        .padding(.top, 2)
                    TextField("Schritt beschreiben…", text: $steps[i], axis: .vertical)
                        .font(.system(size: 14))
                        .lineLimit(2...6)
                    if steps.count > 1 {
                        Button {
                            steps.remove(at: i)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red.opacity(0.7))
                        }
                        .buttonStyle(.borderless)
                        .padding(.top, 2)
                    }
                }
            }
            Button {
                steps.append("")
            } label: {
                Label("Schritt hinzufügen", systemImage: "plus.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.amber)
            }
        } header: {
            Text("Zubereitung")
        }
    }

    @ViewBuilder
    private var mealTypeSection: some View {
        Section {
            let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(state.mealTypes) { mt in
                    let isOn = selectedMealTypes.contains(mt.name)
                    HStack(spacing: 5) {
                        Text(mt.emoji).font(.system(size: 13))
                        Text(mt.name).font(.system(size: 12, weight: isOn ? .semibold : .regular))
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background(isOn ? Theme.amber : Theme.cream)
                    .foregroundColor(isOn ? .white : Theme.dark)
                    .cornerRadius(14)
                    .onTapGesture {
                        if isOn { selectedMealTypes.removeAll { $0 == mt.name } }
                        else    { selectedMealTypes.append(mt.name) }
                    }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Passt zu (Mahlzeit-Kategorie)")
        } footer: {
            Text("Wähle eine oder mehrere Kategorien — für die Filterung in \"Meine Rezepte\".")
                .font(.caption)
        }
    }

    @ViewBuilder
    private var nutritionSection: some View {
        Section {
            nutritionRow(label: "Kalorien", unit: "kcal", binding: $kcalStr)
            nutritionRow(label: "Eiweiß",   unit: "g",    binding: $proteinStr)
            nutritionRow(label: "Fett",     unit: "g",    binding: $fatStr)
            nutritionRow(label: "Kohlenhydrate", unit: "g", binding: $carbsStr)
        } header: {
            Text("Nährwerte (pro Portion)")
        }
    }

    @ViewBuilder
    private func nutritionRow(label: String, unit: String, binding: Binding<String>) -> some View {
        HStack {
            Text(label).font(.system(size: 14))
            Spacer()
            TextField("–", text: binding)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
                .font(.system(size: 14))
            Text(unit).foregroundColor(Theme.muted).font(.system(size: 13)).frame(width: 26, alignment: .leading)
        }
    }

    @ViewBuilder
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                HStack {
                    Spacer()
                    Text("Rezept löschen")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                }
            }
        }
    }

    // MARK: - Helpers

    private func loadExisting() {
        guard let r = existingRecipe else { return }
        name       = r.name
        emoji      = r.emoji
        time       = "\(r.time)"
        category   = r.category
        desc       = r.desc
        isBatch    = r.isBatch
        kcalStr    = r.kcal.map    { "\($0)" } ?? ""
        proteinStr = r.protein.map { "\($0)" } ?? ""
        fatStr     = r.fat.map     { "\($0)" } ?? ""
        carbsStr   = r.carbs.map   { "\($0)" } ?? ""
        steps             = r.steps.isEmpty ? [""] : r.steps
        ingredients       = r.detailIngredients.isEmpty ? [""] : r.detailIngredients
        photoData         = r.photoData
        selectedMealTypes = r.mealTypes
    }

    private func save() {
        let cleanName  = name.trimmingCharacters(in: .whitespaces)
        guard !cleanName.isEmpty else { return }
        let cleanEmoji = emoji.isEmpty ? "🍽" : emoji
        let cleanSteps = steps.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let cleanIngredients = ingredients.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        var recipe = Recipe(
            id:       existingRecipe?.id ?? Int(Date().timeIntervalSince1970),
            name:     cleanName,
            time:     Int(time) ?? 30,
            match:    100,
            uses:     cleanIngredients.prefix(3).map { $0 },
            category: category.trimmingCharacters(in: .whitespaces).isEmpty ? "Eigenes" : category,
            emoji:    cleanEmoji,
            isBatch:  isBatch,
            desc:     desc.trimmingCharacters(in: .whitespaces)
        )
        recipe.kcal    = Int(kcalStr)
        recipe.protein = Int(proteinStr)
        recipe.fat     = Int(fatStr)
        recipe.carbs   = Int(carbsStr)
        recipe.steps              = cleanSteps
        recipe.detailIngredients  = cleanIngredients
        recipe.photoData          = photoData
        recipe.isFavorite         = existingRecipe?.isFavorite ?? false
        recipe.mealTypes          = selectedMealTypes

        if let cb = onSave {
            cb(recipe)
        } else if let existing = existingRecipe,
                  let i = state.userRecipes.firstIndex(where: { $0.id == existing.id }) {
            state.userRecipes[i] = recipe
        } else {
            state.userRecipes.insert(recipe, at: 0)
        }
        dismiss()
    }
}

// MARK: - Camera Picker
struct CameraPickerView: UIViewControllerRepresentable {
    var onImage: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onImage: onImage) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImage: (UIImage?) -> Void
        init(onImage: @escaping (UIImage?) -> Void) { self.onImage = onImage }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            onImage(img)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onImage(nil)
            picker.dismiss(animated: true)
        }
    }
}
