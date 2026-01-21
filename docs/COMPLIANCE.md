# Compliance Guide: BBSaM-Messenger

## Inhaltsverzeichnis

1. [Lizenz-Compliance (AGPLv3)](#lizenz-compliance-agplv3)
2. [Quellcode-Veröffentlichung](#quellcode-veröffentlichung)
3. [DSGVO-Checkliste](#dsgvo-checkliste)
4. [App Store Compliance](#app-store-compliance)
5. [Sicherheit](#sicherheit)

---

## Lizenz-Compliance (AGPLv3)

### Überblick

Element Web, Desktop und die Element X Apps sind unter der **GNU Affero General Public License v3.0 (AGPLv3)** lizenziert. Diese Lizenz hat starke Copyleft-Anforderungen.

### Kernpflichten

| Pflicht | Beschreibung | Status |
|---------|--------------|--------|
| **Quellcode-Veröffentlichung** | Gesamter Quellcode muss verfügbar sein | Erforderlich |
| **Lizenzbeibehaltung** | AGPLv3-Lizenz muss beibehalten werden | Erforderlich |
| **Änderungsdokumentation** | Änderungen müssen dokumentiert sein | Erforderlich |
| **Prominente Hinweise** | Lizenzhinweise müssen sichtbar sein | Erforderlich |
| **Network Use = Distribution** | Server-Nutzung = Weitergabe | Ja |

### AGPLv3 vs. GPLv3

Der entscheidende Unterschied:

> **AGPLv3 § 13**: Wenn Sie eine modifizierte Version über ein Netzwerk bereitstellen, müssen Sie den Quellcode allen Netzwerknutzern zur Verfügung stellen.

Das bedeutet: Auch wenn Sie BBSaM-Messenger nur als Web-App hosten (ohne Download), müssen Benutzer Zugang zum Quellcode haben.

### Erforderliche Maßnahmen

#### 1. NOTICE-Datei erstellen

Erstellen Sie eine `NOTICE` oder `LEGAL` Datei:

```
BBSaM-Messenger
Copyright (C) 2024 BBSaM

Dieses Programm basiert auf Element (https://element.io),
entwickelt von Element (früher New Vector Ltd).

Dieses Programm ist freie Software: Sie können es unter den Bedingungen
der GNU Affero General Public License, wie von der Free Software Foundation
veröffentlicht, weitergeben und/oder modifizieren, entweder gemäß Version 3
der Lizenz oder (nach Ihrer Wahl) jeder späteren Version.

Dieses Programm wird in der Hoffnung verbreitet, dass es nützlich sein wird,
jedoch OHNE JEGLICHE GARANTIE; auch ohne die implizite Garantie der
MARKTFÄHIGKEIT oder EIGNUNG FÜR EINEN BESTIMMTEN ZWECK. Siehe die
GNU Affero General Public License für weitere Details.

Sie sollten eine Kopie der GNU Affero General Public License zusammen mit
diesem Programm erhalten haben. Falls nicht, siehe <https://www.gnu.org/licenses/>.

Der vollständige Quellcode ist verfügbar unter:
https://github.com/bbsam/bbsam-messenger-web
https://github.com/bbsam/bbsam-messenger-desktop
https://github.com/bbsam/bbsam-messenger-android
https://github.com/bbsam/bbsam-messenger-ios

UPSTREAM-LIZENZEN:
- Element Web: AGPLv3 - https://github.com/element-hq/element-web
- Element Desktop: AGPLv3 - https://github.com/element-hq/element-desktop
- Element X Android: AGPLv3 - https://github.com/element-hq/element-x-android
- Element X iOS: AGPLv3 - https://github.com/element-hq/element-x-ios
- Matrix JS SDK: Apache-2.0 - https://github.com/matrix-org/matrix-js-sdk
- Matrix Rust SDK: Apache-2.0 - https://github.com/matrix-org/matrix-rust-sdk
```

#### 2. Lizenz-Datei beibehalten

Die `LICENSE`-Datei mit dem AGPLv3-Text muss in allen Repositories vorhanden sein.

#### 3. Source-Link in der App

In der App muss ein Link zum Quellcode sichtbar sein:

**Element Web/Desktop** (`config.json`):
```json
{
  "branding": {
    "auth_footer_links": [
      {
        "text": "Quellcode",
        "url": "https://github.com/bbsam"
      }
    ]
  }
}
```

**In Settings/About:**
Der Link zum Quellcode sollte auch in den App-Einstellungen unter "Über" oder "Rechtliches" erscheinen.

#### 4. Änderungen dokumentieren

Erstellen Sie eine `CHANGELOG.md` oder führen Sie ein detailliertes Commit-Log:

```markdown
# Änderungen gegenüber Element

## Branding
- App-Name geändert zu "BBSaM-Messenger"
- Logos und Icons ersetzt
- Farbschema angepasst

## Konfiguration
- Standard-Homeserver: matrix.bbsam.eu
- SSO-only Authentifizierung
- Registrierung deaktiviert

## Entfernte Features
- Analytics (Posthog) deaktiviert
- EMS-Werbung entfernt

## Hinzugefügte Features
- [Keine]
```

---

## Quellcode-Veröffentlichung

### Repository-Struktur

Alle Repositories müssen öffentlich zugänglich sein:

```
https://github.com/bbsam/bbsam-branding          (Branding Assets)
https://github.com/bbsam/bbsam-messenger-web      (Web Client)
https://github.com/bbsam/bbsam-messenger-desktop  (Desktop Client)
https://github.com/bbsam/bbsam-messenger-android  (Android App)
https://github.com/bbsam/bbsam-messenger-ios      (iOS App)
```

### Mindestanforderungen

Jedes Repository muss enthalten:

- [ ] Vollständiger Quellcode
- [ ] `LICENSE` (AGPLv3 oder Apache-2.0)
- [ ] `NOTICE` oder Copyright-Hinweise
- [ ] Build-Anleitung (`BUILD.md` oder `README.md`)
- [ ] Abhängigkeitsliste (`package.json`, `build.gradle`, etc.)

### Synchronisation mit Upstream

```bash
# Upstream Remote hinzufügen
git remote add upstream https://github.com/element-hq/element-web.git

# Regelmäßig synchronisieren
git fetch upstream
git merge upstream/main

# Änderungen pushen
git push origin main
```

---

## DSGVO-Checkliste

### Anforderungen

| Anforderung | Beschreibung | Umsetzung |
|-------------|--------------|-----------|
| **Datenschutzerklärung** | Vollständige Erklärung zur Datenverarbeitung | Erforderlich |
| **Impressum** | Anbieterkennzeichnung | Erforderlich (DE) |
| **Einwilligung** | Cookie-Banner, Tracking-Consent | Falls Tracking aktiv |
| **Auskunftsrecht** | Benutzer können Daten anfragen | Prozess definieren |
| **Löschrecht** | Benutzer können Löschung verlangen | Prozess definieren |
| **Datenportabilität** | Export der eigenen Daten | Matrix-Export nutzen |
| **Verarbeitungsverzeichnis** | Interne Dokumentation | Erforderlich |

### Datenschutzerklärung

Die Datenschutzerklärung muss folgende Punkte abdecken:

1. **Verantwortliche Stelle**
   - Name und Kontakt des Verantwortlichen
   - Datenschutzbeauftragter (falls erforderlich)

2. **Verarbeitete Daten**
   - Account-Daten (Benutzername, E-Mail via Keycloak)
   - Nachrichteninhalte (verschlüsselt)
   - Metadaten (Zeitstempel, Teilnehmer)
   - Geräte-Informationen

3. **Rechtsgrundlagen**
   - Art. 6 Abs. 1 lit. b DSGVO (Vertragserfüllung)
   - Art. 6 Abs. 1 lit. f DSGVO (Berechtigtes Interesse)

4. **Empfänger**
   - Homeserver-Betreiber (BBSaM)
   - Keycloak-Betreiber (BBSaM)
   - Keine Weitergabe an Dritte

5. **Speicherdauer**
   - Nachrichten: [Aufbewahrungsrichtlinie definieren]
   - Accounts: Bis zur Löschung

6. **Betroffenenrechte**
   - Auskunft, Berichtigung, Löschung
   - Widerspruch, Datenübertragbarkeit
   - Beschwerde bei Aufsichtsbehörde

### Technische Maßnahmen

- [x] **Ende-zu-Ende-Verschlüsselung** - Standard in Matrix
- [x] **TLS-Verschlüsselung** - Alle Verbindungen
- [ ] **Keine Analytics** - Posthog deaktiviert
- [ ] **Keine Tracking-Cookies** - Keine Third-Party-Cookies
- [x] **Passwörter sicher** - Via Keycloak gehasht (bcrypt/argon2)

### Auftragsverarbeitung

Falls Dritte Zugang zu Daten haben (Hosting-Provider, etc.):

- [ ] Auftragsverarbeitungsvertrag (AVV) abschließen
- [ ] Technische und organisatorische Maßnahmen (TOMs) dokumentieren

---

## App Store Compliance

### Google Play Store

#### Anforderungen

- [ ] **Datenschutzrichtlinie** - URL in Store-Eintrag
- [ ] **Content Rating** - IARC-Fragebogen ausfüllen
- [ ] **Zielgruppe** - Nicht für Kinder unter 13
- [ ] **Berechtigungen erklären** - Warum Kamera, Mikrofon, etc.
- [ ] **Verschlüsselung deklarieren** - Export Compliance

#### Store-Eintrag Texte

```
Kurzbeschreibung (80 Zeichen):
Sicherer Messenger für BBSaM mit Ende-zu-Ende-Verschlüsselung.

Vollständige Beschreibung:
BBSaM-Messenger ist ein sicherer Instant Messenger für die BBSaM-Community.

Features:
• Ende-zu-Ende-Verschlüsselung für alle Nachrichten
• Sprach- und Videoanrufe
• Dateifreigabe
• Synchronisation über alle Geräte
• Single Sign-On mit BBSaM-Account

BBSaM-Messenger basiert auf dem offenen Matrix-Protokoll und garantiert
höchste Sicherheit und Datenschutz.

Nur für Mitglieder der BBSaM-Organisation.
```

### Apple App Store

#### Anforderungen

- [ ] **App Privacy Details** - Datenschutz-Labels ausfüllen
- [ ] **Export Compliance** - Verschlüsselungserklärung
- [ ] **IDFA** - Falls Werbe-ID genutzt (nein)
- [ ] **Sign in with Apple** - Falls andere SSO angeboten (nicht erforderlich bei nur eigenem SSO)

#### Export Compliance für Verschlüsselung

Matrix/Element verwendet Verschlüsselung. Bei Submission:

1. "Does your app use encryption?" → **Yes**
2. "Does your app qualify for any exemptions?" → **Yes**
   - Exemption: Authentication (TLS)
   - OR: File your ERN/SNAP filing with BIS

> Hinweis: Für reine Authentifizierung (TLS) und lokal gespeicherte Verschlüsselung gilt oft eine Ausnahme. Bei E2EE-Export an Dritte ggf. SNAP-Anmeldung erforderlich.

#### App Privacy Labels

```
Data Linked to You:
- Contact Info (Email - from SSO)
- User Content (Messages, Files)
- Identifiers (Matrix ID)

Data Not Linked to You:
- None

Data Used to Track You:
- None
```

---

## Sicherheit

### Sicherheits-Checkliste

#### Infrastruktur

- [ ] TLS 1.2+ für alle Verbindungen
- [ ] HSTS aktiviert
- [ ] Aktuelle Software-Versionen
- [ ] Regelmäßige Updates
- [ ] Firewall konfiguriert
- [ ] SSH nur mit Key-Auth

#### Synapse/Matrix

- [ ] Nur OIDC-Login (Passwort deaktiviert)
- [ ] Rate Limiting aktiviert
- [ ] Federation ggf. eingeschränkt
- [ ] Media-Upload-Limits gesetzt
- [ ] Regelmäßige Backups

#### Keycloak

- [ ] Brute-Force-Schutz aktiviert
- [ ] Starke Passwort-Policy
- [ ] MFA-Option (falls gewünscht)
- [ ] Session-Timeouts konfiguriert
- [ ] Audit-Logging aktiviert

#### Clients

- [ ] Aktuelle Upstream-Versionen
- [ ] Keine bekannten Vulnerabilities
- [ ] Code Signing aktiviert (Desktop, Mobile)
- [ ] Sichere Update-Mechanismen

### Incident Response

1. **Erkennung**
   - Monitoring-Alerts
   - Benutzer-Meldungen

2. **Eindämmung**
   - Betroffene Systeme isolieren
   - Zugriffe sperren

3. **Untersuchung**
   - Logs analysieren
   - Umfang bestimmen

4. **Behebung**
   - Schwachstelle patchen
   - Systeme wiederherstellen

5. **Kommunikation**
   - Betroffene informieren
   - Ggf. Aufsichtsbehörde (72h bei DSGVO-Verletzung)

6. **Lessons Learned**
   - Post-Mortem erstellen
   - Maßnahmen dokumentieren

---

## Checkliste für Go-Live

### Rechtlich

- [ ] AGPLv3-Lizenz in allen Repos
- [ ] NOTICE-Datei erstellt
- [ ] Quellcode öffentlich
- [ ] Datenschutzerklärung verfügbar
- [ ] Impressum verfügbar
- [ ] Cookie-Banner (falls Tracking)

### App Stores

- [ ] Play Store Eintrag vollständig
- [ ] App Store Eintrag vollständig
- [ ] Datenschutz-Labels ausgefüllt
- [ ] Export Compliance erklärt
- [ ] Content Rating durchgeführt

### Sicherheit

- [ ] Penetrationstest (empfohlen)
- [ ] Abhängigkeiten geprüft (npm audit, etc.)
- [ ] TLS-Konfiguration validiert
- [ ] Incident Response Plan

---

*Dokument Version: 1.0*
*Letzte Aktualisierung: 2026-01-21*

**Haftungsausschluss:** Dieses Dokument stellt keine Rechtsberatung dar. Konsultieren Sie einen Fachanwalt für IT-Recht und Datenschutz für verbindliche Auskünfte.
