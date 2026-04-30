import SwiftUI
import MapKit

struct PredictView: View {
    @EnvironmentObject private var vm: AppViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var completer = SearchCompleter()

    @State private var searchText = ""
    @State private var showSuggestions = false
    @State private var blessing = ""

    private let blessings = [
        "愿大鱼频频咬钩", "今日必钓大鱼", "鱼情大好，满载而归",
        "祝竿竿中鱼", "愿鱼儿主动找上门", "风平浪静，鱼获满舱"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerBanner
                    locationCard
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    predictionContent
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                }
            }
            .background(Color.fishBG)
            .navigationBarHidden(true)
        }
        .onAppear { blessing = blessings.randomElement() ?? "" }
        .task { await vm.fetchSpots() }
        .onChange(of: locationManager.updateCount) { _, _ in
            guard let coord = locationManager.coordinate else { return }
            Task { await vm.fetchPrediction(lat: coord.latitude, lon: coord.longitude, locationName: "当前位置") }
        }
    }

    // MARK: - Header

    private var headerBanner: some View {
        ZStack {
            LinearGradient(
                colors: [Color.fishBlue.opacity(0.25), Color.fishBG],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 100)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("🎣 FishPal")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.fishText)
                    Spacer()
                    if !vm.nickname.isEmpty {
                        Text(vm.nickname)
                            .font(.caption)
                            .foregroundStyle(Color.fishMuted)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.fishCard)
                            .clipShape(Capsule())
                    }
                }
                Text(blessing)
                    .font(.caption)
                    .foregroundStyle(Color.fishMuted)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Location Card

    private var locationCard: some View {
        VStack(spacing: 0) {
            searchBar
            if showSuggestions && !completer.results.isEmpty {
                suggestionsView
            }
            if !vm.selectedLocationName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.fishBlue)
                    Text(vm.selectedLocationName)
                        .font(.subheadline)
                        .foregroundStyle(Color.fishText)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.fishInput)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.fishBorder))
                .padding(.top, 8)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.fishMuted)
                .font(.system(size: 16, weight: .medium))
            TextField("搜索钓点或地址...", text: $searchText)
                .foregroundStyle(Color.fishText)
                .submitLabel(.search)
                .onChange(of: searchText) { _, val in
                    completer.update(query: val)
                    showSuggestions = !val.isEmpty
                }
            Spacer()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    showSuggestions = false
                    completer.update(query: "")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.fishMuted)
                }
            }
            Divider()
                .frame(height: 20)
                .background(Color.fishBorder)
            Button {
                locationManager.requestLocation()
            } label: {
                Image(systemName: "location.fill")
                    .foregroundStyle(Color.fishBlue)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.fishBorder))
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(completer.results.enumerated()), id: \.offset) { index, result in
                Button {
                    Task { await selectSuggestion(result) }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "mappin")
                            .foregroundStyle(Color.fishMuted)
                            .font(.caption)
                            .frame(width: 16)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.title)
                                .font(.subheadline)
                                .foregroundStyle(Color.fishText)
                            if !result.subtitle.isEmpty {
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(Color.fishMuted)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
                if index < completer.results.count - 1 {
                    Divider().background(Color.fishBorder)
                }
            }
        }
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.fishBorder))
        .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
        .padding(.top, 4)
    }

    private func selectSuggestion(_ result: MKLocalSearchCompletion) async {
        let request = MKLocalSearch.Request(completion: result)
        guard let response = try? await MKLocalSearch(request: request).start(),
              let item = response.mapItems.first else { return }
        let coord = item.placemark.coordinate
        searchText = result.title
        showSuggestions = false
        await vm.fetchPrediction(lat: coord.latitude, lon: coord.longitude, locationName: result.title)
    }

    // MARK: - Prediction Content

    @ViewBuilder
    private var predictionContent: some View {
        if vm.isLoading {
            loadingSkeleton
        } else if let pred = vm.prediction {
            VStack(spacing: 14) {
                ScoreRingView(prediction: pred)
                FactorsScrollView(factors: pred.factors)
                if !vm.hourly.isEmpty {
                    HourlyBarView(hourly: vm.hourly)
                }
            }
        } else if let err = vm.errorMessage {
            errorCard(err)
        } else {
            emptyState
        }
    }

    private var loadingSkeleton: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.fishCard)
                .frame(height: 260)
                .overlay(
                    ProgressView("分析鱼情中...")
                        .tint(Color.fishBlue)
                        .foregroundStyle(Color.fishMuted)
                )
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.fishCard)
                .frame(height: 80)
                .opacity(0.6)
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.fishCard)
                .frame(height: 100)
                .opacity(0.4)
        }
    }

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.fishOrange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.fishMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🎣")
                .font(.system(size: 56))
            Text("选择钓点查看鱼情预测")
                .font(.headline)
                .foregroundStyle(Color.fishText)
            VStack(spacing: 6) {
                Label("搜索钓点地址", systemImage: "magnifyingglass")
                Label("点击 GPS 按钮定位", systemImage: "location.fill")
                Label("在地图页点击钓点", systemImage: "map.fill")
            }
            .font(.subheadline)
            .foregroundStyle(Color.fishMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.fishBorder))
    }
}

#Preview {
    PredictView().environmentObject(AppViewModel())
}
