import SwiftUI

struct BlockedUsersView: View {

    @StateObject private var viewModel = BlockedUsersViewModel()
    @State private var userToUnblock: BlockedUser?
    @State private var showUnblockAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Text("Zablokovaní uživatelé")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                if viewModel.isLoading {
                    LoadingStateView(defaultMessage: "Načítám...")
                }

                if let error = viewModel.errorMessage {
                    ErrorRetryView(message: error) {
                        Task {
                            await viewModel.loadBlockedUsers()
                        }
                    }
                }

                if !viewModel.isLoading && viewModel.blockedUsers.isEmpty {
                    Text("Nikoho jsi nezablokoval/a.")
                        .foregroundStyle(AppTheme.mutedText)
                        .padding(.horizontal)
                }

                VStack(spacing: 10) {
                    ForEach(viewModel.blockedUsers) { user in
                        HStack {
                            Text(user.username)
                                .font(.headline)
                                .foregroundStyle(AppTheme.text)

                            Spacer()

                            Button("Odblokovat") {
                                userToUnblock = user
                                showUnblockAlert = true
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(AppTheme.background)
        .task {
            await viewModel.loadBlockedUsers()
        }
        .alert("Opravdu odblokovat uživatele \(userToUnblock?.username ?? "")?", isPresented: $showUnblockAlert) {
            Button("Zrušit", role: .cancel) {}
            Button("Odblokovat") {
                if let userToUnblock {
                    Task {
                        await viewModel.unblock(userToUnblock)
                    }
                }
            }
        } message: {
            Text("Jeho recepty se ti znovu začnou zobrazovat.")
        }
    }
}

#Preview {
    NavigationStack {
        BlockedUsersView()
    }
}
