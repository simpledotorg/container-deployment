#!/usr/bin/env bash

# Create config
echo $CPHC_VPN_CONFIG > linux_phat_client/linux_phat_client/naclient.cfg

# Install
linux_phat_client/install_linux_phat_client.sh

# Setup tun device
mkdir -p /dev/net 
mknod /dev/net/tun c 10 200 
chmod 600 /dev/net/tun

# Login
yes | naclient login -profile $CPHC_VPN_PROFILE  -user $CPHC_VPN_USER  -password $CPHC_VPN_PASSWORD

bundle exec sidekiq  -C config/sidekiq.yml -e production -q $CPHC_SIDEKIQ_QUEUE
