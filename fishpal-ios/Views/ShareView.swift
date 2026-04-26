import SwiftUI
import PhotosUI

struct ShareView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photos: [UIImage] = []

    var body: some View {
        NavigationStack {
            Group {
                if photos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 56))
                            .foregroundStyle(.secondary)
                        Text("还没有渔获照片")
                            .foregroundStyle(.secondary)
                        Text("点击右上角 + 上传今日渔获")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 2
                        ) {
                            ForEach(photos.indices, id: \.self) { i in
                                Image(uiImage: photos[i])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                            }
                        }
                    }
                }
            }
            .navigationTitle("渔获分享")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(selection: $selectedItems, matching: .images) {
                        Image(systemName: "plus")
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
    }
}

#Preview {
    ShareView()
}
