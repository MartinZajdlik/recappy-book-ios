import SwiftUI

struct AdminView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab: AdminTab = .recipes
    
    enum AdminTab {
        case recipes
        case users
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    HeaderView(
                        username: UserDefaults.standard.string(forKey: "currentUsername"),
                        showUserControls: true,
                        onLogoTap: {},
                        onLogoutTap: {
                            authViewModel.logout()
                        }
                    )
                    
                    HStack(spacing: 12) {
                        adminTabButton(title: "📋 Recepty", tab: .recipes)
                        adminTabButton(title: "👤 Uživatelé", tab: .users)
                    }
                    .padding(.horizontal)
                    
                    if selectedTab == .recipes {
                        adminRecipesSection
                    } else {
                        adminUsersSection
                    }
                }
                .padding(.top, 35)
                .padding(.bottom, 90)
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                FooterView()
                    .background(AppTheme.background)
            }
        }
    }
    
    private var adminRecipesSection: some View {
        VStack(spacing: 18) {
            
            Button {
                print("Přidat recept později")
            } label: {
                Text("+ Přidat recept")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.green)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Text("Správa receptů")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Text("Tady později zobrazíme kategorie, editaci a mazání receptů.")
                .foregroundStyle(AppTheme.mutedText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
    }
    
    private var adminUsersSection: some View {
        AdminUsersView()
    }
    
    private func adminTabButton(title: String, tab: AdminTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == tab ? AppTheme.green : AppTheme.card)
                .foregroundStyle(selectedTab == tab ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    AdminView(authViewModel: AuthViewModel())
}
