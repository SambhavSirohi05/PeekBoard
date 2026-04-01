import SwiftUI

struct PanelFooterView: View {
    @ObservedObject var ax = AccessibilityChecker.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            if !ax.isTrusted {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("Auto-paste unavailable")
                        .font(.footnote)
                    Spacer()
                    Button("Fix This") {
                        ax.openAccessibilitySettings()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.accentColor)
                    .font(.footnote)
                }
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(Color.yellow.opacity(0.1))
                
                Divider()
            }
            
            HStack {
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 14)
            .frame(height: 36)
        }
        .onAppear {
            ax.startPolling()
        }
    }
}
