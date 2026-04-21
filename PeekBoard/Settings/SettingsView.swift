import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaultsKeys.historyLimit) var historyLimit: Int = 200
    @State private var showingClearConfirm = false
    
    private var githubIcon: NSImage? {
        let img = NSImage(named: "github-logo")
        img?.isTemplate = true
        return img
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                if let appIcon = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                
                VStack(spacing: 4) {
                    Text("PeekBoard")
                        .font(.system(size: 22, weight: .bold))
                    Text("Version 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 36)
            .padding(.bottom, 24)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // History Settings
                    VStack(alignment: .leading, spacing: 8) {
                        Text("General")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        GroupBox {
                            HStack {
                                Text("History Limit")
                                    .font(.system(size: 13, weight: .medium))
                                Spacer()
                                Picker("", selection: $historyLimit) {
                                    Text("50 Items").tag(50)
                                    Text("100 Items").tag(100)
                                    Text("200 Items").tag(200)
                                    Text("500 Items").tag(500)
                                    Text("Unlimited").tag(-1)
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 120)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    // Data Management
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Management")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        GroupBox {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Clear History")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("Permanently delete all unpinned clipboard entries.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    showingClearConfirm = true
                                }) {
                                    Text("Clear All")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .alert("Clear all unpinned clipboard history?", isPresented: $showingClearConfirm) {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Clear", role: .destructive) {
                                        try? DatabaseManager.shared.clearUnpinnedHistory()
                                    }
                                } message: {
                                    Text("This action cannot be undone.")
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    // Footer Link
                    HStack {
                        Spacer()
                        Link(destination: URL(string: "https://github.com/SambhavSirohi05/PeekBoard")!) {
                            HStack(spacing: 4) {
                                if let icon = githubIcon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 14, height: 14)
                                } else {
                                    Image(systemName: "star.fill")
                                }
                                Text("View on GitHub")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { hover in
                            if hover {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .frame(width: 440, height: 480)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
