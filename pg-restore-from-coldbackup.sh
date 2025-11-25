#!/usr/bin/env bash
# Restore every database from a cold PostgreSQL data directory (PGDATA)
# Usage: pg-restore-from-coldbackup.sh [--backup /path/to/pgdata] [--target-host HOST] [--target-port PORT] [--target-user USER] [--roles] [--dry-run] [--yes]
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

set -euo pipefail

DEFAULT_BACKUP="/mnt/evo-870/bk/var/lib/postgresql/16/main"
TARGET_HOST="localhost"
TARGET_PORT=5432
TARGET_USER="$USER"
RESTORE_ROLES=false
DRY_RUN=false
ASSUME_YES=false

show_help() {
  cat <<EOF
Usage: $0 [options]

Options:
  --backup PATH        Path to the cold backup PGDATA (default: $DEFAULT_BACKUP)
  --target-host HOST   Target PostgreSQL host (default: $TARGET_HOST)
  --target-port PORT   Target PostgreSQL port (default: $TARGET_PORT)
  --target-user USER   Target PostgreSQL user (default: current user)
  --roles              Also restore roles (uses pg_dumpall --roles-only)
  --dry-run            Show what would be done, don't modify target
  --yes                Don't prompt for confirmation
  -h, --help           Show this help

This script starts the cold data directory as a temporary PostgreSQL instance
on an ephemeral port, dumps each non-template database and restores it into
the target server.

Assumptions/requirements:
 - You have PostgreSQL client binaries (psql, pg_dump, pg_restore, pg_ctl) in PATH.
 - You can run postgres from the cold data directory, typically via sudo -u postgres.
 - Target server is reachable with provided host/port and credentials (PG environment or .pgpass).
 - This script will try to create/drop databases on the target; use with care.

EOF
}

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2; }
err() { log "ERROR: $*"; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --backup) DEFAULT_BACKUP="$2"; shift 2;;
    --target-host) TARGET_HOST="$2"; shift 2;;
    --target-port) TARGET_PORT="$2"; shift 2;;
    --target-user) TARGET_USER="$2"; shift 2;;
    --roles) RESTORE_ROLES=true; shift;;
    --dry-run) DRY_RUN=true; shift;;
    --yes) ASSUME_YES=true; shift;;
    -h|--help) show_help; exit 0;;
    *) echo "Unknown arg: $1"; show_help; exit 2;;
  esac
done

BACKUP_DIR="$DEFAULT_BACKUP"

find_cmd() {
  # Find a postgres-related binary, trying plain name, versioned name and common install dirs
  local name="$1"
  # first try normal PATH
  if cmd=$(command -v "$name" 2>/dev/null); then
    printf '%s' "$cmd"
    return 0
  fi

  # try versioned name based on PG_VERSION in backup dir
  if [[ -f "$BACKUP_DIR/PG_VERSION" ]]; then
    local ver
    ver=$(cut -d. -f1 "$BACKUP_DIR/PG_VERSION" 2>/dev/null || true)
    if [[ -n "$ver" ]] && cmd=$(command -v "${name}-${ver}" 2>/dev/null); then
      printf '%s' "$cmd"
      return 0
    fi
  fi

  # try common installation locations
  for d in /usr/lib/postgresql/*/bin /usr/pgsql-*/*/bin /usr/local/pgsql/bin /opt/postgres/*/bin /opt/*/bin; do
    if [[ -d $d ]]; then
      if [[ -x "$d/$name" ]]; then
        printf '%s' "$d/$name"
        return 0
      fi
      # also try name-version if we read a ver
      if [[ -n "${ver:-}" ]] && [[ -x "$d/${name}-${ver}" ]]; then
        printf '%s' "$d/${name}-${ver}"
        return 0
      fi
    fi
  done

  return 1
}

PSQL=$(find_cmd psql) || err "psql not found in PATH; try installing postgresql-client or add /usr/lib/postgresql/<version>/bin to your PATH"
PG_DUMP=$(find_cmd pg_dump) || err "pg_dump not found in PATH"
PG_RESTORE=$(find_cmd pg_restore) || err "pg_restore not found in PATH"
PG_CTL=$(find_cmd pg_ctl) || err "pg_ctl not found in PATH; on Debian/Ubuntu install postgresql-<version>-server or postgresql-client, or add the PG binary dir to PATH"
PG_DUMPALL=$(find_cmd pg_dumpall) || true
DROPDB=$(find_cmd dropdb) || true
CREATEDB=$(find_cmd createdb) || true
PG_CTLCLUSTER=$(command -v pg_ctlcluster 2>/dev/null || true)
USE_PG_CTLCLUSTER=false
CLUSTER_VER=""
CLUSTER_NAME=""

# If pg_ctl is not available but pg_ctlcluster is, check if the backup path looks like
# a system cluster under /var/lib/postgresql/<version>/<cluster>. In that case we can
# start/stop the cluster using pg_ctlcluster <version> <cluster> start|stop.
if [[ -z "$PG_CTL" && -n "$PG_CTLCLUSTER" ]]; then
  if [[ "$BACKUP_DIR" =~ ^/var/lib/postgresql/([0-9]+)/(.*) ]]; then
    CLUSTER_VER="${BASH_REMATCH[1]}"
    CLUSTER_NAME="${BASH_REMATCH[2]}"
    USE_PG_CTLCLUSTER=true
  fi
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
  err "Backup directory '$BACKUP_DIR' does not exist"
fi

if [[ ! -f "$BACKUP_DIR/PG_VERSION" ]]; then
  err "'$BACKUP_DIR' does not look like a PostgreSQL data directory (missing PG_VERSION)"
fi

log "Using backup dir: $BACKUP_DIR"

# Check if we need sudo for starting postgres
NEED_SUDO=false
if [[ ! -O "$BACKUP_DIR" ]] || [[ ! -w "$BACKUP_DIR" ]]; then
  NEED_SUDO=true
  log "Backup dir not owned by current user; will require sudo -u postgres"
fi

# If we need sudo, verify it's available without password
if $NEED_SUDO; then
  if ! sudo -n true 2>/dev/null; then
    err "This script needs to run pg_ctl as the postgres user, but passwordless sudo is not available.
You can either:
1. Run this entire script with: sudo -u postgres $0 $*
2. Configure passwordless sudo for your user by adding to /etc/sudoers.d/ (use visudo):
   $USER ALL=(postgres) NOPASSWD: $(command -v pg_ctl || echo /usr/lib/postgresql/*/bin/pg_ctl)
3. Change ownership of the backup to your user (may break system cluster usage):
   sudo chown -R $USER:$USER '$BACKUP_DIR'"
  fi
  log "Passwordless sudo available; will use sudo -u postgres for pg_ctl operations"
fi

TMPROOT="$(mktemp -d /tmp/pg-restore-XXXX)"
SOCKET_DIR="$TMPROOT/socket"
LOGFILE="$TMPROOT/postgres.log"
DUMPDIR="$TMPROOT/dumps"

# Create directories with appropriate ownership
if $NEED_SUDO; then
  # When running as sudo, ensure socket dir is writable by postgres
  sudo mkdir -p "$SOCKET_DIR"
  sudo chown postgres:postgres "$SOCKET_DIR"
  sudo mkdir -p "$DUMPDIR"
  sudo chown postgres:postgres "$DUMPDIR"
else
  mkdir -p "$SOCKET_DIR"
  mkdir -p "$DUMPDIR"
fi

find_free_port() {
  local port=${1:-55432}
  while ss -ltn "sport = :$port" 2>/dev/null | grep -q LISTEN; do
    ((port++)) || true
  done
  echo "$port"
}

PORT="$(find_free_port 55432)"
log "Chosen ephemeral port: $PORT"

confirm_or_exit() {
  if $ASSUME_YES; then return 0; fi
  printf "Proceed? [y/N]: " >&2
  read -r ans
  case "$ans" in
    y|Y|yes|YES) return 0;;
    *) err "Aborted by user";;
  esac
}

if $DRY_RUN; then
  log "DRY RUN: no changes will be made to target ($TARGET_HOST:$TARGET_PORT)"
fi

log "About to start temporary Postgres from '$BACKUP_DIR' on port $PORT (socket $SOCKET_DIR)"
if ! $DRY_RUN; then
  confirm_or_exit
else
  # DRY RUN: print planned commands and exit without starting any server
  log "DRY RUN mode: will NOT start temporary Postgres. Printing planned commands"
  if $USE_PG_CTLCLUSTER; then
    echo "Start command: pg_ctlcluster $CLUSTER_VER $CLUSTER_NAME start"
    echo "Stop command:  pg_ctlcluster $CLUSTER_VER $CLUSTER_NAME stop"
  else
    echo "Start command: $PG_CTL -D '$BACKUP_DIR' -o '-k $SOCKET_DIR -p $PORT' -l '$LOGFILE' -w start"
    echo "Stop command:  $PG_CTL -D '$BACKUP_DIR' -o '-k $SOCKET_DIR -p $PORT' -w stop"
  fi
  echo "Dump command template: sudo -u postgres $PG_DUMP -h '$SOCKET_DIR' -p '$PORT' -U postgres -Fc -f <dumpfile> <dbname>"
  echo "Restore command template: $PG_RESTORE -h '$TARGET_HOST' -p '$TARGET_PORT' -U '$TARGET_USER' -d <dbname> --no-owner <dumpfile>"
  echo "Note: to enumerate databases the script must start the temporary server; this DRY RUN will not do that."
  exit 0
fi

cleanup() {
  local rc=$?
  log "Cleaning up: stopping temporary server if running"
  if $USE_PG_CTLCLUSTER; then
    log "Stopping cluster $CLUSTER_VER/$CLUSTER_NAME via pg_ctlcluster"
    if $NEED_SUDO; then
      sudo -u postgres pg_ctlcluster "$CLUSTER_VER" "$CLUSTER_NAME" stop || true
    else
      pg_ctlcluster "$CLUSTER_VER" "$CLUSTER_NAME" stop || true
    fi
  else
    if $NEED_SUDO; then
      sudo -u postgres "$PG_CTL" -D "$BACKUP_DIR" -o "-k $SOCKET_DIR -p $PORT" -w stop || true
    else
      "$PG_CTL" -D "$BACKUP_DIR" -o "-k $SOCKET_DIR -p $PORT" -w stop || true
    fi
  fi
  log "Removing temporary files: $TMPROOT"
  if $NEED_SUDO; then
    sudo rm -rf "$TMPROOT" || rm -rf "$TMPROOT" || true
  else
    rm -rf "$TMPROOT"
  fi
  exit $rc
}
trap cleanup EXIT

# Start the postgres instance (use sudo -u postgres when needed)
start_temp_postgres() {
  log "Starting temporary postgres..."
  if $USE_PG_CTLCLUSTER; then
    log "Using pg_ctlcluster to start system cluster $CLUSTER_VER/$CLUSTER_NAME"
    log "Note: pg_ctlcluster will start the configured cluster; socket/port from script may be ignored"
    if $NEED_SUDO; then
      sudo -u postgres pg_ctlcluster "$CLUSTER_VER" "$CLUSTER_NAME" start
    else
      pg_ctlcluster "$CLUSTER_VER" "$CLUSTER_NAME" start
    fi
  else
    if [[ -z "$PG_CTL" ]]; then
      err "pg_ctl not available and pg_ctlcluster can't be used for this backup directory.\nInstall the PostgreSQL server packages or add the Postgres bin dir to PATH (e.g. /usr/lib/postgresql/<ver>/bin)."
    fi
    if $NEED_SUDO; then
      sudo -u postgres "$PG_CTL" -D "$BACKUP_DIR" -o "-k $SOCKET_DIR -p $PORT" -l "$LOGFILE" -w start
    else
      "$PG_CTL" -D "$BACKUP_DIR" -o "-k $SOCKET_DIR -p $PORT" -l "$LOGFILE" -w start
    fi
  fi
}

start_temp_postgres

PSQL_TMP=("$PSQL" -h "$SOCKET_DIR" -p "$PORT" -U postgres -At)

log "Checking temporary server is responsive"
if ! "${PSQL_TMP[@]}" -c 'select 1' >/dev/null 2>&1; then
  cat "$LOGFILE" >&2 || true
  err "Temporary postgres did not start or is not responsive"
fi

if $RESTORE_ROLES; then
  ROLES_SQL="$TMPROOT/roles.sql"
  log "Dumping roles from temporary server to $ROLES_SQL"
  if $DRY_RUN; then
    log "DRY RUN: would run pg_dumpall --roles-only against temporary server"
  else
    if [[ -n "$PG_DUMPALL" ]]; then
      if $NEED_SUDO; then
        sudo -u postgres "$PG_DUMPALL" -h "$SOCKET_DIR" -p "$PORT" --roles-only > "$ROLES_SQL"
      else
        "$PG_DUMPALL" -h "$SOCKET_DIR" -p "$PORT" --roles-only > "$ROLES_SQL"
      fi
    else
      err "pg_dumpall not found; cannot dump roles"
    fi
    log "Applying roles to target ($TARGET_HOST:$TARGET_PORT)"
    if $DRY_RUN; then
      log "DRY RUN: would apply $ROLES_SQL to target"
    else
      psql -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" -f "$ROLES_SQL"
    fi
  fi
fi

log "Listing databases in temporary server"
DBS=( $(${PSQL_TMP[@]} -c "SELECT datname FROM pg_database WHERE datallowconn AND NOT datistemplate") )

if [[ ${#DBS[@]} -eq 0 ]]; then
  log "No user databases found in backup"
  exit 0
fi

log "Databases found: ${DBS[*]}"

for db in "${DBS[@]}"; do
  dumpfile="$DUMPDIR/${db}.dump"
  log "Dumping database '$db' to $dumpfile"
  if $DRY_RUN; then
    log "DRY RUN: would run pg_dump for '$db'"
    continue
  fi
  if $NEED_SUDO; then
    sudo -u postgres "$PG_DUMP" -h "$SOCKET_DIR" -p "$PORT" -U postgres -Fc -f "$dumpfile" "$db"
  else
    "$PG_DUMP" -h "$SOCKET_DIR" -p "$PORT" -U postgres -Fc -f "$dumpfile" "$db"
  fi

  log "Restoring '$db' into target $TARGET_HOST:$TARGET_PORT"
  # Drop and recreate database on target, then restore
  if $DRY_RUN; then
    log "DRY RUN: would drop/create and restore '$db' on target"
  else
    # Attempt to determine owner from the dump using pg_restore --list
    owner=$("$PG_RESTORE" -l "$dumpfile" | awk 'NR==1{print $0; exit}' || true)
    # Drop database if exists
    if [[ -n "$DROPDB" ]]; then
      "$DROPDB" -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" --if-exists "$db" || true
    else
      psql -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" -c "DROP DATABASE IF EXISTS \"$db\"" || true
    fi
    if [[ -n "$CREATEDB" ]]; then
      "$CREATEDB" -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" "$db" || true
    else
      psql -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" -c "CREATE DATABASE \"$db\"" || true
    fi
    "$PG_RESTORE" -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" -d "$db" --no-owner "$dumpfile"
  fi
done

log "All databases processed. Temporary server will be stopped by cleanup."
