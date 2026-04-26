import SwiftUI
import MapKit

struct PredictView: View {
    @EnvironmentObject private var vm: AppViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var completer = SearchCompleter()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 31.2, longitude: 121.5),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    @State private var selectedCoord: CLLocationCoordinate2D?
    @State private var searchText = ""
    @State private var showSuggestions = false
    @State private var blessing = ""

    private let blessings = [
        "愿大鱼频频咬钩", "今日必钓大鱼", "鱼情大好，满载而归",
        "祝竿竿中鱼", "愿鱼儿主动找上门", "风平浪静，鱼获满舱"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                welcomeBar
                mapArea
                    .padding(.horizontal)
                predictionSection
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background(Color.fishBG)
        .onAppear { blessing = blessings.randomElement() ?? "" }
        .task { await vm.fetchSpots() }
        .onChange(of: locationManager.updateCount) { _, _ in
            guard let coord = locationManager.coordinate else { return }
            selectedCoord = coord
            cameraPosition = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            Task { await vm.fetchPrediction(lat: coord.latitude, lon: coord.longitude) }
        }
    }

    // MARK: - Welcome

    private var welcomeBar: some View {
        Text("欢迎 \(vm.nickname)，\(blessing)！")
            .font(.subheadline)
            .foregroundStyle(Color.fishMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
    }

    // MARK: - Map

    private var mapArea: some View {
        ZStack {
            // Map
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    if let coord = selectedCoord {
                        Marker("钓点", coordinate: coord)
                    }
                    ForEach(vm.spots) { spot in
                        Marker(spot.name, coordinate: CLLocationCoordinate2D(latitude: spot.lat, longitude: spot.lon))
                            .tint(.orange)
                    }
                    UserAnnotation()
                }
                .onTapGesture { point in
                    guard let coord = proxy.convert(point, from: .local) else { return }
                    selectedCoord = coord
                    showSuggestions = false
                    Task { await vm.fetchPrediction(lat: coord.latitude, lon: coord.longitude) }
                }
            }
            .frame(height: 440)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // GPS button (top right)
            VStack {
                HStack {
                    Spacer()
                    Button { locationManager.requestLocation() } label: {
                        Image(systemName: "location.fill")
                            .padding(10)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                Spacer()
            }
            .padding(10)
            .frame(height: 440)

            // Suggestions + search bar pinned to bottom
            VStack(spacing: 0) {
                Spacer()
                if showSuggestions && !completer.results.isEmpty {
                    suggestionsView
                        .padding(.horizontal, 10)
                        .padding(.bottom, 6)
                }
                searchBar
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
            .frame(height: 440)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(Color.fishMuted)
            TextField("搜索钓点或地址...", text: $searchText)
                .foregroundStyle(Color.fishText)
                .submitLabel(.search)
                .onChange(of: searchText) { _, val in
                    completer.update(query: val)
                    showSuggestions = !val.isEmpty
                }
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    showSuggestions = false
                    completer.update(query: "")
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color.fishInput)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.fishBorder))
    }

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(completer.results.enumerated()), id: \.offset) { index, result in
                Button {
                    Task { await selectSuggestion(result) }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.title)
                            .font(.subheadline).foregroundStyle(Color.fishText)
                        if !result.subtitle.isEmpty {
                            Text(result.subtitle)
                                .font(.caption).foregroundStyle(Color.fishMuted)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                if index < completer.results.count - 1 {
                    Divider()
                }
            }
        }
        .background(Color.fishCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.fishBorder))
        .shadow(color: .black.opacity(0.4), radius: 8)
    }

    private func selectSuggestion(_ result: MKLocalSearchCompletion) async {
        let request = MKLocalSearch.Request(completion: result)
        guard let response = try? await MKLocalSearch(request: request).start(),
              let item = response.mapItems.first else { return }
        let coord = item.placemark.coordinate
        selectedCoord = coord
        cameraPosition = .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        searchText = result.title
        showSuggestions = false
        await vm.fetchPrediction(lat: coord.latitude, lon: coord.longitude)
    }

    // MARK: - Prediction

    @ViewBuilder
    private var predictionSection: some View {
        if vm.isLoading {
            ProgressView("分析鱼情中...").padding(40)
        } else if let pred = vm.prediction {
            ScoreRingView(prediction: pred)
            if !vm.hourly.isEmpty {
                HourlyBarView(hourly: vm.hourly)
            }
        } else if let err = vm.errorMessage {
            Label(err, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red).padding()
        } else {
            VStack(spacing: 8) {
                Text("🎣").font(.system(size: 48))
                Text("点击地图或搜索选择钓点")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
        }
    }
}

#Preview {
    PredictView().environmentObject(AppViewModel())
}
