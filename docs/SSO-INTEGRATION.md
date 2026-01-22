# SSO-Integration: BBSaM-Messenger mit Keycloak

## Inhaltsverzeichnis

1. [Übersicht](#übersicht)
2. [Keycloak-Setup](#keycloak-setup)
3. [Synapse-Konfiguration](#synapse-konfiguration)
4. [Client-Konfigurationen](#client-konfigurationen)
5. [Authentifizierungs-Flow](#authentifizierungs-flow)
6. [Troubleshooting](#troubleshooting)
7. [Sicherheitsüberlegungen](#sicherheitsüberlegungen)

---

## Übersicht

BBSaM-Messenger verwendet ausschließlich SSO-Authentifizierung über Keycloak. Passwort-basierte Anmeldung ist deaktiviert.

### Infrastruktur

| Komponente | URL | Zweck |
|------------|-----|-------|
| Matrix Homeserver | `https://matrix.bbsam.eu` | Synapse Server |
| Keycloak Server | `https://bbb.bbsam.eu/keycloak` | Identity Provider |
| Keycloak Realm | `BBSaM` | Benutzer-Realm |
| Client ID | `bbsam-messenger` | OIDC Client |

### Protokoll-Standards

- **OpenID Connect 1.0** (OIDC)
- **OAuth 2.0** mit Authorization Code Flow
- **PKCE** (Proof Key for Code Exchange) für Mobile Apps

---

## Keycloak-Setup

### 1. Realm erstellen (falls nicht vorhanden)

```
Keycloak Admin Console: https://bbb.bbsam.eu/keycloak/admin

1. Klicke auf "Create Realm"
2. Name: BBSaM
3. Enabled: ON
4. Save
```

### 2. Client erstellen

Navigiere zu: `Clients` → `Create client`

**General Settings:**
```yaml
Client ID: bbsam-messenger
Name: BBSaM-Messenger
Description: Matrix Messenger für BBSaM
Always display in UI: ON
```

**Capability Config:**
```yaml
Client authentication: ON
Authorization: OFF
Authentication flow:
  - Standard flow: ON (für Web/Desktop)
  - Direct access grants: OFF
  - Service accounts roles: OFF
```

**Login Settings:**
```yaml
Root URL: https://matrix.bbsam.eu
Home URL: https://matrix.bbsam.eu
Valid redirect URIs:
  - https://matrix.bbsam.eu/_synapse/client/oidc/callback
  - http://localhost:8080/callback                          # Entwicklung
  - eu.bbsam.messenger://callback                           # Mobile iOS/Android
  - eu.bbsam.messenger.debug://callback                     # Mobile Debug
Valid post logout redirect URIs:
  - https://matrix.bbsam.eu
  - https://app.bbsam.eu
Web origins:
  - https://matrix.bbsam.eu
  - https://app.bbsam.eu
```

### 3. Client Credentials sichern

Nach dem Erstellen:

1. Gehe zu `Clients` → `bbsam-messenger` → `Credentials`
2. Kopiere das `Client secret`
3. Speichere es sicher (wird für Synapse benötigt)

```bash
# Auf dem Synapse-Server:
sudo mkdir -p /etc/synapse/secrets
echo "DEIN_CLIENT_SECRET_HIER" | sudo tee /etc/synapse/secrets/keycloak_client_secret
sudo chmod 600 /etc/synapse/secrets/keycloak_client_secret
sudo chown synapse:synapse /etc/synapse/secrets/keycloak_client_secret
```

### 4. Client Scopes konfigurieren

Stelle sicher, dass folgende Scopes verfügbar sind:

- `openid` (Standard)
- `profile` (für Display Name)
- `email` (für E-Mail-Adresse)

Navigiere zu: `Client scopes` → `Assigned client scopes`

```yaml
Default Client Scopes:
  - openid
  - profile
  - email
```

### 5. User Attribute Mapping (optional)

Für konsistente Benutzernamen:

Navigiere zu: `Clients` → `bbsam-messenger` → `Client scopes` → `bbsam-messenger-dedicated` → `Mappers`

**Mapper erstellen:**
```yaml
Name: preferred_username
Mapper Type: User Property
Property: username
Token Claim Name: preferred_username
Claim JSON Type: String
Add to ID token: ON
Add to access token: ON
Add to userinfo: ON
```

### 6. Benutzer erstellen/migrieren

Navigiere zu: `Users` → `Add user`

```yaml
Username: max.mustermann
Email: max.mustermann@bbsam.eu
Email verified: ON
First name: Max
Last name: Mustermann
Enabled: ON
```

**Passwort setzen:**
1. Gehe zum Benutzer → `Credentials`
2. `Set password`
3. Temporary: OFF (oder ON für Passwort-Änderung beim ersten Login)

---

## Synapse-Konfiguration

### homeserver.yaml

Erstelle oder bearbeite `/etc/synapse/homeserver.yaml`:

```yaml
# ==============================================================================
# Server Basics
# ==============================================================================
server_name: "bbsam.eu"
public_baseurl: "https://matrix.bbsam.eu/"

# ==============================================================================
# OIDC Konfiguration - Keycloak als einziger Identity Provider
# ==============================================================================
oidc_providers:
  - idp_id: keycloak
    idp_name: "BBSaM Login"
    idp_brand: "org.keycloak"
    discover: true
    issuer: "https://bbb.bbsam.eu/keycloak/realms/BBSaM"
    client_id: "bbsam-messenger"
    client_secret_path: "/etc/synapse/secrets/keycloak_client_secret"
    scopes:
      - "openid"
      - "profile"
      - "email"

    # Benutzer-Mapping
    user_mapping_provider:
      config:
        # Matrix-Benutzername aus Keycloak preferred_username
        localpart_template: "{{ user.preferred_username }}"
        # Anzeigename aus Keycloak (fallback auf username)
        display_name_template: "{{ user.name | default(user.preferred_username) }}"
        # E-Mail aus Keycloak
        email_template: "{{ user.email }}"

    # Existierende Benutzer mit SSO verknüpfen (wichtig für Migration!)
    allow_existing_users: true

    # Backchannel Logout (Single Logout)
    backchannel_logout_enabled: true

# ==============================================================================
# Passwort-Login VOLLSTÄNDIG DEAKTIVIEREN
# ==============================================================================
password_config:
  enabled: false
  localdb_enabled: false

# Keine lokale Registrierung erlauben
enable_registration: false
enable_registration_without_verification: false

# Gäste nicht erlauben
allow_guest_access: false

# ==============================================================================
# SSO-Einstellungen
# ==============================================================================
sso:
  # Clients, die SSO-Login verwenden dürfen
  client_whitelist:
    - "https://matrix.bbsam.eu"
    - "https://app.bbsam.eu"
    - "eu.bbsam.messenger"
    - "eu.bbsam.messenger.debug"

  # Profil-Infos bei jedem Login aktualisieren
  update_profile_information: true

# ==============================================================================
# Session Management
# ==============================================================================

# Standard Session-Länge (in Stunden)
session_lifetime: 24h

# Refresh Token (für Mobile Apps)
refresh_token_lifetime: 336h  # 14 Tage

# Logout URL (optional)
# sso_logout_url: "https://bbb.bbsam.eu/keycloak/realms/BBSaM/protocol/openid-connect/logout"
```

### Synapse neustarten

```bash
sudo systemctl restart synapse
sudo systemctl status synapse

# Logs prüfen
sudo journalctl -u synapse -f
```

### Konfiguration testen

```bash
# OIDC Discovery testen
curl -s "https://bbb.bbsam.eu/keycloak/realms/BBSaM/.well-known/openid-configuration" | jq .

# Synapse Login-Optionen prüfen
curl -s "https://matrix.bbsam.eu/_matrix/client/v3/login" | jq .
```

Erwartete Ausgabe (Login-Optionen):
```json
{
  "flows": [
    {
      "type": "m.login.sso",
      "identity_providers": [
        {
          "id": "keycloak",
          "name": "BBSaM Login",
          "brand": "org.keycloak"
        }
      ]
    },
    {
      "type": "m.login.token"
    }
  ]
}
```

**WICHTIG:** Es sollte KEIN `m.login.password` in den Flows erscheinen!

---

## Client-Konfigurationen

### Element Web / Desktop

**config.json:**

```json
{
    "default_server_config": {
        "m.homeserver": {
            "base_url": "https://matrix.bbsam.eu",
            "server_name": "bbsam.eu"
        }
    },

    "brand": "BBSaM-Messenger",

    "disable_custom_urls": true,
    "disable_guests": true,
    "disable_login_language_selector": false,

    "sso_redirect_options": {
        "immediate": true,
        "on_welcome_page": true
    },

    "setting_defaults": {
        "UIFeature.registration": false,
        "UIFeature.passwordReset": false,
        "UIFeature.deactivate": false
    },

    "branding": {
        "welcome_background_url": "themes/bbsam/img/backgrounds/welcome.svg",
        "auth_header_logo_url": "themes/bbsam/img/logos/bbsam-logo.svg",
        "auth_footer_links": [
            {
                "text": "Datenschutz",
                "url": "https://bbsam.eu/datenschutz"
            },
            {
                "text": "Impressum",
                "url": "https://bbsam.eu/impressum"
            },
            {
                "text": "Hilfe",
                "url": "https://bbsam.eu/hilfe"
            }
        ]
    },

    "room_directory": {
        "servers": ["bbsam.eu"]
    },

    "show_labs_settings": false,

    "features": {
        "feature_registration": false
    }
}
```

### Element X Android

**app/src/main/res/values/strings.xml:**
```xml
<resources>
    <string name="app_name">BBSaM-Messenger</string>
    <string name="login_redirect_scheme">eu.bbsam.messenger</string>
</resources>
```

**app/src/main/AndroidManifest.xml** (OAuth Callback Intent):
```xml
<activity
    android:name=".features.login.impl.oidc.OidcCallbackActivity"
    android:exported="true"
    android:launchMode="singleTask">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="eu.bbsam.messenger"
            android:host="callback" />
    </intent-filter>
</activity>
```

**Hardcodierter Homeserver** (optional, für Enterprise):
Bearbeite die Login-Logik, um nur `matrix.bbsam.eu` zu erlauben.

### Element X iOS

**app.yml:**
```yaml
APP_DISPLAY_NAME: BBSaM-Messenger
BASE_BUNDLE_IDENTIFIER: eu.bbsam.messenger
APP_GROUP_IDENTIFIER: group.eu.bbsam
```

**ElementX/SupportingFiles/target.yml** (Associated Domains):
```yaml
settings:
  CODE_SIGN_ENTITLEMENTS: ElementX/SupportingFiles/ElementX.entitlements

entitlements:
  com.apple.developer.associated-domains:
    - webcredentials:bbsam.eu
    - applinks:matrix.bbsam.eu
```

**Server-seitig (apple-app-site-association):**

Erstelle die Datei unter `https://bbsam.eu/.well-known/apple-app-site-association`:

```json
{
    "webcredentials": {
        "apps": ["TEAM_ID.eu.bbsam.messenger"]
    },
    "applinks": {
        "apps": [],
        "details": [
            {
                "appID": "TEAM_ID.eu.bbsam.messenger",
                "paths": ["/*"]
            }
        ]
    }
}
```

---

## Authentifizierungs-Flow

### Web/Desktop SSO-Flow

```
1. Benutzer öffnet BBSaM-Messenger Web
   ↓
2. Client prüft: Ist Benutzer eingeloggt?
   ↓ (Nein)
3. Client ruft GET /_matrix/client/v3/login auf
   ↓
4. Synapse antwortet mit SSO-Provider (Keycloak)
   ↓
5. Client initiiert SSO: GET /_matrix/client/v3/login/sso/redirect/keycloak
   ↓
6. Synapse redirected zu Keycloak:
   https://bbb.bbsam.eu/keycloak/realms/BBSaM/protocol/openid-connect/auth
   ?client_id=bbsam-messenger
   &redirect_uri=https://matrix.bbsam.eu/_synapse/client/oidc/callback
   &response_type=code
   &scope=openid%20profile%20email
   &state=...
   &nonce=...
   ↓
7. Keycloak zeigt Login-Seite
   ↓
8. Benutzer gibt Credentials ein
   ↓
9. Keycloak validiert und redirected:
   https://matrix.bbsam.eu/_synapse/client/oidc/callback
   ?code=AUTH_CODE
   &state=...
   ↓
10. Synapse tauscht Code gegen Tokens (Backend-to-Backend)
    ↓
11. Synapse erstellt/verknüpft Matrix-Benutzer
    ↓
12. Synapse redirected zurück zum Client mit Matrix-Token
    ↓
13. Client ist eingeloggt!
```

### Mobile OIDC-Flow (mit PKCE)

```
1. Benutzer öffnet BBSaM-Messenger App
   ↓
2. App generiert code_verifier und code_challenge (PKCE)
   ↓
3. App öffnet System-Browser für Keycloak-Login:
   https://bbb.bbsam.eu/keycloak/realms/BBSaM/protocol/openid-connect/auth
   ?client_id=bbsam-messenger
   &redirect_uri=eu.bbsam.messenger://callback
   &response_type=code
   &scope=openid%20profile%20email
   &code_challenge=...
   &code_challenge_method=S256
   ↓
4. Benutzer loggt sich bei Keycloak ein
   ↓
5. Keycloak redirected zu App:
   eu.bbsam.messenger://callback?code=AUTH_CODE
   ↓
6. App fängt Deep Link ab
   ↓
7. App tauscht Code gegen Tokens (mit code_verifier):
   POST https://matrix.bbsam.eu/_matrix/client/v3/login
   ↓
8. Matrix Session erstellt
   ↓
9. App ist eingeloggt!
```

### Token-Refresh

```
1. Access Token läuft ab (nach ~5 Minuten)
   ↓
2. Client sendet Refresh Token an Synapse
   ↓
3. Synapse validiert Refresh Token
   ↓
4. Falls gültig: Neues Access Token + Refresh Token
   ↓
5. Falls ungültig: Logout und Re-Authentication erforderlich
```

---

## Troubleshooting

### Häufige Probleme

#### 1. "OIDC callback failed" Fehler

**Symptom:** Redirect von Keycloak schlägt fehl.

**Mögliche Ursachen:**
- Redirect URI in Keycloak nicht korrekt konfiguriert
- Client Secret stimmt nicht überein
- Uhrzeit zwischen Servern nicht synchronisiert

**Lösung:**
```bash
# 1. Redirect URIs in Keycloak prüfen
#    Muss exakt übereinstimmen!

# 2. Client Secret prüfen
sudo cat /etc/synapse/secrets/keycloak_client_secret

# 3. Zeit synchronisieren
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd
```

#### 2. "User not found" nach SSO-Login

**Symptom:** Benutzer wird nicht erstellt/gefunden.

**Mögliche Ursachen:**
- `preferred_username` nicht im Token
- Template-Fehler in `localpart_template`

**Lösung:**
```bash
# 1. Token-Inhalt prüfen (in Keycloak):
#    Gehe zu Clients → bbsam-messenger → Client scopes
#    Prüfe, ob preferred_username gemappt ist

# 2. Synapse-Logs prüfen
sudo journalctl -u synapse | grep -i "oidc\|user_mapping"

# 3. Template anpassen:
localpart_template: "{{ user.preferred_username | lower | replace(' ', '_') }}"
```

#### 3. Mobile App: Callback wird nicht abgefangen

**Symptom:** Browser bleibt nach Login offen.

**Android-Lösung:**
```xml
<!-- AndroidManifest.xml: Intent Filter prüfen -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="eu.bbsam.messenger" android:host="callback" />
</intent-filter>
```

**iOS-Lösung:**
```yaml
# target.yml: URL Schemes prüfen
settings:
  INFOPLIST_KEY_CFBundleURLSchemes: eu.bbsam.messenger
```

#### 4. "Invalid redirect_uri" Fehler

**Symptom:** Keycloak lehnt Redirect ab.

**Lösung:**
```
1. Gehe zu Keycloak Admin → Clients → bbsam-messenger
2. Prüfe "Valid redirect URIs"
3. Füge alle benötigten URIs hinzu:
   - https://matrix.bbsam.eu/_synapse/client/oidc/callback
   - eu.bbsam.messenger://callback
   - eu.bbsam.messenger.debug://callback
   - http://localhost:8080/callback (Entwicklung)
```

#### 5. Session wird nicht beendet (Logout)

**Symptom:** Nach Logout im Client ist man bei Keycloak noch eingeloggt.

**Lösung - Backchannel Logout aktivieren:**

In Synapse:
```yaml
oidc_providers:
  - idp_id: keycloak
    backchannel_logout_enabled: true
```

In Keycloak:
```
1. Clients → bbsam-messenger → Settings
2. Backchannel logout URL:
   https://matrix.bbsam.eu/_synapse/client/oidc/backchannel_logout
3. Backchannel logout session required: ON
```

### Diagnose-Befehle

```bash
# Synapse-Logs (OIDC-spezifisch)
sudo journalctl -u synapse --since "1 hour ago" | grep -i "oidc"

# Keycloak-Events prüfen
# In Keycloak Admin: Events → Login Events

# OIDC Discovery testen
curl -s "https://bbb.bbsam.eu/keycloak/realms/BBSaM/.well-known/openid-configuration" | jq .

# Synapse Login-Flows prüfen
curl -s "https://matrix.bbsam.eu/_matrix/client/v3/login" | jq .

# Token manuell dekodieren (für Debugging)
# Kopiere ID Token und gehe zu jwt.io

# Synapse Benutzer-Liste
curl -s "https://matrix.bbsam.eu/_synapse/admin/v2/users" \
  -H "Authorization: Bearer ADMIN_TOKEN" | jq .
```

---

## Sicherheitsüberlegungen

### Empfohlene Keycloak-Einstellungen

```yaml
# Realm Settings → Security Defenses

Brute Force Detection:
  Enabled: ON
  Max Login Failures: 5
  Wait Increment: 60 seconds
  Max Wait: 900 seconds

Password Policies:
  Length: 12
  Digits: 1
  Special Characters: 1
  Not Username: ON
  Not Email: ON

Session Settings:
  SSO Session Idle: 30 minutes
  SSO Session Max: 8 hours
  Client Session Idle: 15 minutes
  Client Session Max: 8 hours
```

### TLS/HTTPS

- **Alle** Verbindungen müssen über HTTPS laufen
- TLS 1.2+ erforderlich
- Starke Cipher Suites verwenden

### Token-Sicherheit

```yaml
# In Keycloak: Realm Settings → Tokens

Access Token Lifespan: 5 minutes
Refresh Token Max Reuse: 0
Refresh Token Lifespan: 14 days

# PKCE für alle Clients erzwingen (empfohlen):
Clients → bbsam-messenger → Advanced → Proof Key for Code Exchange
  Code Challenge Method: S256
```

### Audit-Logging

```yaml
# In Keycloak: Events → Config

Login Events:
  Save Events: ON
  Saved Types: LOGIN, LOGIN_ERROR, LOGOUT, CODE_TO_TOKEN, CODE_TO_TOKEN_ERROR

Admin Events:
  Save Events: ON
  Include Representation: ON
```

---

## Checkliste für Go-Live

- [ ] Keycloak-Realm erstellt und konfiguriert
- [ ] Client `bbsam-messenger` erstellt
- [ ] Redirect URIs für alle Plattformen eingetragen
- [ ] Client Secret sicher auf Synapse gespeichert
- [ ] Synapse OIDC-Konfiguration getestet
- [ ] Passwort-Login deaktiviert (`password_config.enabled: false`)
- [ ] Web-Client SSO-Flow funktioniert
- [ ] Desktop-Client SSO-Flow funktioniert
- [ ] Android-App SSO-Flow funktioniert
- [ ] iOS-App SSO-Flow funktioniert
- [ ] Logout funktioniert auf allen Plattformen
- [ ] Backchannel Logout konfiguriert
- [ ] Token-Refresh funktioniert
- [ ] Benutzer können sich selbst registrieren (falls gewünscht über Keycloak)
- [ ] Brute Force Protection aktiviert
- [ ] TLS/HTTPS überall aktiv
- [ ] Audit-Logging aktiviert

---

*Dokument Version: 1.0*
*Letzte Aktualisierung: 2026-01-21*
