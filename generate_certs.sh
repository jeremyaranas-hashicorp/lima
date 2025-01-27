#!/bin/bash

openssl genrsa -out certs/myCA.key 2048
openssl req -x509 -new -nodes -key certs/myCA.key -sha256 -days 1825 -out certs/myCA.pem -subj "/C=US/ST=CA/L=SJ/O=Test/OU=Test/CN=vault"
openssl genrsa -out certs/vault -out certs/vault.key
openssl req -new -key  certs/vault.key -out  certs/vault.csr -subj "/C=US/ST=CA/L=SJ/O=Test/OU=Test/CN=vault"

# Create an extension file to add SANs to certs
cat >  certs/vault.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = vault
IP.1 = "192.168.104.1"
IP.2 = "192.168.104.3"
IP.3 = "192.168.104.4"
EOF

openssl x509 -req -in  certs/vault.csr -CA  certs/myCA.pem -CAkey  certs/myCA.key -CAcreateserial -out certs/vault.pem -days 365 -sha256 -extfile  certs/vault.ext

