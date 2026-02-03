import Foundation

struct TransferItem: Identifiable {
    let id = UUID()
    let sourceURL: URL
    let relativePath: String
    let fileSize: Int64
}
