import Foundation

final class TransferService {
    private let fileManager = FileManager.default

    func performTransfer(
        items: [TransferItem],
        eventName: String,
        date: Date,
        photographerName: String,
        destinationBase: URL,
        progressHandler: @escaping @Sendable (TransferProgress) -> Void
    ) async throws -> TransferResult {
        let startTime = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let photographerDir = destinationBase
            .appendingPathComponent(sanitizePathComponent(eventName))
            .appendingPathComponent(dateString)
            .appendingPathComponent(sanitizePathComponent(photographerName))

        // Determine target directory — check for filename collisions
        let targetDir = try resolveTargetDirectory(photographerDir: photographerDir, items: items)

        // Create target directory
        try fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true)

        var progress = TransferProgress()
        progress.totalFiles = items.count
        progress.totalBytes = items.reduce(0) { $0 + $1.fileSize }

        var errors: [FileTransferError] = []
        var copiedBytes: Int64 = 0

        for item in items {
            let destination: URL
            if item.relativePath.isEmpty {
                destination = targetDir.appendingPathComponent(item.sourceURL.lastPathComponent)
            } else {
                destination = targetDir.appendingPathComponent(item.relativePath)
            }

            // Create intermediate directories for nested files
            let parentDir = destination.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: parentDir.path) {
                try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
            }

            progress.currentFileName = item.sourceURL.lastPathComponent
            progressHandler(progress)

            do {
                try fileManager.copyItem(at: item.sourceURL, to: destination)
                copiedBytes += item.fileSize
            } catch {
                errors.append(FileTransferError(
                    fileName: item.sourceURL.lastPathComponent,
                    message: error.localizedDescription
                ))
            }

            progress.copiedFiles += 1
            progress.copiedBytes = copiedBytes
            progressHandler(progress)
        }

        let duration = Date().timeIntervalSince(startTime)
        let uploadFolderName = targetDir.lastPathComponent.hasPrefix("Upload ")
            ? targetDir.lastPathComponent
            : nil

        return TransferResult(
            totalFiles: items.count,
            totalBytes: copiedBytes,
            destinationPath: targetDir.path,
            duration: duration,
            errors: errors,
            uploadFolderName: uploadFolderName
        )
    }

    /// Strips characters that are invalid in macOS filenames and enforces a length limit.
    private func sanitizePathComponent(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/:\\0")
        var sanitized = name.components(separatedBy: invalid).joined(separator: "-")
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix(".") { sanitized = "_" + sanitized }
        if sanitized.count > 255 { sanitized = String(sanitized.prefix(255)) }
        return sanitized.isEmpty ? "Untitled" : sanitized
    }

    /// If the photographer directory already has files with the same names,
    /// create an "Upload N" subfolder for the new batch.
    private func resolveTargetDirectory(photographerDir: URL, items: [TransferItem]) throws -> URL {
        guard fileManager.fileExists(atPath: photographerDir.path) else {
            return photographerDir
        }

        let existingFiles = try fileManager.contentsOfDirectory(atPath: photographerDir.path)
        let incomingNames = Set(items.map { item -> String in
            if item.relativePath.isEmpty {
                return item.sourceURL.lastPathComponent
            }
            // For nested files, check top-level name
            let components = item.relativePath.split(separator: "/", maxSplits: 1)
            return String(components.first ?? Substring(item.sourceURL.lastPathComponent))
        })

        let hasCollision = existingFiles.contains { incomingNames.contains($0) }
        guard hasCollision else {
            return photographerDir
        }

        // Find next "Upload N" number
        let existingUploads = existingFiles.compactMap { name -> Int? in
            guard name.hasPrefix("Upload ") else { return nil }
            return Int(name.dropFirst("Upload ".count))
        }
        let nextNumber = (existingUploads.max() ?? 0) + 1
        return photographerDir.appendingPathComponent("Upload \(nextNumber)")
    }
}
