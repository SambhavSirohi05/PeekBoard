import SwiftUI

struct SearchBarView: View {
    @Binding var query: String
    @Binding var isSearching: Bool
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search...", text: $query)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                // When text is empty and backspace is pressed, we could exit search mode
                .onChange(of: query) { newValue in
                    // In SwiftUI onChange usually doesn't capture backspace if empty directly.
                    // We'll trust Escape to close it.
                }
            
            if !query.isEmpty {
                Button(action: {
                    query = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
        .onChange(of: isSearching) { searching in
            if searching {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            } else {
                isFocused = false
            }
        }
    }
}
