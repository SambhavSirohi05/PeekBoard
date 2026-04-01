import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaultsKeys.historyLimit) var historyLimit: Int = 200
    @AppStorage(UserDefaultsKeys.autoPauseOnLock) var autoPauseOnLock: Bool = false
    @AppStorage(UserDefaultsKeys.autoClearOnLock) var autoClearOnLock: Bool = false
    @AppStorage(UserDefaultsKeys.panelDensity) var panelDensity: String = "Normal"
    
    @State private var showingClearConfirm = false
    
    var body: some View {
        Form {
            Section("General") {
                Picker("History limit", selection: $historyLimit) {
                    Text("50").tag(50)
                    Text("100").tag(100)
                    Text("200").tag(200)
                    Text("500").tag(500)
                    Text("Unlimited").tag(-1)
                }
            }
            Section("Privacy") {
                Toggle("Auto-pause when screen locks", isOn: $autoPauseOnLock)
                Toggle("Auto-clear history when screen locks", isOn: $autoClearOnLock)
                
                Button("Clear All History") {
                    showingClearConfirm = true
                }
                .foregroundColor(.red)
                .alert("Clear all unpinned clipboard history?", isPresented: $showingClearConfirm) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        try? DatabaseManager.shared.clearUnpinnedHistory()
                    }
                }
            }
            Section("Appearance") {
                Picker("Panel density", selection: $panelDensity) {
                    Text("Compact").tag("Compact")
                    Text("Normal").tag("Normal")
                    Text("Expanded").tag("Expanded")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section("About") {
                Text("PeekBoard v1.0.0")
            }
        }
        .padding(20)
        .frame(width: 480, height: 520)
    }
}
