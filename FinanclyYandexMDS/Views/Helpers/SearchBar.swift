import SwiftUI

// MARK: – SearchBar
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search", text: $text)
                .disableAutocorrection(true)
        }
        .padding(8)
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}
