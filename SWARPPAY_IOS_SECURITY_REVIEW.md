# SwarpPay iOS Security Review

## 1. Executive Summary

- **Overall risk rating:** High for production release.
- **Release recommendation:** **No-Go for App Store production** until the release blockers below are fixed and the backend authorization model is verified.
- **Review type:** Local static and configuration review of the iOS repository only. No live systems were attacked, scanned, brute-forced, exploited, or tested.
- **Primary standards:** OWASP MASVS and OWASP MASTG iOS methodology, with Apple iOS security, privacy, App Store, Keychain, ATS, App Attest / DeviceCheck, and PCI considerations.

### Top 5 Highest-Risk Issues

1. **Demo API client is the default app backend** (`SWARPVouchers/Core/AppState.swift`, `SWARPVouchers/Demo/DemoAPIClient.swift`). This bypasses real authentication, catalog, orders, receipts, claim preview, support, and KYC state.
2. **Payment/voucher checkout is completed locally** (`SWARPVouchers/Features/Checkout/PaymentWidget.swift`). The app calculates fees, accepts selected denominations, and navigates to receipts without server confirmation.
3. **Voucher claim flow is completed locally** (`SWARPVouchers/Features/Claim/ClaimPreviewView.swift`, `SWARPVouchers/Demo/DemoAPIClient.swift`). This is unsafe for any real voucher redemption.
4. **Plain HTTP local API endpoint is compiled into the app configuration** (`SWARPVouchers/Core/EnvironmentConfig.swift`). Production endpoint separation and TLS-only configuration are absent.
5. **Release configuration is not App Store ready** (`SWARPVouchers.xcodeproj/project.pbxproj`, `SWARPVouchers/Info.plist`). Release has `CODE_SIGNING_ALLOWED = NO`, empty `DEVELOPMENT_TEAM`, a `localdemo` bundle identifier, demo URL scheme, and no privacy manifest.

### App Store Release Blockers

- Demo backend/client remains in the default app state.
- Release signing is disabled and the development team is empty.
- Bundle identifier is `com.swarppay.localdemo.SWARPVouchers`.
- App display name is still `SWARP Vouchers`, not a final SwarpPay production name.
- `PrivacyInfo.xcprivacy` is absent.
- No Associated Domains entitlement exists for universal links.
- Custom URL scheme is `swarpvouchers-demo`.
- Production privacy policy URL, App Store privacy answers, legal entity submission status, voucher/IAP classification, and regulated financial/crypto licensing are not verifiable from this repository.

### Fintech / Payment-Specific Concerns

This app currently behaves like a frontend prototype. The backend must become the sole authority for authentication, session validity, KYC status, limits, amount, currency, fee, voucher ownership, voucher claim state, redemption status, receipt issuance, refunds, settlement, and support/ticket state. App Attest / DeviceCheck, rate limits, idempotency keys, transaction IDs, replay protection, and server-side fraud monitoring are not visible in the iOS repository and require backend verification.

## 2. Scope and Method

### Repository Paths Reviewed

- Repository root: `/Users/gorkhmazbeydullayev/Developer/SWARPVouchers`
- Xcode project: `SWARPVouchers.xcodeproj`
- Main app source: `SWARPVouchers/`
- Scripts: `scripts/`
- Docs and local screenshots: `docs/`, `test-results/ios-screenshots/`

### Commands Executed

- `pwd`
- `find . -maxdepth 3 -type f | sed 's#^\./##' | sort | head -300`
- `find . -name "*.xcodeproj" -o -name "*.xcworkspace" -o -name "Package.resolved" -o -name "Podfile.lock" -o -name "Cartfile.resolved" -o -name "*.entitlements" -o -name "Info.plist" -o -name "PrivacyInfo.xcprivacy" -o -name "*.xcconfig" -o -name "Fastfile" -o -name "*.yml" -o -name "*.yaml"`
- `/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -list -project SWARPVouchers.xcodeproj`
- `/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -showBuildSettings -project SWARPVouchers.xcodeproj -scheme SWARPVouchers -configuration Release`
- `plutil -p SWARPVouchers/Info.plist`
- Broad `rg` search for ATS, networking, WebView, UserDefaults, Keychain, crypto, token, voucher, deep link, logging, SDK, App Attest, DeviceCheck, jailbreak, and privacy keywords.
- Targeted `rg` searches for signing, entitlements, privacy manifests, dependencies, demo routes, and hardcoded values.
- `find` for local `.ipa`, `.app`, `.framework`, `.xcframework`, `.a`, and `.dylib` artifacts.

### Commands Unavailable or Skipped

- `plutil -p` on entitlements and privacy manifests was not applicable because no `.entitlements` or `PrivacyInfo.xcprivacy` files were found.
- IPA inspection was not applicable because no `.ipa` or built `.app` artifact exists inside the repository.
- Dependency vulnerability lookup was not performed because this review is local-only and no dependency lockfiles were present.

### Standards Used

- OWASP MASVS: STORAGE, CRYPTO, AUTH, NETWORK, PLATFORM, CODE, RESILIENCE, PRIVACY.
- OWASP MASTG iOS testing methodology.
- Apple Keychain, Data Protection, ATS, App Attest / DeviceCheck, Privacy Manifest, App Tracking Transparency, and App Store review guidance.
- PCI considerations only from repository evidence.

## 3. Architecture and Attack Surface

### App Architecture

- **Technology:** Native Swift / SwiftUI iOS app.
- **UIKit usage:** Minimal; `UIKit` is imported for haptics in `SWARPVouchers/DesignSystem/SWARPComponents.swift`.
- **React Native / Flutter / Cordova / Capacitor:** Not present from repository evidence.
- **Backend code:** Not present. Repository appears to contain iOS app code, scripts, docs, screenshots, and Xcode project metadata only.

### Project Files, Targets, and Schemes

- `.xcodeproj`: `SWARPVouchers.xcodeproj`
- `.xcworkspace`: `SWARPVouchers.xcodeproj/project.xcworkspace`
- Target: `SWARPVouchers`
- Scheme: `SWARPVouchers`
- Build configurations: `Debug`, `Release`
- App extensions/widgets/notification extensions/watch targets/test targets: none found.

### Dependency Managers and Supply Chain

- Swift Package Manager: no `Package.swift` or `Package.resolved` found.
- CocoaPods: no `Podfile` or `Podfile.lock` found.
- Carthage: no `Cartfile` or `Cartfile.resolved` found.
- Manually embedded frameworks / binary SDKs: none found in the repository.
- Build scripts: `scripts/capture-ios-screenshots.sh`, `scripts/ios-consumer-copy-scan.sh`.
- PBX shell script build phases: none found.

### Configuration and Privacy Files

- `SWARPVouchers/Info.plist` exists.
- No `.entitlements` file found.
- No `PrivacyInfo.xcprivacy` file found.
- No `.xcconfig` files found.
- No `Fastfile` found.
- No CI `.yml` / `.yaml` files found.

### Network/API Surface

- `SWARPVouchers/Networking/APIClient.swift` defines login, register, catalog, orders, receipt, claim preview, support submission, and metrics endpoints.
- `URLSessionAPIClient` defaults to `EnvironmentConfig.localDemo`.
- `EnvironmentConfig.localDemo` uses `http://localhost:3000`.
- No certificate pinning, custom trust evaluation, or App Attest / DeviceCheck code was found.

### Payment / Voucher / Deep-Link Surface

- Voucher catalog and orders are seeded in `DemoFixtures`.
- Checkout is implemented in `SWARPVouchers/Features/Checkout/PaymentWidget.swift`.
- Claim preview is implemented in `SWARPVouchers/Features/Claim/ClaimPreviewView.swift`.
- Deep link parsing is implemented in `SWARPVouchers/Core/DeepLinkRouter.swift`.
- `Info.plist` registers the custom scheme `swarpvouchers-demo`.
- No Associated Domains entitlement found for universal links.
- No QR parser or WebView code found.

### Sensitive Assets

- Session handle storage through Keychain exists in `SecureSessionStore.swift`.
- Demo/default account email, passcode, session handle, KYC status, voucher references, receipts, and order IDs are present in source code.
- No raw card data, private keys, mnemonics, wallet signing code, or payment SDK credentials were found.

## 4. Findings Table

| ID | Severity | Confidence | MASVS Category | Title | Affected File/Location | Impact | Exploit Scenario | Evidence | Recommended Fix | Release Blocker |
|---|---|---:|---|---|---|---|---|---|---|---|
| SP-IOS-001 | Critical | High | AUTH, CODE | Demo API client is the default app backend | `AppState.init`, `DemoAPIClient` | Full auth/business-logic bypass if shipped | Modified client or normal user gets approved KYC, orders, receipts, claims without backend | `AppState.swift:13`, `DemoAPIClient.swift:3-34`, `DemoAPIClient.swift:38-52` | Remove demo client from production builds; inject production API by configuration; fail closed if production config missing | Yes |
| SP-IOS-002 | High | High | AUTH, STORAGE | Hardcoded test credentials/session state | `SplashOnboardingViews`, `AppState.completeDemoAuth` | Account/session bypass and App Store rejection risk | Attacker reverse-engineers default passcode/session path | `SplashOnboardingViews.swift:68-76`, `AppState.swift:28-31` | Remove test credentials; authenticate against backend; store issued tokens securely; delete local demo bypass | Yes |
| SP-IOS-003 | High | High | CODE, AUTH | Checkout completes locally without server confirmation | `CheckoutView`, `DemoFixtures.receipts` | Money/voucher theft if real flow mirrors code | Attacker tampers denomination/fee/product and app still displays receipt | `PaymentWidget.swift:12-15`, `PaymentWidget.swift:69-76`, `DemoAPIClient.swift:134-145` | Server must quote, authorize, charge, issue receipt; app must wait for signed backend result | Yes |
| SP-IOS-004 | High | High | CODE, PLATFORM | Voucher claim flow completes locally | `ClaimPreviewView`, `DemoFixtures.claimPreview` | Voucher replay/unauthorized claim if not server-gated | Attacker opens crafted link and client moves to vouchers | `ClaimPreviewView.swift:8-10`, `ClaimPreviewView.swift:55-61`, `DemoAPIClient.swift:159-168` | Validate claim code server-side; require nonce/expiry/recipient binding; mark single-use on server | Yes |
| SP-IOS-005 | High | High | NETWORK | Plain HTTP local API endpoint is compiled into app config | `EnvironmentConfig.localDemo`, `URLSessionAPIClient` | MITM/plaintext risk and production misrouting | Release build talks to HTTP local/staging endpoint or fails insecurely | `EnvironmentConfig.swift:7-10`, `APIClient.swift:18`, `APIClient.swift:56-65` | Use HTTPS-only production config; compile-time environment separation; no HTTP in Release | Yes |
| SP-IOS-006 | High | High | PLATFORM | Demo custom URL scheme and weak deep-link production posture | `Info.plist`, `DeepLinkRouter` | Claim/payment link interception and unsafe routing risk | Malicious app claims custom scheme or crafted link opens claim/support route | `Info.plist:21-31`, `DeepLinkRouter.swift:4-11`, `DeepLinkRouter.swift:39-52` | Use universal links with Associated Domains; keep custom schemes non-sensitive; validate all links server-side | Yes |
| SP-IOS-007 | High | High | STORAGE | Keychain storage lacks explicit accessibility and access control | `KeychainSessionStore.save/load/clear` | Session handle may be stored with default accessibility; no ThisDeviceOnly/passcode policy | Stolen backup/device compromise exposes long-lived session material more easily | `SecureSessionStore.swift:14-24`, `SecureSessionStore.swift:27-38` | Add `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` or justified alternative; check SecItem status; use access control for high-value secrets | Yes before real tokens |
| SP-IOS-008 | Medium | High | AUTH, STORAGE | Logout/session revocation path is incomplete | `SecureSessionStore.clear`, missing call sites | Stale local sessions and backend sessions may remain active | User logs out or account is stolen; token remains usable | `SecureSessionStore.swift:41-48`; no repository use of `clear()` found | Implement logout UI and backend revocation; clear Keychain and local caches; validate token expiry | Yes before real auth |
| SP-IOS-009 | High | High | RESILIENCE, AUTH | App Attest / DeviceCheck absent for fraud-sensitive actions | Repository-wide search | Tampered clients can automate claim/payment/account abuse without app-integrity signal | Instrumented app calls payment/claim endpoints at scale | Broad scan found no `DCAppAttestService`, `DeviceCheck`, or `AppAttest`; claim/checkout/support actions exist | Add App Attest assertions for claim, checkout, account creation, support abuse, and high-risk actions; verify server-side | Yes before production fraud exposure |
| SP-IOS-010 | Medium | High | NETWORK | No certificate/public-key pinning for sensitive APIs | `URLSessionAPIClient` | Enterprise/root CA or compromised trust path can intercept high-risk APIs | Attacker with local device trust profile proxies checkout/claim API | `APIClient.swift:14-21`, `APIClient.swift:65`; no trust delegate/pinning found | Add public-key or intermediate pinning with backup pins and rotation runbook for payment/voucher APIs | No, but strongly recommended |
| SP-IOS-011 | Medium | High | PRIVACY | Privacy manifest is missing | Repository file map | App Store privacy validation and disclosure risk | App collects contact/support/financial data without manifest coverage | `find` found no `PrivacyInfo.xcprivacy`; app collects email/support content in `SupportView.swift:10`, `SupportView.swift:117-128` | Add `PrivacyInfo.xcprivacy`; document collected data, tracking status, required-reason APIs, and SDK data | Yes |
| SP-IOS-012 | High | High | CODE, PRIVACY | Release signing and bundle configuration are not production-ready | Xcode project build settings | App cannot be submitted as-is; wrong bundle/legal identity risk | Release build uses localdemo bundle and disabled code signing | `project.pbxproj:370-382`, `Info.plist:7-8`, `Info.plist:36-37` | Set organization team, production bundle ID, display name, signing, entitlements, and provisioning | Yes |
| SP-IOS-013 | Medium | Medium | PRIVACY | Notification/support copy can expose voucher/order details | `NotificationsView`, `SupportView` | Sensitive voucher/order data may leak on lock screen or screenshots if reused for APNs | Push notification reveals voucher product/value/reference | `NotificationsView.swift:21-74`, `SupportView.swift:117-128` | Keep push payloads generic; fetch details after unlock; redact voucher codes/order refs in notifications | No |
| SP-IOS-014 | Medium | Medium | PRIVACY | No app-switcher/background privacy shield found | `SWARPVouchersApp`, `RootView` | Sensitive voucher, receipt, KYC, or support data may appear in app switcher snapshot | User backgrounds app; iOS snapshot shows voucher/receipt details | No `scenePhase` or privacy overlay found in reviewed SwiftUI app entry/root files | Add scene phase privacy overlay and mark sensitive screens for redaction when inactive | No |

## 5. Detailed Findings

### SP-IOS-001: Demo API client is the default app backend

- **Severity:** Critical
- **Confidence:** High
- **Category:** MASVS-AUTH, MASVS-CODE
- **Affected files/classes/functions:** `SWARPVouchers/Core/AppState.swift` `AppState.init`; `SWARPVouchers/Demo/DemoAPIClient.swift` `DemoAPIClient`; `DemoFixtures.session`

**What is wrong:**  
`AppState` defaults to `DemoAPIClient()` rather than `URLSessionAPIClient` or a production API client. `DemoAPIClient` returns local seeded sessions, catalog, orders, receipts, claim previews, support ticket IDs, and KYC status.

**Why it matters for SwarpPay:**  
For a payment/voucher app, authentication, KYC tier, voucher ownership, receipt issuance, and claim state must come from server-side authority. A default demo client is a complete business-logic bypass if it reaches production.

**Attack scenario:**  
An attacker reverse-engineers or modifies the app to keep using the demo client, or a production build accidentally ships with the default client. The app presents approved KYC, delivered orders, receipts, and claim previews without server authorization.

**Evidence from repository:**

- `SWARPVouchers/Core/AppState.swift:13`: `api: APIClient = DemoAPIClient()`
- `SWARPVouchers/Demo/DemoAPIClient.swift:3-34`: local implementation of all API methods.
- `SWARPVouchers/Demo/DemoAPIClient.swift:38-52`: session fixture returns approved KYC and a session handle.

**Exact remediation:**

1. Remove `DemoAPIClient` as the default dependency for production app state.
2. Add compile-time environment selection, for example `#if DEBUG` demo client and `#else` production URLSession client with a required production base URL.
3. Make production launch fail closed if no production API configuration is present.
4. Move demo fixtures to a test/demo target or DEBUG-only compilation unit.
5. Add CI checks that fail Release builds if `DemoAPIClient`, `DemoFixtures`, `localDemo`, or `--swarp-demo-route` are included.

**Verification after fix:**

- `rg "DemoAPIClient|DemoFixtures|localDemo|--swarp-demo-route" SWARPVouchers` returns no Release-compiled paths.
- Release build uses production API client only.
- Login, claim, checkout, receipt, support, and KYC flows require backend responses.

### SP-IOS-002: Hardcoded test credentials/session state

- **Severity:** High
- **Confidence:** High
- **Category:** MASVS-AUTH, MASVS-STORAGE
- **Affected files/classes/functions:** `LoginView`, `RegisterView`, `AppState.completeDemoAuth`

**What is wrong:**  
The login/register screens include prefilled test identity values, and `completeDemoAuth()` saves a hardcoded session handle directly to Keychain without backend authentication.

**Why it matters for SwarpPay:**  
Hardcoded credentials and local auth completion are unacceptable for a financial/voucher application. These values are visible through reverse engineering and provide a release-time auth bypass.

**Attack scenario:**  
An attacker inspects the app binary and identifies the test passcode/session path. If shipped, the app can create a local authenticated state without server validation.

**Evidence from repository:**

- `SWARPVouchers/Features/Auth/SplashOnboardingViews.swift:68-76`: default email and passcode fields are initialized in source. **Secret redacted:** `passcode` variable contains a hardcoded test password.
- `SWARPVouchers/Core/AppState.swift:28-31`: `completeDemoAuth()` saves a local session handle. **Secret redacted:** hardcoded session-handle placeholder.
- `SWARPVouchers/Features/Auth/SplashOnboardingViews.swift:88-96`: registration prefilled with a local identity.

**Exact remediation:**

1. Remove default credentials and hardcoded session handles from production source.
2. Authenticate against backend `/auth/login` and `/auth/register`.
3. Store only backend-issued short-lived access token and rotated refresh token.
4. Add server-side session revocation and logout.
5. Add tests/CI grep to block hardcoded passcodes, tokens, and session handles.

**Verification after fix:**

- Auth screens start empty.
- Release build contains no hardcoded credentials.
- Login fails offline and succeeds only with backend-issued credentials.

### SP-IOS-003: Checkout completes locally without server confirmation

- **Severity:** High
- **Confidence:** High
- **Category:** MASVS-CODE, MASVS-AUTH
- **Affected files/classes/functions:** `CheckoutView`, `PriceBreakdownCard`, `DemoFixtures.receipts`

**What is wrong:**  
Checkout calculates service fee locally, selects denomination locally, displays a payment method, and on “Confirm purchase” directly navigates to a receipt ID. There is no backend quote, payment authorization, idempotency key, transaction ID, KYC authorization, voucher reservation, or server-issued receipt in this flow.

**Why it matters for SwarpPay:**  
If this pattern is used for real money or vouchers, a tampered client can change amount, fee, product, KYC state, or status and still reach a receipt screen. The server must own all money and voucher decisions.

**Attack scenario:**  
An attacker modifies `selectedDenominationMinor`, `serviceFeeMinor`, or `productId`, then taps confirm. The app displays a receipt for the manipulated state without backend verification.

**Evidence from repository:**

- `SWARPVouchers/Features/Checkout/PaymentWidget.swift:12-15`: service fee calculated client-side.
- `SWARPVouchers/Features/Checkout/PaymentWidget.swift:33-44`: denomination selected client-side.
- `SWARPVouchers/Features/Checkout/PaymentWidget.swift:69-76`: confirm purchase appends `AppRoute.receipt(...)`.
- `SWARPVouchers/Demo/DemoAPIClient.swift:134-145`: receipts are generated from local fixtures.

**Exact remediation:**

1. Replace local confirm action with a backend `POST /checkout/intents` or equivalent.
2. Server must compute product availability, amount, currency, fees, KYC eligibility, limits, tax, voucher inventory, and final total.
3. Server must return a transaction ID and idempotency key.
4. App must submit payment confirmation to backend and wait for server-issued final status.
5. Receipt screen must load a receipt only after server confirmation.

**Verification after fix:**

- Tampering client-side amount does not change backend charge/receipt.
- Duplicate confirm taps are idempotent.
- Offline confirm cannot create a receipt.

### SP-IOS-004: Voucher claim flow completes locally

- **Severity:** High
- **Confidence:** High
- **Category:** MASVS-CODE, MASVS-PLATFORM
- **Affected files/classes/functions:** `ClaimPreviewView`, `DemoFixtures.claimPreview`, `DeepLinkRouter`

**What is wrong:**  
Claim preview is read from local fixtures. The “Claim voucher” button moves the user to the vouchers tab without sending a claim request to the backend or verifying single-use, expiry, replay protection, recipient binding, or voucher ownership.

**Why it matters for SwarpPay:**  
Claim/redeem flows are high-value. The backend must validate that a claim link is valid, unexpired, unclaimed, intended for the user, and not replayed.

**Attack scenario:**  
An attacker opens or crafts a claim route and the client presents a valid-looking voucher. In a real flow, a similar local completion path could be used to spoof claim success or abuse voucher state.

**Evidence from repository:**

- `SWARPVouchers/Features/Claim/ClaimPreviewView.swift:8-10`: preview comes from `DemoFixtures`.
- `SWARPVouchers/Demo/DemoAPIClient.swift:159-168`: claim preview is hardcoded.
- `SWARPVouchers/Features/Claim/ClaimPreviewView.swift:55-61`: claim action moves to vouchers locally.
- `SWARPVouchers/Core/DeepLinkRouter.swift:39-52`: claim/support routes are created from URL path segments.

**Exact remediation:**

1. Add backend claim-preview and claim-submit endpoints.
2. Claim token must be high-entropy, short-lived, single-use, and bound to a server-side transaction.
3. Bind claim to authenticated account or intended recipient when required.
4. Server must reject replay, expired, cancelled, refunded, or already-claimed links.
5. App must render server status and never decide claim completion locally.

**Verification after fix:**

- Replaying a claim link fails after first successful claim.
- Expired/cancelled/refunded links fail.
- Claim from wrong account fails when recipient binding is required.

### SP-IOS-005: Plain HTTP local API endpoint is compiled into app config

- **Severity:** High
- **Confidence:** High
- **Category:** MASVS-NETWORK
- **Affected files/classes/functions:** `EnvironmentConfig.localDemo`, `URLSessionAPIClient.init`

**What is wrong:**  
`EnvironmentConfig.localDemo` uses `http://localhost:3000`, and `URLSessionAPIClient` defaults to `.localDemo`. No production HTTPS configuration is present in repository evidence.

**Why it matters for SwarpPay:**  
Payment/voucher APIs must be HTTPS-only. A plaintext endpoint in Release configuration is a production misconfiguration and MITM risk.

**Attack scenario:**  
The app is shipped with the local HTTP endpoint or an HTTP staging endpoint. Traffic can be intercepted or the app fails insecurely in production.

**Evidence from repository:**

- `SWARPVouchers/Core/EnvironmentConfig.swift:7-10`: `apiBaseURL` is `http://localhost:3000`.
- `SWARPVouchers/Networking/APIClient.swift:18`: API client defaults to `.localDemo`.
- `SWARPVouchers/Networking/APIClient.swift:56-65`: request builder uses the configured base URL.
- `SWARPVouchers/Info.plist`: no ATS exceptions are declared; absence of exceptions is good, but the app config still contains HTTP.

**Exact remediation:**

1. Add production HTTPS base URL and remove HTTP from Release builds.
2. Use build configurations or xcconfig files with explicit Debug/Staging/Release separation.
3. Add CI grep that fails Release builds containing `http://`.
4. Verify ATS remains strict: no `NSAllowsArbitraryLoads`.
5. Add runtime assertion that Release base URL scheme is `https`.

**Verification after fix:**

- `rg "http://|localhost|localDemo" SWARPVouchers` has no Release-compiled endpoint.
- Release API traffic is HTTPS-only.

### SP-IOS-006: Demo custom URL scheme and weak deep-link production posture

- **Severity:** High
- **Confidence:** High
- **Category:** MASVS-PLATFORM
- **Affected files/classes/functions:** `Info.plist`, `DeepLinkRouter`

**What is wrong:**  
The app registers a demo custom URL scheme (`swarpvouchers-demo`) and has no Associated Domains entitlement. Custom schemes can be claimed by other apps and are unsuitable for sensitive claim/payment flows. The router maps path segments into claim, receipt, support, checkout, product, and other routes.

**Why it matters for SwarpPay:**  
Claim links, payment callbacks, OAuth redirects, and voucher redemption links need strict universal-link validation and server-side state checks. Custom schemes should not carry sensitive state.

**Attack scenario:**  
A malicious app registers the same custom scheme to intercept links, or sends crafted links to the SwarpPay app to exercise claim/support/receipt routes.

**Evidence from repository:**

- `SWARPVouchers/Info.plist:21-31`: `CFBundleURLTypes` registers `swarpvouchers-demo`.
- `SWARPVouchers/Core/DeepLinkRouter.swift:4-5`: allowed schemes include `https` and `swarpvouchers-demo`.
- `SWARPVouchers/Core/DeepLinkRouter.swift:39-52`: claim, receipt, support, referral, and campaign routes are derived from URL parts.
- No `.entitlements` file or Associated Domains entitlement found.

**Exact remediation:**

1. Use universal links with Associated Domains for sensitive flows.
2. Remove demo scheme from Release builds.
3. Keep custom schemes only for non-sensitive internal/debug actions if needed.
4. Validate host, path, token format, nonce, expiry, account binding, and server state.
5. Never put bearer tokens, raw voucher secrets, KYC tokens, payment authorization tokens, or wallet material in URLs.

**Verification after fix:**

- Release `Info.plist` contains no demo scheme.
- Associated Domains entitlement includes only approved production domains.
- Crafted links are rejected unless backend validates the referenced transaction/claim.

### SP-IOS-007: Keychain storage lacks explicit accessibility and access control

- **Severity:** High
- **Confidence:** High
- **Category:** MASVS-STORAGE
- **Affected files/classes/functions:** `KeychainSessionStore`

**What is wrong:**  
Keychain save attributes do not specify `kSecAttrAccessible`, `kSecAttrAccessControl`, `ThisDeviceOnly`, passcode gating, or biometric/passcode access control. `SecItemAdd` and `SecItemDelete` status values are ignored.

**Why it matters for SwarpPay:**  
Real access/refresh tokens, wallet session handles, or high-value authentication material should be non-migratable where appropriate and should use explicit access controls. Ignoring `SecItemAdd` failures can leave the app believing a session was saved when it was not.

**Attack scenario:**  
An attacker with backup/device access or a compromised device gets more opportunity to recover session material if default accessibility is used. Silent Keychain errors can cause inconsistent auth state.

**Evidence from repository:**

- `SWARPVouchers/Core/SecureSessionStore.swift:14-24`: saves generic password without explicit accessibility/access control.
- `SWARPVouchers/Core/SecureSessionStore.swift:21`: delete status ignored.
- `SWARPVouchers/Core/SecureSessionStore.swift:24`: add status ignored.
- `SWARPVouchers/Core/SecureSessionStore.swift:27-38`: reads the item without access-control policy.

**Exact remediation:**

1. For refresh tokens/high-value session material, prefer `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` where product requirements allow.
2. Use `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` if access while locked is not required.
3. For biometric unlock, use `SecAccessControlCreateWithFlags` with `biometryCurrentSet` or passcode-gated flags to unlock a Keychain item, not a UI Boolean.
4. Check and handle all `SecItemAdd`, `SecItemUpdate`, `SecItemCopyMatching`, and `SecItemDelete` statuses.
5. Ensure tokens are not synchronizable unless explicitly required and justified.

**Verification after fix:**

- Keychain queries include explicit accessibility.
- Unit tests cover duplicate save, missing item, failed add, and clear.
- Tokens do not migrate via backup when ThisDeviceOnly is selected.

### SP-IOS-008: Logout/session revocation path is incomplete

- **Severity:** Medium
- **Confidence:** High
- **Category:** MASVS-AUTH, MASVS-STORAGE
- **Affected files/classes/functions:** `SecureSessionStore.clear`; missing logout flow

**What is wrong:**  
`SecureSessionStore.clear()` exists, but no call site was found. No backend session revocation path or logout UI was found.

**Why it matters for SwarpPay:**  
Users must be able to terminate local and server-side sessions. For payment/voucher products, stolen or stale tokens must be revocable.

**Attack scenario:**  
A device is lost or an account is compromised. Without server revocation and local clear, a session can remain usable.

**Evidence from repository:**

- `SWARPVouchers/Core/SecureSessionStore.swift:41-48`: `clear()` deletes the Keychain item.
- Repository search found no `clear()` usage outside the implementation.
- `APIClient` does not define logout or token revocation.

**Exact remediation:**

1. Add backend logout/revoke endpoint.
2. Add local logout flow that calls backend revocation then clears Keychain.
3. Clear cached sensitive state, notification state, and user profile state.
4. Add device/session management UI for fintech readiness.

**Verification after fix:**

- Logout deletes Keychain state.
- Revoked refresh token cannot obtain a new access token.
- Existing API calls fail after logout.

### SP-IOS-009: App Attest / DeviceCheck absent for fraud-sensitive actions

- **Severity:** High
- **Confidence:** High
- **Category:** MASVS-RESILIENCE, MASVS-AUTH
- **Affected files/classes/functions:** Repository-wide absence; checkout/claim/support flows

**What is wrong:**  
No `DCAppAttestService`, `DeviceCheck`, or App Attest code was found. Sensitive flows exist for claim, checkout, account creation, and support/ticket creation.

**Why it matters for SwarpPay:**  
Attackers can modify the iOS client. App Attest is not an authorization control, but it provides a valuable server-side abuse signal for fraud-sensitive endpoints.

**Attack scenario:**  
An attacker instruments the app or builds a modified client to automate claim validation, checkout initiation, account creation, or support abuse. The backend lacks an app-integrity signal if none is implemented.

**Evidence from repository:**

- Broad security scan found no `DCAppAttestService`, `DeviceCheck`, or `AppAttest`.
- Claim and checkout flows exist in `ClaimPreviewView.swift` and `PaymentWidget.swift`.
- `APIClient.swift:43-48` has claim preview and support endpoints.

**Exact remediation:**

1. Add App Attest key generation and attestation at first trusted launch/session.
2. Send App Attest assertions with high-risk API calls.
3. Server must verify attestations/assertions and bind them to device/session/account state.
4. Use App Attest as one fraud signal with rate limits, velocity checks, idempotency, and server authorization.
5. Define fallback policy for unsupported devices.

**Verification after fix:**

- Server rejects missing/invalid assertions for high-risk endpoints after rollout.
- Tampered client requests are scored or blocked server-side.
- App handles unsupported devices safely.

### SP-IOS-010: No certificate/public-key pinning for sensitive APIs

- **Severity:** Medium
- **Confidence:** High
- **Category:** MASVS-NETWORK
- **Affected files/classes/functions:** `URLSessionAPIClient`

**What is wrong:**  
`URLSessionAPIClient` uses `URLSession.shared` with no custom trust evaluation or pinning. No backup pins or pin rotation strategy are present.

**Why it matters for SwarpPay:**  
ATS and system trust are the baseline. For high-risk payment/voucher APIs, certificate or public-key pinning can reduce MITM risk on compromised devices or hostile networks. Bad pinning can break production, so rotation support is required.

**Attack scenario:**  
An attacker installs a trusted root CA on their own device and proxies traffic to inspect checkout/claim requests during testing or abuse.

**Evidence from repository:**

- `SWARPVouchers/Networking/APIClient.swift:14-21`: URLSession client uses injected session/default `.shared`.
- `SWARPVouchers/Networking/APIClient.swift:65`: request sent with `session.data(for:)`.
- Broad scan found no `URLSessionDelegate`, `SecTrust`, `ServerTrust`, `certificatePinning`, or pinning-related code.

**Exact remediation:**

1. Implement public-key pinning for production payment/voucher API hosts.
2. Include backup pins.
3. Document certificate rotation and emergency pin update procedure.
4. Keep staging pins separate from production.
5. Do not disable ATS or server trust validation.

**Verification after fix:**

- Valid production cert chain succeeds.
- Wrong public key fails.
- Backup pin works during staged rotation.

### SP-IOS-011: Privacy manifest is missing

- **Severity:** Medium
- **Confidence:** High
- **Category:** MASVS-PRIVACY
- **Affected files/classes/functions:** Repository configuration; `SupportView`

**What is wrong:**  
No `PrivacyInfo.xcprivacy` file was found. The app collects or displays email/support content and financial/voucher-related data in UI flows.

**Why it matters for SwarpPay:**  
Apple requires accurate privacy disclosures, including collected data and third-party SDK data. Privacy manifest requirements also cover required-reason APIs when used.

**Attack scenario:**  
App Store submission is rejected or privacy disclosures are inaccurate. Users are not correctly informed about financial/support data handling.

**Evidence from repository:**

- `find` command found no `PrivacyInfo.xcprivacy`.
- `SWARPVouchers/Features/Support/SupportView.swift:10`: contact email state.
- `SWARPVouchers/Features/Support/SupportView.swift:117-128`: support body includes contact, topic, reference, and user message.
- No third-party SDKs were found locally, but future SDKs must be covered.

**Exact remediation:**

1. Add `SWARPVouchers/PrivacyInfo.xcprivacy`.
2. Declare collected data categories: contact info, identifiers, purchase/financial/voucher data, support content, diagnostics if added.
3. Declare tracking status and ATT usage if applicable.
4. Declare required-reason API usage if any appears in final app/SDKs.
5. Keep App Store privacy answers synchronized with the manifest and actual SDK behavior.

**Verification after fix:**

- Xcode privacy report includes expected declarations.
- App Store Connect privacy answers match manifest and backend/SDK data flows.

### SP-IOS-012: Release signing and bundle configuration are not production-ready

- **Severity:** High
- **Confidence:** High
- **Category:** MASVS-CODE, MASVS-PRIVACY
- **Affected files/classes/functions:** Xcode project build settings; `Info.plist`

**What is wrong:**  
Release target configuration has code signing disabled, empty development team, local demo bundle identifier, and preview enabled. The app display name and URL scheme still reflect voucher/demo naming.

**Why it matters for SwarpPay:**  
The app cannot be submitted in this state and does not satisfy legal-entity/App Store readiness for fintech/voucher/crypto-adjacent distribution.

**Attack scenario:**  
An internal/demo build is mistaken for release. App Review rejects the app or the app ships with incorrect identity and capabilities.

**Evidence from repository:**

- `SWARPVouchers.xcodeproj/project.pbxproj:370-382`: Release settings include `CODE_SIGNING_ALLOWED = NO`, empty `DEVELOPMENT_TEAM`, `ENABLE_PREVIEWS = YES`, and `PRODUCT_BUNDLE_IDENTIFIER = com.swarppay.localdemo.SWARPVouchers`.
- `SWARPVouchers/Info.plist:7-8`: display name `SWARP Vouchers`.
- `SWARPVouchers/Info.plist:36-37`: finance category.

**Exact remediation:**

1. Configure a legal-entity Apple Developer organization team.
2. Use final production bundle identifier.
3. Enable signing for Release and configure distribution provisioning.
4. Remove demo identifiers and demo schemes from Release.
5. Add necessary entitlements only: Associated Domains, push, Apple Pay, etc., if actually used.
6. Confirm app name, category, privacy policy URL, and App Store metadata.

**Verification after fix:**

- Archive succeeds with App Store distribution signing.
- Exported archive has expected entitlements and bundle ID.
- No `localdemo` strings in Release.

### SP-IOS-013: Notification/support copy can expose voucher/order details

- **Severity:** Medium
- **Confidence:** Medium
- **Category:** MASVS-PRIVACY
- **Affected files/classes/functions:** `NotificationsView`, `SupportView`

**What is wrong:**  
Current notification mock content includes voucher product names, values, receipts, and claim context. Support submission body includes contact email, topic, reference, and user-provided message.

**Why it matters for SwarpPay:**  
If this pattern is reused for APNs or local notifications, voucher/order details can leak on lock screens, notification previews, logs, support tooling, or screenshots.

**Attack scenario:**  
A push notification reveals “Steam Wallet delivered” or voucher value on a locked device. A support event sends voucher code/reference to tools without redaction.

**Evidence from repository:**

- `SWARPVouchers/Features/Notifications/NotificationsView.swift:21-74`: notification bodies include voucher/order details.
- `SWARPVouchers/Features/Support/SupportView.swift:117-128`: support body includes contact and reference.

**Exact remediation:**

1. Use generic push notification bodies: “Your voucher update is ready.”
2. Fetch sensitive details only after app unlock/session validation.
3. Redact voucher codes and order references before analytics/crash/support tooling.
4. Classify support messages as sensitive and encrypt in transit/storage server-side.
5. Add notification privacy tests.

**Verification after fix:**

- APNs payloads contain no voucher codes, receipt IDs, payment amounts, KYC data, or PII.
- Lock-screen previews are generic.

### SP-IOS-014: No app-switcher/background privacy shield found

- **Severity:** Medium
- **Confidence:** Medium
- **Category:** MASVS-PRIVACY
- **Affected files/classes/functions:** App root/lifecycle

**What is wrong:**  
No scene phase handling or privacy overlay was found to hide sensitive voucher, receipt, support, profile, or KYC data when the app enters background/inactive state.

**Why it matters for SwarpPay:**  
iOS app switcher snapshots may reveal voucher/order/receipt/KYC/support information.

**Attack scenario:**  
User backgrounds the app while viewing a receipt or support message. The app switcher snapshot exposes transaction details to shoulder surfers or device viewers.

**Evidence from repository:**

- Reviewed `SWARPVouchers/App/SWARPVouchersApp.swift` and `SWARPVouchers/App/RootView.swift`; no `scenePhase` privacy overlay or background redaction logic found.
- Sensitive screens include receipts, vouchers, profile, support, notifications, and claim flows.

**Exact remediation:**

1. Add `@Environment(\.scenePhase)` handling at the app/root level.
2. Show a branded privacy shield when inactive/backgrounded.
3. Consider redacting sensitive screen content with `.privacySensitive()` where appropriate.
4. Ensure screenshots used for QA do not contain real PII or real voucher codes.

**Verification after fix:**

- Backgrounding the app while on receipt/support/profile screens shows only privacy shield in app switcher.
- UI tests or manual tests confirm no sensitive snapshot leakage.

## 6. Business Logic Abuse Review

| Abuse Case | Classification | Evidence / Notes |
|---|---|---|
| Payment amount tampering | Risk found | Client selects denomination and computes fee locally in `PaymentWidget.swift:12-15`, `PaymentWidget.swift:33-44`. Backend authority not shown. |
| Currency tampering | Needs backend verification | Products use `currency: "MAD"` in `DemoFixtures` and models. No backend enforcement visible. |
| Fee tampering | Risk found | Fee is client-side in `PaymentWidget.swift:12-15`. |
| Voucher value tampering | Risk found | Voucher products/denominations come from `DemoFixtures`; checkout uses local selected amount. |
| Voucher ownership | Needs backend verification | Local orders/receipts are fixtures. No account-bound receipt fetch enforcement visible. |
| Claim state / redemption state | Risk found | Claim button transitions locally in `ClaimPreviewView.swift:55-61`. |
| Claim replay / brute force | Needs backend verification | No entropy, rate limit, single-use, or expiry controls visible in iOS repo. |
| QR parsing | Not applicable from repository evidence | No QR scanner/parser code found. |
| Refund/cancel/settlement | Needs backend verification | No refund/cancel/settlement flows found. |
| Wallet/private-key transaction signing | Not applicable from repository evidence | No wallet, seed phrase, private key, or signing code found. |
| KYC status tampering | Risk found | KYC status is local fixture `DemoAPIClient.swift:43-50`; checkout displays hardcoded Tier 2 in `PaymentWidget.swift:120-145`. |
| User role/merchant role tampering | Needs backend verification | No roles visible in iOS repo. |
| Account takeover controls | Needs backend verification | No MFA, password reset, token refresh/revocation, or step-up auth visible. |
| Duplicate submit/idempotency | Needs backend verification | Checkout and support do not show idempotency keys. |
| Offline/poor-network transaction state | Risk found | Demo checkout/claim can complete without backend/network. |

## 7. App Store and Privacy Readiness

- **Privacy manifest:** Missing. Add `PrivacyInfo.xcprivacy`.
- **Required-reason API status:** No direct `UserDefaults`, file timestamp, disk space, active keyboard, or system boot time usage found in app code. Reassess after adding SDKs.
- **ATT/tracking:** No `NSUserTrackingUsageDescription`, `ATTrackingManager`, IDFA, ad SDK, or tracking SDK found. If tracking or ad attribution is added, ATT is required.
- **Permissions:** No camera, photo, location, contacts, microphone, Face ID, push notification, or background mode usage descriptions found. This is acceptable only if those capabilities are not used.
- **Third-party SDK disclosure:** No third-party dependency managers or SDKs found. Future payment/KYC/fraud/analytics/crash SDKs must be disclosed in App Store privacy answers and privacy manifest.
- **Financial/voucher App Review risk:** The app category is finance. The repository does not prove legal-entity developer account, licensing/permissions, privacy policy URL, or whether voucher sales require IAP versus external payment. This is a release blocker outside code.
- **Crypto/wallet risk:** No crypto wallet/signing code found. If crypto features are added, organization developer enrollment, country/region licensing, wallet security, and App Review crypto rules must be reassessed.

## 8. PCI / Payment Scope Assessment

- **Raw card data in app:** Not found.
- **Payment card entry UI:** Not found. `PaymentMethodCard` displays a placeholder card label only.
- **Apple Pay / hosted/tokenized provider:** Not found.
- **Cardholder data storage/process/transmission:** Not evidenced in this iOS repository.
- **PCI DSS status:** PCI scope cannot be finalized until the payment provider architecture is known. If raw card data touches the app, PCI scope becomes materially larger.
- **PCI MPoC:** No evidence that the app accepts PIN/contactless cardholder data on the phone itself. If added, PCI MPoC review is required.

## 9. Needs Verification

These cannot be confirmed from the iOS repository and must be verified before production:

- Backend authorization of all payment, voucher, claim, receipt, refund, KYC, support, role, merchant, and settlement decisions.
- Backend recomputation of amount, currency, fees, discounts, taxes, exchange rates, voucher value, ownership, and status.
- Token expiry, refresh-token rotation, server-side revocation, logout, device/session list, and step-up authentication.
- Rate limits for account creation, login, support, claim preview, claim submit, checkout, and receipt access.
- Voucher entropy, single-use behavior, short expiry, brute-force resistance, replay protection, recipient/account binding, and invalidation after refund/cancel/completion.
- App Attest / DeviceCheck server verification and rollout policy.
- KYC/AML provider data flow, storage, retention, privacy disclosure, and webhook security.
- Payment provider architecture, tokenization, Apple Pay/hosted checkout use, and PCI scope.
- Production privacy policy URL and App Store privacy answers.
- Incident logging, fraud monitoring, audit logs, alerting, and abuse response.
- Whether digital voucher/coupon/gift card sales require Apple IAP for any catalog items.
- Legal-entity Apple Developer account and country/region licensing for financial/crypto-adjacent services.
- Smart contract, wallet, custody, key management, or blockchain audit if crypto/wallet features are added.

## 10. Release Gate

### Must Fix Before TestFlight External Beta

- Remove or gate demo auth/data behind DEBUG/internal build flags.
- Remove hardcoded test credentials and prefilled production-looking PII.
- Configure production/staging environment separation.
- Add privacy manifest draft.
- Add final bundle identifier, signing team, and release signing configuration.
- Remove `localdemo` identifiers from external builds.
- Ensure TestFlight backend enforces auth, KYC, voucher ownership, and receipt access.

### Must Fix Before App Store Production

- Replace demo client with production API client in Release.
- Backend-authorize checkout, claim, receipt, support, KYC, and session flows.
- Implement secure token storage with explicit Keychain accessibility and logout/revocation.
- Remove local HTTP endpoint from Release and enforce HTTPS-only.
- Use universal links with Associated Domains for sensitive flows.
- Add App Attest / DeviceCheck for fraud-sensitive actions with server verification.
- Add privacy manifest and complete App Store privacy disclosures.
- Confirm App Review legal-entity, voucher/IAP, finance, crypto, licensing, and privacy policy readiness.
- Add background privacy shield for sensitive screens.
- Confirm no sensitive data in notifications, logs, crash reports, analytics, or support tooling.

### Should Fix Within 30 Days After Launch

- Add certificate/public-key pinning with backup pins and rotation runbook.
- Add jailbreak/debugger/instrumentation detection as telemetry only, not authorization.
- Add mobile security regression tests for deep links, claim replay, duplicate checkout, and token storage.
- Add automated secret scanning and Release-build grep gates.
- Add dependency vulnerability monitoring when dependencies are introduced.

### Security Monitoring Required After Launch

- Monitor claim attempts, replay failures, brute-force patterns, account creation velocity, checkout failures, refund/cancel races, support abuse, and suspicious device integrity signals.
- Alert on duplicate idempotency keys, abnormal voucher redemption patterns, unusual KYC changes, and receipt access anomalies.
- Maintain incident runbooks for voucher theft, account takeover, payment dispute, data exposure, and App Attest rollout failures.
