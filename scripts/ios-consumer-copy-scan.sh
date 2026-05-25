#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PATTERN='investor demo|sandbox demo|local demo|native SwiftUI|seeded|demo GMV|active resellers|catalog health|open reviews|future auth|remittance|money transfer|cash-out|payout|wallet balance|crypto|stablecoin|blockchain|external P2P'

if rg -n -i "$PATTERN" "$ROOT_DIR/SWARPVouchers" "$ROOT_DIR/README.md" "$ROOT_DIR/docs" 2>/dev/null; then
  echo "Consumer copy scan failed: prohibited product or prototype wording found."
  exit 1
fi

echo "Consumer copy scan passed."
