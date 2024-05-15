#!/bin/bash

# Variables
WINDOWS_SHARE="//192.168.1.11/CompanyData"
MOUNT_POINT="/mnt/windows_share"
SAMBA_CONF="/etc/samba/smb.conf"
WINDOWS_USERNAME="your_windows_username"
WINDOWS_PASSWORD="your_windows_password"

# Étape 1 : Monter le partage Windows sur Debian

# Installer les utilitaires nécessaires
echo "Installation de cifs-utils..."
apt-get update
apt-get install -y cifs-utils

# Créer le point de montage
echo "Création du point de montage..."
mkdir -p $MOUNT_POINT

# Monter le partage Windows
echo "Montage du partage Windows..."
mount -t cifs $WINDOWS_SHARE $MOUNT_POINT -o username=$WINDOWS_USERNAME,password=$WINDOWS_PASSWORD,vers=3.0

# Ajouter le montage au fstab pour un montage automatique au démarrage
echo "Ajout du partage Windows à fstab..."
bash -c "echo '$WINDOWS_SHARE $MOUNT_POINT cifs username=$WINDOWS_USERNAME,password=$WINDOWS_PASSWORD,vers=3.0 0 0' >> /etc/fstab"

# Étape 2 : Configurer Samba pour partager ce point de montage

# Installer Samba
echo "Installation de Samba..."
apt-get install -y samba

# Sauvegarder le fichier de configuration Samba
echo "Sauvegarde du fichier de configuration Samba..."
cp $SAMBA_CONF $SAMBA_CONF.bak

# Configurer Samba pour partager le point de montage
echo "Configuration de Samba..."
bash -c "cat > $SAMBA_CONF <<EOL
[global]
workgroup = VOTREDOMAINE
security = user
map to guest = Bad User

[shared]
path = $MOUNT_POINT
read only = no
browsable = yes
EOL"

# Redémarrer le service Samba
echo "Redémarrage du service Samba..."
systemctl restart smbd
systemctl enable smbd

echo "Configuration de Samba avec un partage NTFS sur Windows terminée."

# Créer le dossier partagé et définir les permissions
echo "Création du dossier partagé et définition des permissions..."
mkdir -p /srv/samba/shared
chown -R nobody:nogroup /srv/samba/shared
chmod -R 0775 /srv/samba/shared

# Redémarrer le service Samba
echo "Redémarrage du service Samba..."
systemctl restart smbd
systemctl enable smbd

# Étape 6 : Administration à distance

# 1. Installer OpenSSH Server
echo "Installation de OpenSSH Server..."
apt-get install -y openssh-server

# Vérifier le statut de SSH
echo "Vérification du statut de SSH..."
systemctl status ssh

echo "Installation et configuration terminées."
