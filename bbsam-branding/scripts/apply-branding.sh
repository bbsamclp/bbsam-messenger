#!/bin/bash
# =============================================================================
# BBSaM-Messenger Branding Applicator
# =============================================================================
# Wendet Branding-Assets auf ein App-Repository an
#
# Verwendung:
#   ./apply-branding.sh <platform>
#
# Plattformen:
#   web      - Element Web
#   desktop  - Element Desktop
#   android  - Element X Android
#   ios      - Element X iOS
#   all      - Alle Plattformen
#
# =============================================================================

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Basis-Verzeichnisse
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRANDING_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$BRANDING_DIR/assets"
CONFIG_DIR="$BRANDING_DIR/config"

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
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Findet das App-Repository relativ zum Branding-Verzeichnis
find_app_repo() {
    local platform=$1
    local repo_name=""

    case $platform in
        web)     repo_name="bbsam-messenger-web" ;;
        desktop) repo_name="bbsam-messenger-desktop" ;;
        android) repo_name="bbsam-messenger-android" ;;
        ios)     repo_name="bbsam-messenger-ios" ;;
    esac

    # Versuche verschiedene Pfade
    local paths=(
        "$(dirname "$BRANDING_DIR")/$repo_name"
        "$BRANDING_DIR/../$repo_name"
        "$HOME/projects/$repo_name"
        "./$repo_name"
    )

    for path in "${paths[@]}"; do
        if [ -d "$path" ]; then
            echo "$(cd "$path" && pwd)"
            return 0
        fi
    done

    log_error "Repository nicht gefunden: $repo_name"
    log_info "Erwartete Pfade: ${paths[*]}"
    return 1
}

# =============================================================================
# Web Branding
# =============================================================================

apply_web_branding() {
    log_step "Wende Web-Branding an..."

    local repo_dir=$(find_app_repo web) || return 1
    log_info "Repository: $repo_dir"

    # Config.json kopieren
    if [ -f "$CONFIG_DIR/web-config.json" ]; then
        cp "$CONFIG_DIR/web-config.json" "$repo_dir/config.json"
        log_success "config.json kopiert"
    fi

    # Icons kopieren
    local web_icons="$ASSETS_DIR/icons/web"
    if [ -d "$web_icons" ]; then
        # Favicon
        cp "$web_icons/favicon.ico" "$repo_dir/res/vector-icons/" 2>/dev/null || true
        cp "$web_icons/apple-touch-icon.png" "$repo_dir/res/vector-icons/" 2>/dev/null || true
        cp "$web_icons/favicon-192.png" "$repo_dir/res/vector-icons/" 2>/dev/null || true
        cp "$web_icons/favicon-512.png" "$repo_dir/res/vector-icons/" 2>/dev/null || true
        log_success "Web Icons kopiert"
    fi

    # Logos kopieren
    local logos="$ASSETS_DIR/logos"
    if [ -d "$logos" ]; then
        mkdir -p "$repo_dir/res/img/logos"
        cp "$logos"/*.svg "$repo_dir/res/img/logos/" 2>/dev/null || true
        cp "$logos"/*.png "$repo_dir/res/img/logos/" 2>/dev/null || true
        log_success "Logos kopiert"
    fi

    # Manifest.json aktualisieren
    if [ -f "$repo_dir/res/manifest.json" ]; then
        local tmp_manifest=$(mktemp)
        jq '.name = "BBSaM-Messenger" | .short_name = "BBSaM" | .description = "Sicherer Messenger für BBSaM"' \
            "$repo_dir/res/manifest.json" > "$tmp_manifest"
        mv "$tmp_manifest" "$repo_dir/res/manifest.json"
        log_success "manifest.json aktualisiert"
    fi

    # String-Ersetzungen
    log_info "Führe String-Ersetzungen durch..."

    # In HTML-Dateien
    find "$repo_dir" -name "*.html" -type f ! -path "*/node_modules/*" | while read -r file; do
        sed -i 's/Element/BBSaM-Messenger/g' "$file" 2>/dev/null || true
    done

    log_success "Web-Branding angewendet"
}

# =============================================================================
# Desktop Branding
# =============================================================================

apply_desktop_branding() {
    log_step "Wende Desktop-Branding an..."

    local repo_dir=$(find_app_repo desktop) || return 1
    log_info "Repository: $repo_dir"

    # Icons kopieren
    local desktop_icons="$ASSETS_DIR/icons/desktop"
    if [ -d "$desktop_icons" ]; then
        mkdir -p "$repo_dir/build/icons"
        cp "$desktop_icons/icon.ico" "$repo_dir/build/icons/" 2>/dev/null || true
        cp "$desktop_icons/icon.icns" "$repo_dir/build/icons/" 2>/dev/null || true
        cp "$desktop_icons/icon.png" "$repo_dir/build/icons/" 2>/dev/null || true
        log_success "Desktop Icons kopiert"
    fi

    # package.json aktualisieren
    if [ -f "$repo_dir/package.json" ]; then
        local tmp_pkg=$(mktemp)
        jq '.name = "bbsam-messenger-desktop" |
            .productName = "BBSaM-Messenger" |
            .description = "BBSaM-Messenger Desktop Client" |
            .author = "BBSaM"' \
            "$repo_dir/package.json" > "$tmp_pkg"
        mv "$tmp_pkg" "$repo_dir/package.json"
        log_success "package.json aktualisiert"
    fi

    # electron-builder.json aktualisieren
    if [ -f "$repo_dir/electron-builder.json" ]; then
        local tmp_builder=$(mktemp)
        jq '.appId = "eu.bbsam.messenger" |
            .productName = "BBSaM-Messenger"' \
            "$repo_dir/electron-builder.json" > "$tmp_builder"
        mv "$tmp_builder" "$repo_dir/electron-builder.json"
        log_success "electron-builder.json aktualisiert"
    fi

    log_success "Desktop-Branding angewendet"
}

# =============================================================================
# Android Branding
# =============================================================================

apply_android_branding() {
    log_step "Wende Android-Branding an..."

    local repo_dir=$(find_app_repo android) || return 1
    log_info "Repository: $repo_dir"

    # Icons kopieren
    local android_icons="$ASSETS_DIR/icons/android"
    if [ -d "$android_icons" ]; then
        local res_dir="$repo_dir/app/src/main/res"

        for density in mipmap-mdpi mipmap-hdpi mipmap-xhdpi mipmap-xxhdpi mipmap-xxxhdpi; do
            if [ -d "$android_icons/$density" ]; then
                mkdir -p "$res_dir/$density"
                cp "$android_icons/$density"/*.png "$res_dir/$density/" 2>/dev/null || true
            fi
        done

        # Adaptive Icon XML
        if [ -d "$android_icons/mipmap-anydpi-v26" ]; then
            mkdir -p "$res_dir/mipmap-anydpi-v26"
            cp "$android_icons/mipmap-anydpi-v26"/*.xml "$res_dir/mipmap-anydpi-v26/" 2>/dev/null || true
        fi

        log_success "Android Icons kopiert"
    fi

    # strings.xml aktualisieren
    local strings_file="$repo_dir/app/src/main/res/values/strings.xml"
    if [ -f "$strings_file" ]; then
        sed -i 's/<string name="app_name">.*<\/string>/<string name="app_name">BBSaM-Messenger<\/string>/g' "$strings_file"
        log_success "strings.xml aktualisiert"
    fi

    # Farben aktualisieren
    local colors_file="$repo_dir/app/src/main/res/values/colors.xml"
    if [ -f "$colors_file" ] && [ -f "$CONFIG_DIR/colors.json" ]; then
        local primary=$(jq -r '.themes.light.primary' "$CONFIG_DIR/colors.json")
        sed -i "s/<color name=\"colorPrimary\">.*<\/color>/<color name=\"colorPrimary\">$primary<\/color>/g" "$colors_file" 2>/dev/null || true
        log_success "colors.xml aktualisiert"
    fi

    log_success "Android-Branding angewendet"
}

# =============================================================================
# iOS Branding
# =============================================================================

apply_ios_branding() {
    log_step "Wende iOS-Branding an..."

    local repo_dir=$(find_app_repo ios) || return 1
    log_info "Repository: $repo_dir"

    # Icons kopieren
    local ios_icons="$ASSETS_DIR/icons/ios/AppIcon.appiconset"
    if [ -d "$ios_icons" ]; then
        local dest_dir="$repo_dir/ElementX/Resources/Assets.xcassets/AppIcon.appiconset"
        if [ -d "$(dirname "$dest_dir")" ]; then
            mkdir -p "$dest_dir"
            cp "$ios_icons"/*.png "$dest_dir/" 2>/dev/null || true
            cp "$ios_icons/Contents.json" "$dest_dir/" 2>/dev/null || true
            log_success "iOS Icons kopiert"
        fi
    fi

    # app.yml aktualisieren
    local app_yml="$repo_dir/app.yml"
    if [ -f "$app_yml" ]; then
        sed -i 's/APP_DISPLAY_NAME:.*/APP_DISPLAY_NAME: BBSaM-Messenger/g' "$app_yml"
        sed -i 's/BASE_BUNDLE_IDENTIFIER:.*/BASE_BUNDLE_IDENTIFIER: eu.bbsam.messenger/g' "$app_yml"
        sed -i 's/APP_GROUP_IDENTIFIER:.*/APP_GROUP_IDENTIFIER: group.eu.bbsam/g' "$app_yml"
        sed -i 's/PRODUCTION_APP_NAME:.*/PRODUCTION_APP_NAME: BBSaM/g' "$app_yml"
        log_success "app.yml aktualisiert"
    fi

    # XcodeGen ausführen (falls verfügbar)
    if command -v xcodegen &> /dev/null && [ -f "$repo_dir/project.yml" ]; then
        log_info "Führe xcodegen aus..."
        (cd "$repo_dir" && xcodegen generate) || log_warn "xcodegen fehlgeschlagen"
    fi

    log_success "iOS-Branding angewendet"
}

# =============================================================================
# Alle Plattformen
# =============================================================================

apply_all_branding() {
    log_step "Wende Branding auf alle Plattformen an..."

    apply_web_branding || log_warn "Web-Branding fehlgeschlagen"
    echo ""
    apply_desktop_branding || log_warn "Desktop-Branding fehlgeschlagen"
    echo ""
    apply_android_branding || log_warn "Android-Branding fehlgeschlagen"
    echo ""
    apply_ios_branding || log_warn "iOS-Branding fehlgeschlagen"

    log_success "Alle Plattformen verarbeitet"
}

# =============================================================================
# Hauptprogramm
# =============================================================================

main() {
    echo ""
    echo "=============================================="
    echo "  BBSaM-Messenger Branding Applicator"
    echo "=============================================="
    echo ""

    local platform="${1:-}"

    if [ -z "$platform" ]; then
        log_error "Keine Plattform angegeben"
        echo ""
        echo "Verwendung: $0 <platform>"
        echo ""
        echo "Plattformen:"
        echo "  web      - Element Web"
        echo "  desktop  - Element Desktop"
        echo "  android  - Element X Android"
        echo "  ios      - Element X iOS"
        echo "  all      - Alle Plattformen"
        echo ""
        exit 1
    fi

    case $platform in
        web)     apply_web_branding ;;
        desktop) apply_desktop_branding ;;
        android) apply_android_branding ;;
        ios)     apply_ios_branding ;;
        all)     apply_all_branding ;;
        *)
            log_error "Unbekannte Plattform: $platform"
            exit 1
            ;;
    esac

    echo ""
    echo "=============================================="
    log_success "Branding erfolgreich angewendet!"
    echo "=============================================="
    echo ""
}

main "$@"
