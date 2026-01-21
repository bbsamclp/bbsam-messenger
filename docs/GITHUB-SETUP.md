# GitHub CI/CD Setup Guide

## Übersicht

Dieses Dokument beschreibt die notwendigen Schritte zur Einrichtung der CI/CD-Pipeline in GitHub.

## Workflows

| Workflow | Datei | Trigger | Beschreibung |
|----------|-------|---------|--------------|
| **Build & Test** | `build.yml` | Push, PR | Baut alle Plattformen, validiert Branding |
| **Release** | `release.yml` | Tag `v*` | Erstellt Release mit allen Artefakten |
| **Sync Branding** | `sync-branding.yml` | Manual, Dispatch | Synchronisiert Branding-Änderungen |
| **Generate Icons** | `generate-icons.yml` | Push (icon.svg) | Generiert Icons aus Master-SVG |
| **Upstream Check** | `upstream-check.yml` | Täglich 6:00 UTC | Prüft auf neue Upstream-Releases |

---

## 1. GitHub Secrets einrichten

Gehe zu: **Repository → Settings → Secrets and variables → Actions**

### Erforderliche Secrets

#### Für alle Plattformen

| Secret | Beschreibung | Wie erstellen |
|--------|--------------|---------------|
| `PAT_TOKEN` | Personal Access Token für Submodule | GitHub → Settings → Developer settings → PAT |

#### Android Signing

| Secret | Beschreibung | Wie erstellen |
|--------|--------------|---------------|
| `ANDROID_KEYSTORE` | Base64-encoded Keystore | `base64 -i keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore Passwort | - |
| `ANDROID_KEY_ALIAS` | Key Alias | - |
| `ANDROID_KEY_PASSWORD` | Key Passwort | - |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | Play Store API JSON | Google Cloud Console |

**Keystore erstellen:**
```bash
keytool -genkey -v -keystore bbsam-messenger.jks \
  -alias bbsam \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=BBSaM, OU=IT, O=BBSaM, L=Aschersleben, ST=Sachsen-Anhalt, C=DE"

# Base64 für GitHub Secret
base64 -i bbsam-messenger.jks > keystore.b64
```

#### iOS/macOS Signing

| Secret | Beschreibung | Wie erstellen |
|--------|--------------|---------------|
| `APPLE_ID` | Apple Developer Account Email | - |
| `APPLE_ID_PASSWORD` | App-spezifisches Passwort | appleid.apple.com → App-Specific Passwords |
| `APPLE_TEAM_ID` | Team ID | developer.apple.com → Membership |
| `IOS_CERTIFICATE` | Base64-encoded .p12 | Keychain Export |
| `IOS_CERTIFICATE_PWD` | Zertifikat Passwort | - |
| `IOS_PROVISIONING_PROFILE` | Base64-encoded .mobileprovision | developer.apple.com |

**Zertifikat exportieren:**
```bash
# In Keychain Access: Export → .p12
# Dann:
base64 -i certificate.p12 > certificate.b64

# Provisioning Profile
base64 -i profile.mobileprovision > profile.b64
```

#### macOS Code Signing

| Secret | Beschreibung |
|--------|--------------|
| `MACOS_CERTIFICATE` | Base64-encoded Developer ID Application .p12 |
| `MACOS_CERTIFICATE_PWD` | Zertifikat Passwort |

#### Windows Code Signing

| Secret | Beschreibung |
|--------|--------------|
| `WIN_CERTIFICATE` | Base64-encoded .pfx Code Signing Certificate |
| `WIN_CERTIFICATE_PWD` | Zertifikat Passwort |

---

## 2. Repository-Einstellungen

### Branch Protection Rules

Gehe zu: **Settings → Branches → Add rule**

Für `main` Branch:
- [x] Require a pull request before merging
- [x] Require status checks to pass before merging
  - Status checks: `validate-branding`, `build-web`
- [x] Require branches to be up to date before merging
- [ ] Include administrators (optional)

### GitHub Pages (für Web-Hosting)

Falls die Web-App auf GitHub Pages gehostet werden soll:

1. **Settings → Pages**
2. Source: GitHub Actions
3. Custom domain: `app.bbsam.eu` (optional)

### Environments

Für kontrollierte Deployments:

1. **Settings → Environments → New environment**
2. Erstelle: `production`, `staging`
3. Füge Reviewer hinzu für manuelle Freigabe

---

## 3. Was GitHub automatisch erledigt

### Bei jedem Push/PR:
- ✅ Branding-Validierung
- ✅ Web-Build testen
- ✅ Desktop-Builds (Linux, macOS, Windows)
- ✅ Android Debug-APK bauen
- ✅ iOS Simulator-Build

### Bei Tag-Erstellung (z.B. `v1.0.0`):
- ✅ Release-Draft erstellen
- ✅ Alle Plattformen bauen und signieren
- ✅ Artefakte an Release anhängen
- ✅ Optional: Play Store / TestFlight Upload

### Täglich (6:00 UTC):
- ✅ Upstream-Repositories auf Updates prüfen
- ✅ Issue erstellen/aktualisieren mit neuen Versionen

---

## 4. Release erstellen

### Automatisch (empfohlen):

```bash
# 1. Version bumpen
# 2. Tag erstellen und pushen
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions:
# - Erstellt Draft-Release
# - Baut alle Plattformen
# - Lädt Artefakte hoch
# - Optional: Publiziert zu App Stores
```

### Manuell:

1. **Actions → Release → Run workflow**
2. Version eingeben: `v1.0.0`
3. Workflow läuft durch
4. **Releases** → Draft bearbeiten → Publish

---

## 5. Checkliste für Setup

### GitHub Repository

- [ ] Repository erstellt
- [ ] Secrets eingerichtet (siehe Abschnitt 1)
- [ ] Branch Protection aktiviert
- [ ] Environments konfiguriert (optional)

### Zertifikate

- [ ] Android Keystore erstellt und als Secret hinterlegt
- [ ] Apple Developer Account vorhanden
- [ ] iOS Distribution Certificate erstellt
- [ ] iOS Provisioning Profile erstellt
- [ ] macOS Developer ID Certificate (für Notarization)
- [ ] Windows Code Signing Certificate (optional)

### App Store Accounts

- [ ] Google Play Console Account
- [ ] Google Play Service Account erstellt
- [ ] Apple Developer Program Mitgliedschaft
- [ ] App Store Connect App angelegt

---

## 6. Fehlerbehebung

### Build schlägt fehl

```bash
# Lokal testen
yarn install
yarn build
```

### Code Signing Fehler

1. Prüfe ob Zertifikate gültig sind
2. Prüfe ob Secrets korrekt Base64-encoded sind
3. Prüfe Team ID / Bundle ID Übereinstimmung

### Upstream Merge Konflikte

```bash
# 1. Upstream hinzufügen
git remote add upstream https://github.com/element-hq/element-web.git

# 2. Fetch und Merge
git fetch upstream
git checkout main
git merge upstream/v1.x.x

# 3. Konflikte lösen, committen, pushen
```

---

## 7. Kosten

GitHub Actions Free Tier beinhaltet:
- 2.000 Minuten/Monat für private Repos
- Unbegrenzt für public Repos

Geschätzte Build-Zeiten:
- Web: ~5 Min
- Desktop (je OS): ~10 Min
- Android: ~15 Min
- iOS: ~20 Min

**Gesamt pro Release: ~60-90 Minuten**

---

*Dokument Version: 1.0*
*Letzte Aktualisierung: 2026-01-21*
