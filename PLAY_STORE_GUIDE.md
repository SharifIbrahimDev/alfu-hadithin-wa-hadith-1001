# Google Play Store Publishing Guide

This guide walks you step-by-step through generating your Android release signing keys, building the production `.aab` (Android App Bundle), and submitting **1001 Authentic Hadith** to the Google Play Console.

---

## Step 1: Generate Release Keystore

Run the following command in PowerShell or Terminal to create your secure upload keystore file (`upload-keystore.jks`):

```powershell
keytool -genkey -v -keystore "mobile\upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> [!IMPORTANT]
> You will be prompted to enter a password and your name/organization. Keep this password and the `upload-keystore.jks` file in a secure location (such as a password manager or backup drive). Never share or lose this file.

---

## Step 2: Configure `key.properties`

Create a file named `key.properties` inside the `mobile/android/` directory (you can base it on `mobile/android/key.properties.example`):

```properties
keyAlias=upload
keyPassword=YOUR_KEYSTORE_PASSWORD
storeFile=C:\\Users\\USER\\flutter_projects\\Alfu Hadithin Wa Hadith 1001\\mobile\\upload-keystore.jks
storePassword=YOUR_KEYSTORE_PASSWORD
```

*(Note: On Windows, use double backslashes `\\` for file paths).*

---

## Step 3: Build the Android App Bundle (`.aab`)

You can build the bundle automatically using our automated release tool:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build_playstore_bundle.ps1
```

Or run the Flutter command directly inside `mobile/`:

```powershell
cd mobile
flutter clean
flutter pub get
flutter build appbundle --release
```

The resulting file will be located at:
```
mobile/build/app/outputs/bundle/release/app-release.aab
```

This `.aab` file is the package you upload to the Google Play Console.

---

## Step 4: Google Play Console Setup

1. **Log in to Play Console:** Go to [Google Play Console](https://play.google.com/console) with your Google Developer Account ($25 one-time registration fee if new).
2. **Create App:**
   - Click **Create app** (top right).
   - **App name:** `1001 Authentic Hadith - Book`
   - **Default language:** English (United States) or Arabic
   - **App or Game:** App
   - **Free or Paid:** Free
   - Accept the Developer Program Policies and US export laws.
   - Click **Create app**.

---

## Step 5: Complete App Content Questionnaires

Under the left sidebar **Policy and programs > App content**:

| Section | Required Selection |
| :--- | :--- |
| **Privacy Policy** | Enter your repository privacy policy URL: `https://github.com/SharifIbrahimDev/alfu-hadithin-wa-hadith-1001/blob/main/PRIVACY_POLICY.md` |
| **Ads** | Select **"No, my app does not contain ads"**. |
| **App Access** | Select **"All functionality is available without special access restrictions"** (no login needed). |
| **Content Rating** | Fill the IARC rating questionnaire: Category: *Reference, News, or Educational*. Result: *Everyone / PEGI 3 / USK 0*. |
| **Target Audience & Content** | Target age groups: Select **13 and older, 18 and over** (or All Ages). Children's policy: Not primarily directed to children under 13. |
| **News Apps** | Select **"No"**. |
| **COVID-19 Contact Tracing** | Select **"My app is not a publicly available contact tracing or status app"**. |
| **Data Safety** | Select **"No, this app does not collect or share any user data"**. All storage is strictly on-device. |
| **Government Apps** | Select **"No"**. |
| **Financial Features** | Select **"My app does not provide any financial features"**. |

---

## Step 6: Set Up Main Store Listing

Under the left sidebar **Store presence > Main store listing**:

1. **Copy text from `PLAY_STORE_LISTING.md`:**
   - **App title:** `1001 Authentic Hadith - Book`
   - **Short description:** `1001 authentic prophetic Hadiths with commentary, e-book reader & PDF export.`
   - **Full description:** Copy the English & Arabic full descriptions provided in `PLAY_STORE_LISTING.md`.
2. **Graphics & Screenshots:**
   - **App Icon:** Upload `assets/icon/app_icon.png` (512x512 px).
   - **Feature Graphic:** Upload a 1024x500 banner.
   - **Phone Screenshots:** Upload at least 4 screenshots (1080x1920 or 1080x2400 px) showing the Home screen, Hadith reader, E-book viewer, PDF export, and Bibliography.

---

## Step 7: Release Track & Rollout

1. Go to **Testing > Closed testing** (or **Release > Production** if your account allows direct production rollout).
2. Click **Create new release**.
3. In the **App bundles** section, click **Upload** and select `mobile/build/app/outputs/bundle/release/app-release.aab`.
4. **Release name:** `1.0.0 (1)`
5. **Release notes:**
   ```
   Initial public release of 1001 Authentic Hadith (ألف حديث وحديث)
   - 1,001 authentic prophetic traditions with Tashkeel, English translations, and Fawa'idul Hadith.
   - 22 thematic chapters and 39 canonical Ahlus Sunnah source bibliography.
   - Complete e-book reader and 1-tap PDF book generation.
   - Offline search, audio narration, and daily Hadith widget.
   ```
6. Click **Next**, review summary, and click **Save & Start rollout to review**.

Google typically reviews and approves apps within 1 to 3 business days!
