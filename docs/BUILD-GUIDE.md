# Build Guide: BBSaM-Messenger

## Inhaltsverzeichnis

1. [Voraussetzungen](#voraussetzungen)
2. [Web Build](#web-build)
3. [Desktop Build](#desktop-build)
4. [Android Build](#android-build)
5. [iOS Build](#ios-build)
6. [CI/CD Pipelines](#cicd-pipelines)
7. [Release-Prozess](#release-prozess)

---

## Voraussetzungen

### Allgemeine Tools

| Tool | Version | Installation |
|------|---------|--------------|
| Git | 2.30+ | `apt install git` |
| Node.js | 20 LTS | [nvm](https://github.com/nvm-sh/nvm) |
| Yarn | 4.x | `corepack enable` |
| Docker | 24+ | [docker.com](https://docs.docker.com/engine/install/) |

### Plattform-spezifische Voraussetzungen

**Web/Desktop:**
- Node.js 20 LTS
- Yarn 4.x (Berry)
- Python 3.x (für node-gyp)

**Android:**
- Java 17 (JDK)
- Android Studio 2024.1+
- Android SDK 34
- Kotlin 1.9+
- Rust Toolchain (für Matrix Rust SDK)

**iOS:**
- macOS 14+
- Xcode 16+
- XcodeGen
- SwiftLint
- CocoaPods oder Swift Package Manager
- Rust Toolchain (für Matrix Rust SDK)

---

## Web Build

### Repository klonen

```bash
git clone --recursive https://github.com/bbsam/bbsam-messenger-web.git
cd bbsam-messenger-web
```

### Abhängigkeiten installieren

```bash
# Node.js Version prüfen
node --version  # Sollte 20.x sein

# Yarn aktivieren (falls noch nicht geschehen)
corepack enable

# Abhängigkeiten installieren
yarn install
```

### Branding anwenden

```bash
# Submodule aktualisieren
git submodule update --init --recursive

# Branding-Skript ausführen
./branding/scripts/apply-branding.sh web
```

### Entwicklungs-Server

```bash
# Entwicklungsserver starten (Hot Reload)
yarn start

# Öffne http://localhost:8080
```

### Produktion Build

```bash
# Produktions-Build erstellen
yarn build

# Build-Artefakte sind in ./webapp/
```

### Docker Build

```bash
# Docker Image erstellen
docker build -t bbsam-messenger-web:latest .

# Container starten
docker run -d -p 8080:80 bbsam-messenger-web:latest
```

### Nginx Deployment

```nginx
# /etc/nginx/sites-available/bbsam-messenger

server {
    listen 443 ssl http2;
    server_name app.bbsam.eu;

    ssl_certificate /etc/letsencrypt/live/app.bbsam.eu/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.bbsam.eu/privkey.pem;

    root /var/www/bbsam-messenger-web/webapp;
    index index.html;

    # SPA Routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Config.json
    location /config.json {
        alias /etc/bbsam-messenger/config.json;
    }

    # Cache Static Assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://matrix.bbsam.eu wss://matrix.bbsam.eu;" always;
}
```

---

## Desktop Build

### Repository klonen

```bash
git clone --recursive https://github.com/bbsam/bbsam-messenger-desktop.git
cd bbsam-messenger-desktop
```

### Abhängigkeiten installieren

```bash
yarn install
```

### Branding anwenden

```bash
git submodule update --init --recursive
./branding/scripts/apply-branding.sh desktop
```

### Entwicklung

```bash
# Desktop-App im Entwicklungsmodus starten
yarn start
```

### Builds für alle Plattformen

```bash
# Windows (NSIS Installer + Portable)
yarn dist:win

# macOS (DMG + ZIP)
yarn dist:mac

# Linux (AppImage + deb + rpm)
yarn dist:linux

# Alle Plattformen
yarn dist
```

### Build-Ausgaben

```
dist/
├── BBSaM-Messenger-1.0.0-win.exe          # Windows NSIS Installer
├── BBSaM-Messenger-1.0.0-win-portable.exe # Windows Portable
├── BBSaM-Messenger-1.0.0-mac.dmg          # macOS Disk Image
├── BBSaM-Messenger-1.0.0-mac.zip          # macOS ZIP
├── BBSaM-Messenger-1.0.0-linux.AppImage   # Linux AppImage
├── bbsam-messenger_1.0.0_amd64.deb        # Debian/Ubuntu
└── bbsam-messenger-1.0.0.x86_64.rpm       # Fedora/RHEL
```

### Code Signing

**Windows:**
```bash
# Umgebungsvariablen setzen
export WIN_CSC_LINK=/path/to/certificate.pfx
export WIN_CSC_KEY_PASSWORD=your_password

yarn dist:win
```

**macOS:**
```bash
# Keychain vorbereiten
security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security import certificate.p12 -k build.keychain -P "$CERT_PASSWORD" -T /usr/bin/codesign

# Mit Notarization
export APPLE_ID=your@email.com
export APPLE_ID_PASSWORD=app-specific-password
export APPLE_TEAM_ID=YOUR_TEAM_ID

yarn dist:mac
```

---

## Android Build

### Repository klonen

```bash
git clone --recursive https://github.com/bbsam/bbsam-messenger-android.git
cd bbsam-messenger-android
```

### Rust Toolchain installieren

```bash
# Rust installieren
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Android Targets hinzufügen
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android

# NDK-Pfad setzen (in ~/.bashrc oder ~/.zshrc)
export ANDROID_NDK_HOME=$HOME/Android/Sdk/ndk/26.1.10909125
```

### Branding anwenden

```bash
git submodule update --init --recursive
./branding/scripts/apply-branding.sh android
```

### Debug Build

```bash
# Debug APK erstellen
./gradlew assembleGplayDebug

# APK ist unter:
# app/build/outputs/apk/gplay/debug/app-gplay-debug.apk
```

### Release Build

```bash
# Signing-Konfiguration in gradle.properties
echo "
signing.bbsam.release.storeFile=/path/to/keystore.jks
signing.bbsam.release.storePassword=store_password
signing.bbsam.release.keyAlias=key_alias
signing.bbsam.release.keyPassword=key_password
" >> ~/.gradle/gradle.properties

# Release APK erstellen
./gradlew assembleGplayRelease

# APK ist unter:
# app/build/outputs/apk/gplay/release/app-gplay-release.apk
```

### AAB für Play Store

```bash
# Android App Bundle erstellen
./gradlew bundleGplayRelease

# AAB ist unter:
# app/build/outputs/bundle/gplayRelease/app-gplay-release.aab
```

### Build Flavors

| Flavor | Beschreibung | App ID |
|--------|--------------|--------|
| gplay | Google Play Store | `eu.bbsam.messenger` |
| fdroid | F-Droid (FOSS) | `eu.bbsam.messenger` |
| bbsam | Custom Branding | `eu.bbsam.messenger` |

```bash
# Spezifischen Flavor bauen
./gradlew assembleBbsamRelease
```

---

## iOS Build

### Repository klonen

```bash
git clone --recursive https://github.com/bbsam/bbsam-messenger-ios.git
cd bbsam-messenger-ios
```

### Voraussetzungen installieren

```bash
# XcodeGen installieren
brew install xcodegen

# SwiftLint installieren
brew install swiftlint

# Rust installieren (falls noch nicht vorhanden)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# iOS Targets
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
```

### Branding anwenden

```bash
git submodule update --init --recursive
./branding/scripts/apply-branding.sh ios
```

### Xcode-Projekt generieren

```bash
# XcodeGen ausführen
xcodegen generate
```

### Entwicklung

```bash
# Xcode öffnen
open ElementX.xcodeproj
```

### Build über Kommandozeile

```bash
# Debug Build für Simulator
xcodebuild \
  -project ElementX.xcodeproj \
  -scheme ElementX \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build

# Release Build für Device
xcodebuild \
  -project ElementX.xcodeproj \
  -scheme ElementX \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive \
  -archivePath ./build/BBSaM-Messenger.xcarchive
```

### IPA Export

```bash
# Export Options Plist erstellen
cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
</dict>
</plist>
EOF

# IPA exportieren
xcodebuild \
  -exportArchive \
  -archivePath ./build/BBSaM-Messenger.xcarchive \
  -exportPath ./build/ipa \
  -exportOptionsPlist ExportOptions.plist
```

### TestFlight Upload

```bash
# Mit altool (veraltet, aber funktioniert)
xcrun altool \
  --upload-app \
  --type ios \
  --file ./build/ipa/BBSaM-Messenger.ipa \
  --username "your@email.com" \
  --password "@keychain:AC_PASSWORD"

# Oder mit xcrun notarytool (moderner)
xcrun notarytool submit \
  ./build/ipa/BBSaM-Messenger.ipa \
  --apple-id "your@email.com" \
  --password "@keychain:AC_PASSWORD" \
  --team-id "YOUR_TEAM_ID" \
  --wait
```

---

## CI/CD Pipelines

### GitHub Actions Workflow: Build

**.github/workflows/build.yml:**

```yaml
name: Build All Platforms

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # =========================================================================
  # Web Build
  # =========================================================================
  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'

      - name: Install Dependencies
        run: yarn install --immutable

      - name: Apply Branding
        run: ./branding/scripts/apply-branding.sh web

      - name: Build
        run: yarn build

      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: web-build
          path: webapp/

  # =========================================================================
  # Desktop Build
  # =========================================================================
  build-desktop:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'

      - name: Install Dependencies
        run: yarn install --immutable

      - name: Apply Branding
        run: ./branding/scripts/apply-branding.sh desktop
        shell: bash

      - name: Build (Linux)
        if: runner.os == 'Linux'
        run: yarn dist:linux

      - name: Build (macOS)
        if: runner.os == 'macOS'
        run: yarn dist:mac

      - name: Build (Windows)
        if: runner.os == 'Windows'
        run: yarn dist:win

      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: desktop-${{ matrix.os }}
          path: dist/

  # =========================================================================
  # Android Build
  # =========================================================================
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Rust
        uses: dtolnay/rust-action@stable
        with:
          targets: aarch64-linux-android,armv7-linux-androideabi,x86_64-linux-android

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Apply Branding
        run: ./branding/scripts/apply-branding.sh android

      - name: Build Debug APK
        run: ./gradlew assembleGplayDebug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: android-apk
          path: app/build/outputs/apk/

  # =========================================================================
  # iOS Build
  # =========================================================================
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable

      - name: Install XcodeGen
        run: brew install xcodegen

      - name: Setup Rust
        uses: dtolnay/rust-action@stable
        with:
          targets: aarch64-apple-ios,aarch64-apple-ios-sim

      - name: Apply Branding
        run: ./branding/scripts/apply-branding.sh ios

      - name: Generate Xcode Project
        run: xcodegen generate

      - name: Build for Simulator
        run: |
          xcodebuild \
            -project ElementX.xcodeproj \
            -scheme ElementX \
            -configuration Debug \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            build

      - name: Upload Build
        uses: actions/upload-artifact@v4
        with:
          name: ios-build
          path: build/
```

### GitHub Actions Workflow: Release

**.github/workflows/release.yml:**

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Download All Artifacts
        uses: actions/download-artifact@v4

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            web-build/*
            desktop-*/*
            android-apk/*
          draft: true
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Branding Sync Workflow

**.github/workflows/sync-branding.yml:**

```yaml
name: Sync Branding

on:
  repository_dispatch:
    types: [branding-updated]
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
          token: ${{ secrets.PAT_TOKEN }}

      - name: Update Submodule
        run: |
          git submodule update --remote --merge branding
          git add branding
          git commit -m "chore: update branding submodule" || exit 0

      - name: Apply Branding
        run: ./branding/scripts/apply-branding.sh ${{ github.event.repository.name }}

      - name: Commit Changes
        run: |
          git add -A
          git commit -m "chore: apply branding updates" || exit 0

      - name: Push Changes
        run: git push
```

---

## Release-Prozess

### Versionierung

Format: `major.minor.patch-bbsam.build`

Beispiel: `1.7.23-bbsam.5`

- `1.7.23` = Upstream Element Version
- `bbsam.5` = BBSaM Build-Nummer

### Release-Checkliste

```markdown
## Pre-Release

- [ ] Alle Tests bestanden
- [ ] Upstream-Änderungen gemerged
- [ ] Branding aktuell
- [ ] Changelog aktualisiert
- [ ] Version bumped

## Build & Test

- [ ] Web Build erfolgreich
- [ ] Desktop Builds erfolgreich (Win/Mac/Linux)
- [ ] Android Build erfolgreich
- [ ] iOS Build erfolgreich
- [ ] E2E-Tests bestanden
- [ ] SSO-Login funktioniert

## Release

- [ ] GitHub Release erstellt
- [ ] Assets hochgeladen
- [ ] Web deployed
- [ ] Desktop Auto-Update veröffentlicht
- [ ] APK auf Play Store hochgeladen
- [ ] IPA auf TestFlight/App Store hochgeladen

## Post-Release

- [ ] Ankündigung veröffentlicht
- [ ] Dokumentation aktualisiert
- [ ] Monitoring aktiv
```

### Changelog-Generierung

```bash
# Mit conventional-changelog
npx conventional-changelog -p angular -i CHANGELOG.md -s

# Oder manuell mit git log
git log --oneline v1.0.0..HEAD
```

---

*Dokument Version: 1.0*
*Letzte Aktualisierung: 2026-01-21*
