import SwiftUI

struct AutocompleteTextField: View {
    let title: String
    @Binding var text: String
    let suggestions: [String]

    @State private var showSuggestions = false
    @State private var filteredSuggestions: [String] = []
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    updateSuggestions(for: newValue)
                }
                .onChange(of: isFocused) { _, focused in
                    if focused {
                        updateSuggestions(for: text)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            showSuggestions = false
                        }
                    }
                }
                .onSubmit {
                    showSuggestions = false
                }

            if showSuggestions {
                suggestionList
            }
        }
    }

    private var suggestionList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(filteredSuggestions.prefix(8).enumerated()), id: \.element) { index, suggestion in
                Button {
                    text = suggestion
                    showSuggestions = false
                } label: {
                    Text(suggestion)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < min(filteredSuggestions.count, 8) - 1 {
                    Divider().opacity(0.3)
                }
            }
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusSmall)
                .strokeBorder(Theme.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        .padding(.top, 2)
    }

    private func updateSuggestions(for value: String) {
        if value.isEmpty {
            filteredSuggestions = suggestions
        } else {
            filteredSuggestions = suggestions.filter {
                $0.localizedCaseInsensitiveContains(value) && $0.caseInsensitiveCompare(value) != .orderedSame
            }
        }
        showSuggestions = !filteredSuggestions.isEmpty && isFocused
    }
}
