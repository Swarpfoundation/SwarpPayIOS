# SwarpPay iOS Security Remediation

## 1. Summary

This pass hardened the iOS app as a safe frontend/demo build, not a production payment or voucher system.

Fixed locally:
- Centralized build/security feature availability.
- Release now uses a fail-closed `NoBackendAPIClient`.
- Release disables local auth, checkout, voucher claim, receipt issuing, KYC authority, and support submission.
- Demo API and fixtures are compile-time Debug-only.
- Demo custom URL scheme was removed from `Info.plist`.
- Deep links are HTTPS-only and fail closed in Release because no production Associated Domains exist.
- Keychain session storage now uses explicit `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`, update-or-add semantics, and typed errors.
- Privacy manifest was added and included in the app target.
- Notification/support copy was made generic and non-sensitive.
- A SwiftUI background/app-switcher privacy shield was added.
- Release gate script was added at `scripts/security-release-gate.sh`.

Intentionally not implemented:
- Real backend, real auth, payment processing, voucher issuing/claiming, KYC authority, receipt issuing, App Attest server verification, certificate pinning, or PCI provider integration.

Current posture:
- Acceptable only as a frontend/demo build with sensitive actions disabled.
- Not safe for real money, real vouchers, real KYC, or production payment flows.

## 2. Files Changed

- `SWARPVouchers/Core/EnvironmentConfig.swift`: Added `BuildMode`, `FeatureAvailability`, `SecurityPolicy`, `AppEnvironment`, and Debug-only demo data accessors.
- `SWARPVouchers/Networking/APIClient.swift`: Added typed API errors and `NoBackendAPIClient`; removed default local API config from `URLSessionAPIClient`.
- `SWARPVouchers/Core/AppState.swift`: Removed Release default demo backend; made demo auth and launch-route handling Debug-only; added local session clear path.
- `SWARPVouchers/Demo/DemoAPIClient.swift`: Wrapped demo client and fixtures in `#if DEBUG`.
- `SWARPVouchers/Core/SecureSessionStore.swift`: Hardened Keychain accessibility, errors, update/add/delete handling.
- `SWARPVouchers/Core/DeepLinkRouter.swift`: Removed custom scheme support; Release has no allowed production hosts until Associated Domains are configured.
- `SWARPVouchers/Info.plist`: Removed demo URL scheme registration.
- `SWARPVouchers/PrivacyInfo.xcprivacy`: Added manifest with no tracking and no Release data collection declared.
- `SWARPVouchers.xcodeproj/project.pbxproj`: Added privacy manifest to resources; Release bundle identifier now depends on external `SWARPPAY_PRODUCT_BUNDLE_IDENTIFIER`.
- `SWARPVouchers/App/RootView.swift`: Added scene-phase privacy shield.
- Auth, Home, Catalog, Product, Checkout, Claim, Orders, Receipts, KYC, Profile, Notifications, Support views: disabled backend-required actions in Release and removed sensitive/mock-success copy from Release-visible states.
- `scripts/security-release-gate.sh`: Added deterministic release scan.
- `RELEASE_CONFIGURATION_REQUIRED.md`: Documents required external production values.

## 3. Findings Addressed

- `SP-IOS-001`: Fixed. Release no longer defaults to `DemoAPIClient`; it uses fail-closed `NoBackendAPIClient`.
- `SP-IOS-002`: Fixed. Prefilled credentials removed from Release; demo auth is Debug-only; no hardcoded Release session handle.
- `SP-IOS-005`: Fixed. Release has no local HTTP API path; URLSession client requires HTTPS when used outside Debug.
- `SP-IOS-006`: Fixed/External configuration required. Demo URL scheme removed; universal links require real Associated Domains later.
- `SP-IOS-007`: Fixed for local storage. Keychain now has explicit ThisDeviceOnly/passcode accessibility and typed error handling.
- `SP-IOS-008`: Partially fixed. Local clear path exists; server revocation is deferred until backend auth exists.
- `SP-IOS-011`: Fixed. `PrivacyInfo.xcprivacy` exists and is in target resources.
- `SP-IOS-012`: External configuration required. No Apple Team ID or production bundle ID was invented.
- `SP-IOS-013`: Fixed. Notification/support copy is generic; support submission is disabled in Release.
- `SP-IOS-014`: Fixed. Root scene-phase privacy shield and `.privacySensitive()` markings were added.

## 4. Backend/Payment-Dependent Items Deferred

These are not fixed by iOS-only changes:
- Real authentication.
- Token expiry, refresh, and revocation.
- Checkout authorization.
- Payment processing.
- Voucher issuing.
- Voucher claiming.
- Receipt issuing.
- KYC authority.
- App Attest server verification.
- Certificate pinning for a production API host.
- PCI/payment provider scope.

App Attest requires server verification and is intentionally not completed in this no-backend build. Certificate pinning is also deferred until a real production API host, backup pins, and rotation plan exist.

## 5. Release Safety

Release no longer ships:
- Demo backend as authority.
- Hardcoded credentials.
- Local payment success.
- Local claim success.
- Local receipt issuing from checkout/claim actions.
- HTTP localhost API endpoint.
- Demo custom URL scheme.
- Sensitive notification bodies.
- Sensitive app-switcher snapshots.

Release-visible sensitive flows show unavailable states and explain that backend verification is required. Debug still supports internal demo fixtures for UI iteration.

## 6. External Configuration Still Required

- Apple Developer Team ID.
- Final production bundle identifier via `SWARPPAY_PRODUCT_BUNDLE_IDENTIFIER`.
- Production Associated Domains.
- Production privacy policy URL.
- App Store privacy answers.
- Legal entity submission confirmation.
- Backend API URL.
- Payment provider architecture.
- Voucher/IAP classification.
- App Attest server rollout.
- Certificate pinning host and backup pins.

## 7. Verification Commands

- `pwd`: `/Users/gorkhmazbeydullayev/Developer/SWARPVouchers`.
- `find . -maxdepth 4 -type f | sed 's#^\./##' | sort | head -500`: completed; confirmed app source, assets, docs, scripts, and security reports.
- `find . -name "*.xcodeproj" ...`: found `SWARPVouchers.xcodeproj`, workspace, `Info.plist`, and `PrivacyInfo.xcprivacy`; no entitlements, pods, Carthage, Fastlane, or xcconfig files found.
- `xcodebuild -list -project SWARPVouchers.xcodeproj`: passed; one target and one scheme: `SWARPVouchers`.
- `xcodebuild -showBuildSettings -project SWARPVouchers.xcodeproj -scheme SWARPVouchers -configuration Release`: passed; Release uses `Info.plist`, app icon `AppIcon`, no development team configured, and external bundle identifier setting.
- `plutil -p SWARPVouchers/Info.plist`: passed; no `CFBundleURLTypes`.
- `plutil -p SWARPVouchers/PrivacyInfo.xcprivacy`: passed; tracking false, no collected data, no accessed API declarations.
- Broad `rg` security scan: completed; remaining demo symbols are in `#if DEBUG`, demo files, docs, or the release gate script itself.
- `scripts/security-release-gate.sh`: passed.
- `xcodebuild -project SWARPVouchers.xcodeproj -scheme SWARPVouchers -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/SwarpPayHardeningDebug CODE_SIGNING_ALLOWED=NO build`: passed.
- `xcodebuild -project SWARPVouchers.xcodeproj -scheme SWARPVouchers -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/SwarpPayHardeningRelease CODE_SIGNING_ALLOWED=NO build`: passed; bundle identifier remains externally required.

## 8. Remaining Risk

This app is not yet safe for real money, real voucher issuance, real voucher claiming, real KYC, real payment authorization, or production support workflows.

The app is acceptable only as a frontend/demo build with sensitive actions disabled until backend, payment provider, App Attest server verification, privacy policy, App Store disclosures, production signing, and PCI/payment scope are completed.
