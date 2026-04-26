import Foundation

// MARK: - Auth

struct AuthResponse: Codable {
    let success: Bool
    let token: String?
    let nickname: String?
    let error: String?
}

// MARK: - Prediction

struct PredictionResult: Codable {
    let score: Double
    let label: String
    let confidence: Double
    let factors: [String: Double]
}

struct HourlyPoint: Codable, Identifiable {
    let hour: Int
    let score: Double
    let label: String
    var id: Int { hour }
}

struct DayResponse: Codable {
    let success: Bool
    let hourly: [HourlyPoint]
}

// MARK: - Spots

struct FishingSpot: Codable, Identifiable {
    let id: Int
    let name: String
    let lat: Double
    let lon: Double
    let description: String
    let sourceUrl: String
    let likes: Int
    let species: String
    let catchResult: String
    let addedBy: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, lat, lon, description, likes, species
        case sourceUrl = "source_url"
        case catchResult = "catch_result"
        case addedBy = "added_by"
        case createdAt = "created_at"
    }
}

struct SpotsResponse: Codable {
    let success: Bool
    let spots: [FishingSpot]
}
