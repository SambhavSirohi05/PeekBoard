#!/bin/bash
set -e

APP_NAME="PeekBoard"
DMG_NAME="${APP_NAME}.dmg"
DMG_VOL_NAME="${APP_NAME} Installer"
STAGING_DIR="build/dmg_staging"
SOURCE_APP="build/staging/${APP_NAME}.app"

# Ensure we're in the project root
cd "$(dirname "$0")"

echo "=== Building ${APP_NAME} in Release mode ==="
swift build -c release

# Use the existing build_and_install assembly logic but without the install part
# We'll just run a partial version of build_and_install.sh or replicate it here.
# For simplicity and reliability, let's replicate the assembly logic.

echo "=== Assembling App Bundle ==="
rm -rf "build/staging"
mkdir -p "build/staging/${APP_NAME}.app/Contents/MacOS"
mkdir -p "build/staging/${APP_NAME}.app/Contents/Resources"

cp ".build/release/${APP_NAME}" "build/staging/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

# Create Info.plist
cat > "build/staging/${APP_NAME}.app/Contents/Info.plist" << 'PLIST'
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

echo -n "APPL????" > "build/staging/${APP_NAME}.app/Contents/PkgInfo"

# Recover resources from existing installation if build folder was wiped
INSTALLED_APP="$HOME/Applications/${APP_NAME}.app"

if [ -f "${INSTALLED_APP}/Contents/Resources/AppIcon.icns" ]; then
    cp "${INSTALLED_APP}/Contents/Resources/AppIcon.icns" "build/staging/${APP_NAME}.app/Contents/Resources/"
    echo "Restored AppIcon.icns from installed app"
fi

if [ -f "github-logo.png" ]; then
    cp "github-logo.png" "build/staging/${APP_NAME}.app/Contents/Resources/"
fi

if [ -f "${INSTALLED_APP}/Contents/Resources/Assets.car" ]; then
    cp "${INSTALLED_APP}/Contents/Resources/Assets.car" "build/staging/${APP_NAME}.app/Contents/Resources/"
    echo "Restored Assets.car from installed app"
fi

if [ -d "${INSTALLED_APP}/Contents/Resources/GRDB_GRDB.bundle" ]; then
    cp -R "${INSTALLED_APP}/Contents/Resources/GRDB_GRDB.bundle" "build/staging/${APP_NAME}.app/Contents/Resources/"
    echo "Restored GRDB bundle"
fi

echo "Code signing..."
codesign --force --sign - "build/staging/${APP_NAME}.app"

echo "=== Creating DMG Staging Area ==="
rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}"
cp -R "build/staging/${APP_NAME}.app" "${STAGING_DIR}/"
ln -s /Applications "${STAGING_DIR}/Applications"

echo "=== Creating Disk Image ==="
rm -f "${DMG_NAME}"
hdiutil create -volname "${DMG_VOL_NAME}" -srcfolder "${STAGING_DIR}" -ov -format UDRW "tmp_${DMG_NAME}"

echo "=== Arranging DMG Layout ==="
device=$(hdiutil attach -readwrite -noverify "tmp_${DMG_NAME}" | grep "/Volumes/${DMG_VOL_NAME}" | awk '{print $1}')
sleep 2

osascript <<EOT
tell application "Finder"
    tell disk "${DMG_VOL_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 880, 480}
        set viewOptions to the icon view options of container window
        set icon size of viewOptions to 128
        set arrangement of viewOptions to not arranged
        set position of item "${APP_NAME}.app" of container window to {120, 130}
        set position of item "Applications" of container window to {360, 130}
        close
    end tell
end tell
EOT

chmod -Rf go-w /Volumes/"${DMG_VOL_NAME}" || true
sync
hdiutil detach "${device}"

echo "=== Converting and Compressing DMG ==="
hdiutil convert "tmp_${DMG_NAME}" -format UDZO -o "${DMG_NAME}"
rm "tmp_${DMG_NAME}"

echo "=== Cleaning up ==="
rm -rf "${STAGING_DIR}"

echo "=== Done! ${DMG_NAME} created successfully ==="
