#!/bin/bash
# lists connected bluetooth devices and their battery charge percentage

show_help() {
  echo "lists connected bluetooth devices and their battery charge percentage."
  echo "usage: $(basename $0) [--all]"
  echo "  --all    include disconnected/paired devices too"
}

all=false

while test $# -gt 0; do
  case "$1" in
  --help|-h)
    show_help
    exit 0
    ;;
  --all|-a)
    all=true
    ;;
  -*)
    echo "bad option '$1'"
    exit 1
    ;;
  esac
  shift
done

if ! command -v bluetoothctl >/dev/null 2>&1; then
  echo "bluetoothctl not found. please install bluez."
  exit 1
fi

if ! command -v upower >/dev/null 2>&1; then
  echo "upower not found. please install upower."
  exit 1
fi

# collect all paired device MAC addresses
mapfile -t macs < <(bluetoothctl devices 2>/dev/null | awk '{print $2}')

if [[ ${#macs[@]} -eq 0 ]]; then
  echo "no paired bluetooth devices found."
  exit 0
fi

found=0
for mac in "${macs[@]}"; do
  [[ -z "$mac" ]] && continue

  info=$(bluetoothctl info "$mac" 2>/dev/null)

  connected=$(echo "$info" | grep "Connected:" | awk '{print $2}')
  [[ "$all" != true && "$connected" != "yes" ]] && continue

  name=$(echo "$info" | grep "Name:" | sed 's/.*Name: //')
  [[ -z "$name" ]] && name="$mac"

  # upower uses underscores instead of colons in the MAC address
  mac_upower=$(echo "$mac" | tr ':' '_')
  upower_path=$(upower -e 2>/dev/null | grep -i "$mac_upower" | head -1)

  if [[ -n "$upower_path" ]]; then
    battery=$(upower -i "$upower_path" 2>/dev/null | grep -i "percentage:" | awk '{print $2}')
  fi

  [[ -z "$battery" ]] && battery="N/A"

  status_label=""
  [[ "$connected" == "yes" ]] && status_label=" [connected]"

  printf "%-35s %s  battery: %s\n" "$name" "$mac$status_label" "$battery"
  ((found++))
  battery=""
done

if [[ "$found" -eq 0 ]]; then
  if [[ "$all" == true ]]; then
    echo "no bluetooth devices found."
  else
    echo "no connected bluetooth devices found. use --all to include paired devices."
  fi
fi
