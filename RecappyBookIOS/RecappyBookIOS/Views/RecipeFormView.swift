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
    
    var isEditMode: Bool {
        recipe != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                
                Text(isEditMode ? "Upravit recept" : "Přidat recept")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Název receptu", text: $title)
                    .textFieldStyle(.plain)
                    .padding()
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
                
                TextEditor(text: $ingredients)
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
                
                TextEditor(text: $instructions)
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
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
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
                    Text(isEditMode ? "Uložit změny" : "Přidat recept")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.green)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if isSaving {
                    ProgressView("Ukládám recept...")
                        .foregroundStyle(AppTheme.text)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
        .background(AppTheme.background)
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
                    selectedImageData = data
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
                _ = try await APIService.shared.createRecipe(
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
