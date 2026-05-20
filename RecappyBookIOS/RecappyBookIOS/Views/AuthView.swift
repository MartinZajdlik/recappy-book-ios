import SwiftUI

struct AuthView: View {
    
    @ObservedObject var viewModel: AuthViewModel
    @State private var isRegisterMode = false
    @State private var showForgotPassword = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            HeaderView(onLogoTap: {})
            
        
            HStack(spacing: 12) {
                authTabButton(title: "Přihlásit", isActive: !isRegisterMode) {
                    isRegisterMode = false
                }
                
                authTabButton(title: "Registrovat", isActive: isRegisterMode) {
                    isRegisterMode = true
                }
            }
            
            VStack(spacing: 18) {
                TextField("Uživatelské jméno", text: $viewModel.username)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding()
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(AppTheme.text)
                
                if isRegisterMode {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(AppTheme.text)
                }
                
                SecureField("Heslo", text: $viewModel.password)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(AppTheme.text)
                
                Button {
                    Task {
                        if isRegisterMode {
                            await viewModel.register()
                        } else {
                            await viewModel.login()
                        }
                    }
                } label: {
                    Text(isRegisterMode ? "Registrovat" : "Přihlásit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(viewModel.isLoading)
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            
            if !viewModel.successMessage.isEmpty {
                Text(viewModel.successMessage)
                    .foregroundStyle(AppTheme.accent)
                    .multilineTextAlignment(.center)
            }
            
            Button("Zapomněli jste heslo?") {
                showForgotPassword.toggle()
            }
            .foregroundStyle(AppTheme.blue)
            
            if showForgotPassword {
                VStack(spacing: 12) {
                    TextField("E-mail pro reset hesla", text: $viewModel.email)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(AppTheme.text)
                    
                    Button {
                        Task {
                            await viewModel.forgotPassword()
                        }
                    } label: {
                        Text("Poslat odkaz pro reset")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            
            Spacer()
            
            FooterView()
        }
        .padding()
        .background(AppTheme.background)
    }
    
    private func authTabButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(width: 150)
                .padding(.vertical, 12)
                .background(isActive ? AppTheme.green : AppTheme.card)
                .foregroundStyle(isActive ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
