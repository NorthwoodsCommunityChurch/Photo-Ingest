import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @Environment(AppState.self) private var appState
    @State private var isTargeted = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: Theme.spacingSM) {
            if appState.droppedItems.isEmpty {
                emptyState
            } else {
                fileList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusLarge)
                .strokeBorder(
                    isTargeted ? Theme.accent : (appState.droppedItems.isEmpty ? Theme.border.opacity(0.5) : Theme.border.opacity(0.3)),
                    style: appState.droppedItems.isEmpty
                        ? StrokeStyle(lineWidth: 2, dash: [8, 5])
                        : StrokeStyle(lineWidth: 1)
                )
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusLarge)
                        .fill(isTargeted ? Theme.accentMuted : Color.white.opacity(0.02))
                )
        )
        .scaleEffect(isTargeted ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isTargeted)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers)
            return true
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.spacingSM) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 44))
                .foregroundStyle(Theme.accent.opacity(0.4))
                .scaleEffect(pulseScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        pulseScale = 1.04
                    }
                }

            Text("Drop your photos here")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("RAW, JPEG, HEIC \u{2014} we handle them all")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var fileList: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                HStack(spacing: Theme.spacingXS) {
                    Text("\(appState.droppedItems.count)")
                        .font(.headline)
                        .foregroundStyle(Theme.secondary)
                    Text("files")
                        .font(.headline)
                }
                Text("(\(formattedSize(appState.totalDroppedSize)))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Clear All") {
                    appState.clearDroppedItems()
                }
                .buttonStyle(.plain)
                .foregroundStyle(Theme.error.opacity(0.8))
                .font(.caption)
            }
            .padding(.horizontal, Theme.spacingSM + 4)
            .padding(.top, Theme.spacingSM + 2)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(appState.droppedItems.enumerated()), id: \.element.id) { index, item in
                        FileRowView(item: item, index: index)
                    }
                }
            }
            .padding(.bottom, Theme.spacingSM)

            HStack(spacing: Theme.spacingXS) {
                Image(systemName: "plus.circle")
                    .font(.caption2)
                Text("Drop more to add")
                    .font(.caption2)
            }
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.bottom, Theme.spacingSM)
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, _ in
                guard let data = data as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                Task { @MainActor in
                    appState.addDroppedURLs([url])
                }
            }
        }
    }

    private func formattedSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - File Row

private struct FileRowView: View {
    @Environment(AppState.self) private var appState
    let item: TransferItem
    let index: Int
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconForFile(item.sourceURL.pathExtension))
                .font(.caption)
                .foregroundStyle(Theme.accent.opacity(0.6))
                .frame(width: 16)
            Text(item.relativePath.isEmpty ? item.sourceURL.lastPathComponent : item.relativePath)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Text(formattedSize(item.fileSize))
                .font(.caption2)
                .foregroundStyle(.tertiary)

            if isHovered {
                Button {
                    appState.removeDroppedItem(at: index)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, Theme.spacingSM + 4)
        .padding(.vertical, 4)
        .background(
            index % 2 == 0
                ? Color.clear
                : Color.white.opacity(0.03)
        )
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }

    private func iconForFile(_ ext: String) -> String {
        let imageExts = ["jpg", "jpeg", "png", "heic", "tiff", "tif", "raw", "cr2", "cr3", "nef", "arw", "dng"]
        let videoExts = ["mov", "mp4", "m4v", "avi"]
        let lower = ext.lowercased()
        if imageExts.contains(lower) { return "photo" }
        if videoExts.contains(lower) { return "video" }
        return "doc"
    }

    private func formattedSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
