#!/bin/bash

# Étape 5 : Intégration de Linux

# 1. Installer Samba
echo "Installation de Samba..."
sudo apt-get update
sudo apt-get install -y samba

# 2. Configurer Samba
echo "Configuration de Samba..."
SAMBA_CONF="/etc/samba/smb.conf"
sudo cp $SAMBA_CONF $SAMBA_CONF.bak

sudo bash -c "cat > $SAMBA_CONF <<EOL
[global]
workgroup = VOTREDOMAINE
security = user
map to guest = Bad User

[shared]
path = /srv/samba/shared
read only = no
browsable = yes
EOL"

# Créer le dossier partagé et définir les permissions
echo "Création du dossier partagé et définition des permissions..."
sudo mkdir -p /srv/samba/shared
sudo chown -R nobody:nogroup /srv/samba/shared
sudo chmod -R 0775 /srv/samba/shared

# Redémarrer le service Samba
echo "Redémarrage du service Samba..."
sudo systemctl restart smbd
sudo systemctl enable smbd

# Étape 6 : Administration à distance

# 1. Installer OpenSSH Server
echo "Installation de OpenSSH Server..."
sudo apt-get install -y openssh-server

# Vérifier le statut de SSH
echo "Vérification du statut de SSH..."
sudo systemctl status ssh

echo "Installation et configuration terminées."
