#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "⬇️  Neueste Änderungen herunterladen..."
git pull origin claude/add-recipe-of-the-day-NyNOD

echo "🔧 Xcode-Projekt generieren..."
xcodegen generate --spec project.yml

echo "🚀 Xcode öffnen..."
open NextCooking.xcodeproj

echo ""
echo "✅ Fertig! In Xcode:"
echo "   1. Oben links das Ziel auf 'My Mac' setzen"
echo "   2. ▶ Starten drücken — die App läuft direkt auf deinem Mac"
