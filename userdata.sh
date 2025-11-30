#!/bin/bash

set -e
LOG="/var/log/nodeapp_install.log"

echo "[INFO] Starting CentOS 7 provisioning" | tee -a $LOG

yum update -y
yum install -y epel-release
yum install -y nginx nodejs npm openssl

systemctl enable nginx
systemctl start nginx

# Create non-root user
useradd -r -s /sbin/nologin nodeusr || true
mkdir -p /var/www/nodeapp
chown -R nodeusr:nodeusr /var/www/nodeapp

# Install Node application
cp -r /tmp/app/* /var/www/nodeapp/
cd /var/www/nodeapp
npm install
chown -R nodeusr:nodeusr /var/www/nodeapp

# SSL
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/selfsigned.key \
  -out /etc/nginx/ssl/selfsigned.crt \
  -subj "/CN=ec2"
chmod 600 /etc/nginx/ssl/selfsigned.key

# Nginx config
mv /tmp/node.conf /etc/nginx/conf.d/node.conf

# systemd service
mv /tmp/nodeapp.service /etc/systemd/system/nodeapp.service
systemctl daemon-reload
systemctl enable nodeapp
systemctl restart nodeapp

systemctl restart nginx

echo "[INFO] Provisioning complete" | tee -a $LOG
