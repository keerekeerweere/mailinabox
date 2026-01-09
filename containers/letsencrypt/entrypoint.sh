#!/bin/sh

# Wait for nginx to be ready
echo "Waiting for nginx to be ready..."
while ! curl -f http://nginx:80/.well-known/acme-challenge/test > /dev/null 2>&1; do
  echo "Waiting for nginx..."
  sleep 5
done

echo "Requesting SSL certificate for domains: $DOMAINS"

# Request certificate
certbot certonly \
  --webroot \
  --webroot-path=/var/www/html \
  --email="$EMAIL" \
  --agree-tos \
  --no-eff-email \
  --domains="$DOMAINS" \
  --keep-until-expiring \
  --rsa-key-size 2048

# Check if certificate was obtained
if [ -f "/etc/letsencrypt/live/$DOMAINS/fullchain.pem" ]; then
  echo "SSL certificate obtained successfully"
  # Reload nginx to use the new certificate
  curl -X POST http://nginx:80/nginx-reload 2>/dev/null || true
else
  echo "Failed to obtain SSL certificate"
  exit 1
fi

# Keep container running for certificate renewal
echo "Certificate obtained. Container will stay running for renewal checks."
while true; do
  # Check if certificate needs renewal (Let's Encrypt recommends every 60 days)
  certbot renew --quiet
  sleep 86400  # Check daily
done