#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0
release_view="$(mktemp)"
release_file_list="$(mktemp)"
trap 'rm -f "$release_view" "$release_file_list" /tmp/swarppay-release-gate-match.txt' EXIT

find SWARPVouchers -type f \( -name "*.swift" -o -name "Info.plist" -o -name "PrivacyInfo.xcprivacy" \) \
  ! -path "SWARPVouchers/Demo/*" \
  | sort > "$release_file_list"

if [[ ! -s "$release_file_list" ]]; then
  echo "security-release-gate: no release-relevant source files found"
  exit 1
fi

awk '
  FNR == 1 { skip = 0 }
  /^[[:space:]]*#if[[:space:]]+DEBUG/ { skip = 1; next }
  /^[[:space:]]*#else/ && skip { skip = 0; next }
  /^[[:space:]]*#endif/ { if (skip) { skip = 0; next } }
  !skip { print FILENAME ":" FNR ":" $0 }
' $(cat "$release_file_list") | grep -v "www.apple.com/DTDs" > "$release_view" || true

check_absent() {
  local label="$1"
  local pattern="$2"
  if grep -E -n "$pattern" "$release_view" >/tmp/swarppay-release-gate-match.txt; then
    echo "FAIL: $label found in Release-relevant code:"
    cat /tmp/swarppay-release-gate-match.txt
    failures=$((failures + 1))
  fi
}

check_file_absent() {
  local label="$1"
  local file="$2"
  local pattern="$3"
  local stripped_file
  stripped_file="$(mktemp)"
  awk '
    /^[[:space:]]*#if[[:space:]]+DEBUG/ { skip = 1; next }
    /^[[:space:]]*#else/ && skip { skip = 0; next }
    /^[[:space:]]*#endif/ { if (skip) { skip = 0; next } }
    !skip { print FNR ":" $0 }
  ' "$file" > "$stripped_file"
  if grep -E -n "$pattern" "$stripped_file" >/tmp/swarppay-release-gate-match.txt; then
    echo "FAIL: $label found in $file Release view:"
    cat /tmp/swarppay-release-gate-match.txt
    failures=$((failures + 1))
  fi
  rm -f "$stripped_file"
}

check_absent "plain HTTP endpoint" "http://"
check_absent "local host endpoint" "localhost"
check_absent "legacy local demo config" "localDemo"
check_absent "demo API client reference" "DemoAPIClient"
check_absent "demo fixture reference" "DemoFixtures"
check_absent "demo auth bypass" "completeDemoAuth"
check_absent "demo custom URL scheme" "swarpvouchers-demo"
check_absent "broad ATS bypass" "NSAllowsArbitraryLoads"
check_absent "hardcoded session handle" "swarppay-session"
check_absent "hardcoded non-empty passcode" "passcode[[:space:]]*=[[:space:]]*\"[^\"]+\""

if grep -q "CFBundleURLTypes" SWARPVouchers/Info.plist; then
  echo "FAIL: Info.plist still registers URL schemes. Use verified universal links before enabling sensitive routes."
  failures=$((failures + 1))
fi

check_file_absent "local receipt navigation from checkout" "SWARPVouchers/Features/Checkout/PaymentWidget.swift" "AppRoute[.]receipt|Confirm purchase|receiptIdForProduct"
check_file_absent "local claim completion" "SWARPVouchers/Features/Claim/ClaimPreviewView.swift" "selectedTab[[:space:]]*=[[:space:]]*[.]vouchers"

release_bundle_setting="$(
  awk '
    /190000000000000000000004 .* Release/ { in_release = 1 }
    in_release && /PRODUCT_BUNDLE_IDENTIFIER/ { print; exit }
    in_release && /^		};/ { in_release = 0 }
  ' SWARPVouchers.xcodeproj/project.pbxproj
)"

if [[ "$release_bundle_setting" == *localdemo* ]]; then
  echo "FAIL: Release PRODUCT_BUNDLE_IDENTIFIER still contains localdemo: $release_bundle_setting"
  failures=$((failures + 1))
fi

if [[ "$release_bundle_setting" != *SWARPPAY_PRODUCT_BUNDLE_IDENTIFIER* ]]; then
  echo "FAIL: Release PRODUCT_BUNDLE_IDENTIFIER must come from external SWARPPAY_PRODUCT_BUNDLE_IDENTIFIER."
  failures=$((failures + 1))
fi

if [[ $failures -ne 0 ]]; then
  echo "security-release-gate: failed with $failures issue(s)."
  exit 1
fi

echo "security-release-gate: passed"
