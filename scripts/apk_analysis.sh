#!/bin/bash
# apk_analysis.sh
# Pokémon GO Modified APK - Analysis Script
# Author: @TorranceTech
# Usage: bash apk_analysis.sh <path_to_apk>

APK="${1:-~/pokemongo_anygo.apk}"
EXTRACT_DIR="/tmp/poke_extract"
OUTPUT_DIR="./output"

mkdir -p "$OUTPUT_DIR" "$EXTRACT_DIR"

echo "================================================"
echo "  Modified Pokémon GO APK Analysis"
echo "  APK: $APK"
echo "  $(date)"
echo "================================================"

echo ""
echo "[1] File Info & MD5"
file "$APK"
md5 "$APK"

echo ""
echo "[2] APK Contents (top 30)"
unzip -l "$APK" | head -30

echo ""
echo "[3] Native Libraries (.so)"
unzip -l "$APK" | grep "\.so$" | awk '{print $4}' | tee "$OUTPUT_DIR/native_libs.txt"

echo ""
echo "[4] Extracting APK"
unzip -o "$APK" -d "$EXTRACT_DIR" 2>&1 | tail -5

echo ""
echo "[5] Signing Certificate"
keytool -printcert -jarfile "$APK" 2>&1 | grep -E "Owner|Issuer|Valid|SHA|MD5|Signer" | tee "$OUTPUT_DIR/certificate.txt"

echo ""
echo "[6] Anti-Cheat Bypass Strings (classes.dex)"
cd "$EXTRACT_DIR" && strings classes*.dex | grep -iE \
  "gps|spoof|location|fake|virtual|mock|simulat|bypass|anti|detect|niantic|root|violation|cheat" \
  | sort -u | head -80 | tee "$OUTPUT_DIR/anticheat_strings.txt"

echo ""
echo "[7] Package Activity"
strings "$EXTRACT_DIR/classes.dex" | grep -i "nianticproject\|holoholo\|PKG_ACTIVITY" | head -10

echo ""
echo "================================================"
echo "  Done. Results saved to $OUTPUT_DIR/"
echo "================================================"
