import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var vm: AppViewModel
    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fishBG.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        avatarSection
                        statsSection
                        settingsSection
                        versionSection
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.large)
        }
        .confirmationDialog("确定退出登录？", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("退出登录", role: .destructive) { vm.logout() }
            Button("取消", role: .cancel) {}
        }
    }

    // MARK: - Avatar

    private var avatarSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.fishBlue, Color.fishBlue.opacity(0.5)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Text(avatarInitials)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color.fishBlue.opacity(0.4), radius: 12)

            VStack(spacing: 4) {
                Text(vm.nickname)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.fishText)
                Text("钓鱼爱好者")
                    .font(.caption)
                    .foregroundStyle(Color.fishMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            ZStack {
                Color.fishCard
                LinearGradient(
                    colors: [Color.fishBlue.opacity(0.1), .clear],
                    startPoint: .top, endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.fishBorder))
    }

    private var avatarInitials: String {
        let nick = vm.nickname
        if nick.hasPrefix("fp") {
            return "🎣"
        }
        return String(nick.prefix(2)).uppercased()
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(value: "-", label: "查询次数", icon: "chart.bar.fill", color: .fishBlue)
            statCard(value: "-", label: "渔获记录", icon: "fish.fill", color: .fishGreen)
            statCard(value: "-", label: "钓点收藏", icon: "heart.fill", color: .fishRed)
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 20))
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.fishText)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.fishMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fishBorder))
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(spacing: 1) {
            menuRow(icon: "bell.fill", label: "鱼情通知", color: .fishOrange) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.fishMuted)
            }
            menuRow(icon: "shield.fill", label: "隐私政策", color: .fishBlue) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.fishMuted)
            }
            menuRow(icon: "rectangle.portrait.and.arrow.right", label: "退出登录", color: .fishRed) {
                EmptyView()
            } action: {
                showLogoutConfirm = true
            }
        }
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fishBorder))
    }

    private func menuRow<T: View>(icon: String, label: String, color: Color, @ViewBuilder trailing: () -> T, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 28)
                Text(label)
                    .foregroundStyle(Color.fishText)
                    .font(.system(size: 15))
                Spacer()
                trailing()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .disabled(action == nil)
    }

    // MARK: - Version

    private var versionSection: some View {
        VStack(spacing: 4) {
            Text("FishPal")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.fishMuted)
            Text("v1.0.0")
                .font(.caption2)
                .foregroundStyle(Color.fishMuted.opacity(0.6))
        }
        .padding(.top, 8)
    }
}

#Preview {
    ProfileView().environmentObject(AppViewModel())
}
