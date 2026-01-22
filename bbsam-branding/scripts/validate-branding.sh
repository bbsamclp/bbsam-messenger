#!/bin/bash
# =============================================================================
# BBSaM-Messenger Branding Validator
# =============================================================================
# Prüft die Vollständigkeit aller Branding-Assets
#
# Verwendung:
#   ./validate-branding.sh
#
# =============================================================================

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Basis-Verzeichnisse
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRANDING_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$BRANDING_DIR/assets"
CONFIG_DIR="$BRANDING_DIR/config"

# Zähler
ERRORS=0
WARNINGS=0

# =============================================================================
# Hilfsfunktionen
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((ERRORS++))
}

check_file() {
    local file=$1
    local description=$2
    local required=${3:-true}

    if [ -f "$file" ]; then
        log_success "$description: $file"
        return 0
    else
        if [ "$required" = true ]; then
            log_error "$description fehlt: $file"
        else
            log_warn "$description fehlt (optional): $file"
        fi
        return 1
    fi
}

check_dir() {
    local dir=$1
    local description=$2

    if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
        local count=$(find "$dir" -type f | wc -l)
        log_success "$description: $dir ($count Dateien)"
        return 0
    else
        log_error "$description fehlt oder leer: $dir"
        return 1
    fi
}

# =============================================================================
# Validierungen
# =============================================================================

validate_master_icon() {
    echo ""
    echo "=== Master Icon ==="

    check_file "$ASSETS_DIR/icons/app-icon.svg" "Master Icon (SVG)"
}

validate_android_icons() {
    echo ""
    echo "=== Android Icons ==="

    local android_dir="$ASSETS_DIR/icons/android"

    check_file "$android_dir/mipmap-mdpi/ic_launcher.png" "Android MDPI (48x48)"
    check_file "$android_dir/mipmap-hdpi/ic_launcher.png" "Android HDPI (72x72)"
    check_file "$android_dir/mipmap-xhdpi/ic_launcher.png" "Android XHDPI (96x96)"
    check_file "$android_dir/mipmap-xxhdpi/ic_launcher.png" "Android XXHDPI (144x144)"
    check_file "$android_dir/mipmap-xxxhdpi/ic_launcher.png" "Android XXXHDPI (192x192)"
    check_file "$android_dir/mipmap-anydpi-v26/ic_launcher.xml" "Android Adaptive Icon"
}

validate_ios_icons() {
    echo ""
    echo "=== iOS Icons ==="

    local ios_dir="$ASSETS_DIR/icons/ios/AppIcon.appiconset"

    check_file "$ios_dir/Contents.json" "iOS Contents.json"
    check_file "$ios_dir/Icon-60@2x.png" "iOS App Icon @2x"
    check_file "$ios_dir/Icon-60@3x.png" "iOS App Icon @3x"
    check_file "$ios_dir/Icon-1024.png" "iOS App Store Icon (1024x1024)"
}

validate_web_icons() {
    echo ""
    echo "=== Web Icons ==="

    local web_dir="$ASSETS_DIR/icons/web"

    check_file "$web_dir/favicon.ico" "Favicon ICO"
    check_file "$web_dir/favicon-16.png" "Favicon 16x16"
    check_file "$web_dir/favicon-32.png" "Favicon 32x32"
    check_file "$web_dir/favicon-192.png" "PWA Icon 192x192"
    check_file "$web_dir/favicon-512.png" "PWA Icon 512x512"
    check_file "$web_dir/apple-touch-icon.png" "Apple Touch Icon"
}

validate_desktop_icons() {
    echo ""
    echo "=== Desktop Icons ==="

    local desktop_dir="$ASSETS_DIR/icons/desktop"

    check_file "$desktop_dir/icon.ico" "Windows ICO"
    check_file "$desktop_dir/icon.icns" "macOS ICNS" false
    check_file "$desktop_dir/icon.png" "Linux PNG"
}

validate_logos() {
    echo ""
    echo "=== Logos ==="

    local logos_dir="$ASSETS_DIR/logos"

    check_file "$logos_dir/bbsam-logo.svg" "Hauptlogo (SVG)"
    check_file "$logos_dir/bbsam-wordmark.svg" "Wordmark (SVG)" false
    check_file "$logos_dir/bbsam-logo-white.svg" "Logo weiß (SVG)" false
}

validate_config_files() {
    echo ""
    echo "=== Konfigurationsdateien ==="

    check_file "$CONFIG_DIR/colors.json" "Farbdefinitionen"
    check_file "$CONFIG_DIR/strings.json" "String-Ersetzungen"
    check_file "$CONFIG_DIR/web-config.json" "Web Config"
    check_file "$CONFIG_DIR/servers.json" "Server-Konfiguration"

    # JSON-Validierung
    for json_file in "$CONFIG_DIR"/*.json; do
        if [ -f "$json_file" ]; then
            if jq empty "$json_file" 2>/dev/null; then
                log_success "JSON valide: $(basename "$json_file")"
            else
                log_error "JSON ungültig: $(basename "$json_file")"
            fi
        fi
    done
}

validate_scripts() {
    echo ""
    echo "=== Skripte ==="

    local scripts_dir="$BRANDING_DIR/scripts"

    check_file "$scripts_dir/generate-icons.sh" "Icon-Generator"
    check_file "$scripts_dir/apply-branding.sh" "Branding-Applicator"
    check_file "$scripts_dir/check-upstream.sh" "Upstream-Checker"
    check_file "$scripts_dir/validate-branding.sh" "Validator (dieses Skript)"

    # Ausführbarkeit prüfen
    for script in "$scripts_dir"/*.sh; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                log_success "Ausführbar: $(basename "$script")"
            else
                log_warn "Nicht ausführbar: $(basename "$script") (chmod +x)"
            fi
        fi
    done
}

validate_element_references() {
    echo ""
    echo "=== Element-Referenzen prüfen ==="

    # Suche nach "Element" in Konfigurationsdateien (sollte ersetzt sein)
    local element_refs=$(grep -r "Element" "$CONFIG_DIR" --include="*.json" 2>/dev/null | \
                         grep -v "element.io" | \
                         grep -v "element-hq" | \
                         grep -v '"Element"' || true)

    if [ -n "$element_refs" ]; then
        log_warn "Mögliche Element-Referenzen gefunden (prüfen!):"
        echo "$element_refs" | head -5
    else
        log_success "Keine unerwünschten Element-Referenzen gefunden"
    fi
}

# =============================================================================
# Hauptprogramm
# =============================================================================

main() {
    echo ""
    echo "=============================================="
    echo "  BBSaM-Messenger Branding Validator"
    echo "=============================================="
    echo ""
    echo "Branding-Verzeichnis: $BRANDING_DIR"

    validate_master_icon
    validate_android_icons
    validate_ios_icons
    validate_web_icons
    validate_desktop_icons
    validate_logos
    validate_config_files
    validate_scripts
    validate_element_references

    echo ""
    echo "=============================================="
    echo "  Zusammenfassung"
    echo "=============================================="
    echo ""

    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        log_success "Alle Validierungen bestanden!"
        exit 0
    else
        echo -e "  Fehler:    ${RED}$ERRORS${NC}"
        echo -e "  Warnungen: ${YELLOW}$WARNINGS${NC}"
        echo ""

        if [ $ERRORS -gt 0 ]; then
            log_error "Validierung fehlgeschlagen. Bitte beheben Sie die Fehler."
            exit 1
        else
            log_warn "Validierung mit Warnungen abgeschlossen."
            exit 0
        fi
    fi
}

main "$@"
