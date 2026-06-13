# Implementation Plan - Payment Launcher

This plan outlines the design and implementation steps for creating "Payment Launcher", a production-ready, mobile-first responsive Flutter Web application.

## User Review Required

> [!IMPORTANT]
> - **Flutter Version**: The system's Flutter version is detected as **3.41.4**. We will initialize and build the application using this version.
> - **Deep Link Detection on Web**: Since standard browser environments do not allow querying registered custom scheme handlers via API, we will implement a robust blur/visibility change listener mechanism to detect if the Aani Pay app fails to open.

## Proposed Changes

We will create a new Flutter project configured for Web inside the workspace directory `/Users/fssdeveloper/Desktop/Manikandan/PG/dib-war/demo-web`.

### 1. Project Creation & Setup

We will initialize the Flutter project in the workspace:
- Command: `/Users/fssdeveloper/development/flutter/bin/flutter create --platforms=web --project-name=payment_launcher .`

We will update the `pubspec.yaml` to configure dependencies:
- Add `url_launcher` (latest stable compatibility) for external links (like Play Store/App Store URL).
- Configure package assets if any.

### 2. Configuration Layer

We will create [payment_config.dart](file:///Users/fssdeveloper/Desktop/Manikandan/PG/dib-war/demo-web/lib/config/payment_config.dart) to store configurable constants:
- `upiId`: UPI VPA for payment
- `merchantName`: Merchant name
- `amount`: Transaction amount
- `aaniPayDeepLink`: Aani Pay custom URL scheme
- `aaniPayStoreUrl`: Play Store/App Store link for downloading Aani Pay

### 3. Utility Layer

We will create [payment_launcher.dart](file:///Users/fssdeveloper/Desktop/Manikandan/PG/dib-war/demo-web/lib/utils/payment_launcher.dart):
- `isMobileBrowser()`: Checks if the browser user agent belongs to a mobile/tablet device.
- `launchUpi()`: Handles UPI payment generation and launch.
- `launchAaniPay()`: Attempts deep link launch, detecting failures using a visibility/focus timeout, and alerting the UI on success/failure.

### 4. Presentation Layer (UI)

We will customize the main app files:
- [main.dart](file:///Users/fssdeveloper/Desktop/Manikandan/PG/dib-war/demo-web/lib/main.dart): Entry point, configuring Material 3 theme with curated primary/secondary colors (e.g., deep sapphire blue primary and vibrant teal/cyan secondary), dark mode compatibility, and routing.
- [payment_home_page.dart](file:///Users/fssdeveloper/Desktop/Manikandan/PG/dib-war/demo-web/lib/presentation/payment_home_page.dart): Home Screen with responsive modern card layout, loading indicators, custom Material 3 payment buttons, and error dialogs/snackbars.

### 5. Vercel Configuration

We will generate [vercel.json](file:///Users/fssdeveloper/Desktop/Manikandan/PG/dib-war/demo-web/vercel.json):
- Configures SPA routing rewrites to point all sub-routes to `index.html`.

## Verification Plan

### Automated Build Verification
- Compile and build for release web target using `/Users/fssdeveloper/development/flutter/bin/flutter build web --release`.
- Verify the output files exist in `build/web`.

### Security Verification
- Ensure no sensitive client credentials/keys are exposed in plain text.
- Verify that standard web input escaping/encoding is followed during link construction.
- Avoid native blocking dialogues (`alert`, `confirm`) in production.

### Manual Verification
- Test payment launching logic inside desktop and mobile browsers.
- Verify desktop UPI payment click opens the correct warning dialog.
- Verify Aani Pay click attempts to open the custom scheme and handles the fallback/app store button correctly.
