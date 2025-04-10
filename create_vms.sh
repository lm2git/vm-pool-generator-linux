#!/bin/bash

# Chiedi se è la prima volta che si lancia lo script
read -p "È la prima volta che lanci questo script? Vuoi installare i prerequisiti? (s/n): " INSTALL_PREREQUISITES
if [[ "$INSTALL_PREREQUISITES" == "s" || "$INSTALL_PREREQUISITES" == "S" ]]; then
  echo "🔧 Installazione dei prerequisiti..."
  chmod +x prerequisites.sh
  ./prerequisites.sh
fi

# Carica la configurazione da config.json
CONFIG_FILE="config.json"
INTERFACE=$(jq -r '.interface' $CONFIG_FILE)
DOMAIN=$(jq -r '.domain' $CONFIG_FILE)

# Pulizia delle VM esistenti
echo "🧹 Pulizia delle VM esistenti..."
for VM in $(jq -r '.vms[].name' $CONFIG_FILE); do
  if multipass info "$VM" &>/dev/null; then
    echo "Eliminazione della VM esistente: $VM"
    multipass delete "$VM"
  fi
done
multipass purge

# Creazione delle VM
echo "🚀 Creazione delle VM..."
for VM in $(jq -r '.vms[].name' $CONFIG_FILE); do
  echo "Creazione della VM: $VM"
  multipass launch 22.04 --name "$VM" \
    --cpus 1 --memory 1G --disk 5G \
    --cloud-init "cloud-init/$VM.yaml" \
    --timeout 300
done

# Generazione dei file cloud-init e inventory.ini
echo "⚙️  Generazione dei file cloud-init e inventory..."
python3 generate_cloud_init.py

# Configurazione con Ansible
echo "🔧 Configurazione con Ansible..."
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini ansible/playbook.yml

# Output finale
echo "🎉 Tutto pronto! Dettagli delle VM:"
multipass list --format json | jq -r '.list[] | select(.state == "Running") | "\(.name) \(.ipv4[0])"' | while read name ip; do
  echo "$name - IP: $ip"
  echo "   ➤ SSH: ssh -i ssh_keys/id_rsa root@$ip"
done
