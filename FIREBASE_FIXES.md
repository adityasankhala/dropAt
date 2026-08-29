# 🔥 DropAt — Firebase Production Checklist

> **Firebase Project:** `dropat-80f0b`
> **Platforms:** Android, iOS, Web, macOS
> **Auth Methods:** Google Sign-In, Apple Sign-In, Phone OTP

---

## 🚨 Critical Issues (Blocking Launch)

### 0. Enable Firebase Blaze Plan (Billing)
**Status:** ❌ Blocks Phone OTP — `billing-not-enabled` error

Firebase Phone Auth **requires the Blaze (pay-as-you-go) plan**. The free Spark plan no longer supports phone verification.

**Fix:**
1. Go to [Firebase Console → Usage and billing](https://console.firebase.google.com/project/dropat-80f0b/usage)
2. Click **"Upgrade"** → Select **Blaze plan**
3. Link a billing account (credit/debit card)
4. Phone OTP will work immediately after upgrade

> **💰 Cost:** Blaze plan is pay-as-you-go. Phone auth costs ~$0.01 per verification in India. You won't be charged unless you exceed the free tier (10K verifications/month). You can set budget alerts to avoid surprises.

---

### 1. Register a Firebase Web App
**Status:** ❌ Missing — No web app registered in Firebase

The web platform has no Firebase app registered, which means auth (Google, Phone OTP) won't work on web at all.

**Fix:**
1. Go to [Firebase Console → Project Settings](https://console.firebase.google.com/project/dropat-80f0b/settings/general)
2. Click **"Add app"** → Select the **Web** icon (`</>`)
3. Name it **"DropAt Web"**
4. Copy the generated config values:
   - `apiKey`
   - `appId`
   - `authDomain`
   - `measurementId` (optional)
5. Update [`firebase_options.dart`](file:///Users/anshika2912/Desktop/lifeproject/dropat_user/lib/firebase_options.dart) — replace the `web` config (lines 27-33) with the real values

---

### 2. Fix Google Sign-In "origin_mismatch" Error
**Status:** ❌ Blocks Google login on web

The OAuth 2.0 web client doesn't have `localhost` or your production domain authorized.

**Fix:**
1. Go to [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials?project=dropat-80f0b)
2. Under **"OAuth 2.0 Client IDs"**, click the **Web client** (`22433737402-o006mk12vv9ni71r0u952urn8b0ud818`)
3. Add to **"Authorized JavaScript origins"**:
   ```
   http://localhost
   https://dropat-80f0b.firebaseapp.com
   https://your-production-domain.com        ← replace with your real domain
   ```
4. Add to **"Authorized redirect URIs"**:
   ```
   http://localhost
   https://dropat-80f0b.firebaseapp.com/__/auth/handler
   https://your-production-domain.com/__/auth/handler
   ```
5. Click **Save** (takes ~5 minutes to propagate)

---

### 3. Enable Phone Auth in Firebase Console
**Status:** ⚠️ Verify this is enabled

**Fix:**
1. Go to [Firebase Console → Authentication → Sign-in method](https://console.firebase.google.com/project/dropat-80f0b/authentication/providers)
2. Ensure **Phone** provider is **Enabled**
3. For web phone auth, also ensure:
   - **reCAPTCHA verification** is set up (Firebase does this automatically for web)
   - Your domain is added to **Authorized domains** list

---

### 4. Add SHA Fingerprints for Android
**Status:** ❌ Missing — No SHA fingerprints in `google-services.json`

Google Sign-In and Phone Auth on Android **require** SHA-1 and SHA-256 fingerprints.

**Fix:**
1. On the dev machine, generate the debug SHA-1:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy the `SHA1` and `SHA-256` values from the output.

2. Go to [Firebase Console → Project Settings → Your Apps → Android app](https://console.firebase.google.com/project/dropat-80f0b/settings/general)
3. Under the Android app (`com.dropat.app`), click **"Add fingerprint"**
4. Paste both SHA-1 and SHA-256
5. Download the updated `google-services.json` and replace [the current one](file:///Users/anshika2912/Desktop/lifeproject/dropat_user/android/app/src/google-services.json)

> [!IMPORTANT]
> For production release, you must also add your **release keystore** SHA fingerprints (not just the debug ones).

---

### 5. Fix `firebase_options.dart` with Real Web Credentials
**Status:** ❌ Currently using fabricated web appId

After completing Step 1 (registering the web app), update [firebase_options.dart](file:///Users/anshika2912/Desktop/lifeproject/dropat_user/lib/firebase_options.dart):

```dart
// Replace lines 27-33 with the REAL values from Firebase Console:
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_REAL_WEB_API_KEY',           // ← from Firebase Console
  appId: 'YOUR_REAL_WEB_APP_ID',             // ← from Firebase Console
  messagingSenderId: '22433737402',
  projectId: 'dropat-80f0b',
  authDomain: 'dropat-80f0b.firebaseapp.com',
  storageBucket: 'dropat-80f0b.firebasestorage.app',
);
```
---

## ⚠️ Important Fixes (Pre-Launch)

### 6. Grant Team Members Proper GCP Access
**Status:** ⚠️ Current user (Anshika) lacks GCP permissions

The "Firebase Admin" role isn't enough to manage OAuth credentials. Team members who need to manage auth settings need the **"Editor"** or **"Owner"** role on the GCP project.

**Fix:**
1. Go to [Google Cloud Console → IAM](https://console.cloud.google.com/iam-admin/iam?project=dropat-80f0b)
2. Click **"Grant Access"**
3. Add team members with **"Editor"** role

---

### 7. Enable Required Auth Providers
**Status:** ⚠️ Verify all are enabled

Go to [Firebase Authentication → Sign-in method](https://console.firebase.google.com/project/dropat-80f0b/authentication/providers) and ensure:

| Provider | Status Needed | Notes |
|----------|--------------|-------|
| **Google** | ✅ Enabled | Must configure OAuth consent screen |
| **Apple** | ✅ Enabled | Requires Apple Developer account setup |
| **Phone** | ✅ Enabled | Needs reCAPTCHA for web |

---

### 8. Configure Apple Sign-In (for iOS/macOS)
**Status:** ⚠️ Needs Apple Developer setup

For Apple Sign-In to work on real devices:
1. Log into [Apple Developer Portal](https://developer.apple.com/account)
2. Go to **Certificates, Identifiers & Profiles → Identifiers**
3. Select your app ID (`com.dropat.user`)
4. Enable **"Sign In with Apple"** capability
5. In Firebase Console → Authentication → Sign-in method → Apple:
   - Add your **Services ID**
   - Add your **Team ID**
   - Upload your **Key file** (.p8)

---

### 9. Set Up Firestore Security Rules
**Status:** ⚠️ Check current rules

For production, you MUST have proper security rules (not the default test mode).

Go to [Firebase Console → Firestore → Rules](https://console.firebase.google.com/project/dropat-80f0b/firestore/rules) and ensure:
- Users can only read/write their own data
- Ride data has proper access controls
- No open `allow read, write: if true;` rules remain

---

### 10. Add Authorized Domains
**Status:** ⚠️ Needed for production

Go to [Firebase Console → Authentication → Settings → Authorized domains](https://console.firebase.google.com/project/dropat-80f0b/authentication/settings):
- Add your production domain (e.g., `dropat.com`)
- `localhost` is already included by default for development

---

## 📋 Platform Status Summary

| Platform | Firebase App | Auth Config | Build Status |
|----------|-------------|-------------|--------------|
| **Android** | ✅ `com.dropat.app` | ❌ Missing SHA fingerprints | ❌ No Android SDK on dev machine |
| **iOS** | ✅ `com.dropat.user` | ✅ GoogleService-Info.plist present | ❌ Razorpay blocks simulator; needs real device + code signing |
| **Web** | ❌ Not registered | ❌ origin_mismatch error | ✅ Builds & runs on Chrome |
| **macOS** | ✅ `com.example.finaltouch` | ✅ GoogleService-Info.plist present | ✅ Builds & runs |

---

## 🚀 Quick Start: Get Login Working TODAY

The **fastest path** to get a working login flow:

1. **Project owner** registers a web app in Firebase (Step 1) — **2 minutes**
2. **Project owner** adds `http://localhost` to OAuth origins (Step 2) — **2 minutes**
3. Update `firebase_options.dart` with real web values (Step 5) — **1 minute**
4. Run `flutter run -d chrome` — login works! 🎉

---

> [!TIP]
> For production launch, use `flutterfire configure` CLI to auto-generate `firebase_options.dart` with correct values for all platforms:
> ```bash
> dart pub global activate flutterfire_cli
> flutterfire configure --project=dropat-80f0b
> ```
