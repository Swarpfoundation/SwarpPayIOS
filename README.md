# SWARP Vouchers iOS

This folder contains the native iOS app for the SwarpPay / SWARP Digital Vouchers consumer experience.

## Current Scope

- Browse digital voucher and prepaid products.
- Review product details, delivery, verification state, and total price.
- Track orders and view receipts.
- Claim voucher links through the app.
- Contact support without sharing sensitive details.
- Manage profile and verification status.

The app currently uses local fixtures for development while preserving the product-facing consumer flow.

## Open In Xcode

1. Open `SWARPVouchers.xcodeproj`.
2. Select the `SWARPVouchers` scheme.
3. Choose an iOS Simulator.
4. Build and run.

For unsigned simulator validation:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project SWARPVouchers.xcodeproj \
  -scheme SWARPVouchers \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Do not add real provider credentials, voucher codes, document references, Apple Team IDs, or production signing values to this folder.
