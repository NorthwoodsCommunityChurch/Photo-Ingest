import SwiftUI

enum WizardStep {
    case eventInfo
    case transferring
    case complete
}

@Observable
final class AppState {
    var currentStep: WizardStep = .eventInfo

    // Step 1 fields
    var eventName: String = ""
    var eventDate: Date = Date()
    var photographerName: String = ""
    var droppedItems: [TransferItem] = []

    // Step 2 state
    var transferProgress = TransferProgress()

    // Step 3 state
    var transferResult: TransferResult?
    var errorMessage: String?

    // Services
    let historyService = HistoryService()
    private let transferService = TransferService()

    // Destination path - read from UserDefaults (can't use @AppStorage inside @Observable)
    @ObservationIgnored
    private let defaults = UserDefaults.standard
    private static let destinationKey = "destinationPath"

    var destinationPath: String {
        get { defaults.string(forKey: Self.destinationKey) ?? "" }
        set { defaults.set(newValue, forKey: Self.destinationKey) }
    }

    var canStartTransfer: Bool {
        !eventName.trimmingCharacters(in: .whitespaces).isEmpty
            && !photographerName.trimmingCharacters(in: .whitespaces).isEmpty
            && !droppedItems.isEmpty
            && !destinationPath.isEmpty
    }

    var totalDroppedSize: Int64 {
        droppedItems.reduce(0) { $0 + $1.fileSize }
    }

    // MARK: - File Drop Handling

    func addDroppedURLs(_ urls: [URL]) {
        let fm = FileManager.default
        for url in urls {
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else { continue }

            if isDir.boolValue {
                enumerateDirectory(url)
            } else {
                let size = (try? fm.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
                let item = TransferItem(sourceURL: url, relativePath: "", fileSize: size)
                if !droppedItems.contains(where: { $0.sourceURL == url }) {
                    droppedItems.append(item)
                }
            }
        }
    }

    func removeDroppedItem(at index: Int) {
        guard droppedItems.indices.contains(index) else { return }
        droppedItems.remove(at: index)
    }

    func clearDroppedItems() {
        droppedItems.removeAll()
    }

    private func enumerateDirectory(_ dirURL: URL) {
        let fm = FileManager.default
        let baseName = dirURL.lastPathComponent
        guard let enumerator = fm.enumerator(
            at: dirURL,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
                  resourceValues.isRegularFile == true else { continue }

            let relativePath = baseName + "/" + fileURL.path.replacingOccurrences(of: dirURL.path + "/", with: "")
            let size = Int64(resourceValues.fileSize ?? 0)
            let item = TransferItem(sourceURL: fileURL, relativePath: relativePath, fileSize: size)
            if !droppedItems.contains(where: { $0.sourceURL == fileURL }) {
                droppedItems.append(item)
            }
        }
    }

    // MARK: - Transfer

    func startTransfer() {
        guard canStartTransfer else { return }
        currentStep = .transferring
        transferProgress = TransferProgress()
        errorMessage = nil

        Task {
            do {
                let result = try await transferService.performTransfer(
                    items: droppedItems,
                    eventName: eventName.trimmingCharacters(in: .whitespaces),
                    date: eventDate,
                    photographerName: photographerName.trimmingCharacters(in: .whitespaces),
                    destinationBase: URL(fileURLWithPath: destinationPath)
                ) { [weak self] progress in
                    Task { @MainActor in
                        self?.transferProgress = progress
                    }
                }

                await MainActor.run {
                    historyService.addEventName(eventName.trimmingCharacters(in: .whitespaces))
                    historyService.addPhotographerName(photographerName.trimmingCharacters(in: .whitespaces))
                    transferResult = result
                    currentStep = .complete
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    currentStep = .complete
                }
            }
        }
    }

    // MARK: - Reset

    func resetForNewTransfer() {
        currentStep = .eventInfo
        eventName = ""
        eventDate = Date()
        photographerName = ""
        droppedItems = []
        transferProgress = TransferProgress()
        transferResult = nil
        errorMessage = nil
    }
}
