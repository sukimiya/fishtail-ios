import SwiftUI
import PhotosUI

struct LogView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photos: [UIImage] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fishBG.ignoresSafeArea()
                if photos.isEmpty {
                    emptyState
                } else {
                    photoGrid
                }
            }
            .navigationTitle("渔获记录")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(selection: $selectedItems, matching: .images) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.fishBlue)
                            .font(.system(size: 22))
                    }
                }
            }
        }
        .onChange(of: selectedItems) { _, items in
            Task {
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        photos.append(image)
                    }
                }
                selectedItems = []
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("🐟")
                .font(.system(size: 64))
            Text("还没有渔获记录")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.fishText)
            Text("点击右上角 + 上传今日渔获照片")
                .font(.subheadline)
                .foregroundStyle(Color.fishMuted)
                .multilineTextAlignment(.center)

            PhotosPicker(selection: $selectedItems, matching: .images) {
                Label("添加照片", systemImage: "photo.badge.plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.fishBlue)
                    .clipShape(Capsule())
            }
        }
        .padding(40)
    }

    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 3), GridItem(.flexible(), spacing: 3), GridItem(.flexible(), spacing: 3)],
                spacing: 3
            ) {
                ForEach(photos.indices, id: \.self) { i in
                    Image(uiImage: photos[i])
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .padding(3)
        }
    }
}

#Preview {
    LogView()
}
