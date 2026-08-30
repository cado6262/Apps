#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "⬇️  Änderungen herunterladen..."
git pull origin claude/add-recipe-of-the-day-NyNOD

echo "🔧 Xcode-Projekt generieren..."
xcodegen generate --spec project.yml

echo "📱 iPhone Simulator starten..."
UDID=$(xcrun simctl list devices available | grep "iPhone 16" | grep -v "Pro" | head -1 | grep -Eo "[0-9A-F-]{36}" | head -1)
if [ -z "$UDID" ]; then
  UDID=$(xcrun simctl list devices available | grep "iPhone 15" | grep -v "Pro" | head -1 | grep -Eo "[0-9A-F-]{36}" | head -1)
fi
if [ -n "$UDID" ]; then
  xcrun simctl boot "$UDID" 2>/dev/null || true
  open -a Simulator
fi

echo "🚀 Xcode öffnen..."
open NextCooking.xcodeproj

echo ""
echo "✅ Fertig! Drücke in Xcode auf ▶"
