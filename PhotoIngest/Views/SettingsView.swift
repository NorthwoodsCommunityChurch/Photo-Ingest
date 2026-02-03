import SwiftUI

struct SettingsView: View {
    @AppStorage("destinationPath") private var destinationPath: String = ""

    var body: some View {
        Form {
            Section("Destination Folder") {
                HStack {
                    if destinationPath.isEmpty {
                        Text("Not configured")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(destinationPath)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Spacer()
                    Button("Choose...") {
                        selectFolder()
                    }
                }
                Text("All photo transfers will be organized inside this folder.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 500, height: 160)
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Select Destination"
        panel.message = "Choose the root folder where photo transfers will be organized."
        if panel.runModal() == .OK, let url = panel.url {
            destinationPath = url.path
        }
    }
}
