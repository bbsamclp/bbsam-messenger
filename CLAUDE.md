# BBSaM-Messenger — Projekt-Konventionen für Claude Code

## Projekt

BBSaM-Messenger ist ein custom-branded Fork der Element Messenger Suite (Web, Desktop, Android, iOS) mit SSO-only Authentifizierung via Keycloak. Dieses Repository (`bbsam-messenger`) dient als **zentrales Branding- und Planungs-Hub**. Die eigentlichen Messenger-Apps liegen in separaten Fork-Repositories.

## Sprache

- **Dokumentation und Kommentare**: Deutsch
- **Code** (Variablen, Funktionen, Klassen): Englisch

## Lizenz

AGPLv3 — Alle Forks müssen einen Link zum öffentlichen Quellcode enthalten.

## Infrastruktur

| Dienst       | URL                                          |
|-------------|----------------------------------------------|
| Synapse     | `https://matrix.bbsam.eu`                   |
| Keycloak    | `https://bbb.bbsam.eu/keycloak`             |
| Realm       | `BBSaM`                                      |
| Client ID   | `bbsam-messenger`                            |
| Web App     | `https://app.bbsam.eu`                       |

## Repository-Struktur

```
bbsam-branding/          # Assets, Konfigurationen, Skripte
  assets/                # Icons, Logos, Splash Screens, Screenshots
  config/                # colors.json, strings.json, web-config.json, servers.json
  scripts/               # apply-branding.sh, validate-branding.sh, generate-icons.sh, check-upstream.sh
docs/                    # Architektur, Build, SSO, Deployment, Compliance
.github/workflows/       # CI/CD Pipelines (build, release, generate-icons, sync-branding, upstream-check)
branding-checklist.yaml  # Maschinenlesbare Branding-Konfiguration
```

## Branding-Workflow

1. Konfigurationen in `bbsam-branding/config/` bearbeiten
2. `bbsam-branding/scripts/apply-branding.sh [web|desktop|android|ios|all]` ausführen
3. `bbsam-branding/scripts/validate-branding.sh` zur Überprüfung ausführen
4. Icons aus Master-SVG generieren: `bbsam-branding/scripts/generate-icons.sh`

## Build-Anforderungen

| Plattform | Toolchain                            |
|-----------|--------------------------------------|
| Web       | Node.js 20, Yarn 4                  |
| Desktop   | Electron, electron-builder           |
| Android   | Kotlin, JDK 17, Rust SDK, Gradle    |
| iOS       | Swift, Xcode 16+, XcodeGen          |

## SSO-Konfiguration

- OIDC mit PKCE (insbesondere für Mobile)
- Passwort-Login deaktiviert (`password_config.enabled: false`)
- Registrierung deaktiviert
- Scopes: `openid`, `profile`, `email`
- Redirect-URIs für alle Plattformen konfiguriert (siehe `bbsam-branding/config/servers.json`)

## Konventionen

- Bestehende Branding-Skripte verwenden, keine Konfigurationen duplizieren
- `branding-checklist.yaml` für Vollständigkeit prüfen
- Farbdefinitionen aus `config/colors.json` verwenden (Primär: `#1A73E8`)
- String-Ersetzungen aus `config/strings.json` verwenden
- Upstream-Forks: Web/Desktop (Classic Element), Android/iOS (Element X)
- Nach jedem Branding-Schritt `validate-branding.sh` ausführen

## Fork-Repositories

| Plattform | Upstream                              | Fork                          |
|-----------|---------------------------------------|-------------------------------|
| Web       | `element-hq/element-web`              | `bbsam-messenger-web`         |
| Desktop   | `element-hq/element-desktop`          | `bbsam-messenger-desktop`     |
| Android   | `element-hq/element-x-android`        | `bbsam-messenger-android`     |
| iOS       | `element-hq/element-x-ios`            | `bbsam-messenger-ios`         |
