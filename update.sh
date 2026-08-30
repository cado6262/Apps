#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "⬇️  Pulling latest changes..."
git pull origin claude/add-recipe-of-the-day-NyNOD

echo "🔧 Generating Xcode project..."
xcodegen generate --spec project.yml

echo "🚀 Opening Xcode..."
open NextCooking.xcodeproj

echo "✅ Done!"
