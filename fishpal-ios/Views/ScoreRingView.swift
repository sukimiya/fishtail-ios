import SwiftUI

struct ScoreRingView: View {
    let prediction: PredictionResult

    private var scoreColor: Color {
        switch prediction.score {
        case 0.7...: return Color(red: 0.298, green: 0.686, blue: 0.314) // #4caf50
        case 0.55...: return Color(red: 0.298, green: 0.686, blue: 0.314)
        case 0.4...: return Color(red: 1.0, green: 0.596, blue: 0.0)     // #ff9800
        default: return Color(red: 0.957, green: 0.263, blue: 0.212)     // #f44336
        }
    }

    private static let factorNames: [String: String] = [
        "temperature": "水温", "pressure": "气压", "time_of_day": "时段",
        "moon_phase": "月相", "season": "季节", "weather_condition": "天气",
        "wind": "风力", "water_level": "水位"
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Ring
            ZStack {
                Circle()
                    .stroke(Color.fishTrack, lineWidth: 18)
                Circle()
                    .trim(from: 0, to: prediction.score)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: prediction.score)
                VStack(spacing: 4) {
                    Text("\(Int(prediction.score * 100))%")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                    Text(prediction.label)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.fishMuted)
                }
            }
            .frame(width: 150, height: 150)

            Text("置信度 \(Int(prediction.confidence * 100))%")
                .font(.caption).foregroundStyle(Color.fishMuted)

            // Factors
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(prediction.factors.sorted(by: { $0.key < $1.key }), id: \.key) { key, val in
                    VStack(spacing: 2) {
                        Text(Self.factorNames[key] ?? key)
                            .font(.caption2).foregroundStyle(Color.fishMuted)
                        Text("\(Int(val * 100))%")
                            .font(.headline.bold())
                            .foregroundStyle(Color.fishText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.fishInput)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.fishBorder))
                }
            }
        }
        .padding(20)
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.fishBorder))
    }
}
