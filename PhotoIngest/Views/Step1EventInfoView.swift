import SwiftUI

struct Step1EventInfoView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            // Header
            VStack(spacing: Theme.spacingSM) {
                Image("NorthwoodsSymbol")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .foregroundStyle(Theme.accent)
                Text("Photo Ingest")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .tracking(0.5)
                Text("Get your photos organized")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, Theme.spacingXL)
            .padding(.bottom, Theme.spacingLG)

            // Guided steps with connecting lines
            VStack(spacing: 0) {
                // Step 1 - Event
                stepRow(
                    number: 1,
                    title: "What's the event?",
                    filled: !appState.eventName.isEmpty,
                    isLast: false
                ) {
                    AutocompleteTextField(
                        title: "e.g. Sunday Service, Easter, Youth Night...",
                        text: $state.eventName,
                        suggestions: appState.historyService.eventNames()
                    )
                }

                // Step 2 - Photographer
                stepRow(
                    number: 2,
                    title: "Who took the photos?",
                    filled: !appState.photographerName.isEmpty,
                    isLast: false
                ) {
                    AutocompleteTextField(
                        title: "Photographer name",
                        text: $state.photographerName,
                        suggestions: appState.historyService.photographerNames()
                    )
                }

                // Step 3 - Date
                stepRow(
                    number: 3,
                    title: "When was it?",
                    filled: true,
                    isLast: true
                ) {
                    DatePicker("", selection: $state.eventDate, displayedComponents: .date)
                        .datePickerStyle(.field)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, Theme.spacingXL)

            // Drop zone
            DropZoneView()
                .frame(maxHeight: .infinity)
                .padding(.horizontal, Theme.spacingXL)
                .padding(.top, Theme.spacingLG)

            // Footer
            VStack(spacing: Theme.spacingSM) {
                if appState.destinationPath.isEmpty {
                    Label("Choose a destination folder in Settings", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(Theme.warning)
                } else {
                    HStack(spacing: Theme.spacingXS) {
                        Image(systemName: "folder.fill")
                            .font(.caption2)
                        Text(appState.destinationPath)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .foregroundStyle(.secondary)
                }

                Button {
                    appState.startTransfer()
                } label: {
                    Label("Start Transfer", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .controlSize(.large)
                .disabled(!appState.canStartTransfer)
            }
            .padding(.horizontal, Theme.spacingXL)
            .padding(.bottom, Theme.spacingLG)
        }
    }

    private func stepRow<Content: View>(
        number: Int,
        title: String,
        filled: Bool,
        isLast: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .top, spacing: Theme.spacingMD) {
            // Badge + connecting line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(filled ? Theme.accent : Theme.surfaceHover)
                        .frame(width: 28, height: 28)
                    Text("\(number)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(filled ? .white : .secondary)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filled)

                if !isLast {
                    Rectangle()
                        .fill(Theme.border.opacity(0.5))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 28)

            // Content
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                content()
            }
            .padding(.bottom, isLast ? 0 : Theme.spacingMD)
        }
    }
}
