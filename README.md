This reproduction will deploy a local Ubuntu instance on MacOS using [Lima](https://lima-vm.io/).

* Update the **ent.hclic** file with your Vault Enterprise license.

1. Run `./startup.sh`
   1. Choose *Proceed with the current configuration*
2. Exec into Ubuntu instance
   1. `limactl shell vault`
3. Install and init Vault
   1. `./install_and_init_vault.sh`
4. Source environment variables
   1. `source vars-vault.sh`

Logging

1. View operational logs 
   1. `sudo journalctl -u vault -f`
2. View audit logs
   1. `sudo tail -f /opt/vault/audit.log`

Cleanup

Uninstall Vault without deleting Ubuntu instance.

1. `cd /Users/jeremyaranas/Reproductions/lima`
   1. `./re-init.sh`

Delete Ubuntu instance.

1. Exit Ubuntu instance
2. Run `./cleanup.sh`