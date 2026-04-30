import SwiftUI

struct HourlyBarView: View {
    let hourly: [HourlyPoint]
    private let currentHour = Calendar.current.component(.hour, from: Date())

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("全天鱼情走势", systemImage: "chart.xyaxis.line")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.fishMuted)
                .padding(.horizontal, 4)

            ScrollViewReader { scroll in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(hourly) { h in
                            barCell(h).id(h.hour)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)
                    .padding(.top, 20)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        scroll.scrollTo(currentHour, anchor: .center)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.fishBorder))
    }

    private func barCell(_ h: HourlyPoint) -> some View {
        let isCurrent = h.hour == currentHour
        let barH = max(6, CGFloat(h.score) * 64)
        let color = Color.scoreColor(for: h.score)

        return VStack(spacing: 5) {
            if isCurrent {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.fishBlue)
            } else {
                Text("\(Int(h.score * 100))")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.fishMuted)
            }

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.fishTrack)
                    .frame(width: 22, height: 64)
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.7), color],
                            startPoint: .bottom, endPoint: .top
                        )
                    )
                    .frame(width: 22, height: barH)
            }

            Text(String(format: "%02d", h.hour))
                .font(.system(size: 9, weight: isCurrent ? .bold : .regular))
                .foregroundStyle(isCurrent ? Color.fishBlue : Color.fishMuted)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 3)
        .background(isCurrent ? Color.fishBlue.opacity(0.12) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            isCurrent
                ? RoundedRectangle(cornerRadius: 10).stroke(Color.fishBlue.opacity(0.4), lineWidth: 1)
                : nil
        )
    }
}
