#!/usr/bin/env bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

set -euo pipefail

trap 'catch $? $LINENO' ERR
catch() {
  if [[ "$1" != "0" ]]; then
    error="$ME - returned $1 at line $2"
    >&2 echo "$error"
    notify-send "$error"
  fi
}

usage() {
    cat <<EOF
Usage: $0 [options] <minutes> [message]

Starts a timer for <minutes> and sends a GNOME notification when finished.

Positional arguments:
  minutes     number of minutes (integer or decimal, e.g. 1.5)
  message     optional message to show when the timer finishes (default: "Time up!")

Options:
  -n, --name NAME   optional timer name to show as the notification title
  -h, --help        show this help message and exit

Examples:
  $0 10                    # notify after 10 minutes
  $0 -n Lunch 45           # notify after 45 minutes with title 'Lunch'
  $0 0.5 "Stretch now"    # notify after 30 seconds

Requirements:
  - `notify-send` (usually provided by the `libnotify-bin` package)

EOF
}

# Require minutes as the first argument
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Error: missing <minutes> argument." >&2
    usage
    exit 1
fi

MINUTES="$1"
shift || true

# Now parse options (after minutes) and optional message
TIMER_NAME=""
MESSAGE=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -n|--name)
            shift
            if [ "${1:-}" = "" ]; then
                echo "Error: --name requires an argument." >&2
                exit 1
            fi
            TIMER_NAME="$1"
            shift
            ;;
        --)
            shift
            MESSAGE="${*:-}"
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
        *)
            MESSAGE="${*}"
            break
            ;;
    esac
done

if [ -z "$MESSAGE" ]; then
    MESSAGE="Time up!"
fi
# Check notify-send is available
if ! command -v notify-send >/dev/null 2>&1; then
    echo "Error: notify-send not found. Install libnotify (e.g. apt install libnotify-bin)." >&2
    exit 1
fi

# Validate minutes as a positive number (integer or decimal)
if ! printf '%s' "$MINUTES" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
    echo "Error: <minutes> must be a positive number (e.g. 5 or 0.5)." >&2
    exit 1
fi

# Helpers for titles
title_started() {
    if [ -n "$TIMER_NAME" ]; then
        printf '%s started' "$TIMER_NAME"
    else
        printf 'Timer started'
    fi
}

title_finished() {
    if [ -n "$TIMER_NAME" ]; then
        printf '%s finished' "$TIMER_NAME"
    else
        printf 'Timer finished'
    fi
}

title_cancelled() {
    if [ -n "$TIMER_NAME" ]; then
        printf '%s cancelled' "$TIMER_NAME"
    else
        printf 'Timer cancelled'
    fi
}

# Trap SIGINT/SIGTERM to notify cancellation
cancel() {
    notify-send "$(title_cancelled)" "Cancelled timer: ${MINUTES} minute(s)."
    exit 1
}
trap cancel INT TERM

date
#notify-send "$(title_started)" "${MINUTES} minute(s)." || true

# Sleep using minute suffix so fractional minutes work (GNU sleep supports 'm')
sleep "${MINUTES}m"

notify-send "$(title_finished)" "Time up after ${MINUTES} minutes!"
date

exit 0
