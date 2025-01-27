#! /usr/bin/sh

IP=$(ip addr show eth0 | grep inet | head -n 1 | awk '{print $2}' | cut -d/ -f1)

export VAULT_ADDR=https://$IP:8200