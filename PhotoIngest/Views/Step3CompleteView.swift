import SwiftUI

struct Step3CompleteView: View {
    @Environment(AppState.self) private var appState
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkOpacity: Double = 0

    var body: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            if let error = appState.errorMessage {
                errorContent(error)
            } else if let result = appState.transferResult {
                successContent(result)
            }

            Spacer()

            // Action buttons
            VStack(spacing: Theme.spacingSM) {
                if let result = appState.transferResult {
                    Button {
                        NSWorkspace.shared.open(URL(fileURLWithPath: result.destinationPath))
                    } label: {
                        Label("Open in Finder", systemImage: "folder")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button {
                    appState.resetForNewTransfer()
                } label: {
                    Label("Ingest More Photos", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .controlSize(.large)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, Theme.spacingLG)
        }
        .padding(Theme.spacingXL)
    }

    @ViewBuilder
    private func successContent(_ result: TransferResult) -> some View {
        // Animated checkmark
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 56))
            .foregroundStyle(Theme.success)
            .scaleEffect(checkmarkScale)
            .opacity(checkmarkOpacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    checkmarkScale = 1.0
                    checkmarkOpacity = 1.0
                }
            }

        Text("All set!")
            .font(.system(.title, design: .rounded, weight: .bold))

        // Stat cards
        HStack(spacing: Theme.spacingSM) {
            statCard(value: "\(result.totalFiles)", label: "Files")
            statCard(value: formattedSize(result.totalBytes), label: "Total Size")
            statCard(value: formattedDuration(result.duration), label: "Duration")
        }
        .padding(.horizontal, Theme.spacingMD)

        if let uploadFolder = result.uploadFolderName {
            Label("Saved to \(uploadFolder) (duplicates detected)", systemImage: "info.circle")
                .font(.caption)
                .foregroundStyle(Theme.warning)
        }

        // Destination
        VStack(spacing: Theme.spacingXS) {
            Text("Saved to:")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(result.destinationPath)
                .font(.caption)
                .lineLimit(2)
                .truncationMode(.middle)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }

        // Errors
        if !result.errors.isEmpty {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Label("Some files could not be copied", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(Theme.error)
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(result.errors) { error in
                            Text("\(error.fileName): \(error.message)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxHeight: 100)
            }
            .padding(Theme.spacingSM)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusSmall)
                    .fill(Theme.error.opacity(0.08))
            )
            .padding(.horizontal, 40)
        }
    }

    private func errorContent(_ error: String) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.error)

            Text("Transfer Failed")
                .font(.system(.title, design: .rounded, weight: .bold))

            Text(error)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: Theme.spacingXS) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .semibold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingSM + 4)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusSmall)
                .fill(Theme.surface)
        )
    }

    private func formattedSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        if duration < 60 {
            return String(format: "%.1fs", duration)
        }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}
