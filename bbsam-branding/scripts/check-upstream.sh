#!/bin/bash
# =============================================================================
# BBSaM-Messenger Upstream Checker
# =============================================================================
# Prüft auf neue Upstream-Releases und generiert einen Merge-Report
#
# Verwendung:
#   ./check-upstream.sh [platform]
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

# Upstream Repositories
declare -A UPSTREAM_REPOS=(
    ["web"]="element-hq/element-web"
    ["desktop"]="element-hq/element-desktop"
    ["android"]="element-hq/element-x-android"
    ["ios"]="element-hq/element-x-ios"
)

# Fork Repositories
declare -A FORK_REPOS=(
    ["web"]="bbsam/bbsam-messenger-web"
    ["desktop"]="bbsam/bbsam-messenger-desktop"
    ["android"]="bbsam/bbsam-messenger-android"
    ["ios"]="bbsam/bbsam-messenger-ios"
)

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

log_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Holt die neueste Release-Version von GitHub
get_latest_release() {
    local repo=$1
    curl -s "https://api.github.com/repos/$repo/releases/latest" | \
        jq -r '.tag_name // empty' 2>/dev/null || echo "unknown"
}

# Holt alle Releases der letzten 30 Tage
get_recent_releases() {
    local repo=$1
    local since=$(date -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
                  date -v-30d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)

    curl -s "https://api.github.com/repos/$repo/releases?per_page=10" | \
        jq -r '.[] | "\(.tag_name) (\(.published_at | split("T")[0]))"' 2>/dev/null || echo "error"
}

# Holt Commit-Anzahl zwischen zwei Tags
get_commit_count() {
    local repo=$1
    local from_tag=$2
    local to_tag=$3

    curl -s "https://api.github.com/repos/$repo/compare/$from_tag...$to_tag" | \
        jq -r '.total_commits // 0' 2>/dev/null || echo "0"
}

# =============================================================================
# Plattform-Check
# =============================================================================

check_platform() {
    local platform=$1
    local upstream_repo="${UPSTREAM_REPOS[$platform]}"
    local fork_repo="${FORK_REPOS[$platform]}"

    log_header "$platform"
    echo ""

    log_info "Upstream: $upstream_repo"
    log_info "Fork: $fork_repo"
    echo ""

    # Neueste Upstream-Version
    local upstream_version=$(get_latest_release "$upstream_repo")
    echo -e "  Upstream Version:  ${GREEN}$upstream_version${NC}"

    # Fork-Version (falls verfügbar)
    local fork_version=$(get_latest_release "$fork_repo")
    if [ "$fork_version" != "unknown" ] && [ -n "$fork_version" ]; then
        echo -e "  Fork Version:      ${YELLOW}$fork_version${NC}"
    else
        echo -e "  Fork Version:      ${YELLOW}(noch kein Release)${NC}"
    fi

    echo ""

    # Letzte Releases
    log_info "Letzte Upstream-Releases (30 Tage):"
    get_recent_releases "$upstream_repo" | while read -r release; do
        echo "    - $release"
    done

    echo ""

    # Changelog-Link
    log_info "Changelog: https://github.com/$upstream_repo/releases"

    echo ""
}

# =============================================================================
# Merge-Report generieren
# =============================================================================

generate_report() {
    local report_file="upstream-report-$(date +%Y%m%d).md"

    log_info "Generiere Report: $report_file"

    cat > "$report_file" << EOF
# BBSaM-Messenger Upstream-Report

Generiert am: $(date '+%Y-%m-%d %H:%M:%S')

## Zusammenfassung

| Plattform | Upstream | Fork | Status |
|-----------|----------|------|--------|
EOF

    for platform in web desktop android ios; do
        local upstream_repo="${UPSTREAM_REPOS[$platform]}"
        local fork_repo="${FORK_REPOS[$platform]}"
        local upstream_version=$(get_latest_release "$upstream_repo")
        local fork_version=$(get_latest_release "$fork_repo")

        local status="---"
        if [ "$fork_version" = "unknown" ] || [ -z "$fork_version" ]; then
            status="Kein Release"
        elif [ "$upstream_version" = "$fork_version" ]; then
            status="Aktuell"
        else
            status="Update verfügbar"
        fi

        echo "| $platform | $upstream_version | ${fork_version:-n/a} | $status |" >> "$report_file"
    done

    cat >> "$report_file" << EOF

## Details

EOF

    for platform in web desktop android ios; do
        local upstream_repo="${UPSTREAM_REPOS[$platform]}"

        cat >> "$report_file" << EOF
### $platform

**Repository:** https://github.com/$upstream_repo

**Letzte Releases:**
$(get_recent_releases "$upstream_repo" | sed 's/^/- /')

---

EOF
    done

    cat >> "$report_file" << EOF
## Empfohlene Aktionen

1. Prüfen Sie die Changelogs auf Breaking Changes
2. Führen Sie Upstream-Merges nacheinander durch
3. Testen Sie nach jedem Merge
4. Aktualisieren Sie die Branding-Anpassungen falls nötig

## Links

- [Element Web Releases](https://github.com/element-hq/element-web/releases)
- [Element Desktop Releases](https://github.com/element-hq/element-desktop/releases)
- [Element X Android Releases](https://github.com/element-hq/element-x-android/releases)
- [Element X iOS Releases](https://github.com/element-hq/element-x-ios/releases)
EOF

    log_success "Report erstellt: $report_file"
}

# =============================================================================
# Hauptprogramm
# =============================================================================

main() {
    echo ""
    echo "=============================================="
    echo "  BBSaM-Messenger Upstream Checker"
    echo "=============================================="
    echo ""

    local platform="${1:-}"

    if [ -n "$platform" ] && [ "$platform" != "all" ] && [ "$platform" != "report" ]; then
        if [ -z "${UPSTREAM_REPOS[$platform]}" ]; then
            log_error "Unbekannte Plattform: $platform"
            exit 1
        fi
        check_platform "$platform"
    elif [ "$platform" = "report" ]; then
        generate_report
    else
        # Alle Plattformen prüfen
        for p in web desktop android ios; do
            check_platform "$p"
        done

        echo ""
        log_info "Report generieren mit: $0 report"
    fi

    echo ""
}

main "$@"
