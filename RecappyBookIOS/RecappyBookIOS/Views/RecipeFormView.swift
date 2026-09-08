import SwiftUI
import PhotosUI

struct RecipeFormView: View {
    
    let recipe: Recipe?
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var category = "Polévky"
    @State private var ingredients = ""
    @State private var instructions = ""
    @State private var showSaveAlert = false
    @State private var errorMessage: String?
    @State private var isSaving = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    let categories = ["Polévky", "Hlavní jídla", "Dezerty", "Snídaně", "Ostatní"]

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isPad: Bool { horizontalSizeClass == .regular }
    private var contentMaxWidth: CGFloat? { isPad ? 940 : nil }
    private var fieldFont: Font? { isPad ? .title3 : nil }
    
    var isEditMode: Bool {
        recipe != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: isPad ? 22 : 18) {
                
                Text(isEditMode ? "Upravit recept" : "Přidat recept")
                    .font(isPad ? .largeTitle.bold() : .title2.bold())
                    .foregroundStyle(AppTheme.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Název receptu", text: $title)
                    .textFieldStyle(.plain)
                    .font(fieldFont)
                    .padding(isPad ? 18 : 12)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(AppTheme.text)
                
                Picker("Kategorie", selection: $category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(AppTheme.text)
                
                VStack(alignment: .leading, spacing: 4) {
                    TextEditor(text: $ingredients)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(AppTheme.text)
                        .overlay(alignment: .topLeading) {
                            if ingredients.isEmpty {
                                Text("Ingredience oddělené čárkou")
                                    .foregroundStyle(AppTheme.mutedText)
                                    .padding(.top, 16)
                                    .padding(.leading, 14)
                            }
                        }

                    Text("Ingredience odděluj čárkou, např.: mouka, cukr, vejce")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                        .padding(.leading, 4)
                }

                TextEditor(text: $instructions)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160)
                    .padding(8)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(AppTheme.text)
                    .overlay(alignment: .topLeading) {
                        if instructions.isEmpty {
                            Text("Postup")
                                .foregroundStyle(AppTheme.mutedText)
                                .padding(.top, 16)
                                .padding(.leading, 14)
                        }
                    }
                
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    HStack {
                        Image(systemName: "camera")
                        Text(selectedImageData == nil ? "Vybrat obrázek" : "Obrázek vybrán")
                    }
                    .font(isPad ? .title3.weight(.semibold) : .headline)
                    .frame(maxWidth: .infinity)
                    .padding(isPad ? 18 : 12)
                    .background(AppTheme.card)
                    .foregroundStyle(AppTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button {
                    showSaveAlert = true
                } label: {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(isEditMode ? "Uložit změny" : "Přidat recept")
                            .font(isPad ? .title3.weight(.semibold) : .headline)
                            .frame(maxWidth: .infinity)
                            .padding(isPad ? 18 : 12)
                    }
                }
                .background(AppTheme.green)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(isSaving)


                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .frame(maxWidth: contentMaxWidth)
        }
        .frame(maxWidth: .infinity)
        .background(AppTheme.background)
        .dismissKeyboardOnTap()
        .onAppear {
            if let recipe {
                title = recipe.title
                category = recipe.category ?? "Polévky"
                ingredients = recipe.ingredients ?? ""
                instructions = recipe.instructions ?? ""
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = compressImageData(data)
                }
            }
        }
        .alert(isEditMode ? "Uložit změny?" : "Přidat recept?", isPresented: $showSaveAlert) {
            Button("Zrušit", role: .cancel) {}

            Button(isEditMode ? "Uložit" : "Přidat") {
                Task {
                    await saveRecipe()
                }
            }
        } message: {
            Text(isEditMode ? "Opravdu chceš uložit změny receptu?" : "Opravdu chceš přidat nový recept?")
        }
    }
    
        private func saveRecipe() async {
            isSaving = true
            errorMessage = nil
            
            guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Vyplň název receptu."
                isSaving = false
                return
            }

            guard !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Vyplň ingredience."
                isSaving = false
                return
            }

            guard !instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Vyplň postup."
                isSaving = false
                return
            }

            guard selectedImageData != nil || isEditMode else {
                errorMessage = "Vyber obrázek receptu."
                isSaving = false
                return
            }
            
            defer {
                isSaving = false
            }
            
            do {
            if let recipe {
                _ = try await APIService.shared.updateRecipe(
                    id: recipe.id,
                    title: title,
                    category: category,
                    ingredients: ingredients,
                    instructions: instructions,
                    imageData: selectedImageData
                )
            } else {
                try await APIService.shared.createRecipe(
                    title: title,
                    category: category,
                    ingredients: ingredients,
                    instructions: instructions,
                    imageData: selectedImageData
                )
            }
            
            onSave()
            dismiss()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
}


#Preview {
    RecipeFormView(recipe: nil, onSave: {})
}
private func compressImageData(_ data: Data) -> Data? {
    guard let image = UIImage(data: data) else {
        return nil
    }
    
    let maxWidth: CGFloat = 1200
    let scale = maxWidth / image.size.width
    
    let newSize: CGSize
    
    if image.size.width > maxWidth {
        newSize = CGSize(
            width: maxWidth,
            height: image.size.height * scale
        )
    } else {
        newSize = image.size
    }
    
    let renderer = UIGraphicsImageRenderer(size: newSize)
    
    let resizedImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
    
    return resizedImage.jpegData(compressionQuality: 0.7)
}
