import SwiftUI

struct ContentView: View {
    @StateObject private var vm = AppViewModel()
    @State private var isReady = false

    var body: some View {
        Group {
            if isReady {
                TabView {
                    PredictView()
                        .tabItem { Label("鱼情", systemImage: "fish.fill") }
                    ShareView()
                        .tabItem { Label("分享", systemImage: "photo.on.rectangle") }
                }
            } else {
                ZStack {
                    Color.fishBG.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Text("🎣").font(.system(size: 64))
                        ProgressView().tint(Color.fishBlue)
                    }
                }
            }
        }
        .environmentObject(vm)
        .preferredColorScheme(.dark)
        .task {
            await vm.autoLogin()
            isReady = true
        }
    }
}

#Preview {
    ContentView()
}
