#!/bin/bash
set -e

APP_NAME="PeekBoard"
BUILT_BINARY=".build/release/PeekBoard"
STAGING_DIR="build/staging"
APP_BUNDLE="${STAGING_DIR}/${APP_NAME}.app"
INSTALL_DIR="$HOME/Applications"
INSTALLED_APP="${INSTALL_DIR}/${APP_NAME}.app"

echo "=== Assembling ${APP_NAME}.app bundle ==="

# Clean and create staging directory
rm -rf "${STAGING_DIR}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy the built binary
cp "${BUILT_BINARY}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Create Info.plist with resolved values
cat > "${APP_BUNDLE}/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>PeekBoard</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>com.peekboard.PeekBoard</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>PeekBoard</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>LSUIElement</key>
	<true/>
</dict>
</plist>
PLIST

# Create PkgInfo
echo -n "APPL????" > "${APP_BUNDLE}/Contents/PkgInfo"

# Copy AppIcon.icns
if [ -f "build/AppIcon.icns" ]; then
    cp "build/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    echo "Copied AppIcon.icns"
fi

if [ -f "github-logo.png" ]; then
    cp "github-logo.png" "${APP_BUNDLE}/Contents/Resources/github-logo.png"
    echo "Copied github-logo.png"
fi

# Copy Assets.car (check Xcode build output first, then installed app)
if [ -f "build/Release/PeekBoard.app/Contents/Resources/Assets.car" ]; then
    cp "build/Release/PeekBoard.app/Contents/Resources/Assets.car" "${APP_BUNDLE}/Contents/Resources/Assets.car"
    echo "Copied Assets.car from Xcode build"
elif [ -f "${INSTALLED_APP}/Contents/Resources/Assets.car" ]; then
    cp "${INSTALLED_APP}/Contents/Resources/Assets.car" "${APP_BUNDLE}/Contents/Resources/Assets.car"
    echo "Copied Assets.car from installed app"
else
    echo "WARNING: No Assets.car found! Menu bar icons may not work."
fi

# Copy GRDB bundle from installed app
if [ -d "${INSTALLED_APP}/Contents/Resources/GRDB_GRDB.bundle" ]; then
    cp -R "${INSTALLED_APP}/Contents/Resources/GRDB_GRDB.bundle" "${APP_BUNDLE}/Contents/Resources/"
    echo "Copied GRDB bundle from installed app"
elif [ -d "build/Release/PeekBoard.app/Contents/Resources/GRDB_GRDB.bundle" ]; then
    cp -R "build/Release/PeekBoard.app/Contents/Resources/GRDB_GRDB.bundle" "${APP_BUNDLE}/Contents/Resources/"
    echo "Copied GRDB bundle from previous build"
fi

# Ad-hoc code sign
echo "Code signing..."
codesign --force --sign - "${APP_BUNDLE}"

echo "=== Quitting running PeekBoard ==="
killall PeekBoard 2>/dev/null || true
sleep 1

echo "=== Installing to ${INSTALL_DIR} ==="
mkdir -p "${INSTALL_DIR}"
rm -rf "${INSTALLED_APP}"
cp -R "${APP_BUNDLE}" "${INSTALLED_APP}"

echo "=== Launching PeekBoard ==="
open "${INSTALLED_APP}"

echo "=== Done! PeekBoard has been updated and relaunched ==="
