#!/usr/bin/env bash
# pg-install.sh
# Installs a specific PostgreSQL MAJOR version using official repositories.
#
# Usage:
#   ./pg-install.sh <version>
# Examples:
#   ./pg-install.sh 15
#   ./pg-install.sh 14
#
# Notes:
# - Supports: Ubuntu/Debian, RHEL/CentOS/Rocky/Alma, Fedora, Amazon Linux (via PGDG), macOS (Homebrew).
# - Requires root or sudo privileges for system-level installs.
# - On Debian/Ubuntu, the cluster is auto-initialized. On RHEL/Fedora family, the script initializes and starts the service.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <postgres_major_version>"
  exit 1
fi

INPUT_VERSION="$1"
PG_MAJOR="${INPUT_VERSION%%.*}"

if ! [[ "$PG_MAJOR" =~ ^[0-9]+$ ]]; then
  echo "Error: version must be a number like 15 or 14 (major version). Got: $INPUT_VERSION"
  exit 1
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "This script needs root privileges. Please run as root or install sudo."
    exit 1
  fi
fi

OS_ID=""
OS_VER_ID=""
OS_LIKE=""
if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  OS_ID="${ID:-}"
  OS_VER_ID="${VERSION_ID:-}"
  OS_LIKE="${ID_LIKE:-}"
fi

uname_s="$(uname -s || true)"

info() { echo "[-] $*"; }
ok()   { echo "[+] $*"; }
warn() { echo "[!] $*"; }

install_debian() {
  info "Installing PostgreSQL $PG_MAJOR on Debian/Ubuntu (PGDG repo)"
  $SUDO apt-get update -y
  $SUDO apt-get install -y curl ca-certificates gnupg lsb-release
  $SUDO mkdir -p /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/postgresql.gpg ]]; then
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg
  fi
  CODENAME=""
  if [[ -n "${VERSION_CODENAME:-}" ]]; then
    CODENAME="$VERSION_CODENAME"
  else
    CODENAME="$(lsb_release -cs 2>/dev/null || true)"
  fi
  if [[ -z "$CODENAME" ]]; then
    echo "Could not determine distro codename."
    exit 1
  fi
  echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt ${CODENAME}-pgdg main" | $SUDO tee /etc/apt/sources.list.d/pgdg.list >/dev/null
  $SUDO apt-get update -y
  $SUDO apt-get install -y "postgresql-$PG_MAJOR" "postgresql-client-$PG_MAJOR"
  ok "PostgreSQL $PG_MAJOR installed."
  if command -v systemctl >/dev/null 2>&1; then
    $SUDO systemctl enable --now postgresql || true
  fi
}

install_rhel_family() {
  # Works for RHEL/CentOS/Rocky/Alma, Amazon Linux (via rhel macro), and Fedora (handled separately)
  pkgcmd=""
  if command -v dnf >/dev/null 2>&1; then
    pkgcmd="dnf"
  elif command -v yum >/dev/null 2>&1; then
    pkgcmd="yum"
  else
    echo "Neither dnf nor yum found."
    exit 1
  fi

  if [[ "$OS_ID" == "fedora" ]] || [[ "$OS_LIKE" == *"fedora"* && "$OS_ID" != "amzn" ]]; then
    info "Installing PGDG repo for Fedora"
    FEDVER="$(rpm -E %fedora)"
    ARCH="$(uname -m)"
    $SUDO "$pkgcmd" -y install "https://download.postgresql.org/pub/repos/yum/reporpms/F-${FEDVER}-${ARCH}/pgdg-fedora-repo-latest.noarch.rpm"
    $SUDO dnf -qy module disable postgresql || true
  else
    info "Installing PGDG repo for RHEL-compatible"
    RHELVER="$(rpm -E %rhel)"
    ARCH="$(uname -m)"
    $SUDO "$pkgcmd" -y install "https://download.postgresql.org/pub/repos/yum/reporpms/EL-${RHELVER}-${ARCH}/pgdg-redhat-repo-latest.noarch.rpm"
    # On EL8/9, disable the default module stream
    if command -v dnf >/dev/null 2>&1; then
      $SUDO dnf -qy module disable postgresql || true
    fi
  fi

  $SUDO "$pkgcmd" -y makecache
  $SUDO "$pkgcmd" -y install "postgresql${PG_MAJOR}-server" "postgresql${PG_MAJOR}"
  ok "PostgreSQL $PG_MAJOR packages installed."

  # Initialize and start
  if [[ -x "/usr/pgsql-${PG_MAJOR}/bin/postgresql-${PG_MAJOR}-setup" ]]; then
    $SUDO "/usr/pgsql-${PG_MAJOR}/bin/postgresql-${PG_MAJOR}-setup" initdb || true
    $SUDO systemctl enable --now "postgresql-${PG_MAJOR}"
  else
    # Fallback (rare)
    if command -v postgresql-setup >/dev/null 2>&1; then
      $SUDO postgresql-setup --initdb
      $SUDO systemctl enable --now postgresql
    fi
  fi
  ok "PostgreSQL $PG_MAJOR service started."
}

install_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required on macOS: https://brew.sh"
    exit 1
  fi
  info "Installing PostgreSQL $PG_MAJOR via Homebrew"
  brew update
  brew install "postgresql@${PG_MAJOR}"
  # Start service
  brew services start "postgresql@${PG_MAJOR}" || true
  ok "PostgreSQL $PG_MAJOR installed."
  echo
  echo "Note:"
  echo "  Homebrew keeps versioned PostgreSQL keg-only. Add to your PATH if needed:"
  if [[ -d "/opt/homebrew/opt/postgresql@${PG_MAJOR}/bin" ]]; then
    echo "    export PATH=\"/opt/homebrew/opt/postgresql@${PG_MAJOR}/bin:\$PATH\""
  else
    echo "    export PATH=\"/usr/local/opt/postgresql@${PG_MAJOR}/bin:\$PATH\""
  fi
}

case "$uname_s" in
  Darwin)
    install_macos
    ;;
  Linux)
    # Normalize ID
    case "$OS_ID" in
      ubuntu|debian)
        install_debian
        ;;
      rhel|centos|rocky|almalinux|ol|fedora|amzn)
        install_rhel_family
        ;;
      *)
        # Try ID_LIKE hints
        if [[ "$OS_LIKE" == *"debian"* ]]; then
          install_debian
        elif [[ "$OS_LIKE" == *"rhel"* ]] || [[ "$OS_LIKE" == *"fedora"* ]]; then
          install_rhel_family
        else
          echo "Unsupported or unrecognized Linux distribution: ID=${OS_ID}, ID_LIKE=${OS_LIKE}"
          exit 1
        fi
        ;;
    esac
    ;;
  *)
    echo "Unsupported OS: $uname_s"
    exit 1
    ;;
esac

# Verification
if command -v psql >/dev/null 2>&1; then
  echo
  ok "psql version: $(psql --version)"
fi

echo
ok "PostgreSQL $PG_MAJOR installation complete."
