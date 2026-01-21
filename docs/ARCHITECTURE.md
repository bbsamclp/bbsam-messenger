# BBSaM-Messenger Architektur

## Inhaltsverzeichnis

1. [Systemübersicht](#systemübersicht)
2. [Komponenten-Diagramm](#komponenten-diagramm)
3. [Repository-Struktur](#repository-struktur)
4. [Datenfluss-Diagramm](#datenfluss-diagramm)
5. [SSO-Sequenzdiagramm](#sso-sequenzdiagramm)
6. [Plattform-Architektur](#plattform-architektur)
7. [Branding-Integration](#branding-integration)

---

## Systemübersicht

BBSaM-Messenger ist ein vollständig gebrandeter Fork der Element Messenger-Familie, der ausschließlich SSO-Authentifizierung über Keycloak unterstützt.

### Kernkomponenten

| Komponente | Beschreibung | URL |
|------------|--------------|-----|
| **Matrix Homeserver** | Synapse Server für Messaging | `matrix.bbsam.eu` |
| **Keycloak IdP** | Identity Provider für SSO | `bbb.bbsam.eu/keycloak` |
| **Web Client** | Browser-basierter Messenger | Fork von element-web |
| **Desktop Client** | Electron-basierte Desktop-App | Fork von element-desktop |
| **Android App** | Native Android-App | Fork von element-x-android |
| **iOS App** | Native iOS-App | Fork von element-x-ios |

---

## Komponenten-Diagramm

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              BBSaM-Messenger Ecosystem                       │
└─────────────────────────────────────────────────────────────────────────────┘

                                    ┌─────────────────┐
                                    │   Keycloak IdP  │
                                    │ bbb.bbsam.eu/kc │
                                    │                 │
                                    │  ┌───────────┐  │
                                    │  │BBSaM Realm│  │
                                    │  └───────────┘  │
                                    └────────┬────────┘
                                             │
                                             │ OIDC
                                             │
                                    ┌────────▼────────┐
                                    │ Matrix Synapse  │
                                    │matrix.bbsam.eu  │
                                    │                 │
                                    │ ┌─────────────┐ │
                                    │ │  Postgres   │ │
                                    │ └─────────────┘ │
                                    └────────┬────────┘
                                             │
                          ┌──────────────────┼──────────────────┐
                          │                  │                  │
              ┌───────────▼───────┐ ┌───────▼───────┐ ┌────────▼────────┐
              │                   │ │               │ │                 │
              │   Web Clients     │ │Desktop Clients│ │  Mobile Clients │
              │                   │ │               │ │                 │
              │ ┌───────────────┐ │ │ ┌───────────┐ │ │ ┌─────────────┐ │
              │ │ bbsam-web     │ │ │ │ Electron  │ │ │ │ Android App │ │
              │ │ (React)       │ │ │ │ + Web     │ │ │ │ (Kotlin)    │ │
              │ └───────────────┘ │ │ └───────────┘ │ │ └─────────────┘ │
              │                   │ │               │ │                 │
              │                   │ │ ┌───────────┐ │ │ ┌─────────────┐ │
              │                   │ │ │ Windows   │ │ │ │ iOS App     │ │
              │                   │ │ │ macOS     │ │ │ │ (Swift)     │ │
              │                   │ │ │ Linux     │ │ │ └─────────────┘ │
              │                   │ │ └───────────┘ │ │                 │
              └───────────────────┘ └───────────────┘ └─────────────────┘

                                             │
                                             │
                              ┌──────────────▼──────────────┐
                              │      bbsam-branding         │
                              │   (Zentrales Repository)    │
                              │                             │
                              │  ┌─────────┐ ┌───────────┐  │
                              │  │ Assets  │ │  Config   │  │
                              │  │ Icons   │ │  Scripts  │  │
                              │  │ Logos   │ │  Themes   │  │
                              │  └─────────┘ └───────────┘  │
                              └─────────────────────────────┘
```

---

## Repository-Struktur

### Übersicht der Repositories

```
github.com/bbsam/
│
├── bbsam-branding/                 # Zentrales Branding & Konfiguration
│   ├── assets/
│   │   ├── icons/
│   │   │   ├── app-icon.svg        # Master-Icon (SVG)
│   │   │   ├── android/            # Generierte Android-Icons
│   │   │   │   ├── mipmap-mdpi/
│   │   │   │   ├── mipmap-hdpi/
│   │   │   │   ├── mipmap-xhdpi/
│   │   │   │   ├── mipmap-xxhdpi/
│   │   │   │   └── mipmap-xxxhdpi/
│   │   │   ├── ios/                # Generierte iOS-Icons
│   │   │   │   └── AppIcon.appiconset/
│   │   │   ├── web/                # Favicons, PWA-Icons
│   │   │   └── desktop/            # Windows ICO, macOS ICNS
│   │   ├── splash/
│   │   ├── logos/
│   │   │   ├── bbsam-logo.svg
│   │   │   ├── bbsam-wordmark.svg
│   │   │   └── bbsam-logo-white.svg
│   │   └── screenshots/            # Für App Stores
│   │
│   ├── config/
│   │   ├── colors.json             # Farbdefinitionen
│   │   ├── strings.json            # Übersetzungen/Texte
│   │   ├── web-config.json         # Element Web config.json
│   │   └── servers.json            # Homeserver & SSO Konfiguration
│   │
│   ├── scripts/
│   │   ├── generate-icons.sh       # Icon-Generierung
│   │   ├── apply-branding.sh       # Branding auf App-Repos anwenden
│   │   ├── sync-to-repos.sh        # Assets verteilen
│   │   ├── check-upstream.sh       # Upstream-Updates prüfen
│   │   └── validate-branding.sh    # Vollständigkeit prüfen
│   │
│   ├── docs/
│   │   ├── BRANDING-GUIDE.md
│   │   └── COLOR-PALETTE.md
│   │
│   └── README.md
│
├── bbsam-messenger-web/            # Fork: element-hq/element-web
│   ├── branding -> ../bbsam-branding (Submodule)
│   ├── src/
│   ├── res/
│   └── config.json
│
├── bbsam-messenger-desktop/        # Fork: element-hq/element-desktop
│   ├── branding -> ../bbsam-branding (Submodule)
│   ├── build/
│   └── electron/
│
├── bbsam-messenger-android/        # Fork: element-hq/element-x-android
│   ├── branding -> ../bbsam-branding (Submodule)
│   ├── app/
│   └── libraries/
│
└── bbsam-messenger-ios/            # Fork: element-hq/element-x-ios
    ├── branding -> ../bbsam-branding (Submodule)
    ├── ElementX/
    └── app.yml
```

### Submodule-Integration

Jedes App-Repository bindet das Branding-Repository als Git-Submodule ein:

```bash
# Einmalige Einrichtung in jedem App-Repo
git submodule add https://github.com/bbsam/bbsam-branding.git branding

# Submodule aktualisieren
git submodule update --remote --merge
```

---

## Datenfluss-Diagramm

### Messaging-Datenfluss

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Client A  │         │   Synapse   │         │   Client B  │
│ (Sender)    │         │  Homeserver │         │ (Empfänger) │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                       │
       │  1. Nachricht senden  │                       │
       │  POST /send           │                       │
       │──────────────────────>│                       │
       │                       │                       │
       │  2. Speichern &       │                       │
       │     Verarbeiten       │                       │
       │                       │                       │
       │                       │  3. Push/Sync         │
       │                       │──────────────────────>│
       │                       │                       │
       │  4. Bestätigung       │                       │
       │<──────────────────────│                       │
       │                       │                       │
       │                       │  5. Nachricht abrufen │
       │                       │  GET /sync            │
       │                       │<──────────────────────│
       │                       │                       │
       │                       │  6. Nachricht         │
       │                       │──────────────────────>│
       │                       │                       │
```

### Verschlüsselungs-Datenfluss (E2EE)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Ende-zu-Ende-Verschlüsselung                 │
└─────────────────────────────────────────────────────────────────┘

     Client A                    Synapse                   Client B
        │                          │                          │
        │  Device Keys hochladen   │                          │
        │─────────────────────────>│                          │
        │                          │                          │
        │                          │  Device Keys abrufen     │
        │                          │<─────────────────────────│
        │                          │                          │
        │                          │  Keys zurückgeben        │
        │                          │─────────────────────────>│
        │                          │                          │
        │  Megolm Session erstellen│                          │
        │  (lokal)                 │                          │
        │                          │                          │
        │  Verschlüsselte         │                          │
        │  Nachricht senden       │                          │
        │─────────────────────────>│─────────────────────────>│
        │                          │                          │
        │                          │       Entschlüsseln      │
        │                          │       (lokal mit         │
        │                          │        Megolm Key)       │
        │                          │                          │
```

---

## SSO-Sequenzdiagramm

### Vollständiger OIDC-Login-Flow

```
┌──────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌──────────────────────────┐
│  Benutzer│     │ BBSaM-Messenger │     │  matrix.bbsam.eu│     │ bbb.bbsam.eu/keycloak    │
│          │     │   (Client)      │     │    (Synapse)    │     │      (Keycloak)          │
└────┬─────┘     └───────┬─────────┘     └───────┬─────────┘     └────────────┬─────────────┘
     │                   │                       │                            │
     │  1. App öffnen    │                       │                            │
     │──────────────────>│                       │                            │
     │                   │                       │                            │
     │                   │ 2. GET /_matrix/      │                            │
     │                   │    client/v3/login    │                            │
     │                   │──────────────────────>│                            │
     │                   │                       │                            │
     │                   │ 3. Login-Optionen     │                            │
     │                   │    (nur SSO/OIDC)     │                            │
     │                   │<──────────────────────│                            │
     │                   │                       │                            │
     │                   │ 4. SSO-Redirect       │                            │
     │                   │    initiieren         │                            │
     │                   │──────────────────────>│                            │
     │                   │                       │                            │
     │                   │ 5. Redirect-URL       │                            │
     │                   │    mit state/nonce    │                            │
     │                   │<──────────────────────│                            │
     │                   │                       │                            │
     │  6. Weiterleitung │                       │                            │
     │     zu Keycloak   │                       │                            │
     │<──────────────────│                       │                            │
     │                   │                       │                            │
     │  7. Keycloak      │                       │                            │
     │     Login-Seite   │                       │                            │
     │──────────────────────────────────────────────────────────────────────>│
     │                   │                       │                            │
     │  8. Benutzer      │                       │                            │
     │     authentifiziert                       │                            │
     │     sich          │                       │                            │
     │──────────────────────────────────────────────────────────────────────>│
     │                   │                       │                            │
     │                   │                       │ 9. Keycloak validiert      │
     │                   │                       │    Credentials             │
     │                   │                       │<───────────────────────────│
     │                   │                       │                            │
     │  10. Redirect     │                       │                            │
     │      mit Auth-Code│                       │                            │
     │<──────────────────────────────────────────────────────────────────────│
     │                   │                       │                            │
     │  11. Callback an  │                       │                            │
     │      Synapse      │                       │                            │
     │───────────────────────────────────────────>                            │
     │                   │                       │                            │
     │                   │                       │ 12. Token Exchange         │
     │                   │                       │     (Backend-to-Backend)   │
     │                   │                       │───────────────────────────>│
     │                   │                       │                            │
     │                   │                       │ 13. ID Token +             │
     │                   │                       │     Access Token           │
     │                   │                       │<───────────────────────────│
     │                   │                       │                            │
     │                   │                       │ 14. Benutzer erstellen/    │
     │                   │                       │     verknüpfen             │
     │                   │                       │     (localpart aus         │
     │                   │                       │      preferred_username)   │
     │                   │                       │                            │
     │                   │ 15. Matrix Session    │                            │
     │                   │     + Access Token    │                            │
     │                   │<──────────────────────│                            │
     │                   │                       │                            │
     │  16. Login        │                       │                            │
     │      erfolgreich  │                       │                            │
     │<──────────────────│                       │                            │
     │                   │                       │                            │
     │  17. Messenger    │                       │                            │
     │      ist bereit   │                       │                            │
     │<──────────────────│                       │                            │
     │                   │                       │                            │
```

### Logout-Flow mit Backchannel

```
┌──────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌──────────────────────────┐
│  Benutzer│     │ BBSaM-Messenger │     │  matrix.bbsam.eu│     │ bbb.bbsam.eu/keycloak    │
│          │     │   (Client)      │     │    (Synapse)    │     │      (Keycloak)          │
└────┬─────┘     └───────┬─────────┘     └───────┬─────────┘     └────────────┬─────────────┘
     │                   │                       │                            │
     │  1. Logout        │                       │                            │
     │──────────────────>│                       │                            │
     │                   │                       │                            │
     │                   │ 2. POST /logout       │                            │
     │                   │──────────────────────>│                            │
     │                   │                       │                            │
     │                   │                       │ 3. Backchannel Logout      │
     │                   │                       │    (Optional)              │
     │                   │                       │───────────────────────────>│
     │                   │                       │                            │
     │                   │                       │ 4. Session invalidieren    │
     │                   │                       │<───────────────────────────│
     │                   │                       │                            │
     │                   │ 5. Logout bestätigt   │                            │
     │                   │<──────────────────────│                            │
     │                   │                       │                            │
     │  6. Redirect zu   │                       │                            │
     │     Login         │                       │                            │
     │<──────────────────│                       │                            │
     │                   │                       │                            │
```

---

## Plattform-Architektur

### Web (element-web Fork)

```
┌─────────────────────────────────────────────────────────────────┐
│                     bbsam-messenger-web                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────────────┐ │
│  │    React     │   │   matrix-    │   │  @vector-im/         │ │
│  │  Components  │   │   js-sdk     │   │  compound-web        │ │
│  └──────┬───────┘   └──────┬───────┘   └──────────┬───────────┘ │
│         │                  │                      │              │
│         └──────────────────┼──────────────────────┘              │
│                            │                                     │
│                    ┌───────▼───────┐                            │
│                    │   Webpack     │                            │
│                    │   Bundle      │                            │
│                    └───────┬───────┘                            │
│                            │                                     │
│  ┌─────────────────────────▼─────────────────────────────────┐  │
│  │                    config.json                             │  │
│  │  - Homeserver: matrix.bbsam.eu                            │  │
│  │  - SSO: immediate redirect                                 │  │
│  │  - Brand: BBSaM-Messenger                                  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Themes                                │    │
│  │  res/themes/light/  │  res/themes/dark/                 │    │
│  │  - CSS Variables    │  - CSS Variables                  │    │
│  │  - BBSaM Colors     │  - BBSaM Dark Colors              │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Desktop (element-desktop Fork)

```
┌─────────────────────────────────────────────────────────────────┐
│                   bbsam-messenger-desktop                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    Electron Shell                          │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐│  │
│  │  │   Main      │  │  Renderer   │  │     Preload         ││  │
│  │  │  Process    │  │  Process    │  │     Bridge          ││  │
│  │  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘│  │
│  │         │                │                    │           │  │
│  │         └────────────────┼────────────────────┘           │  │
│  │                          │                                │  │
│  │                  ┌───────▼───────┐                        │  │
│  │                  │ element-web   │                        │  │
│  │                  │   (embedded)  │                        │  │
│  │                  └───────────────┘                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                 Platform Installers                        │  │
│  │  ┌──────────┐   ┌──────────┐   ┌────────────────────────┐ │  │
│  │  │ Windows  │   │  macOS   │   │        Linux           │ │  │
│  │  │   NSIS   │   │   DMG    │   │ AppImage / deb / rpm   │ │  │
│  │  └──────────┘   └──────────┘   └────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   Auto-Update                              │  │
│  │  GitHub Releases → electron-builder publish                │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Android (element-x-android Fork)

```
┌─────────────────────────────────────────────────────────────────┐
│                  bbsam-messenger-android                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    Application Layer                       │  │
│  │  ┌─────────────────┐  ┌─────────────────────────────────┐ │  │
│  │  │  Jetpack        │  │      Features                   │ │  │
│  │  │  Compose UI     │  │  ┌─────────┐ ┌─────────────────┐│ │  │
│  │  │                 │  │  │ Login   │ │  Messaging      ││ │  │
│  │  │  Material 3     │  │  │ (OIDC)  │ │  Rooms, DMs     ││ │  │
│  │  │  Design System  │  │  └─────────┘ └─────────────────┘│ │  │
│  │  └─────────────────┘  └─────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   Matrix Rust SDK                          │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  Kotlin Bindings (via UniFFI)                       │  │  │
│  │  │  - Sliding Sync                                     │  │  │
│  │  │  - E2EE (Vodozemac)                                │  │  │
│  │  │  - OIDC Native Support                             │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   Build Flavors                            │  │
│  │  ┌──────────┐  ┌──────────┐  ┌────────────────────────┐   │  │
│  │  │  gplay   │  │  fdroid  │  │       bbsam            │   │  │
│  │  │ (Google) │  │ (FOSS)   │  │  (Custom Branding)     │   │  │
│  │  └──────────┘  └──────────┘  └────────────────────────┘   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### iOS (element-x-ios Fork)

```
┌─────────────────────────────────────────────────────────────────┐
│                    bbsam-messenger-ios                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    Application Layer                       │  │
│  │  ┌─────────────────┐  ┌─────────────────────────────────┐ │  │
│  │  │   SwiftUI       │  │      Features                   │ │  │
│  │  │   Views         │  │  ┌─────────┐ ┌─────────────────┐│ │  │
│  │  │                 │  │  │ Auth    │ │  Messaging      ││ │  │
│  │  │                 │  │  │ (OIDC)  │ │  Rooms, DMs     ││ │  │
│  │  └─────────────────┘  └─────────┘ └─────────────────┘  │ │  │
│  │                                                         │ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   Matrix Rust SDK                          │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  Swift Bindings (via UniFFI)                        │  │  │
│  │  │  - Sliding Sync                                     │  │  │
│  │  │  - E2EE (Vodozemac)                                │  │  │
│  │  │  - OIDC Native Support                             │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                     XcodeGen                               │  │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────────────┐ │  │
│  │  │  app.yml   │  │project.yml │  │    target.yml        │ │  │
│  │  │ Bundle ID  │  │ Settings   │  │ Associated Domains   │ │  │
│  │  └────────────┘  └────────────┘  └──────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Branding-Integration

### Sync-Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Branding Sync Workflow                        │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  bbsam-branding  │
│    Repository    │
└────────┬─────────┘
         │
         │  1. Asset-Änderungen
         │     (Icons, Logos, Config)
         │
         ▼
┌──────────────────┐
│  GitHub Action   │
│  sync-branding   │
└────────┬─────────┘
         │
         │  2. Trigger Sync-Workflow
         │
         ├─────────────────────────────────────────────┐
         │                                             │
         ▼                                             ▼
┌──────────────────┐                         ┌──────────────────┐
│  Web/Desktop     │                         │  Android/iOS     │
│  Repositories    │                         │  Repositories    │
└────────┬─────────┘                         └────────┬─────────┘
         │                                             │
         │  3. apply-branding.sh                       │  3. apply-branding.sh
         │                                             │
         ▼                                             ▼
┌──────────────────┐                         ┌──────────────────┐
│  Assets kopiert  │                         │  Assets kopiert  │
│  Config updated  │                         │  Config updated  │
└────────┬─────────┘                         └────────┬─────────┘
         │                                             │
         │  4. Commit & Push                           │  4. Commit & Push
         │                                             │
         ▼                                             ▼
┌──────────────────┐                         ┌──────────────────┐
│  CI/CD Build     │                         │  CI/CD Build     │
│  Trigger         │                         │  Trigger         │
└──────────────────┘                         └──────────────────┘
```

### Icon-Generierung

```
                        ┌─────────────────┐
                        │  app-icon.svg   │
                        │  (Master-Icon)  │
                        └────────┬────────┘
                                 │
                                 │  generate-icons.sh
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
        ▼                        ▼                        ▼
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│    Android    │       │      iOS      │       │   Web/Desktop │
├───────────────┤       ├───────────────┤       ├───────────────┤
│ mdpi: 48px    │       │ 20@1x: 20px   │       │ favicon.ico   │
│ hdpi: 72px    │       │ 20@2x: 40px   │       │ 16x16.png     │
│ xhdpi: 96px   │       │ 20@3x: 60px   │       │ 32x32.png     │
│ xxhdpi: 144px │       │ 29@1x: 29px   │       │ 192x192.png   │
│ xxxhdpi: 192px│       │ 29@2x: 58px   │       │ 512x512.png   │
│               │       │ ...           │       │ icon.icns     │
│ Adaptive Icon │       │ 1024@1x       │       │ icon.ico      │
└───────────────┘       └───────────────┘       └───────────────┘
```

---

## Nächste Schritte

1. **Phase 1**: Repository-Forks erstellen und Submodules einrichten
2. **Phase 2**: Branding-Assets erstellen (Icons, Logos)
3. **Phase 3**: Konfigurationen anpassen (config.json, build files)
4. **Phase 4**: SSO-Integration testen
5. **Phase 5**: CI/CD-Pipelines einrichten
6. **Phase 6**: App Store Submissions vorbereiten

---

*Dokument Version: 1.0*
*Letzte Aktualisierung: 2026-01-21*
