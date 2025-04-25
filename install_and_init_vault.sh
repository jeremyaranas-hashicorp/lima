#! /usr/bin/sh

echo "Enter Vault version (e.g. 1.18.3): "
read VAULT_VERSION
export VAULT_VERSION=$VAULT_VERSION

echo "Enter local path to Lima repo (e.g. /Users/jeremyaranas/GitHub/jeremy/lima): "
read LIMA_DIR
export LIMA_DIR=$LIMA_DIR

# Get IP of instance
IP=$(ip addr show eth0 | grep inet | head -n 1 | awk '{print $2}' | cut -d/ -f1)

# Download and install Vault
cd ~
curl -o vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}+ent/vault_${VAULT_VERSION}+ent_linux_arm64.zip
sudo apt install unzip -y
unzip vault.zip
sudo mv vault /usr/local/bin/vault
sudo mkdir /srv/vault

# Add Linux user and group
USER_NAME="vault"
USER_COMMENT="HashiCorp Vault user"
USER_GROUP="vault"
USER_HOME="/srv/vault"

sudo addgroup --system ${USER_GROUP} >/dev/null

sudo adduser \
    --system \
    --disabled-login \
    --ingroup ${USER_GROUP} \
    --home ${USER_HOME} \
    --no-create-home \
    --gecos "${USER_COMMENT}" \
    --shell /bin/false \
    ${USER_NAME}  >/dev/null

# Update permissions
sudo chmod 0755 /usr/local/bin/vault
sudo chown vault:vault /usr/local/bin/vault
sudo mkdir -pm 0755 /etc/vault.d
sudo mkdir -pm 0755 /etc/ssl/vault
sudo mkdir -p /opt/vault/
sudo mkdir -pm 0755 /opt/vault/
sudo chown -R vault:vault /opt/vault/
sudo chmod -R a+rwx /opt/vault/

# Create Vault config
sudo tee /etc/vault.d/vault.hcl <<EOF
storage "raft" {
  path    = "/opt/vault/"
  node_id = "node-1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  cluster_address     = "0.0.0.0:8201"
  tls_disable = true
}

license_path = "$LIMA_DIR/ent.hclic"
api_addr = "https://$IP:8200"
cluster_addr = "https://$IP:8201"
disable_mlock = true
ui=true
log_level = "trace"
EOF

# Update permissions
sudo chown -R vault:vault /etc/vault.d /etc/ssl/vault
sudo chmod -R 0644 /etc/vault.d/*

sudo tee /lib/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault"
Documentation="https://developer.hashicorp.com/vault/docs"
ConditionFileNotEmpty="/etc/vault.d/vault.hcl"

[Service]
User=vault
Group=vault
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

# Enable Vault service
sudo systemctl enable vault
sudo systemctl start vault

sleep 5
# Init Vault

export VAULT_ADDR=http://$IP:8200
vault operator init -format=json -key-shares=1 -key-threshold=1 > ~/init.json
vault operator unseal $(jq -r ".unseal_keys_b64[]" ~/init.json)
vault login $(cat ~/init.json | jq -r ".root_token")

sudo touch /opt/vault/audit.log
sudo chown vault:vault /opt/vault/audit.log
vault audit enable file file_path=/opt/vault/audit.log
