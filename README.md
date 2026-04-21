# PeekBoard
A minimalist, high-performance clipboard manager for macOS. 

Designed to stay out of your way until you need it, PeekBoard silently catalogs your copied text, images, and files—holding them locally, natively, and securely.

---

## Installation

PeekBoard is designed for developers and power users. The most direct way to get started is by building it from source.

### Building from Source (Recommended)
PeekBoard is written in pure Swift and utilizes the native Swift Package Manager (SPM), ensuring a lightweight and transparent installation.

**Requirements:** macOS 13.0+, Swift CLI (Xcode Command Line Tools)

```bash
# Clone the repository
git clone https://github.com/SambhavSirohi05/PeekBoard.git
cd PeekBoard

# Build and install the application directly to your ~/Applications folder
bash build_and_install.sh
```

---

### Alternative: Disk Image (.dmg)
If you prefer a standard installation, you can download a pre-built package.

1. Download the latest `PeekBoard.dmg` from the **Releases** tab.
2. Open the disk image and drag **PeekBoard** into your **Applications** folder.
3. Launch PeekBoard and grant the necessary permissions.

*(Note: On the first launch, right-click the app icon and select "Open" to bypass macOS security checks for unsigned independent software.)*

## Usage & Workflows

PeekBoard stays out of your way. It lives strictly in your menu bar and keyboard—no Dock icon or persistent windows.

### Accessing your History
- **Summon:** Press `Option + V` (⌥V) to bring up the PeekBoard overlay instantly.
- **Menu Bar:** Click the eye icon in your top menu bar for manual access.

### Managing Entries
- **Filter:** Type while the panel is open to instantly filter your history.
- **Copy:** Select an item and press `Return` to push it to your active clipboard.
- **Alias:** Right-click an entry and select `Set Alias` to assign a custom title for rapid retrieval.

### Quick Actions

| `Return` / `⌘C` | Copy the selected item to your clipboard |
| `Backspace` | Permanently delete the selected item |
| `Escape` | Dismiss the panel |

## Privacy by Design

We believe clipboard data is sensitive. PeekBoard operates on a strict local-only philosophy.
*   **Zero Telemetry:** No network entitlements, no tracking, no analytics.
*   **Local Storage:** Your history is indexed in a local SQLite database at `~/Library/Application Support/PeekBoard/`.

## Distribution Packaging

To compile and package a distributable Disk Image (`.dmg`) for others:
```bash
bash package_dmg.sh
```

## License
Distributed under the MIT License.
