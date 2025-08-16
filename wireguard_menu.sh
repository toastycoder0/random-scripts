#!/bin/bash

echo "Select an action for WireGuard (wg-quick@wg0):"
echo "1) Start"
echo "2) Status"
echo "3) Stop"
echo "4) Exit"
read -p "Enter your choice [1-4]: " choice

case $choice in
1)
  echo "Starting WireGuard..."
  nmcli connection up wg0
  ;;
2)
  echo "Checking WireGuard status..."
  nmcli connection show --active
  ;;
3)
  echo "Stopping WireGuard..."
  nmcli connection down wg0
  ;;
4)
  echo "Exiting..."
  exit 0
  ;;
*)
  echo "Invalid option. Please enter a number between 1 and 4."
  ;;
esac
