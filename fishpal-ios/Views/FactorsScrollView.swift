import SwiftUI

struct FactorsScrollView: View {
    let factors: [String: Double]

    private static let meta: [(key: String, name: String, icon: String)] = [
        ("temperature",       "水温", "thermometer.medium"),
        ("pressure",          "气压", "gauge.medium"),
        ("time_of_day",       "时段", "clock"),
        ("moon_phase",        "月相", "moon.stars"),
        ("season",            "季节", "leaf"),
        ("weather_condition", "天气", "cloud.sun.fill"),
        ("wind",              "风力", "wind"),
        ("water_level",       "水位", "water.waves"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("环境因子", systemImage: "chart.bar.xaxis")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.fishMuted)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Self.meta, id: \.key) { item in
                        if let val = factors[item.key] {
                            factorCard(icon: item.icon, name: item.name, value: val)
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.fishBorder))
    }

    private func factorCard(icon: String, name: String, value: Double) -> some View {
        let color = Color.scoreColor(for: value)
        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.fishTrack, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
            .frame(width: 44, height: 44)

            Text("\(Int(value * 100))%")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.fishText)
            Text(name)
                .font(.system(size: 10))
                .foregroundStyle(Color.fishMuted)
        }
        .frame(width: 68)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color.fishInput)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.fishBorder))
    }
}
