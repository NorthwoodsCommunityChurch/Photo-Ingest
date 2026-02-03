import Foundation

struct TransferProgress {
    var totalFiles: Int = 0
    var copiedFiles: Int = 0
    var totalBytes: Int64 = 0
    var copiedBytes: Int64 = 0
    var currentFileName: String = ""

    var fractionComplete: Double {
        guard totalFiles > 0 else { return 0 }
        return Double(copiedFiles) / Double(totalFiles)
    }
}

struct TransferResult {
    let totalFiles: Int
    let totalBytes: Int64
    let destinationPath: String
    let duration: TimeInterval
    let errors: [FileTransferError]
    let uploadFolderName: String?
}

struct FileTransferError: Identifiable {
    let id = UUID()
    let fileName: String
    let message: String
}
