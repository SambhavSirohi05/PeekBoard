import SwiftUI

public struct PanelView: View {
    @State private var totalItems: Int = 0
    @State private var isSearching: Bool = false
    @State private var searchQuery: String = ""
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("PEEKBOARD")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\\(totalItems) items")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .frame(height: 40)
            
            Divider()
            
            if isSearching {
                SearchBarView(query: $searchQuery, isSearching: $isSearching)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeOut(duration: 0.15), value: isSearching)
                Divider()
            }
            
            ClipboardListView(searchQuery: $searchQuery)
            
            PanelFooterView()
        }
        .frame(width: 340)
        .frame(minHeight: 400, maxHeight: 520)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewClipboardEntry"))) { _ in updateTotal() }
        .onAppear { updateTotal() }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PanelKeyDown"))) { notification in
            if let event = notification.object as? NSEvent {
                let chars = event.charactersIgnoringModifiers ?? ""
                if !isSearching, let char = chars.first, char.isLetter || char.isNumber {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isSearching = true
                    }
                    searchQuery = String(char)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EscapePressed"))) { _ in
            if isSearching && !searchQuery.isEmpty {
                searchQuery = ""
            } else if isSearching && searchQuery.isEmpty {
                withAnimation(.easeIn(duration: 0.1)) {
                    isSearching = false
                }
            } else {
                PanelController.shared.close()
            }
        }
    }
    
    private func updateTotal() {
        do {
            totalItems = try DatabaseManager.shared.fetchRecent().count + DatabaseManager.shared.fetchPinned().count
        } catch {
            totalItems = 0
        }
    }
}
