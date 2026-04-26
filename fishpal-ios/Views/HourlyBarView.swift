import SwiftUI

struct HourlyBarView: View {
    let hourly: [HourlyPoint]
    private let currentHour = Calendar.current.component(.hour, from: Date())

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⏰ 全天鱼情走势")
                .font(.headline)
                .foregroundStyle(Color.fishMuted)

            ScrollViewReader { scroll in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(hourly) { h in
                            cell(h).id(h.hour)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
                }
                .onAppear {
                    withAnimation { scroll.scrollTo(currentHour, anchor: .center) }
                }
            }
        }
        .padding(16)
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.fishBorder))
    }

    private func cell(_ h: HourlyPoint) -> some View {
        let isCurrent = h.hour == currentHour
        let barH = max(4, CGFloat(h.score) * 56)
        let color: Color = h.score >= 0.7
            ? Color(red: 0.298, green: 0.686, blue: 0.314)
            : h.score >= 0.4 ? Color(red: 1.0, green: 0.596, blue: 0.0)
            : Color(red: 0.957, green: 0.263, blue: 0.212)

        return VStack(spacing: 4) {
            Text("\(Int(h.score * 100))%")
                .font(.system(size: 9))
                .foregroundStyle(Color.fishMuted)
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.fishTrack)
                    .frame(width: 24, height: 56)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 24, height: barH)
            }
            Text(String(format: "%02d", h.hour))
                .font(.system(size: 9))
                .foregroundStyle(Color.fishMuted)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 3)
        .background(isCurrent ? Color.fishBlue.opacity(0.15) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
