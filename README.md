This reproduction will deploy a local Ubuntu instance on MacOS using [Lima](https://lima-vm.io/).

1. Run `./startup.sh`
   1. Choose *Proceed with the current configuration*
2. Exec into Ubuntu instance
   1. `limactl shell vault-1`
3. Install Vault
   1. `cd /Users/<your_user>/GitHub/jeremy/lima`
   2. `./install-vault-1.sh`
4. Init Vault
   1. `cd /Users/<your_user>/GitHub/jeremy/lima`
   2. `./init-vault-1.sh`
5. Source environment variables
   1. `source vars-vault-1.sh`

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