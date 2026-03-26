#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

message="$1"
require message

# 69 chars max
body="$2"

notifier=$(which notify-send)
require -f notifier

# When running from cron, display environment variables are not set.
# Detect them from the current user's running processes.
if [ -z "$DISPLAY" ] || [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    uid=$(id -u)
    for pid in /proc/[0-9]*; do
        [ -r "$pid/environ" ] || continue
        [ "$(stat -c %u "$pid" 2>/dev/null)" = "$uid" ] || continue
        env_vars=$(tr '\0' '\n' < "$pid/environ" 2>/dev/null)
        [ -z "$DISPLAY" ] && disp=$(echo "$env_vars" | grep '^DISPLAY=') && [ -n "$disp" ] && export "$disp"
        [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && dbus=$(echo "$env_vars" | grep '^DBUS_SESSION_BUS_ADDRESS=') && [ -n "$dbus" ] && export "$dbus"
        [ -n "$DISPLAY" ] && [ -n "$DBUS_SESSION_BUS_ADDRESS" ] && break
    done
    [ -z "$DISPLAY" ] && export DISPLAY=:0
fi

$notifier "$message" "$body"
