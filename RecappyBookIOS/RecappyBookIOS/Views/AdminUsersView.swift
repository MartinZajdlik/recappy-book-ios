import SwiftUI

struct AdminUsersView: View {
    
    @StateObject private var viewModel = AdminUsersViewModel()
    @State private var userToDelete: AdminUser?
    @State private var showDeleteAlert = false
    
    @State private var userToChangeRole: AdminUser?
    @State private var selectedRole = ""
    @State private var showRoleAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("Správa uživatelů")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView("Načítám uživatele...")
                    .foregroundStyle(AppTheme.text)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            
            LazyVStack(spacing: 14) {
                ForEach(viewModel.users) { user in
                    AdminUserCardView(
                        user: user,
                        onRoleChange: { newRole in
                            userToChangeRole = user
                            selectedRole = newRole
                            showRoleAlert = true
                        },
                        onDelete: {
                            userToDelete = user
                            showDeleteAlert = true
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .task {
            await viewModel.loadUsers()
        }
        .alert("Smazat uživatele?", isPresented: $showDeleteAlert) {
            Button("Zrušit", role: .cancel) {}

            Button("Smazat", role: .destructive) {
                if let user = userToDelete {
                    Task {
                        await viewModel.deleteUser(user)
                        userToDelete = nil
                    }
                }
            }
        } message: {
            Text("Opravdu chceš smazat tohoto uživatele?")
        }
        
        .alert("Změnit roli?", isPresented: $showRoleAlert) {
            
            Button("Zrušit", role: .cancel) {}

            Button("Potvrdit") {
                if let user = userToChangeRole {
                    Task {
                        await viewModel.changeRole(for: user, to: selectedRole)
                        userToChangeRole = nil
                    }
                }
            }
            
        } message: {
            Text("Opravdu chceš změnit roli uživatele?")
        }
    }
}

struct AdminUserCardView: View {
    
    let user: AdminUser
    let onRoleChange: (String) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.username)
                        .font(.headline)
                        .foregroundStyle(AppTheme.text)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedText)
                }
                
                Spacer()
                
                Text(user.role.replacingOccurrences(of: "ROLE_", with: ""))
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(user.role == "ROLE_ADMIN" ? AppTheme.blue : AppTheme.categoryCard)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 10) {
                Button("USER") {
                    onRoleChange("ROLE_USER")
                }
                .buttonStyle(.bordered)
                
                Button("ADMIN") {
                    onRoleChange("ROLE_ADMIN")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Text("Smazat")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    AdminUsersView()
        .background(AppTheme.background)
}
