# BBSaM Asset-Konfiguration

## Offizielle Assets

Die folgenden offiziellen BBSaM-Assets werden für das Branding verwendet:

### 1. Logo

**URL:** https://www.bbsam.de/wp-content/uploads/2024/08/bbs_logo_mit_kacheln.png

Das Logo mit den charakteristischen farbigen Kacheln wird als App-Icon und in der Anmeldeseite verwendet.

**Lokale Kopie erstellen:**
```bash
cd bbsam-branding/assets

# Logo herunterladen
curl -o logos/bbsam-logo.png "https://www.bbsam.de/wp-content/uploads/2024/08/bbs_logo_mit_kacheln.png"

# Als App-Icon Basis kopieren
cp logos/bbsam-logo.png icons/app-icon.png
```

### 2. Hintergrundbild

**URL:** https://www.bbsam.de/wp-content/uploads/2020/03/cropped-Header-BBSaM-2020-web.jpg

Das Schulgebäude-Bild wird als Hintergrund auf der Willkommens-/Anmeldeseite verwendet.

**Lokale Kopie erstellen:**
```bash
curl -o splash/welcome-background.jpg "https://www.bbsam.de/wp-content/uploads/2020/03/cropped-Header-BBSaM-2020-web.jpg"
```

## Nach dem Download

1. **Icons für alle Plattformen generieren:**
   ```bash
   ./scripts/generate-icons.sh
   ```

2. **Branding validieren:**
   ```bash
   ./scripts/validate-branding.sh
   ```

3. **Branding auf App-Repos anwenden:**
   ```bash
   ./scripts/apply-branding.sh all
   ```

## Hinweis zur Web-Konfiguration

Die `config/web-config.json` ist so konfiguriert, dass sie die Assets direkt von der BBSaM-Webseite lädt. Falls die Assets lokal gehostet werden sollen, müssen die URLs angepasst werden.

Aktuelle Konfiguration:
```json
{
  "branding": {
    "welcome_background_url": "https://www.bbsam.de/wp-content/uploads/2020/03/cropped-Header-BBSaM-2020-web.jpg",
    "auth_header_logo_url": "https://www.bbsam.de/wp-content/uploads/2024/08/bbs_logo_mit_kacheln.png"
  }
}
```
