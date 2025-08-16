#!/usr/bin/env bash

set -e

HOSTNAME="$(hostname).local"
CERT_DIR="/etc/nginx/selfsigned"
CRT_PATH="$CERT_DIR/$HOSTNAME.crt"
KEY_PATH="$CERT_DIR/$HOSTNAME.key"
NGINX_CONF="/etc/nginx/conf.d/$HOSTNAME.conf"
HTML_PATH="/usr/share/nginx/html/index.html"

echo "[+] Detected hostname: $HOSTNAME"

sudo mkdir -p "$CERT_DIR"
sudo chmod 700 "$CERT_DIR"

echo "[+] Generating self-signed certificate..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$KEY_PATH" \
  -out "$CRT_PATH" \
  -subj "/CN=$HOSTNAME"

if ! command -v nginx &>/dev/null; then
  echo "[+] Installing Nginx..."
  sudo pacman -Sy --noconfirm nginx
fi

echo "[+] Ensuring Nginx config directory exists..."
sudo mkdir -p /etc/nginx/conf.d/

echo "[+] Creating Nginx configuration..."
sudo tee "$NGINX_CONF" >/dev/null <<EOF
server {
    listen 443 ssl;
    server_name $HOSTNAME;

    ssl_certificate     $CRT_PATH;
    ssl_certificate_key $KEY_PATH;

    root /usr/share/nginx/html;
    index index.html;
}

server {
    listen 80;
    server_name $HOSTNAME;
    return 301 https://\$host\$request_uri;
}
EOF

echo "[+] Creating test HTML page..."
sudo tee "$HTML_PATH" >/dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>$HOSTNAME</title>
</head>
<body>
    <h1>Success! You're accessing $HOSTNAME over HTTPS.</h1>
</body>
</html>
EOF

echo "[+] Restarting Nginx..."
sudo systemctl enable --now nginx

echo
echo "[✔] Setup complete."
echo "Open https://$HOSTNAME from another machine on the same network."
echo "You may see a security warning because of the self-signed certificate."
