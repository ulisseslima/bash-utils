#!/usr/bin/env bash
# Mount an FTP server as a drive using curlftpfs
# Features:
# - Checks for required tools and offers to install them
# - First-run wizard to create named connection configs (~/.config/mount-ftp/)
# - Commands: wizard, list, mount <name>, unmount <name>, remove <name>

set -euo pipefail

CONF_DIR="$HOME/.config/mount-ftp"
mkdir -p "$CONF_DIR"

print_help() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  wizard            Run interactive setup to add a new FTP connection
  list              List saved connections
  mount <name>      Mount connection named <name>
  unmount <name>    Unmount connection named <name>
  remove <name>     Remove saved connection <name>
  help              Show this help

Examples:
  $(basename "$0") wizard
  $(basename "$0") mount work-ftp
  $(basename "$0") unmount work-ftp

Note: This uses `curlftpfs` (FUSE). Passwords are stored in plain files under
`$CONF_DIR` with restrictive permissions (600). Consider using system credential
stores or mounting via other secure methods for production use.
EOF
}

detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then echo apt-get
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  elif command -v yum >/dev/null 2>&1; then echo yum
  elif command -v pacman >/dev/null 2>&1; then echo pacman
  elif command -v zypper >/dev/null 2>&1; then echo zypper
  else echo unknown
  fi
}

ensure_deps() {
  local missing=()
  for cmd in curlftpfs fusermount mountpoint; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -eq 0 ]; then
    return 0
  fi

  echo "Missing dependencies: ${missing[*]}"
  local mgr
  mgr=$(detect_pkg_mgr)
  echo "Package manager: $mgr"
  echo "I can attempt to install the missing packages. Proceed? [y/N]"
  read -r ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    case "$mgr" in
      apt-get)
        sudo apt-get update && sudo apt-get install -y curlftpfs fuse
        ;;
      dnf)
        sudo dnf install -y curlftpfs fuse
        ;;
      yum)
        sudo yum install -y curlftpfs fuse
        ;;
      pacman)
        sudo pacman -Sy --noconfirm curlftpfs fuse3
        ;;
      zypper)
        sudo zypper install -y curlftpfs fuse
        ;;
      *)
        echo "Unknown package manager. Please install: ${missing[*]}"
        return 1
        ;;
    esac
  else
    echo "Install dependencies and re-run the script."
    return 1
  fi
}

sanitise_name() {
  # lower-case, replace spaces with -, remove problematic chars
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g'
}

wizard() {
  echo "Creating a new FTP connection profile"
  read -r -p "Profile name (short, e.g. work-ftp): " name_raw
  if [ -z "$name_raw" ]; then echo "Name required"; return 1; fi
  name=$(sanitise_name "$name_raw")
  cfg="$CONF_DIR/$name.conf"
  if [ -e "$cfg" ]; then
    echo "Profile '$name' already exists. Use a different name or remove it first."; return 1
  fi

  read -r -p "FTP host (e.g. ftp.example.com): " host
  read -r -p "Port [21]: " port
  port=${port:-21}
  read -r -p "Username: " user
  read -s -r -p "Password: " pass
  echo
  read -r -p "Mount point [$HOME/mnt/$name]: " mnt
  mnt=${mnt:-$HOME/mnt/$name}
  read -r -p "Use passive FTP? [Y/n]: " passive
  if [[ -z "$passive" || "$passive" =~ ^[Yy]$ ]]; then
    passive_opt=1
  else
    passive_opt=0
  fi

  mkdir -p "$(dirname "$mnt")"
  mkdir -p "$CONF_DIR"

  cat > "$cfg" <<EOF
HOST="$host"
PORT="$port"
USER="$user"
PASS="$pass"
MOUNTPOINT="$mnt"
PASSIVE="$passive_opt"
EOF
  chmod 600 "$cfg"
  echo "Profile '$name' saved to $cfg"
  echo "To mount: $(basename "$0") mount $name"
}

list_profiles() {
  echo "Saved profiles in $CONF_DIR:"
  local any=0
  for f in "$CONF_DIR"/*.conf; do
    [ -e "$f" ] || continue
    any=1
    nm=$(basename "$f" .conf)
    source "$f"
    printf "- %s -> %s@%s:%s mounted at %s\n" "$nm" "${USER:-}" "${HOST:-}" "${PORT:-}" "${MOUNTPOINT:-}"
  done
  [ $any -eq 1 ] || echo "(none)"
}

mount_profile() {
  local name=$1
  local cfg="$CONF_DIR/$name.conf"
  if [ ! -f "$cfg" ]; then echo "Profile not found: $name"; return 1; fi
  # shellcheck source=/dev/null
  source "$cfg"

  if [ -z "${HOST:-}" ] || [ -z "${MOUNTPOINT:-}" ]; then
    echo "Corrupt profile: missing HOST or MOUNTPOINT"; return 1
  fi

  if mountpoint -q "$MOUNTPOINT"; then
    echo "Already mounted: $MOUNTPOINT"; return 0
  fi

  mkdir -p "$MOUNTPOINT"

  local userinfo
  if [ -n "${USER:-}" ] && [ -n "${PASS:-}" ]; then
    # Escape @ in password and username minimally
    esc_user=$(printf '%s' "$USER" | sed -e 's/@/%40/g')
    esc_pass=$(printf '%s' "$PASS" | sed -e 's/@/%40/g')
    userinfo="${esc_user}:${esc_pass}@"
  elif [ -n "${USER:-}" ]; then
    userinfo="${USER}@"
  else
    userinfo=""
  fi

  local passive_arg=""
  if [ "${PASSIVE:-0}" -eq 1 ]; then
    passive_arg=--ftp-passive
  fi

  local url="ftp://${userinfo}${HOST}:${PORT}"

  echo "Mounting $url -> $MOUNTPOINT"
  # Use curlftpfs; allow_other may require user in fuse group or /etc/fuse.conf adjustment
  if curlftpfs -o allow_other $passive_arg "$url" "$MOUNTPOINT"; then
    echo "Mounted $name at $MOUNTPOINT"
  else
    echo "Mount failed. Check credentials, network, and that you are allowed to use FUSE."; return 1
  fi
}

unmount_profile() {
  local name=$1
  local cfg="$CONF_DIR/$name.conf"
  if [ ! -f "$cfg" ]; then echo "Profile not found: $name"; return 1; fi
  # shellcheck source=/dev/null
  source "$cfg"
  if [ -z "${MOUNTPOINT:-}" ]; then echo "Corrupt profile: missing MOUNTPOINT"; return 1; fi

  if mountpoint -q "$MOUNTPOINT"; then
    echo "Unmounting $MOUNTPOINT"
    if fusermount -u "$MOUNTPOINT" 2>/dev/null || umount "$MOUNTPOINT" 2>/dev/null; then
      echo "Unmounted $MOUNTPOINT"
    else
      echo "Failed to unmount $MOUNTPOINT"
      return 1
    fi
  else
    echo "Not mounted: $MOUNTPOINT"
  fi
}

remove_profile() {
  local name=$1
  local cfg="$CONF_DIR/$name.conf"
  if [ ! -f "$cfg" ]; then echo "Profile not found: $name"; return 1; fi
  # try unmount if mounted
  # shellcheck source=/dev/null
  source "$cfg"
  if [ -n "${MOUNTPOINT:-}" ] && mountpoint -q "$MOUNTPOINT"; then
    echo "Profile is mounted. Unmount first or answer y to unmount now. Unmount? [y/N]"
    read -r ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      unmount_profile "$name" || return 1
    else
      echo "Not removing while mounted."; return 1
    fi
  fi
  rm -f "$cfg"
  echo "Removed profile $name"
}

main() {
  if [ $# -lt 1 ]; then print_help; exit 1; fi

  cmd=$1; shift || true
  case "$cmd" in
    help|-h|--help)
      print_help
      ;;
    wizard)
      ensure_deps || exit 1
      wizard
      ;;
    list)
      list_profiles
      ;;
    mount)
      ensure_deps || exit 1
      if [ $# -lt 1 ]; then echo "mount requires profile name"; exit 1; fi
      mount_profile "$1"
      ;;
    unmount)
      if [ $# -lt 1 ]; then echo "unmount requires profile name"; exit 1; fi
      unmount_profile "$1"
      ;;
    remove)
      if [ $# -lt 1 ]; then echo "remove requires profile name"; exit 1; fi
      remove_profile "$1"
      ;;
    *)
      echo "Unknown command: $cmd"; print_help; exit 1
      ;;
  esac
}

main "$@"
