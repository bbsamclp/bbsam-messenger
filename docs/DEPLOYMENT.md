# Deployment Guide: BBSaM-Messenger

## Inhaltsverzeichnis

1. [Web-Deployment](#web-deployment)
2. [Desktop-Distribution](#desktop-distribution)
3. [Android App Store](#android-app-store)
4. [iOS App Store](#ios-app-store)
5. [Monitoring & Wartung](#monitoring--wartung)

---

## Web-Deployment

### Option 1: Docker Compose (Empfohlen)

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  bbsam-messenger-web:
    image: ghcr.io/bbsam/bbsam-messenger-web:latest
    container_name: bbsam-messenger-web
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./config.json:/usr/share/nginx/html/config.json:ro
    environment:
      - NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx/conf.d
    networks:
      - bbsam-network

  # Optional: Nginx Reverse Proxy
  nginx-proxy:
    image: nginx:alpine
    container_name: nginx-proxy
    restart: unless-stopped
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/certs:/etc/nginx/certs:ro
      - ./nginx/html/.well-known:/var/www/html/.well-known:ro
    networks:
      - bbsam-network

networks:
  bbsam-network:
    driver: bridge
```

**Deployment:**

```bash
# Build und Start
docker-compose up -d

# Logs prüfen
docker-compose logs -f bbsam-messenger-web

# Update
docker-compose pull
docker-compose up -d
```

### Option 2: Nginx Static Hosting

```bash
# Build erstellen
cd bbsam-messenger-web
yarn install
yarn build

# Auf Server kopieren
rsync -avz webapp/ user@server:/var/www/bbsam-messenger/

# Nginx-Konfiguration
sudo cp nginx.conf /etc/nginx/sites-available/bbsam-messenger
sudo ln -s /etc/nginx/sites-available/bbsam-messenger /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

**nginx.conf:**

```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name app.bbsam.eu;

    # SSL-Zertifikate (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/app.bbsam.eu/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.bbsam.eu/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # Modern SSL-Konfiguration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;

    # Root-Verzeichnis
    root /var/www/bbsam-messenger;
    index index.html;

    # SPA Routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Config.json (dynamisch laden)
    location = /config.json {
        alias /etc/bbsam-messenger/config.json;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # Statische Assets cachen
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(self), payment=(), usb=()" always;

    # CSP (anpassen!)
    add_header Content-Security-Policy "
        default-src 'self';
        script-src 'self' 'unsafe-inline' 'unsafe-eval';
        style-src 'self' 'unsafe-inline';
        img-src 'self' data: https: blob:;
        font-src 'self' data:;
        connect-src 'self' https://matrix.bbsam.eu wss://matrix.bbsam.eu https://bbb.bbsam.eu;
        media-src 'self' blob:;
        worker-src 'self' blob:;
        frame-ancestors 'self';
    " always;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
}

# HTTP → HTTPS Redirect
server {
    listen 80;
    listen [::]:80;
    server_name app.bbsam.eu;
    return 301 https://$server_name$request_uri;
}
```

### Let's Encrypt SSL

```bash
# Certbot installieren
sudo apt install certbot python3-certbot-nginx

# Zertifikat erstellen
sudo certbot --nginx -d app.bbsam.eu

# Auto-Renewal testen
sudo certbot renew --dry-run
```

---

## Desktop-Distribution

### Automatische Releases (GitHub Actions)

Die Desktop-Builds werden automatisch über GitHub Actions erstellt und als GitHub Releases veröffentlicht.

**Release-Prozess:**

```bash
# Version bumpen
npm version patch  # oder minor/major

# Tag erstellen und pushen
git push && git push --tags

# GitHub Action wird automatisch getriggert
# Builds werden als Draft-Release erstellt
```

### Manuelle Distribution

**Windows:**

```bash
# Build erstellen
yarn dist:win

# Artefakte:
# dist/BBSaM-Messenger-1.0.0-win.exe  (NSIS Installer)
# dist/BBSaM-Messenger-1.0.0-win-portable.exe  (Portable)
```

**macOS:**

```bash
# Build erstellen (nur auf macOS!)
yarn dist:mac

# Artefakte:
# dist/BBSaM-Messenger-1.0.0-mac.dmg
# dist/BBSaM-Messenger-1.0.0-mac.zip

# Notarization (für Gatekeeper)
# Wird automatisch von electron-builder durchgeführt
# wenn APPLE_ID, APPLE_ID_PASSWORD und APPLE_TEAM_ID gesetzt sind
```

**Linux:**

```bash
# Build erstellen
yarn dist:linux

# Artefakte:
# dist/BBSaM-Messenger-1.0.0-linux.AppImage
# dist/bbsam-messenger_1.0.0_amd64.deb
# dist/bbsam-messenger-1.0.0.x86_64.rpm
```

### Auto-Update

Die Desktop-App prüft automatisch auf Updates über GitHub Releases:

```json
// electron-builder.json
{
  "publish": {
    "provider": "github",
    "owner": "bbsam",
    "repo": "bbsam-messenger-desktop"
  }
}
```

---

## Android App Store

### Google Play Store

#### 1. App Signing

```bash
# Keystore erstellen (einmalig!)
keytool -genkeypair \
  -v \
  -storetype PKCS12 \
  -keystore bbsam-release.keystore \
  -alias bbsam \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# WICHTIG: Keystore sicher aufbewahren!
# Verlust = Keine Updates mehr möglich!
```

#### 2. Build

```bash
# Release AAB erstellen
./gradlew bundleGplayRelease

# AAB signieren (falls nicht auto-signiert)
jarsigner -verbose \
  -sigalg SHA256withRSA \
  -digestalg SHA-256 \
  -keystore bbsam-release.keystore \
  app/build/outputs/bundle/gplayRelease/app-gplay-release.aab \
  bbsam
```

#### 3. Play Console

1. Gehe zu [Google Play Console](https://play.google.com/console)
2. Erstelle neue App
3. Fülle Store-Eintrag aus:
   - App-Name: BBSaM-Messenger
   - Kurzbeschreibung (80 Zeichen)
   - Vollständige Beschreibung (4000 Zeichen)
   - Screenshots (mindestens 2)
   - Feature-Grafik (1024x500)
   - App-Symbol (512x512)
4. Lade AAB hoch
5. Wähle Zielgruppe und Inhaltseinstufung
6. Stelle Datenschutzrichtlinie bereit
7. Starte internen/geschlossenen Test
8. Nach Test: Produktion freigeben

#### 4. Fastlane (Automatisierung)

```ruby
# fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Play Store"
  lane :deploy do
    gradle(task: "bundleGplayRelease")
    upload_to_play_store(
      track: 'internal',
      aab: 'app/build/outputs/bundle/gplayRelease/app-gplay-release.aab'
    )
  end
end
```

### F-Droid

```bash
# F-Droid Build (ohne proprietäre Komponenten)
./gradlew assembleFdroidRelease

# APK für F-Droid-Repository
# Siehe: https://f-droid.org/docs/Submitting_to_F-Droid_Quickstart/
```

---

## iOS App Store

### 1. App Store Connect

1. Gehe zu [App Store Connect](https://appstoreconnect.apple.com)
2. Erstelle neue App:
   - Name: BBSaM-Messenger
   - Bundle ID: eu.bbsam.messenger
   - SKU: bbsam-messenger
3. Fülle App-Informationen aus

### 2. Zertifikate & Provisioning

```bash
# Xcode oder Apple Developer Portal:
# 1. App ID erstellen: eu.bbsam.messenger
# 2. Distribution Certificate erstellen
# 3. Provisioning Profile erstellen (App Store)
```

### 3. Build & Upload

```bash
# Archiv erstellen
xcodebuild \
  -project ElementX.xcodeproj \
  -scheme ElementX \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive \
  -archivePath ./build/BBSaM-Messenger.xcarchive

# IPA exportieren
xcodebuild \
  -exportArchive \
  -archivePath ./build/BBSaM-Messenger.xcarchive \
  -exportPath ./build/ipa \
  -exportOptionsPlist ExportOptions.plist

# Zu App Store Connect hochladen
xcrun altool \
  --upload-app \
  --type ios \
  --file ./build/ipa/BBSaM-Messenger.ipa \
  --username "your@email.com" \
  --password "@keychain:AC_PASSWORD"
```

### 4. TestFlight

1. Lade Build zu App Store Connect hoch
2. Warte auf Verarbeitung (~30 Min)
3. Füge interne Tester hinzu
4. Starte internes Testing
5. Optional: Externes Testing (Beta-Review erforderlich)

### 5. App Store Submission

1. Wähle Build für Submission
2. Fülle Metadaten aus:
   - Screenshots (alle Geräte)
   - Keywords
   - Support-URL
   - Marketing-URL
   - Datenschutzrichtlinie-URL
3. Beantworte Fragen zu Verschlüsselung (Matrix = JA)
4. Sende zur Review
5. Warte auf Genehmigung (1-7 Tage)

### 6. Fastlane (Automatisierung)

```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Push to TestFlight"
  lane :beta do
    build_app(
      scheme: "ElementX",
      export_method: "app-store"
    )
    upload_to_testflight
  end

  desc "Push to App Store"
  lane :release do
    build_app(
      scheme: "ElementX",
      export_method: "app-store"
    )
    upload_to_app_store(
      skip_metadata: true,
      skip_screenshots: true
    )
  end
end
```

---

## Monitoring & Wartung

### Health Checks

**Web Health Check:**

```bash
# Verfügbarkeit prüfen
curl -s -o /dev/null -w "%{http_code}" https://app.bbsam.eu

# Config erreichbar
curl -s https://app.bbsam.eu/config.json | jq .brand
```

**Matrix Health Check:**

```bash
# Federation Check
curl -s https://matrix.bbsam.eu/_matrix/federation/v1/version | jq .

# Client API
curl -s https://matrix.bbsam.eu/_matrix/client/versions | jq .
```

### Monitoring-Tools

1. **Uptime Monitoring:**
   - UptimeRobot
   - Pingdom
   - Better Uptime

2. **Error Tracking (optional):**
   - Sentry (selbst gehostet)
   - GlitchTip

3. **Logs:**
   - Docker Logs
   - Journalctl
   - Loki + Grafana

### Backup-Strategie

```bash
# Matrix Synapse Datenbank
pg_dump -h localhost -U synapse synapse > synapse_$(date +%Y%m%d).sql

# Media Store
rsync -avz /var/lib/synapse/media_store/ backup:/synapse/media/

# Keycloak
docker exec keycloak /opt/keycloak/bin/kc.sh export --dir /tmp/export
docker cp keycloak:/tmp/export ./keycloak-backup-$(date +%Y%m%d)
```

### Update-Prozess

1. **Upstream-Updates prüfen:**
   ```bash
   ./branding/scripts/check-upstream.sh
   ```

2. **Merge durchführen:**
   ```bash
   git fetch upstream
   git merge upstream/main --no-ff
   # Konflikte lösen
   git push
   ```

3. **Branding erneut anwenden:**
   ```bash
   ./branding/scripts/apply-branding.sh all
   ```

4. **Testen:**
   - Lokaler Build
   - SSO-Login
   - Grundfunktionen

5. **Deployment:**
   - Staging zuerst
   - Dann Produktion

---

## Checkliste für Go-Live

### Pre-Launch

- [ ] Alle Plattformen gebaut und getestet
- [ ] SSO funktioniert auf allen Plattformen
- [ ] SSL-Zertifikate gültig
- [ ] DNS korrekt konfiguriert
- [ ] Backup-Strategie implementiert
- [ ] Monitoring eingerichtet
- [ ] Dokumentation vollständig
- [ ] Rechtliche Texte (Datenschutz, Impressum, AGB)

### Launch

- [ ] Web-App deployed
- [ ] Desktop-Releases veröffentlicht
- [ ] Android auf Play Store
- [ ] iOS auf App Store
- [ ] Ankündigung vorbereitet

### Post-Launch

- [ ] Monitoring aktiv
- [ ] Support-Kanal eingerichtet
- [ ] Erste Benutzer onboarded
- [ ] Feedback gesammelt
- [ ] Erste Bugfixes deployed

---

*Dokument Version: 1.0*
*Letzte Aktualisierung: 2026-01-21*
