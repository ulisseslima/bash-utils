#!/usr/bin/env bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

set -euo pipefail

# Install a specific version of PostgreSQL via Docker on Ubuntu.
# - Ensures Docker is installed and running
# - Pulls the requested postgres:<version> image
# - Creates a named volume or uses a host directory for data
# - Runs a container with sensible defaults
#
# Usage:
#   sudo bash pg-docker-install.sh -v <version> [-p <host_port>] [-n <name>] [-U <user>] [-P <password>] [-d <host_data_dir> | -V <volume_name>] [--pull-only]
# Examples:
#   sudo bash pg-docker-install.sh -v 14.10
#   sudo bash pg-docker-install.sh -v 16 -p 5416 -n pg16 -P banana -V pgdata16

###############################################################################

PG_VERSION=""
DRY_RUN="false"
PORT=5432
NAME="postgres"
PGUSER="postgres"
PGPASSWORD="${POSTGRES_PASSWORD:-}"
HOST_DATA_DIR=""
VOLUME_NAME=""
RESTART_POLICY="unless-stopped"
PULL_ONLY="false"

usage() {
  cat <<EOF
Usage: $0 -v <postgres_version> [options]

Required:
  -v, --version <ver>     Postgres image tag (e.g., 16, 16-alpine, 14.10)

Options:
  -p, --port <port>       Host port to map to 5432 (default: 5432)
  -n, --name <name>       Container name (default: postgres)
  -U, --user <user>       Postgres user (default: postgres)
  -P, --password <pass>   Postgres password (default: auto-generate if omitted)
  -d, --data-dir <path>   Host directory for data (will chown to 999:999)
  -V, --volume <name>     Docker named volume for data (default: pgdata_<name>)
  -r, --restart <policy>  Restart policy (default: unless-stopped)
      --pull-only         Only pull the image; do not run container
    --dry-run            Show the Docker commands that would be executed and exit
  -h, --help              Show this help

Examples:
  $0 -v 16
  $0 -v 14.10 -p 5433 -n pg14 -P secret -V pgdata14
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
  -v|--version) PG_VERSION="${2:-}"; shift 2 ;;
    -p|--port) PORT="${2:-}"; shift 2 ;;
    -n|--name) NAME="${2:-}"; shift 2 ;;
    -U|--user) PGUSER="${2:-}"; shift 2 ;;
    -P|--password) PGPASSWORD="${2:-}"; shift 2 ;;
    -d|--data-dir) HOST_DATA_DIR="${2:-}"; shift 2 ;;
    -V|--volume) VOLUME_NAME="${2:-}"; shift 2 ;;
    -r|--restart) RESTART_POLICY="${2:-}"; shift 2 ;;
    --pull-only) PULL_ONLY="true"; shift ;;
    --dry-run) DRY_RUN="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$PG_VERSION" ]]; then
  echo "Error: --version is required"
  usage
  exit 1
fi

# Ensure we're on Ubuntu (warn if not)
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "Warning: This script targets Ubuntu. Detected: ${PRETTY_NAME:-unknown}."
  fi
fi

# Ensure sudo privileges upfront if needed
if [[ $EUID -ne 0 ]]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required to install packages and manage services. Please run as root or install sudo."
    exit 1
  fi
  sudo -v || { echo "sudo authentication failed."; exit 1; }
fi
SUDO=''
if [[ $EUID -ne 0 ]]; then SUDO='sudo'; fi

# Install Docker if missing
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Installing docker.io from Ubuntu repositories..."
  $SUDO apt-get update -y
  $SUDO apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https docker.io
  $SUDO systemctl enable --now docker
fi

# Determine docker command (with/without sudo)
DOCKER_CMD="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER_CMD="$SUDO docker"
fi

# Ensure Docker daemon is running
if ! $SUDO systemctl is-active --quiet docker; then
  echo "Starting Docker service..."
  $SUDO systemctl start docker
fi

IMAGE="postgres:${PG_VERSION}"
echo "Prepared image: ${IMAGE}"

# If dry-run, we will skip actual docker pull now and show commands later.
if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry-run: will NOT pull or run any Docker commands."
else
  echo "Pulling image: ${IMAGE} ..."
  if ! $DOCKER_CMD pull "$IMAGE"; then
    echo "Failed to pull image ${IMAGE}. Check that the version/tag exists."
    exit 1
  fi
fi

if [[ "$PULL_ONLY" == "true" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry-run: would have pulled image: ${IMAGE} (exiting because --pull-only)."
    exit 0
  fi
  echo "Image ${IMAGE} pulled successfully. Exiting (--pull-only)."
  exit 0
fi

# Generate password if not provided
if [[ -z "${PGPASSWORD}" ]]; then
  if command -v openssl >/dev/null 2>&1; then
    PGPASSWORD="$(openssl rand -base64 24 | tr -d '=+/ ' | cut -c1-24)"
  else
    PGPASSWORD="$(head -c 32 /dev/urandom | base64 | tr -d '=+/ \n' | cut -c1-24)"
  fi
  GENERATED_PASS="true"
else
  GENERATED_PASS="false"
fi

# Prepare data storage
MOUNT_ARG=""
if [[ -n "$HOST_DATA_DIR" && -n "$VOLUME_NAME" ]]; then
  echo "Please specify either --data-dir or --volume, not both."
  exit 1
fi

if [[ -n "$HOST_DATA_DIR" ]]; then
  echo "Using host data directory: $HOST_DATA_DIR"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry-run: would create host data directory: $HOST_DATA_DIR"
    echo "Dry-run: would set ownership to 999:999 and chmod 700 on $HOST_DATA_DIR"
  else
    $SUDO mkdir -p "$HOST_DATA_DIR"
    # Set ownership to postgres UID/GID used in the official image (999)
    $SUDO chown -R 999:999 "$HOST_DATA_DIR"
    $SUDO chmod 700 "$HOST_DATA_DIR" || true
  fi
  MOUNT_ARG="-v ${HOST_DATA_DIR}:/var/lib/postgresql/data"
else
  if [[ -z "$VOLUME_NAME" ]]; then
    VOLUME_NAME="pgdata_${NAME}"
  fi
  echo "Using Docker named volume: $VOLUME_NAME"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry-run: would create Docker volume: $VOLUME_NAME"
  else
    $DOCKER_CMD volume create "$VOLUME_NAME" >/dev/null
  fi
  MOUNT_ARG="-v ${VOLUME_NAME}:/var/lib/postgresql/data"
fi

# If container exists, handle accordingly
if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry-run: skipping existing container checks. Will only show the commands that would be executed."
else
  if $DOCKER_CMD ps -a --format '{{.Names}}' | grep -wq "$NAME"; then
    echo "Container '$NAME' already exists."
    if $DOCKER_CMD ps --format '{{.Names}}' | grep -wq "$NAME"; then
      echo "Container '$NAME' is already running. Nothing to do."
      echo "Connection: postgresql://${PGUSER}:<password>@localhost:${PORT}/postgres"
      exit 0
    else
      echo "Starting existing container '$NAME'..."
      $DOCKER_CMD start "$NAME"
      echo "Started."
      echo "Connection: postgresql://${PGUSER}:<password>@localhost:${PORT}/postgres"
      exit 0
    fi
  fi
fi

# Run the container
echo "Creating and starting container '$NAME'..."
RUN_CMD="$DOCKER_CMD run -d \\\n+  --name \"$NAME\" \\\n+  --restart \"$RESTART_POLICY\" \\\n+  -e POSTGRES_USER=\"$PGUSER\" \\\n+  -e POSTGRES_PASSWORD=\"$PGPASSWORD\" \\\n+  -p \"${PORT}:5432\" \\\n+  $MOUNT_ARG \\\n+  \"$IMAGE\""

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry-run: would run the following Docker commands:"
  echo
  echo "  # pull image"
  echo "  $DOCKER_CMD pull $IMAGE"
  echo
  echo "  # run container"
  # print the run command in a way that's easy to copy/paste
  # remove the escaping for display
  echo
  echo "  ${RUN_CMD//\\/}"
  echo
  echo "Dry-run complete. No changes made."
  exit 0
fi

eval "$RUN_CMD"

# Basic readiness wait (optional best-effort)
echo "Waiting for PostgreSQL to accept connections (up to ~30s)..."
for i in {1..30}; do
  if $DOCKER_CMD logs "$NAME" 2>&1 | grep -q "database system is ready to accept connections"; then
    break
  fi
  sleep 1
done

echo "PostgreSQL ${PG_VERSION} is running in container '$NAME'."
echo "Host port: ${PORT}"
if [[ -n "$HOST_DATA_DIR" ]]; then
  echo "Data directory: ${HOST_DATA_DIR}"
else
  echo "Data volume: ${VOLUME_NAME}"
fi
echo "User: ${PGUSER}"
if [[ "$GENERATED_PASS" == "true" ]]; then
  echo "Generated password: ${PGPASSWORD}"
else
  echo "Password: [hidden] (provided)"
fi
echo "Connection string:"
echo "  postgresql://${PGUSER}:${PGPASSWORD}@localhost:${PORT}/postgres"
echo "To view logs: $DOCKER_CMD logs -f $NAME"
echo "To exec into the container: $DOCKER_CMD exec -it $NAME psql -U $PGUSER"
