#! /usr/bin/sh

echo "Enter Vault version (e.g. 1.18.3): "
read VAULT_VERSION
export VAULT_VERSION=$VAULT_VERSION

echo "Enter local path to Lima repo (e.g. /Users/jeremyaranas/GitHub/jeremy/lima): "
read LIMA_DIR
export LIMA_DIR=$LIMA_DIR

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

  retry_join {
    leader_api_addr = "https://192.168.104.1:8200"
    leader_client_cert_file = "$LIMA_DIR/certs/vault.pem"
    leader_client_key_file = "$LIMA_DIR/certs/vault.key"
  }
  retry_join {
    leader_api_addr = "https://192.168.104.3:8200"
    leader_client_cert_file = "$LIMA_DIR/certs/vault.pem"
    leader_client_key_file = "$LIMA_DIR/certs/vault.key"
  }
  retry_join {
    leader_api_addr = "https://192.168.104.4:8200"
    leader_client_cert_file = "$LIMA_DIR/certs/vault.pem"
    leader_client_key_file = "$LIMA_DIR/certs/vault.key"
  }
}

listener "tcp" {
  address     = "192.168.104.1:8200"
  cluster_address     = "192.168.104.1:8201"
  tls_disable = false
  tls_cert_file = "$LIMA_DIR/certs/vault.pem"
  tls_key_file = "$LIMA_DIR/certs/vault.key"
}

license_path = "$LIMA_DIR/ent.hclic"
api_addr = "https://192.168.104.1:8200"
cluster_addr = "https://192.168.104.1:8201"
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

# Copy cert to cert store 
sudo cp $LIMA_DIR/certs/myCA.pem /usr/local/share/ca-certificates/myCA.crt
sudo update-ca-certificates