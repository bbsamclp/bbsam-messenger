# BBSaM-Messenger Branding Checkliste

Diese Checkliste enthält alle Dateien und Konfigurationen, die für das vollständige Rebranding angepasst werden müssen.

> **Hinweis:** Die maschinenlesbare Version dieser Checkliste befindet sich in `/branding-checklist.yaml`

---

## Übersicht

| Plattform | Status | Priorität |
|-----------|--------|-----------|
| Web | Pending | Critical |
| Desktop | Pending | Critical |
| Android | Pending | Critical |
| iOS | Pending | Critical |

---

## 1. Zentrales Branding-Repository

### Assets

- [ ] **Master-Icon erstellen**
  - Datei: `bbsam-branding/assets/icons/app-icon.svg`
  - Format: SVG (Vektorgrafik)
  - Empfehlung: Quadratisch, 1024x1024px Viewport

- [ ] **Logos erstellen**
  - `bbsam-branding/assets/logos/bbsam-logo.svg` - Hauptlogo
  - `bbsam-branding/assets/logos/bbsam-wordmark.svg` - Nur Text
  - `bbsam-branding/assets/logos/bbsam-logo-white.svg` - Für dunkle Hintergründe

- [ ] **Icons generieren**
  - `./bbsam-branding/scripts/generate-icons.sh` ausführen
  - Prüfen: Android, iOS, Web, Desktop Icons vorhanden

### Konfiguration

- [ ] **Farben definieren** (`config/colors.json`)
  - Primärfarbe festlegen
  - Sekundärfarbe festlegen
  - Light/Dark Theme Varianten

- [ ] **Strings definieren** (`config/strings.json`)
  - App-Name: "BBSaM-Messenger"
  - Alle Textersetzungen prüfen

- [ ] **Server konfigurieren** (`config/servers.json`)
  - Homeserver URL: `https://matrix.bbsam.eu`
  - Keycloak URL: `https://bbb.bbsam.eu/keycloak`

---

## 2. Web-Plattform (element-web)

### Kritische Dateien

- [ ] **config.json**
  - `brand`: "BBSaM-Messenger"
  - `default_server_config.m.homeserver.base_url`: "https://matrix.bbsam.eu"
  - `sso_redirect_options.immediate`: true
  - `disable_custom_urls`: true
  - `disable_guests`: true

- [ ] **res/manifest.json**
  - `name`: "BBSaM-Messenger"
  - `short_name`: "BBSaM"
  - `description`: "Sicherer Messenger für BBSaM"

### Icons

- [ ] `res/vector-icons/favicon.ico`
- [ ] `res/vector-icons/apple-touch-icon.png` (180x180)
- [ ] `res/vector-icons/favicon-192.png`
- [ ] `res/vector-icons/favicon-512.png`

### Logos

- [ ] `res/img/element-desktop-logo.svg` → BBSaM Logo
- [ ] `res/img/element-shiny.svg` → BBSaM Variante
- [ ] `res/img/logos/` → Alle BBSaM Logos

### Theming

- [ ] `res/themes/light/css/theme.css` - Farben anpassen
- [ ] `res/themes/dark/css/theme.css` - Farben anpassen

### String-Ersetzungen

- [ ] "Element" → "BBSaM-Messenger"
- [ ] "element.io" → "bbsam.eu"
- [ ] EMS-Referenzen entfernen
- [ ] "Powered by Element" entfernen

### Zu entfernen/deaktivieren

- [ ] Posthog Analytics (`posthog.enabled: false`)
- [ ] Sentry (`sentry.enabled: false`)
- [ ] Registrierungs-UI (`UIFeature.registration: false`)
- [ ] Passwort-Reset (`UIFeature.passwordReset: false`)

---

## 3. Desktop-Plattform (element-desktop)

### Package-Metadaten

- [ ] **package.json**
  - `name`: "bbsam-messenger-desktop"
  - `productName`: "BBSaM-Messenger"
  - `description`: "BBSaM-Messenger Desktop Client"
  - `author`: "BBSaM"

- [ ] **electron-builder.json**
  - `appId`: "eu.bbsam.messenger"
  - `productName`: "BBSaM-Messenger"
  - `publish.owner`: "bbsam"
  - `publish.repo`: "bbsam-messenger-desktop"

### Icons

- [ ] `build/icons/icon.ico` (Windows, multi-res)
- [ ] `build/icons/icon.icns` (macOS)
- [ ] `build/icons/icon.png` (Linux, 256x256 oder 512x512)
- [ ] `build/icons/icon.svg` (Quelle)

### Installer

- [ ] Windows NSIS Installer Branding
- [ ] macOS DMG Hintergrundbild (optional)
- [ ] Linux Desktop-Eintrag

### Auto-Update

- [ ] GitHub Releases konfigurieren
- [ ] `publish` Sektion in electron-builder.json

---

## 4. Android-Plattform (element-x-android)

### Build-Konfiguration

- [ ] **app/build.gradle.kts**
  - `namespace`: "eu.bbsam.messenger"
  - `applicationId`: "eu.bbsam.messenger"
  - `APPLICATION_NAME`: "BBSaM-Messenger"

- [ ] **gradle.properties**
  - Signing-Konfiguration

### Ressourcen

- [ ] **strings.xml**
  - `app_name`: "BBSaM-Messenger"
  - `login_redirect_scheme`: "eu.bbsam.messenger"

- [ ] **AndroidManifest.xml**
  - Package Name
  - Deep Links / Intent Filter

### Icons

- [ ] `mipmap-mdpi/ic_launcher.png` (48x48)
- [ ] `mipmap-hdpi/ic_launcher.png` (72x72)
- [ ] `mipmap-xhdpi/ic_launcher.png` (96x96)
- [ ] `mipmap-xxhdpi/ic_launcher.png` (144x144)
- [ ] `mipmap-xxxhdpi/ic_launcher.png` (192x192)
- [ ] `mipmap-anydpi-v26/ic_launcher.xml` (Adaptive Icon)

### Farben

- [ ] `values/colors.xml` - Light Theme
- [ ] `values-night/colors.xml` - Dark Theme

### Build Flavor (empfohlen)

- [ ] `bbsam` Build Flavor erstellen
- [ ] Ressourcen in `app/src/bbsam/res/` isolieren
- [ ] Minimiert Merge-Konflikte mit Upstream

---

## 5. iOS-Plattform (element-x-ios)

### XcodeGen Konfiguration

- [ ] **app.yml**
  - `APP_DISPLAY_NAME`: "BBSaM-Messenger"
  - `BASE_BUNDLE_IDENTIFIER`: "eu.bbsam.messenger"
  - `APP_GROUP_IDENTIFIER`: "group.eu.bbsam"
  - `PRODUCTION_APP_NAME`: "BBSaM"
  - `DEVELOPMENT_TEAM`: "[Team ID]"

- [ ] **project.yml**
  - Version und Build-Nummer

- [ ] **ElementX/SupportingFiles/target.yml**
  - Associated Domains für OIDC:
    - `webcredentials:bbsam.eu`
    - `applinks:matrix.bbsam.eu`

### Icons

- [ ] `ElementX/Resources/Assets.xcassets/AppIcon.appiconset/`
  - Alle iOS Icon-Größen (siehe `Contents.json`)
  - 1024x1024 für App Store

### Farben

- [ ] `ElementX/Resources/Assets.xcassets/Colors/`
  - AccentColor anpassen

### Runtime-Konfiguration

- [ ] `ElementX/Sources/AppSettings.swift`
  - Default Homeserver
  - Map-Konfiguration (optional)

### Server-seitig

- [ ] `apple-app-site-association` auf bbsam.eu
  - Für Associated Domains
  - Für Universal Links

### Nach Änderungen

- [ ] `xcodegen generate` ausführen

---

## 6. SSO/Keycloak

### Keycloak-Konfiguration

- [ ] Realm `BBSaM` vorhanden
- [ ] Client `bbsam-messenger` erstellt
- [ ] Valid Redirect URIs:
  - `https://matrix.bbsam.eu/_synapse/client/oidc/callback`
  - `eu.bbsam.messenger://callback`
  - `eu.bbsam.messenger.debug://callback`
  - `http://localhost:8080/callback`
- [ ] Client Secret generiert und gesichert

### Synapse-Konfiguration

- [ ] OIDC Provider konfiguriert
- [ ] Passwort-Login deaktiviert
- [ ] Registrierung deaktiviert
- [ ] Backchannel Logout aktiviert

### Testen

- [ ] Web SSO-Login
- [ ] Desktop SSO-Login
- [ ] Android SSO-Login
- [ ] iOS SSO-Login
- [ ] Logout auf allen Plattformen
- [ ] Token-Refresh

---

## 7. CI/CD

### GitHub Actions

- [ ] `build.yml` - Automatische Builds
- [ ] `release.yml` - Release-Erstellung
- [ ] `sync-branding.yml` - Branding-Synchronisation

### Secrets konfigurieren

- [ ] `PAT_TOKEN` - Personal Access Token
- [ ] Signing-Zertifikate (Android, iOS, Windows, macOS)
- [ ] App Store Connect Credentials

---

## 8. Validierung

### Vor Go-Live

- [ ] `./scripts/validate-branding.sh` ohne Fehler
- [ ] Alle Plattformen bauen erfolgreich
- [ ] SSO-Login funktioniert end-to-end
- [ ] Keine "Element" Referenzen in UI
- [ ] Rechtliche Hinweise angepasst
- [ ] Datenschutzerklärung verlinkt
- [ ] Impressum verlinkt

### Nach Go-Live

- [ ] Monitoring eingerichtet
- [ ] Fehler-Reporting funktioniert
- [ ] Auto-Update funktioniert (Desktop)
- [ ] Push-Notifications funktionieren (Mobile)

---

## Fortschritt

```
[==>                           ] 10%
```

**Nächste Schritte:**
1. Master-Icon erstellen
2. Icons generieren
3. Repositories forken
4. Branding anwenden
5. SSO testen

---

*Checkliste Version: 1.0*
*Letzte Aktualisierung: 2026-01-21*
