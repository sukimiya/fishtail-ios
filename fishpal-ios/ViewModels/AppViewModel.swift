import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var nickname = ""
    @Published var prediction: PredictionResult?
    @Published var hourly: [HourlyPoint] = []
    @Published var spots: [FishingSpot] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        if let token = UserDefaults.standard.string(forKey: "auth_token"),
           let nick = UserDefaults.standard.string(forKey: "nickname"),
           !token.isEmpty {
            isAuthenticated = true
            nickname = nick
        }
    }

    func login(nickname: String) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            let r = try await APIClient.shared.login(nickname: nickname)
            if r.success, let token = r.token, let nick = r.nickname {
                persist(token: token, nickname: nick)
            } else {
                errorMessage = r.error ?? "登录失败"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(nickname: String, inviteCode: String) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            let r = try await APIClient.shared.register(nickname: nickname, inviteCode: inviteCode)
            if r.success, let token = r.token, let nick = r.nickname {
                persist(token: token, nickname: nick)
            } else {
                errorMessage = r.error ?? "注册失败"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchPrediction(lat: Double, lon: Double) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let p = APIClient.shared.predict(lat: lat, lon: lon)
            async let d = APIClient.shared.predictDay(lat: lat, lon: lon)
            let (pred, day) = try await (p, d)
            prediction = pred
            hourly = day.hourly
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchSpots() async {
        do {
            let r = try await APIClient.shared.fetchSpots()
            spots = r.spots
        } catch {}
    }

    /// 静默自动登录，供启动时使用
    /// - 有本地昵称则沿用，否则生成 fp{12位随机数字}
    func autoLogin() async {
        guard !isAuthenticated else { return }

        let nick = UserDefaults.standard.string(forKey: "nickname") ?? Self.generateNickname()

        // 先尝试登录（服务器有记录时直接拿 token）
        if let r = try? await APIClient.shared.login(nickname: nick),
           r.success, let token = r.token, let name = r.nickname {
            persist(token: token, nickname: name)
            return
        }

        // 登录失败（服务器重启后内存清空），重新注册
        if let r = try? await APIClient.shared.register(nickname: nick, inviteCode: "FISHING_PAL_2026"),
           r.success, let token = r.token, let name = r.nickname {
            persist(token: token, nickname: name)
        }
    }

    private static func generateNickname() -> String {
        let digits = (0..<12).map { _ in String(Int.random(in: 0...9)) }.joined()
        return "fp\(digits)"
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "nickname")
        isAuthenticated = false
        nickname = ""
        prediction = nil
        hourly = []
    }

    private func persist(token: String, nickname: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
        UserDefaults.standard.set(nickname, forKey: "nickname")
        self.nickname = nickname
        self.isAuthenticated = true
    }
}
