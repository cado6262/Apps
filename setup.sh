#!/bin/bash
set -e

echo ""
echo "====================================="
echo "  Next Cooking – Xcode Setup"
echo "====================================="
echo ""

# Homebrew prüfen
if ! command -v brew &>/dev/null; then
    echo "Homebrew wird installiert..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# xcodegen installieren
if ! command -v xcodegen &>/dev/null; then
    echo "xcodegen wird installiert (einmalig)..."
    brew install xcodegen
else
    echo "xcodegen bereits vorhanden."
fi

echo ""
echo "Xcode-Projekt wird generiert..."
xcodegen generate --spec project.yml

echo ""
echo "Xcode wird geoeffnet..."
open NextCooking.xcodeproj

echo ""
echo "Fertig! Xcode sollte sich jetzt oeffnen."
echo ""
echo "WICHTIG: In Xcode einmalig machen:"
echo "  1. Oben dein Team unter Signing & Capabilities eintragen"
echo "  2. HealthKit ist bereits aktiviert"
echo "  3. Simulator oder iPhone auswaehlen und Run druecken"
echo ""
