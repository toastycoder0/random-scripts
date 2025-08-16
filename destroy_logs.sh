#!/bin/bash

destroy_logs() {
  echo "[+] Destroying system logs..."
  sudo journalctl --vacuum-time=1s
  sudo rm -rf /var/log/*
}

destroy_logs
