# BBSaM-Messenger Projektplanung

Vollständige Projektplanung für einen Fork des Element Messengers mit eigenem Branding als **"BBSaM-Messenger"**. Der Messenger unterstützt ausschließlich SSO-Authentifizierung über Keycloak.

## Infrastruktur

| Dienst | URL |
|--------|-----|
| Matrix Homeserver (Synapse) | `https://matrix.bbsam.eu` |
| Keycloak Server | `https://bbb.bbsam.eu/keycloak` |
| Keycloak Realm | `BBSaM` |

## Repository-Struktur

```
bbsam/
├── bbsam-branding/              # Zentrales Branding & Konfiguration
├── bbsam-messenger-web/         # Fork: element-hq/element-web
├── bbsam-messenger-desktop/     # Fork: element-hq/element-desktop
├── bbsam-messenger-android/     # Fork: element-hq/element-x-android
└── bbsam-messenger-ios/         # Fork: element-hq/element-x-ios
```

## Zielplattformen

| Plattform | Upstream Repository | Empfehlung |
|-----------|---------------------|------------|
| Web | `element-hq/element-web` | Classic |
| Desktop | `element-hq/element-desktop` | Classic |
| Android | `element-hq/element-x-android` | Element X |
| iOS | `element-hq/element-x-ios` | Element X |

## Dokumentation

| Dokument | Beschreibung |
|----------|--------------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Systemarchitektur und Komponenten-Diagramme |
| [BUILD-GUIDE.md](docs/BUILD-GUIDE.md) | Build-Anleitungen für alle Plattformen |
| [SSO-INTEGRATION.md](docs/SSO-INTEGRATION.md) | Keycloak SSO-Konfiguration |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | Deployment-Anleitungen |
| [COMPLIANCE.md](docs/COMPLIANCE.md) | Lizenz- und DSGVO-Compliance |
| [BRANDING-CHECKLIST.md](docs/BRANDING-CHECKLIST.md) | Vollständige Branding-Checkliste |

## Branding-Repository

```
bbsam-branding/
├── assets/
│   ├── icons/           # Plattform-spezifische Icons
│   ├── logos/           # BBSaM Logos
│   └── splash/          # Splash Screens
├── config/
│   ├── colors.json      # Farbdefinitionen
│   ├── strings.json     # Textersetzungen
│   ├── web-config.json  # Element Web Konfiguration
│   └── servers.json     # Server-Konfiguration
└── scripts/
    ├── generate-icons.sh    # Icon-Generierung
    ├── apply-branding.sh    # Branding anwenden
    ├── check-upstream.sh    # Upstream-Updates prüfen
    └── validate-branding.sh # Branding validieren
```

## Schnellstart

### 1. Icons generieren

```bash
# Master-Icon erstellen: bbsam-branding/assets/icons/app-icon.svg

# Icons für alle Plattformen generieren
./bbsam-branding/scripts/generate-icons.sh
```

### 2. Branding anwenden

```bash
# Auf Web-Repository anwenden
./bbsam-branding/scripts/apply-branding.sh web

# Auf alle Plattformen anwenden
./bbsam-branding/scripts/apply-branding.sh all
```

### 3. Branding validieren

```bash
./bbsam-branding/scripts/validate-branding.sh
```

## SSO-Konfiguration

BBSaM-Messenger verwendet ausschließlich SSO-Authentifizierung über Keycloak. Passwort-Login ist deaktiviert.

```yaml
# Synapse Konfiguration (Auszug)
oidc_providers:
  - idp_id: keycloak
    idp_name: "BBSaM Login"
    issuer: "https://bbb.bbsam.eu/keycloak/realms/BBSaM"
    client_id: "bbsam-messenger"

password_config:
  enabled: false
```

Vollständige Dokumentation: [SSO-INTEGRATION.md](docs/SSO-INTEGRATION.md)

## Phasen-Übersicht

| Phase | Beschreibung |
|-------|--------------|
| 1 | Repository-Analyse & Setup |
| 2 | Branding-Repository erstellen |
| 3 | App-Forks erstellen |
| 4 | SSO-Integration |
| 5 | Testing & Deployment |

## Lizenz

Dieses Projekt basiert auf Element (https://element.io) und ist unter der **GNU Affero General Public License v3.0 (AGPLv3)** lizenziert.

Der vollständige Quellcode ist verfügbar unter:
- https://github.com/bbsam/bbsam-messenger-web
- https://github.com/bbsam/bbsam-messenger-desktop
- https://github.com/bbsam/bbsam-messenger-android
- https://github.com/bbsam/bbsam-messenger-ios

## Maschinenlesbare Konfiguration

Die vollständige Branding-Checkliste ist auch als YAML verfügbar:
- [branding-checklist.yaml](branding-checklist.yaml)

---

*Projektplanung Version: 1.0*
*Erstellt: 2026-01-21*
