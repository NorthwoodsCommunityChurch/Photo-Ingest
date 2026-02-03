import Foundation

final class HistoryService {
    private let defaults = UserDefaults.standard
    private let eventNamesKey = "eventNameHistory"
    private let photographerNamesKey = "photographerNameHistory"
    private let maxEntries = 100

    func eventNames() -> [String] {
        defaults.stringArray(forKey: eventNamesKey) ?? []
    }

    func photographerNames() -> [String] {
        defaults.stringArray(forKey: photographerNamesKey) ?? []
    }

    func addEventName(_ name: String) {
        addEntry(name, forKey: eventNamesKey)
    }

    func addPhotographerName(_ name: String) {
        addEntry(name, forKey: photographerNamesKey)
    }

    func eventSuggestions(for prefix: String) -> [String] {
        suggestions(for: prefix, from: eventNames())
    }

    func photographerSuggestions(for prefix: String) -> [String] {
        suggestions(for: prefix, from: photographerNames())
    }

    private func addEntry(_ entry: String, forKey key: String) {
        let trimmed = entry.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var list = defaults.stringArray(forKey: key) ?? []
        list.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        list.insert(trimmed, at: 0)
        if list.count > maxEntries {
            list = Array(list.prefix(maxEntries))
        }
        defaults.set(list, forKey: key)
    }

    private func suggestions(for prefix: String, from list: [String]) -> [String] {
        guard !prefix.isEmpty else { return list }
        return list.filter { $0.localizedCaseInsensitiveContains(prefix) }
    }
}
