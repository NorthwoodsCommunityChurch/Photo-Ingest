import SwiftUI

struct Step2TransferProgressView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            // Transfer icon
            Image(systemName: "arrow.right.doc.on.clipboard")
                .font(.system(size: 48))
                .foregroundStyle(Theme.accent)

            Text("Copying your photos...")
                .font(.system(.title2, design: .rounded, weight: .semibold))

            // Event info
            VStack(spacing: Theme.spacingXS) {
                Text(appState.eventName)
                    .font(.headline)
                Text(formattedDate(appState.eventDate) + " \u{2022} " + appState.photographerName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress card
            VStack(spacing: Theme.spacingMD) {
                // Custom progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.surfaceHover)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.accent)
                            .frame(
                                width: max(0, geo.size.width * appState.transferProgress.fractionComplete),
                                height: 8
                            )
                            .animation(.easeOut(duration: 0.3), value: appState.transferProgress.fractionComplete)
                    }
                }
                .frame(height: 8)

                // Stats row
                HStack {
                    HStack(spacing: Theme.spacingXS) {
                        Text("\(appState.transferProgress.copiedFiles)")
                            .fontWeight(.semibold)
                        Text("of \(appState.transferProgress.totalFiles) files")
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)

                    Spacer()

                    Text(formattedSize(appState.transferProgress.copiedBytes) + " / " + formattedSize(appState.transferProgress.totalBytes))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Current file
                if !appState.transferProgress.currentFileName.isEmpty {
                    HStack(spacing: Theme.spacingXS) {
                        ProgressView()
                            .controlSize(.mini)
                        Text(appState.transferProgress.currentFileName)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            }
            .padding(Theme.spacingMD)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMedium)
                    .fill(Theme.surface)
            )
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding(Theme.spacingXL)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
