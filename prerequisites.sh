#!/bin/bash

# Funzione per verificare se un comando esiste
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Aggiorna il sistema
echo "Aggiornamento del sistema..."
sudo apt update && sudo apt upgrade -y

# Installa Multipass
echo "Installazione di Multipass..."
if ! command_exists multipass; then
  sudo snap install multipass
else
  echo "Multipass è già installato."
fi

# Installa jq
echo "Installazione di jq..."
if ! command_exists jq; then
  sudo apt install -y jq
else
  echo "jq è già installato."
fi

# Installa Python3 e pip
echo "Installazione di Python3..."
if ! command_exists python3; then
  sudo apt install -y python3 python3-pip
else
  echo "Python3 è già installato."
fi

# Installa Ansible
echo "Installazione di Ansible..."
if ! command_exists ansible; then
  sudo apt install -y ansible
else
  echo "Ansible è già installato."
fi

# Genera la chiave SSH
echo "Generazione della chiave SSH..."
mkdir -p ssh_keys
ssh-keygen -t rsa -b 4096 -f ssh_keys/id_rsa -N ""


# Verifica se tutte le dipendenze sono state installate correttamente
echo "Verifica delle installazioni:"
echo "Multipass: $(command_exists multipass && echo 'OK' || echo 'KO')"
echo "jq: $(command_exists jq && echo 'OK' || echo 'KO')"
echo "Python3: $(command_exists python3 && echo 'OK' || echo 'KO')"
echo "Ansible: $(command_exists ansible && echo 'OK' || echo 'KO')"



echo "Installazione completata!"
