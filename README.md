# PeekBoard
> Everything you copy, one blink away.

## Install
1. Download PeekBoard-1.0.0.dmg from Releases
2. Drag PeekBoard to Applications
3. Open PeekBoard
4. Grant Accessibility access when prompted (System Settings → Privacy & Security → Accessibility)

## Keyboard Shortcuts
| Shortcut | Action |
|---|---|
| ⌥V | Open / close panel |
| ↑ ↓ | Navigate items |
| Return | Paste selected |
| ⌘+Return | Paste as plain text |
| ⌘1–9 | Paste item 1–9 directly |
| ⌘D | Pin / Unpin |
| Escape | Close panel |

## Building from Source
Requirements: Xcode 15+, macOS 13+
```bash
brew install create-dmg xcodegen
xcodegen
open PeekBoard.xcodeproj
```

For a DMG:
```bash
./build.sh
```

## Privacy
PeekBoard has zero network entitlements. 
All clipboard data is stored locally at:
`~/Library/Application Support/PeekBoard/`

## License
MIT
