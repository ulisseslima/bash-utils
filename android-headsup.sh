#!/bin/bash

# From a Home screen, navigate: Settings Settings icon >Developer options Developer options icon.
# Note If not available, swipe up or down from the center of the display then navigate: Settings > About phone > Software information then tap Build number seven times.
# Note If presented, enter the current PIN, password, or pattern.

option=${1:-0}

adb devices
adb shell settings put global heads_up_notifications_enabled $option

echo "heads up set to $option"
