#!/bin/bash
set -e

VERSION=$(defaults read "$(pwd)/PeekBoard/Info.plist" CFBundleShortVersionString)

xcodebuild \
  -scheme PeekBoard \
  -configuration Release \
  -archivePath ./dist/PeekBoard.xcarchive \
  archive

xcodebuild \
  -exportArchive \
  -archivePath ./dist/PeekBoard.xcarchive \
  -exportPath ./dist \
  -exportOptionsPlist ExportOptions.plist

create-dmg \
  --volname "PeekBoard" \
  --window-size 540 380 \
  --icon-size 128 \
  --icon "PeekBoard.app" 150 185 \
  --app-drop-link 390 185 \
  --hide-extension "PeekBoard.app" \
  "./dist/PeekBoard-${VERSION}.dmg" \
  "./dist/PeekBoard.app"

echo "Built: ./dist/PeekBoard-${VERSION}.dmg"
