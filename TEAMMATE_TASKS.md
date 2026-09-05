# 🎯 Teammate Tasks — Firebase & Backend Setup

> **For:** The teammate who has Firebase Console / Google Cloud / Apple Developer access
> **From:** Anshika
> **Project:** DropAt (`dropat-80f0b`)
> **Date:** September 6, 2026

---

## ℹ️ Context

I've been working on the Flutter app (`dropat_user`). The app builds and runs on Chrome/macOS, but **authentication is completely broken** because of missing Firebase & cloud configurations. I don't have the required GCP permissions to fix these myself (I only have "Firebase Admin" role, which blocks OAuth credential editing).

Below is everything I need from you, organized by **priority**. Each task has exact step-by-step instructions and links.

---

## 🔴 Priority 1 — BLOCKING (Can't test login at all without these)

### Task 1: Upgrade Firebase to Blaze Plan
**Why:** Phone OTP throws `billing-not-enabled` error. Firebase requires pay-as-you-go billing for phone auth.
**Time:** ~2 min

1. Go to [Firebase Console → Usage and billing](https://console.firebase.google.com/project/dropat-80f0b/usage)
2. Click **"Upgrade"** → Select **Blaze plan**
3. Link a billing account (credit/debit card)

> 💰 It's pay-as-you-go. Phone auth = ~₹1/OTP. First 10K verifications/month are free. Set a budget alert at ₹500/month to be safe.

---

### Task 2: Register a Firebase Web App
**Why:** There's no web app registered in Firebase. Without it, Firebase Auth doesn't work on Chrome at all.
**Time:** ~2 min

1. Go to [Firebase Console → Project Settings](https://console.firebase.google.com/project/dropat-80f0b/settings/general)
2. Scroll to **"Your apps"** section at the bottom
3. Click **"Add app"** → Select the **Web** icon (`</>`)
4. Nickname: **"DropAt Web"**
5. ✅ Check "Also set up Firebase Hosting" (optional)
6. Click **Register app**

**📤 Send me these values** from the generated config snippet:
```
apiKey: "..."
authDomain: "..."
projectId: "..."
storageBucket: "..."
messagingSenderId: "..."
appId: "..."
measurementId: "..." (if present)
```

I'll plug these into `dropat_user/lib/firebase_options.dart`.

---

### Task 3: Fix Google Sign-In "origin_mismatch" Error
**Why:** When users click "Login with Google" on web, they get `Error 400: origin_mismatch` because localhost isn't authorized.
**Time:** ~3 min

1. Go to [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials?project=dropat-80f0b)
2. Under **"OAuth 2.0 Client IDs"**, click the **Web client** (ID: `22433737402-o006mk12vv9ni71r0u952urn8b0ud818`)
3. **Authorized JavaScript origins** — click "+ ADD URI" and add:
   - `http://localhost`
   - `https://dropat-80f0b.firebaseapp.com`
4. **Authorized redirect URIs** — click "+ ADD URI" and add:
   - `http://localhost`
   - `https://dropat-80f0b.firebaseapp.com/__/auth/handler`
5. Click **Save**

> ⏳ Changes take ~5 minutes to propagate.

---

### Task 4: Verify Auth Providers Are Enabled
**Why:** All 3 login methods (Google, Apple, Phone) must be enabled in Firebase Auth.
**Time:** ~1 min

1. Go to [Firebase Auth → Sign-in method](https://console.firebase.google.com/project/dropat-80f0b/authentication/providers)
2. Ensure these are all **Enabled**:

| Provider | Action Needed |
|----------|--------------|
| **Google** | Enable + set support email |
| **Apple** | Enable (needs Apple Developer setup — see Task 7) |
| **Phone** | Enable |

---

## 🟡 Priority 2 — IMPORTANT (Needed before testing on real devices)

### Task 5: Grant Me (Anshika) GCP Editor Access
**Why:** I currently only have "Firebase Admin" role, which blocks me from editing OAuth credentials, viewing API keys, or debugging auth issues myself.
**Time:** ~1 min

1. Go to [Google Cloud Console → IAM](https://console.cloud.google.com/iam-admin/iam?project=dropat-80f0b)
2. Find my email or click **"Grant Access"**
3. Set role to **"Editor"**
4. Click **Save**

---

### Task 6: Add Android SHA Fingerprints
**Why:** Google Sign-In and Phone Auth on Android **will not work** without SHA fingerprints registered.
**Time:** ~5 min

1. On your machine (with Android SDK), run in the `dropat_user` folder:
   ```bash
   cd android && ./gradlew signingReport
   ```
2. Copy the **SHA-1** and **SHA-256** values from the `debug` variant
3. Go to [Firebase Console → Project Settings → Your Apps](https://console.firebase.google.com/project/dropat-80f0b/settings/general)
4. Under the Android app (`com.dropat.app`), click **"Add fingerprint"**
5. Paste both SHA-1 and SHA-256
6. Download the **updated `google-services.json`**
7. Replace the file at: `dropat_user/android/app/src/google-services.json`
8. Commit and push

> ⚠️ For production release, also add **release keystore** SHA fingerprints.

---

### Task 7: Configure Apple Sign-In
**Why:** "Login with Apple" button won't work without Apple Developer setup.
**Time:** ~10 min

1. Log into [Apple Developer Portal](https://developer.apple.com/account)
2. Go to **Certificates, Identifiers & Profiles → Identifiers**
3. Select app ID `com.dropat.user`
4. Enable **"Sign In with Apple"** capability
5. Create a **Services ID** for web-based Apple Sign-In
6. Create a **Key** with "Sign In with Apple" enabled → Download the `.p8` file
7. In [Firebase Console → Auth → Sign-in method → Apple](https://console.firebase.google.com/project/dropat-80f0b/authentication/providers):
   - Add the **Services ID**
   - Add the **Team ID**
   - Upload the **Key file** (`.p8`)

---

## 🟢 Priority 3 — PRE-LAUNCH (Before going live)

### Task 8: Set Up Firestore Security Rules
**Why:** Default test-mode rules allow anyone to read/write all data. Must lock down before launch.
**Time:** ~15 min

1. Go to [Firebase Console → Firestore → Rules](https://console.firebase.google.com/project/dropat-80f0b/firestore/rules)
2. Replace test rules with proper production rules:
   - Users can only read/write their own documents
   - Ride data has proper access controls
   - Driver location data is read-only for users
   - **Remove** any `allow read, write: if true;` rules

---

### Task 9: Add Production Authorized Domains
**Why:** Firebase Auth only works on domains explicitly listed in the authorized domains list.
**Time:** ~1 min

1. Go to [Firebase Auth → Settings → Authorized domains](https://console.firebase.google.com/project/dropat-80f0b/authentication/settings)
2. Add your production domain (e.g., `dropat.com`, `app.dropat.com`)

---

### Task 10: Fill Backend `.env` Secrets
**Why:** The backend `.env` has empty values for critical services.
**Time:** ~5 min

These values are currently empty in `dropat_backend/.env` and need to be filled:

| Variable | Where to Get It |
|----------|----------------|
| `SUPABASE_URL` | [Supabase Dashboard](https://supabase.com/dashboard) → Project Settings → API |
| `SUPABASE_ANON_KEY` | Same location as above |
| `SUPABASE_SERVICE_KEY` | Same location as above (service_role key) |
| `GOOGLE_MAPS_API_KEY` | [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials?project=dropat-80f0b) |
| `RAZORPAY_KEY_ID` | [Razorpay Dashboard](https://dashboard.razorpay.com/) → Settings → API Keys |
| `RAZORPAY_KEY_SECRET` | Same location as above |

> ⚠️ **Never commit `.env` to git.** Share these values privately (Slack DM, encrypted message, etc.)

---

### Task 11: iOS Code Signing for Real Device Testing
**Why:** Running the app on a physical iPhone/iPad requires an Apple Developer Team certificate. I need you to either:

**Option A:** Add me to the Apple Developer team so I can sign locally
**Option B:** Share the development provisioning profile + signing certificate

The Xcode project already has `DEVELOPMENT_TEAM = 2V5V9PD9R3` set. I just need the signing identity installed on my machine.

---

## 📤 What I Need Back From You

After completing the tasks above, send me:

| Item | From Task | How I'll Use It |
|------|-----------|----------------|
| Web Firebase config (`apiKey`, `appId`, etc.) | Task 2 | Update `firebase_options.dart` |
| Updated `google-services.json` | Task 6 | Replace Android config |
| Razorpay API keys | Task 10 | Backend `.env` |
| Supabase credentials | Task 10 | Backend `.env` |
| Google Maps API key | Task 10 | Backend `.env` + already in `web/index.html` |
| GCP Editor access granted | Task 5 | So I can debug auth issues myself |

---

## 🏁 Once You're Done

After you complete Priority 1 tasks (Tasks 1-4), ping me and I'll:
1. Update `firebase_options.dart` with the real web config
2. Test all 3 login flows (Google, Apple, Phone)
3. Run the app on Chrome + macOS
4. Prepare the Android/iOS builds

**Let's get this to production! 🚀**
