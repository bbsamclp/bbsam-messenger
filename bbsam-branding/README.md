# BBSaM Branding

Zentrales Repository für alle Branding-Assets und Konfigurationen des BBSaM-Messengers.

## Struktur

```
bbsam-branding/
├── assets/
│   ├── icons/
│   │   ├── app-icon.svg        # Master-Icon (SVG)
│   │   ├── android/            # Android Icons (alle Dichten)
│   │   ├── ios/                # iOS Icons (AppIcon.appiconset)
│   │   ├── web/                # Web Icons (Favicons, PWA)
│   │   └── desktop/            # Desktop Icons (ICO, ICNS, PNG)
│   ├── logos/
│   │   ├── bbsam-logo.svg      # Hauptlogo
│   │   ├── bbsam-wordmark.svg  # Nur Schriftzug
│   │   └── bbsam-logo-white.svg # Für dunkle Hintergründe
│   ├── splash/                 # Splash Screens
│   └── screenshots/            # App Store Screenshots
├── config/
│   ├── colors.json             # Farbdefinitionen
│   ├── strings.json            # Textersetzungen
│   ├── web-config.json         # Element Web config.json
│   └── servers.json            # Server-Konfiguration
├── scripts/
│   ├── generate-icons.sh       # Icon-Generierung
│   ├── apply-branding.sh       # Branding anwenden
│   ├── check-upstream.sh       # Upstream-Updates prüfen
│   └── validate-branding.sh    # Branding validieren
└── docs/
    ├── BRANDING-GUIDE.md       # Design-Richtlinien
    └── COLOR-PALETTE.md        # Farbpalette
```

## Verwendung

### 1. Master-Icon erstellen

Erstellen Sie das Master-Icon als SVG:

```
assets/icons/app-icon.svg
```

Anforderungen:
- Format: SVG (Vektorgrafik)
- Viewport: 1024x1024px
- Keine Transparenz am Rand für iOS
- Ausreichend Kontrast für kleine Größen

### 2. Icons generieren

```bash
# Abhängigkeiten installieren (Ubuntu/Debian)
sudo apt-get install imagemagick librsvg2-bin icnsutils icoutils

# Icons für alle Plattformen generieren
./scripts/generate-icons.sh
```

Generierte Icons:
- Android: `mipmap-*` Ordner
- iOS: `AppIcon.appiconset`
- Web: Favicons, PWA-Icons
- Desktop: ICO, ICNS, PNG

### 3. Branding auf App-Repos anwenden

```bash
# Web-Repository
./scripts/apply-branding.sh web

# Desktop-Repository
./scripts/apply-branding.sh desktop

# Android-Repository
./scripts/apply-branding.sh android

# iOS-Repository
./scripts/apply-branding.sh ios

# Alle Plattformen
./scripts/apply-branding.sh all
```

### 4. Branding validieren

```bash
./scripts/validate-branding.sh
```

### 5. Upstream-Updates prüfen

```bash
# Alle Plattformen
./scripts/check-upstream.sh

# Report generieren
./scripts/check-upstream.sh report
```

## Integration in App-Repos

### Git Submodule (empfohlen)

```bash
# In jedem App-Repo einmalig:
git submodule add https://github.com/bbsam/bbsam-branding.git branding

# Submodule aktualisieren
git submodule update --init --recursive
git submodule update --remote --merge
```

### CI/CD Integration

```yaml
# GitHub Action
- name: Checkout with Submodules
  uses: actions/checkout@v4
  with:
    submodules: recursive

- name: Apply Branding
  run: ./branding/scripts/apply-branding.sh ${{ matrix.platform }}
```

## Konfiguration

### Farben (`config/colors.json`)

```json
{
  "themes": {
    "light": {
      "primary": "#1A73E8",
      "secondary": "#34A853",
      "background": "#FFFFFF"
    },
    "dark": {
      "primary": "#8AB4F8",
      "secondary": "#81C995",
      "background": "#202124"
    }
  }
}
```

### Strings (`config/strings.json`)

```json
{
  "brand": {
    "name": "BBSaM-Messenger",
    "shortName": "BBSaM"
  },
  "replacements": {
    "Element": "BBSaM-Messenger",
    "element.io": "bbsam.eu"
  }
}
```

### Server (`config/servers.json`)

```json
{
  "matrix": {
    "homeserver": {
      "base_url": "https://matrix.bbsam.eu",
      "server_name": "bbsam.eu"
    }
  },
  "sso": {
    "provider": "keycloak",
    "keycloak": {
      "base_url": "https://bbb.bbsam.eu/keycloak",
      "realm": "BBSaM"
    }
  }
}
```

## Lizenz

Alle Assets in diesem Repository sind Eigentum von BBSaM.

Die Skripte sind unter der AGPLv3-Lizenz verfügbar.
