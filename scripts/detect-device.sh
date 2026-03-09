#!/usr/bin/env bash
# Fast HiDock USB device detection.
# Uses ioreg (macOS) to check if HiDock P1 is connected — instant, no hang.
# Exit 0 if found, exit 1 if not found.

set -euo pipefail

detect_macos() {
  local usb_info
  usb_info=$(ioreg -p IOUSB -l 2>/dev/null || true)

  if echo "$usb_info" | grep -qi "HiDock"; then
    # Extract device name for display
    local device_name
    device_name=$(echo "$usb_info" | grep -i "USB Product Name.*HiDock" | head -1 | sed 's/.*= "\(.*\)"/\1/' || echo "HiDock")
    echo "CONNECTED: $device_name"
    return 0
  else
    echo "NOT_CONNECTED"
    return 1
  fi
}

detect_linux() {
  if lsusb 2>/dev/null | grep -qi "hidock"; then
    local device_name
    device_name=$(lsusb 2>/dev/null | grep -i "hidock" | head -1 || echo "HiDock")
    echo "CONNECTED: $device_name"
    return 0
  else
    echo "NOT_CONNECTED"
    return 1
  fi
}

case "$(uname -s)" in
  Darwin) detect_macos ;;
  Linux)  detect_linux ;;
  *)
    echo "UNSUPPORTED_OS: $(uname -s)"
    exit 2
    ;;
esac
