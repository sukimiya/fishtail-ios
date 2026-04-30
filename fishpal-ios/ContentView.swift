import SwiftUI

struct ContentView: View {
    @StateObject private var vm = AppViewModel()
    @State private var isReady = false

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(Color.fishBG.opacity(0.85))
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = UIColor(Color.fishBlue)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.fishMuted)
    }

    var body: some View {
        Group {
            if isReady {
                TabView {
                    PredictView()
                        .tabItem { Label("预测", systemImage: "fish.fill") }
                    MapView()
                        .tabItem { Label("地图", systemImage: "map.fill") }
                    LogView()
                        .tabItem { Label("记录", systemImage: "book.fill") }
                    ProfileView()
                        .tabItem { Label("我的", systemImage: "person.fill") }
                }
            } else {
                splashView
            }
        }
        .environmentObject(vm)
        .preferredColorScheme(.dark)
        .task {
            await vm.autoLogin()
            isReady = true
        }
    }

    private var splashView: some View {
        ZStack {
            Color.fishBG.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("🎣")
                    .font(.system(size: 72))
                Text("FishPal")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.fishBlue)
                ProgressView()
                    .tint(Color.fishBlue)
                    .scaleEffect(1.2)
            }
        }
    }
}

#Preview {
    ContentView()
}
