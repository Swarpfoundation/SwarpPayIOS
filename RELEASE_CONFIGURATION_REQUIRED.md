# SwarpPay iOS Release Configuration Required

The repository intentionally does not contain production Apple, backend, payment, voucher, KYC, or compliance values.

Release builds must not be treated as production-ready until these external values and systems are configured:

- Apple Developer Team ID for the legal entity submitting SwarpPay.
- Final production bundle identifier, provided through `SWARPPAY_PRODUCT_BUNDLE_IDENTIFIER`.
- Production Associated Domains for universal links.
- Production privacy policy URL and App Store privacy answers.
- Legal entity submission confirmation and voucher/payment/App Review classification.
- Production HTTPS backend API URL.
- Real authentication, token refresh, token revocation, and logout APIs.
- Payment provider architecture and PCI scope decision.
- Server-authoritative voucher issuing, claiming, redemption, receipt, refund, and settlement APIs.
- KYC/AML provider data flow and authority model.
- App Attest server rollout and verification endpoints.
- Certificate pinning host, backup pins, and rotation plan.

Do not add placeholder production values to the repository. If a required value is unavailable, Release must fail closed or keep the affected feature disabled.
