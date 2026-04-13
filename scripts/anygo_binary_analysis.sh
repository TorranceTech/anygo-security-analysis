#!/bin/bash
# anygo_binary_analysis.sh
# AnyGo Mac Binary - Static Analysis Script
# Author: @TorranceTech
# Usage: bash anygo_binary_analysis.sh

BINARY="/Applications/AnyGo.app/Contents/MacOS/AnyGo"
OUTPUT_DIR="./output"

mkdir -p "$OUTPUT_DIR"

echo "================================================"
echo "  AnyGo Binary Analysis"
echo "  $(date)"
echo "================================================"

echo ""
echo "[1] File Info"
file "$BINARY"

echo ""
echo "[2] Endpoints & URLs"
strings "$BINARY" | grep -iE "https?://|\.cn|api\." | sort -u | tee "$OUTPUT_DIR/endpoints.txt"

echo ""
echo "[3] SIP / csrutil References"
strings "$BINARY" | grep -i "SIP\|csrutil\|rootless\|DisableSIP\|isEnableSIP" | tee "$OUTPUT_DIR/sip_refs.txt"

echo ""
echo "[4] Location / GPS Strings"
strings "$BINARY" | grep -iE "location|gps|coordinate|latitude|longitude|spoof|mock|fake" | tee "$OUTPUT_DIR/location_strings.txt"

echo ""
echo "[5] Linked Frameworks"
otool -L "$BINARY" 2>/dev/null | tee "$OUTPUT_DIR/frameworks.txt"

echo ""
echo "[6] SIP Status (this machine)"
csrutil status

echo ""
echo "[7] Frida Process Check"
frida-ps 2>/dev/null | grep -i anygo || echo "AnyGo not running or Frida not available"

echo ""
echo "================================================"
echo "  Done. Results saved to $OUTPUT_DIR/"
echo "================================================"
