#!/bin/bash
# fetch_endpoints.sh
# AnyGo JSON Endpoint Enumeration
# Author: @TorranceTech

OUTPUT_DIR="./output/json"
mkdir -p "$OUTPUT_DIR"

ENDPOINTS=(
  "https://download.itoolab.com/resources/anygo/pokmgo.json"
  "https://download.itoolab.com/updateinfo/anygo_update_mac.json"
  "https://download.onvideoeditor.com/resources/anygo/discount/anygo_discount.json"
)

echo "================================================"
echo "  AnyGo Endpoint Enumeration"
echo "  $(date)"
echo "================================================"

for url in "${ENDPOINTS[@]}"; do
  filename=$(basename "$url")
  echo ""
  echo "[*] Fetching: $url"
  curl -s "$url" | python3 -m json.tool | tee "$OUTPUT_DIR/$filename"
  echo ""
done

echo "================================================"
echo "  Done. JSON files saved to $OUTPUT_DIR/"
echo "================================================"
