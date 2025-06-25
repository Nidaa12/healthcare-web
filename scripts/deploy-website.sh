#!/bin/bash

# Website deployment script for VM
set -e

echo "Starting website deployment..."

# Create website directory
sudo mkdir -p /var/www/healthcare
sudo chown -R www-data:www-data /var/www/healthcare

# Copy website files (will be uploaded by rsync)
echo "Website files will be copied by rsync..."

# Configure Nginx
sudo tee /etc/nginx/sites-available/healthcare > /dev/null << 'NGINX_CONFIG'
server {
    listen 80;
    listen [::]:80;
    
    root /var/www/healthcare;
    index index.html index.htm;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
NGINX_CONFIG

# Enable the site
sudo ln -sf /etc/nginx/sites-available/healthcare /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

echo "Website deployment completed successfully!"
