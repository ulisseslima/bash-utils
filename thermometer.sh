#!/bin/bash

# Lists all thermometer readings available on the current machine.
# Sources: /sys/class/hwmon (hardware monitors) and /sys/class/thermal (ACPI thermal zones).

print_temp() {
  local millidegrees=$1
  printf "%.1f°C" "$(echo "scale=1; $millidegrees / 1000" | bc)"
}

echo "=== Hardware Monitor Sensors (hwmon) ==="
for hwmon_dir in /sys/class/hwmon/hwmon*; do
  name=$(cat "$hwmon_dir/name" 2>/dev/null) || continue
  sensor_files=("$hwmon_dir"/temp*_input)
  [[ -e "${sensor_files[0]}" ]] || continue

  echo "  [$name]"
  for input_file in "${sensor_files[@]}"; do
    base="${input_file%_input}"
    label=$(cat "${base}_label" 2>/dev/null || basename "$base")
    temp=$(cat "$input_file" 2>/dev/null) || continue
    printf "    %-20s %s\n" "$label" "$(print_temp "$temp")"
  done
done

echo ""
echo "=== ACPI Thermal Zones ==="
for zone_dir in /sys/class/thermal/thermal_zone*; do
  [[ -e "$zone_dir/temp" ]] || continue
  zone=$(basename "$zone_dir")
  type=$(cat "$zone_dir/type" 2>/dev/null || echo "unknown")
  temp=$(cat "$zone_dir/temp" 2>/dev/null) || continue
  printf "  %-10s %-25s %s\n" "$zone" "$type" "$(print_temp "$temp")"
done
