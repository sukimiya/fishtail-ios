import Foundation

// 本地开发用 localhost；真机测试改成 Mac 的局域网 IP，例如 "http://192.168.1.100:9090"
private let kBaseURL = "https://fishpal.avacha.cloud"

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private var token: String? {
        UserDefaults.standard.string(forKey: "auth_token")
    }

    // MARK: - Auth

    func login(nickname: String) async throws -> AuthResponse {
        try await post("/auth/login", body: ["nickname": nickname])
    }

    func register(nickname: String, inviteCode: String) async throws -> AuthResponse {
        try await post("/auth/register", body: ["nickname": nickname, "invite_code": inviteCode])
    }

    // MARK: - Prediction

    func predict(lat: Double, lon: Double) async throws -> PredictionResult {
        try await get("/predict?lat=\(lat)&lon=\(lon)")
    }

    func predictDay(lat: Double, lon: Double) async throws -> DayResponse {
        try await get("/predict/day?lat=\(lat)&lon=\(lon)")
    }

    // MARK: - Spots

    func fetchSpots() async throws -> SpotsResponse {
        try await get("/api/spots")
    }

    // MARK: - Helpers

    private func get<T: Decodable>(_ path: String) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: try makeRequest(path))
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func post<T: Decodable>(_ path: String, body: [String: Any]) async throws -> T {
        var req = try makeRequest(path)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func makeRequest(_ path: String) throws -> URLRequest {
        guard let url = URL(string: kBaseURL + path) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }
}
