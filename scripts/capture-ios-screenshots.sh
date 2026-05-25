#!/usr/bin/env bash
set -euo pipefail

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

DEVICE_ID="${1:-6CDC7BFF-A06E-4050-9614-A1E000578251}"
APP_ID="com.swarppay.localdemo.SWARPVouchers"
APP_PATH="${2:-/private/tmp/SwarpPayDerivedDataConsumer/Build/Products/Debug-iphonesimulator/SWARPVouchers.app}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/test-results/ios-screenshots"

mkdir -p "$OUT_DIR"

xcrun simctl install "$DEVICE_ID" "$APP_PATH"

capture() {
  local name="$1"
  local wait_seconds="${2:-1.2}"
  shift || true
  shift || true
  xcrun simctl terminate "$DEVICE_ID" "$APP_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$DEVICE_ID" "$APP_ID" "$@" >/dev/null
  sleep "$wait_seconds"
  xcrun simctl io "$DEVICE_ID" screenshot "$OUT_DIR/${name}.png" >/dev/null
}

capture splash 1.0
capture home 1.2 --swarp-skip-intro --swarp-demo-route home
capture catalog 1.2 --swarp-skip-intro --swarp-demo-route catalog
capture product-detail 1.2 --swarp-skip-intro --swarp-demo-route product/spotify
capture checkout 1.2 --swarp-skip-intro --swarp-demo-route checkout/spotify
capture my-vouchers 1.2 --swarp-skip-intro --swarp-demo-route vouchers
capture receipt 1.2 --swarp-skip-intro --swarp-demo-route receipt/spotify
capture claim 1.2 --swarp-skip-intro --swarp-demo-route claim/ABCD1234
capture support 1.2 --swarp-skip-intro --swarp-demo-route support
capture profile 1.2 --swarp-skip-intro --swarp-demo-route profile

echo "Screenshots saved to $OUT_DIR"
