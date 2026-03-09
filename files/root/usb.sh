#!/bin/sh
# usb.sh - Switch USB role and remember choice

case "$1" in
    1) role="host" ;;
    host) role="host" ;;
    *) role="gadget" ;;
esac

driver_path="/sys/class/udc/ci_hdrc.0/device/driver/ci_hdrc.0/role"
state_file="/etc/usb_role"

[ ! -f "$driver_path" ] && echo "Error: role file not found at $driver_path" && exit 1

echo "$role" > "$driver_path" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Failed to set USB role to $role (permission denied or invalid value)"
    exit 1
fi

echo "$role" > "$state_file"
echo "USB Role set to $role"
