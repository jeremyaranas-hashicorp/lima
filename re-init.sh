#! /usr/bin/sh

sudo systemctl stop vault
sudo rm -fr /opt/vault/vault.db
sudo rm -fr /opt/vault/raft
sudo rm -fr /usr/local/bin/vault
sudo rm -fr ~/EULA.txt ~/TermsOfEvaluation.txt ~/vault.zip ~/init.json
