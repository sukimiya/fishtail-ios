import SwiftUI

struct ScoreRingView: View {
    let prediction: PredictionResult
    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.fishTrack, lineWidth: 22)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: animatedScore)
                    .stroke(
                        AngularGradient(
                            colors: [scoreColor.opacity(0.6), scoreColor],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 180, height: 180)

                VStack(spacing: 6) {
                    Text("\(Int(prediction.score * 100))")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                    Text(prediction.label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.fishMuted)
                    Text("置信度 \(Int(prediction.confidence * 100))%")
                        .font(.caption2)
                        .foregroundStyle(Color.fishMuted.opacity(0.7))
                }
            }

            HStack(spacing: 12) {
                qualityBadge(icon: "percent", text: "\(Int(prediction.score * 100))%", label: "综合评分", color: scoreColor)
                qualityBadge(icon: "checkmark.seal.fill", text: "\(Int(prediction.confidence * 100))%", label: "置信度", color: .fishBlue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            ZStack {
                Color.fishCard
                LinearGradient(
                    colors: [scoreColor.opacity(0.08), .clear],
                    startPoint: .top, endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(scoreColor.opacity(0.2)))
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                animatedScore = prediction.score
            }
        }
        .onChange(of: prediction.score) { _, val in
            withAnimation(.easeOut(duration: 0.9)) {
                animatedScore = val
            }
        }
    }

    private var scoreColor: Color { .scoreColor(for: prediction.score) }

    private func qualityBadge(icon: String, text: String, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 1) {
                Text(text)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.fishText)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Color.fishMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.fishInput)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
