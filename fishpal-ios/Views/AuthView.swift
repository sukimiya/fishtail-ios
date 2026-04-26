import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var tab = 0
    @State private var nickname = ""
    @State private var inviteCode = ""

    var body: some View {
        ZStack {
            Color.fishBG.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Text("🎣").font(.system(size: 72))
                    Text("FishPal")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.fishText)
                    Text("个人鱼情预测")
                        .foregroundStyle(Color.fishMuted)
                }

                // Tabs
                Picker("", selection: $tab) {
                    Text("登录").tag(0)
                    Text("注册").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Form
                VStack(spacing: 12) {
                    darkTextField("昵称", text: $nickname)
                        .textInputAutocapitalization(.never)

                    if tab == 1 {
                        darkTextField("邀请码", text: $inviteCode)
                            .textInputAutocapitalization(.characters)
                    }

                    if let err = vm.errorMessage {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }

                    Button {
                        Task {
                            if tab == 0 {
                                await vm.login(nickname: nickname)
                            } else {
                                await vm.register(nickname: nickname, inviteCode: inviteCode)
                            }
                        }
                    } label: {
                        Group {
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(tab == 0 ? "登录" : "注册")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 48)
                    }
                    .background(vm.isLoading || nickname.isEmpty || (tab == 1 && inviteCode.isEmpty)
                        ? Color.fishBlue.opacity(0.4) : Color.fishBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(vm.isLoading || nickname.isEmpty || (tab == 1 && inviteCode.isEmpty))
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .onChange(of: tab) { _, _ in vm.errorMessage = nil }
    }

    private func darkTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .autocorrectionDisabled()
            .foregroundStyle(Color.fishText)
            .padding(14)
            .background(Color.fishInput)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.fishBorder))
    }
}

#Preview {
    AuthView().environmentObject(AppViewModel())
}
