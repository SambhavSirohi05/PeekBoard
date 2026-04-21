# PeekBoard
A minimalist, high-performance clipboard manager for macOS. 

Designed to stay out of your way until you need it, PeekBoard silently catalogs your copied text, images, and files—holding them locally, natively, and securely.

---

## Installation

As an independent, open-source tool, PeekBoard is distributed directly via a Disk Image.

1. Download the latest `PeekBoard.dmg` from the **Releases** tab.
2. Open the downloaded file and drag the **PeekBoard** application into your **Applications** folder shortcut.
3. Launch PeekBoard from your Applications. 

*(Note: On the first launch, macOS may prompt you to confirm opening an application downloaded from the internet. Simply right-click the app icon and select "Open" to bypass this standard security check.)*

## Usage & Workflows

PeekBoard integrates cleanly. There is no Dock icon or persistent window—it lives strictly in your menu bar and keyboard.

### Accessing your History
- **Summon:** Press `Option + V` (⌥V) anywhere on your system to bring up the PeekBoard overlay.
- **Menu Bar:** Alternatively, click the eye icon stationed in your top menu bar.

### Managing Entries
- **Filter:** Start typing immediately while the panel is open to instantly filter your history by text content or alias.
- **Copy:** Select an item and press `Return` (or double-click) to push it directly to your active macOS clipboard.
- **Pin:** Select an item and press `⌘D` to pin it. Pinned items are anchored to the top and protected from the "Clear All" functionality in Settings.
- **Alias:** Right-click an entry and select `Set Alias` to assign a custom, human-readable title to specific snippets, URLs, or images for rapid retrieval.

### Quick Actions

| Command | Action |
| --- | --- |
| `⌥V` | Summon or dismiss the active panel |
| `↑` / `↓` | Navigate the history list |
| `Return` | Copy the selected item to your clipboard |
| `⌘C` | Copy the selected item to your clipboard |
| `⌘D` | Toggle Pin / Unpin status |
| `Backspace` | Permanently delete the selected item |
| `⌘1`–`⌘9` | Instantly copy the 1st through 9th item |
| `Escape` | Dismiss the panel |

## Privacy by Design

We believe clipboard data is highly sensitive. PeekBoard operates on a strict local-only philosophy.
*   **Zero Telemetry:** The application contains absolutely zero network entitlements, tracking scripts, or external analytics.
*   **Local Storage:** Your history is indexed efficiently in a local SQLite database powered by GRDB, stored securely at `~/Library/Application Support/PeekBoard/`.

## Building from Source

PeekBoard is written in pure Swift and utilizes the native Swift Package Manager (SPM), bypassing heavy standard Xcode workspaces.

**Requirements:** macOS 13.0+, Swift CLI

```bash
# Clone the repository
git clone https://github.com/SambhavSirohi05/PeekBoard.git
cd PeekBoard

# Build and install the application straight to your hard drive
bash build_and_install.sh
```

To compile and package a distributable Disk Image (`.dmg`):
```bash
bash package_dmg.sh
```

## License
Distributed under the MIT License.
