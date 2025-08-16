#!/bin/bash

INTERFACE=${1:-wlan0}

if ! ip link show "$INTERFACE" >/dev/null 2>&1; then
  echo "The interface $INTERFACE does not exist."
  exit 1
fi

echo "Disabling interface $INTERFACE..."
sudo ip link set "$INTERFACE" down

echo "Changing MAC address of $INTERFACE..."
sudo macchanger -r "$INTERFACE"

echo "Enabling interface $INTERFACE..."
sudo ip link set "$INTERFACE" up

echo "MAC address of $INTERFACE changed successfully."
