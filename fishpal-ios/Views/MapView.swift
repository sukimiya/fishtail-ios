import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject private var vm: AppViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 31.2, longitude: 121.5),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )
    @State private var selectedSpot: FishingSpot?
    @State private var showSpotList = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    if let coord = vm.selectedCoordinate {
                        Annotation("选中钓点", coordinate: coord) {
                            selectedMarker
                        }
                    }
                    ForEach(vm.spots) { spot in
                        Annotation(spot.name, coordinate: CLLocationCoordinate2D(latitude: spot.lat, longitude: spot.lon)) {
                            spotMarker(spot)
                        }
                    }
                    UserAnnotation()
                }
                .onTapGesture { point in
                    guard let coord = proxy.convert(point, from: .local) else { return }
                    selectedSpot = nil
                    Task {
                        await vm.fetchPrediction(lat: coord.latitude, lon: coord.longitude, locationName: "地图选点")
                    }
                    withAnimation(.spring()) {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            // GPS button
            Button {
                locationManager.requestLocation()
            } label: {
                Image(systemName: "location.fill")
                    .foregroundStyle(Color.fishBlue)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 8)
            }
            .padding(.top, 56)
            .padding(.trailing, 16)
        }
        .safeAreaInset(edge: .bottom) {
            spotListDrawer
        }
        .task { await vm.fetchSpots() }
        .onChange(of: locationManager.updateCount) { _, _ in
            guard let coord = locationManager.coordinate else { return }
            withAnimation(.spring()) {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
            Task {
                await vm.fetchPrediction(lat: coord.latitude, lon: coord.longitude, locationName: "当前位置")
            }
        }
    }

    // MARK: - Markers

    private var selectedMarker: some View {
        VStack(spacing: 0) {
            Image(systemName: "fish.fill")
                .foregroundStyle(.white)
                .padding(8)
                .background(Color.fishBlue)
                .clipShape(Circle())
                .shadow(color: Color.fishBlue.opacity(0.5), radius: 6)
            Triangle()
                .fill(Color.fishBlue)
                .frame(width: 10, height: 6)
        }
    }

    private func spotMarker(_ spot: FishingSpot) -> some View {
        Button {
            withAnimation(.spring()) {
                selectedSpot = spot
                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: spot.lat, longitude: spot.lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                ))
            }
        } label: {
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.fishOrange)
                    .shadow(color: Color.fishOrange.opacity(0.4), radius: 4)
            }
        }
    }

    // MARK: - Spot list drawer

    private var spotListDrawer: some View {
        VStack(spacing: 0) {
            if let spot = selectedSpot {
                spotDetailCard(spot)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                spotListHeader
                if showSpotList {
                    spotListScroll
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.fishBorder))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .animation(.spring(duration: 0.35), value: showSpotList)
        .animation(.spring(duration: 0.35), value: selectedSpot?.id)
    }

    private var spotListHeader: some View {
        HStack {
            Label("社区钓点 (\(vm.spots.count))", systemImage: "map.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.fishText)
            Spacer()
            Button {
                withAnimation { showSpotList.toggle() }
            } label: {
                Image(systemName: showSpotList ? "chevron.down" : "chevron.up")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.fishMuted)
                    .padding(6)
                    .background(Color.fishInput)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var spotListScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vm.spots) { spot in
                    spotChip(spot)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }

    private func spotChip(_ spot: FishingSpot) -> some View {
        Button {
            withAnimation(.spring()) {
                selectedSpot = spot
                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: spot.lat, longitude: spot.lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                ))
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.fishText)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.fishRed)
                    Text("\(spot.likes)")
                        .font(.caption2)
                        .foregroundStyle(Color.fishMuted)
                    if !spot.species.isEmpty {
                        Text("· \(spot.species)")
                            .font(.caption2)
                            .foregroundStyle(Color.fishMuted)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.fishCard)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.fishBorder))
        }
    }

    private func spotDetailCard(_ spot: FishingSpot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.fishText)
                    if !spot.description.isEmpty {
                        Text(spot.description)
                            .font(.caption)
                            .foregroundStyle(Color.fishMuted)
                            .lineLimit(2)
                    }
                }
                Spacer()
                Button {
                    withAnimation { selectedSpot = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.fishMuted)
                        .font(.system(size: 20))
                }
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill").foregroundStyle(Color.fishRed)
                    Text("\(spot.likes) 赞").font(.caption).foregroundStyle(Color.fishMuted)
                }
                if !spot.species.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "fish.fill").foregroundStyle(Color.fishBlue)
                        Text(spot.species)
                            .font(.caption).foregroundStyle(Color.fishMuted)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Button {
                    Task {
                        await vm.fetchPrediction(lat: spot.lat, lon: spot.lon, locationName: spot.name)
                    }
                } label: {
                    Label("查看鱼情", systemImage: "chart.bar.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.fishBlue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
    }
}

// MARK: - Triangle shape for marker

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    MapView().environmentObject(AppViewModel())
}
