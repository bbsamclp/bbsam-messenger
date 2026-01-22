#!/bin/bash
# =============================================================================
# BBSaM-Messenger Icon Generator
# =============================================================================
# Generiert alle Icon-Größen für alle Plattformen aus einem SVG oder PNG Master-Icon
#
# Voraussetzungen:
#   - ImageMagick (convert, identify)
#   - librsvg2-bin (rsvg-convert) für SVG (optional wenn PNG verwendet wird)
#   - icnsutils (png2icns) für macOS Icons
#   - icoutils (icotool) für Windows Icons
#
# Installation (Ubuntu/Debian):
#   sudo apt-get install imagemagick librsvg2-bin icnsutils icoutils
#
# Installation (macOS):
#   brew install imagemagick librsvg libicns
#
# Verwendung:
#   ./generate-icons.sh [path/to/icon.svg|png]
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
ICONS_DIR="$ASSETS_DIR/icons"

# Input (SVG oder PNG)
INPUT_FILE="${1:-}"

# Auto-detect input file
if [ -z "$INPUT_FILE" ]; then
    if [ -f "$ICONS_DIR/app-icon.svg" ]; then
        INPUT_FILE="$ICONS_DIR/app-icon.svg"
    elif [ -f "$ICONS_DIR/app-icon.png" ]; then
        INPUT_FILE="$ICONS_DIR/app-icon.png"
    elif [ -f "$ASSETS_DIR/logos/bbsam-logo.png" ]; then
        INPUT_FILE="$ASSETS_DIR/logos/bbsam-logo.png"
    fi
fi

# Determine file type
INPUT_TYPE=""
if [[ "$INPUT_FILE" == *.svg ]]; then
    INPUT_TYPE="svg"
elif [[ "$INPUT_FILE" == *.png ]] || [[ "$INPUT_FILE" == *.PNG ]]; then
    INPUT_TYPE="png"
elif [[ "$INPUT_FILE" == *.jpg ]] || [[ "$INPUT_FILE" == *.jpeg ]]; then
    INPUT_TYPE="jpg"
fi

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

check_dependencies() {
    log_info "Prüfe Abhängigkeiten..."

    local missing=()

    if ! command -v convert &> /dev/null; then
        missing+=("imagemagick")
    fi

    if [ "$INPUT_TYPE" = "svg" ] && ! command -v rsvg-convert &> /dev/null; then
        missing+=("librsvg2-bin")
    fi

    if ! command -v icotool &> /dev/null; then
        missing+=("icoutils")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Fehlende Abhängigkeiten: ${missing[*]}"
        log_info "Installation: sudo apt-get install ${missing[*]}"
        exit 1
    fi

    log_success "Alle Abhängigkeiten vorhanden"
}

# Konvertiert das Input-Bild in die gewünschte Größe
# Unterstützt sowohl SVG als auch PNG/JPG
resize_image() {
    local width=$1
    local height=$2
    local output=$3

    if [ "$INPUT_TYPE" = "svg" ]; then
        rsvg-convert -w "$width" -h "$height" "$INPUT_FILE" -o "$output"
    else
        # PNG/JPG: Verwende ImageMagick
        convert "$INPUT_FILE" -resize "${width}x${height}" -gravity center -extent "${width}x${height}" "$output"
    fi
}

# =============================================================================
# Android Icon Generierung
# =============================================================================

generate_android_icons() {
    log_info "Generiere Android Icons..."

    local android_dir="$ICONS_DIR/android"

    # Standard Launcher Icons
    local sizes=(
        "mipmap-mdpi:48"
        "mipmap-hdpi:72"
        "mipmap-xhdpi:96"
        "mipmap-xxhdpi:144"
        "mipmap-xxxhdpi:192"
    )

    for size_pair in "${sizes[@]}"; do
        local dir="${size_pair%%:*}"
        local size="${size_pair##*:}"

        mkdir -p "$android_dir/$dir"

        resize_image "$size" "$size" "$android_dir/$dir/ic_launcher.png"

        # Round Icon (mit Kreis-Maske)
        convert "$android_dir/$dir/ic_launcher.png" \
            \( +clone -alpha extract \
                -draw "fill black polygon 0,0 0,$size $size,0 fill white circle $((size/2)),$((size/2)) $((size/2)),0" \
                \( +clone -flip \) -compose Multiply -composite \
                \( +clone -flop \) -compose Multiply -composite \
            \) -alpha off -compose CopyOpacity -composite \
            "$android_dir/$dir/ic_launcher_round.png" 2>/dev/null || true

        log_success "  $dir: ${size}x${size}px"
    done

    # Adaptive Icon XML
    mkdir -p "$android_dir/mipmap-anydpi-v26"

    cat > "$android_dir/mipmap-anydpi-v26/ic_launcher.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
EOF

    cat > "$android_dir/mipmap-anydpi-v26/ic_launcher_round.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
EOF

    # Foreground Icon (mit Padding für Adaptive Icon)
    local fg_sizes=(
        "mipmap-mdpi:108"
        "mipmap-hdpi:162"
        "mipmap-xhdpi:216"
        "mipmap-xxhdpi:324"
        "mipmap-xxxhdpi:432"
    )

    for size_pair in "${fg_sizes[@]}"; do
        local dir="${size_pair%%:*}"
        local size="${size_pair##*:}"
        local inner=$((size * 66 / 108))  # ~61% des Containers
        local offset=$(((size - inner) / 2))

        # Erstelle transparenten Hintergrund mit zentriertem Icon
        resize_image "$inner" "$inner" "/tmp/fg_inner.png"
        convert -size "${size}x${size}" xc:transparent \
            "/tmp/fg_inner.png" -gravity center -composite \
            "$android_dir/$dir/ic_launcher_foreground.png"
    done

    log_success "Android Icons generiert"
}

# =============================================================================
# iOS Icon Generierung
# =============================================================================

generate_ios_icons() {
    log_info "Generiere iOS Icons..."

    local ios_dir="$ICONS_DIR/ios/AppIcon.appiconset"
    mkdir -p "$ios_dir"

    # iOS Icon Größen (basierend auf Apple HIG)
    local sizes=(
        # iPhone Notification
        "20:1:Icon-20"
        "20:2:Icon-20@2x"
        "20:3:Icon-20@3x"
        # iPhone Settings
        "29:1:Icon-29"
        "29:2:Icon-29@2x"
        "29:3:Icon-29@3x"
        # iPhone Spotlight
        "40:1:Icon-40"
        "40:2:Icon-40@2x"
        "40:3:Icon-40@3x"
        # iPhone App
        "60:2:Icon-60@2x"
        "60:3:Icon-60@3x"
        # iPad Notifications
        "20:1:Icon-20~ipad"
        "20:2:Icon-20@2x~ipad"
        # iPad Settings
        "29:1:Icon-29~ipad"
        "29:2:Icon-29@2x~ipad"
        # iPad Spotlight
        "40:1:Icon-40~ipad"
        "40:2:Icon-40@2x~ipad"
        # iPad App
        "76:1:Icon-76"
        "76:2:Icon-76@2x"
        "83.5:2:Icon-83.5@2x"
        # App Store
        "1024:1:Icon-1024"
    )

    for size_info in "${sizes[@]}"; do
        IFS=':' read -r base scale name <<< "$size_info"

        # Berechne Pixelgröße (unterstützt Dezimalzahlen)
        local pixels=$(echo "$base * $scale" | bc | cut -d. -f1)

        resize_image "$pixels" "$pixels" "$ios_dir/$name.png"

        log_success "  $name.png: ${pixels}x${pixels}px"
    done

    # Contents.json erstellen
    cat > "$ios_dir/Contents.json" << 'EOF'
{
  "images" : [
    {"size":"20x20","idiom":"iphone","filename":"Icon-20@2x.png","scale":"2x"},
    {"size":"20x20","idiom":"iphone","filename":"Icon-20@3x.png","scale":"3x"},
    {"size":"29x29","idiom":"iphone","filename":"Icon-29@2x.png","scale":"2x"},
    {"size":"29x29","idiom":"iphone","filename":"Icon-29@3x.png","scale":"3x"},
    {"size":"40x40","idiom":"iphone","filename":"Icon-40@2x.png","scale":"2x"},
    {"size":"40x40","idiom":"iphone","filename":"Icon-40@3x.png","scale":"3x"},
    {"size":"60x60","idiom":"iphone","filename":"Icon-60@2x.png","scale":"2x"},
    {"size":"60x60","idiom":"iphone","filename":"Icon-60@3x.png","scale":"3x"},
    {"size":"20x20","idiom":"ipad","filename":"Icon-20~ipad.png","scale":"1x"},
    {"size":"20x20","idiom":"ipad","filename":"Icon-20@2x~ipad.png","scale":"2x"},
    {"size":"29x29","idiom":"ipad","filename":"Icon-29~ipad.png","scale":"1x"},
    {"size":"29x29","idiom":"ipad","filename":"Icon-29@2x~ipad.png","scale":"2x"},
    {"size":"40x40","idiom":"ipad","filename":"Icon-40~ipad.png","scale":"1x"},
    {"size":"40x40","idiom":"ipad","filename":"Icon-40@2x~ipad.png","scale":"2x"},
    {"size":"76x76","idiom":"ipad","filename":"Icon-76.png","scale":"1x"},
    {"size":"76x76","idiom":"ipad","filename":"Icon-76@2x.png","scale":"2x"},
    {"size":"83.5x83.5","idiom":"ipad","filename":"Icon-83.5@2x.png","scale":"2x"},
    {"size":"1024x1024","idiom":"ios-marketing","filename":"Icon-1024.png","scale":"1x"}
  ],
  "info" : {
    "version" : 1,
    "author" : "BBSaM Icon Generator"
  }
}
EOF

    log_success "iOS Icons generiert"
}

# =============================================================================
# Web Icons Generierung
# =============================================================================

generate_web_icons() {
    log_info "Generiere Web Icons..."

    local web_dir="$ICONS_DIR/web"
    mkdir -p "$web_dir"

    # Favicon Größen
    local sizes=(16 32 48 64 96 128 192 256 512)
    local ico_sizes=()

    for size in "${sizes[@]}"; do
        resize_image "$size" "$size" "$web_dir/favicon-${size}.png"

        if [ "$size" -le 256 ]; then
            ico_sizes+=("$web_dir/favicon-${size}.png")
        fi

        log_success "  favicon-${size}.png"
    done

    # favicon.ico (Multi-Resolution)
    if command -v icotool &> /dev/null; then
        icotool -c -o "$web_dir/favicon.ico" "${ico_sizes[@]}"
        log_success "  favicon.ico (multi-resolution)"
    else
        convert "${ico_sizes[@]}" "$web_dir/favicon.ico"
        log_success "  favicon.ico"
    fi

    # Apple Touch Icon
    resize_image 180 180 "$web_dir/apple-touch-icon.png"
    log_success "  apple-touch-icon.png (180x180)"

    # PWA Icons
    for size in 192 512; do
        cp "$web_dir/favicon-${size}.png" "$web_dir/pwa-${size}.png"
    done

    # Maskable Icon (mit Padding)
    resize_image 384 384 "/tmp/maskable_inner.png"
    convert -size 512x512 xc:white \
        "/tmp/maskable_inner.png" -gravity center -composite \
        "$web_dir/pwa-maskable-512.png"
    log_success "  pwa-maskable-512.png"

    # site.webmanifest
    cat > "$web_dir/site.webmanifest" << 'EOF'
{
  "name": "BBSaM-Messenger",
  "short_name": "BBSaM",
  "description": "Sicherer Messenger für BBSaM",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#1A73E8",
  "icons": [
    {
      "src": "/favicon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/favicon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/pwa-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
EOF

    log_success "Web Icons generiert"
}

# =============================================================================
# Desktop Icons Generierung
# =============================================================================

generate_desktop_icons() {
    log_info "Generiere Desktop Icons..."

    local desktop_dir="$ICONS_DIR/desktop"
    mkdir -p "$desktop_dir"

    # Windows ICO
    local win_sizes=(16 24 32 48 64 128 256)
    local win_pngs=()

    for size in "${win_sizes[@]}"; do
        resize_image "$size" "$size" "/tmp/win_icon_${size}.png"
        win_pngs+=("/tmp/win_icon_${size}.png")
    done

    if command -v icotool &> /dev/null; then
        icotool -c -o "$desktop_dir/icon.ico" "${win_pngs[@]}"
    else
        convert "${win_pngs[@]}" "$desktop_dir/icon.ico"
    fi
    log_success "  icon.ico (Windows)"

    # macOS ICNS
    local iconset_dir="/tmp/icon.iconset"
    mkdir -p "$iconset_dir"

    local mac_sizes=(
        "16:icon_16x16"
        "32:icon_16x16@2x"
        "32:icon_32x32"
        "64:icon_32x32@2x"
        "128:icon_128x128"
        "256:icon_128x128@2x"
        "256:icon_256x256"
        "512:icon_256x256@2x"
        "512:icon_512x512"
        "1024:icon_512x512@2x"
    )

    for size_info in "${mac_sizes[@]}"; do
        IFS=':' read -r size name <<< "$size_info"
        resize_image "$size" "$size" "$iconset_dir/$name.png"
    done

    # ICNS erstellen (macOS)
    if command -v iconutil &> /dev/null; then
        iconutil -c icns -o "$desktop_dir/icon.icns" "$iconset_dir"
    elif command -v png2icns &> /dev/null; then
        png2icns "$desktop_dir/icon.icns" "$iconset_dir"/*.png
    else
        log_warn "Kein ICNS-Tool gefunden, überspringe icon.icns"
    fi
    log_success "  icon.icns (macOS)"

    # Linux PNG (256x256 und 512x512)
    resize_image 256 256 "$desktop_dir/icon-256.png"
    resize_image 512 512 "$desktop_dir/icon-512.png"
    cp "$desktop_dir/icon-256.png" "$desktop_dir/icon.png"
    log_success "  icon.png (Linux)"

    # Aufräumen
    rm -rf "$iconset_dir" /tmp/win_icon_*.png

    log_success "Desktop Icons generiert"
}

# =============================================================================
# Hauptprogramm
# =============================================================================

main() {
    echo ""
    echo "=============================================="
    echo "  BBSaM-Messenger Icon Generator"
    echo "=============================================="
    echo ""

    # Prüfe Input-Datei
    if [ -z "$INPUT_FILE" ] || [ ! -f "$INPUT_FILE" ]; then
        log_error "Input-Datei nicht gefunden: $INPUT_FILE"
        log_info "Bitte laden Sie das Logo herunter:"
        log_info "  curl -o $ICONS_DIR/app-icon.png 'https://www.bbsam.de/wp-content/uploads/2024/08/bbs_logo_mit_kacheln.png'"
        log_info ""
        log_info "Oder erstellen Sie ein SVG Master-Icon unter:"
        log_info "  $ICONS_DIR/app-icon.svg"
        exit 1
    fi

    if [ -z "$INPUT_TYPE" ]; then
        log_error "Unbekanntes Dateiformat: $INPUT_FILE"
        log_info "Unterstützte Formate: SVG, PNG, JPG"
        exit 1
    fi

    log_info "Input: $INPUT_FILE ($INPUT_TYPE)"
    log_info "Output: $ICONS_DIR"
    echo ""

    check_dependencies
    echo ""

    generate_android_icons
    echo ""

    generate_ios_icons
    echo ""

    generate_web_icons
    echo ""

    generate_desktop_icons
    echo ""

    echo "=============================================="
    log_success "Alle Icons erfolgreich generiert!"
    echo "=============================================="
    echo ""
    echo "Nächste Schritte:"
    echo "  1. Prüfen Sie die generierten Icons"
    echo "  2. Führen Sie './apply-branding.sh' aus"
    echo ""
}

main "$@"
