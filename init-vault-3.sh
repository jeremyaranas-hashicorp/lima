#! /usr/bin/sh

IP=$(ip addr show eth0 | grep inet | head -n 1 | awk '{print $2}' | cut -d/ -f1)
export VAULT_ADDR=https://$IP:8200
# vault operator init -format=json -key-shares=1 -key-threshold=1 > ~/init.json
# vault operator unseal $(jq -r ".unseal_keys_b64[]" ~/init.json)
# vault login $(cat ~/init.json | jq -r ".root_token")

# sudo touch /opt/vault/audit.log
# sudo chown vault:vault /opt/vault/audit.log
# vault audit enable file file_path=/opt/vault/audit.log