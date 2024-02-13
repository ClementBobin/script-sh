#!/bin/bash

# Function to display messages in color
print_message() {
  echo -e "\e[1;32m$1\e[0m"
}

# Function to prompt the user with Zenity if available, else in the terminal
prompt_user() {
  local message="$1"
  if command -v zenity &>/dev/null; then
    zenity --question --title="Installation Script" --text="$message" --no-wrap
    [[ $? -eq 0 ]]
  else
    read -p "$message (y/n): " response
    [[ "$response" =~ ^[Yy]$ ]]
  fi
}

# Function to install vsftpd
install_vsftpd() {
  if command -v apt &>/dev/null; then
    sudo apt install vsftpd -y
  elif command -v dnf &>/dev/null; then
    sudo dnf install vsftpd -y
  elif command -v pacman &>/dev/null; then
    sudo pacman -S vsftpd --noconfirm
  else
    print_message "Unsupported package manager. Please install vsftpd manually."
    exit 1
  fi
  print_message "vsftpd installed."
}

# Function to backup and create vsftpd configuration
configure_vsftpd() {
  sudo mv /etc/vsftpd.conf /etc/vsftpd.conf_orig
  sudo tee /etc/vsftpd.conf > /dev/null <<EOF
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
pasv_enable=YES
pasv_min_port=10000
pasv_max_port=10100
allow_writeable_chroot=YES
EOF
  print_message "vsftpd configuration created."
}

# Function to update firewall rules
update_firewall() {
  if command -v ufw &>/dev/null; then
    sudo ufw allow from any to any port 20,21 proto tcp
  elif command -v firewall-cmd &>/dev/null; then
    sudo firewall-cmd --zone=public --permanent --add-service=ftp
  elif command -v iptables &>/dev/null; then
    sudo iptables -A INPUT -m state --state NEW,ESTABLISHED -m tcp -p tcp --dport 20,21 -j ACCEPT
  else
    print_message "Firewall rules not updated. Please update manually."
  fi
  print_message "Firewall rules updated."
}

# Function to restart vsftpd
restart_vsftpd() {
  sudo systemctl restart vsftpd
  print_message "vsftpd restarted."
}

# Function to create an FTP user
create_ftp_user() {
  sudo useradd -m ftpuser
  sudo passwd ftpuser
  print_message "FTP user created successfully."
}

# Function to create a test file in the FTP user's home directory
create_test_file() {
  sudo bash -c "echo FTP TESTING > /home/ftpuser/FTP-TEST"
  print_message "Test file created in the FTP user's home directory."
}

# Function to connect to the FTP server via command line
connect_to_ftp() {
  local ip_address=$(hostname -I)
  echo "Your IP address is: $ip_address"
  ftp 127.0.0.1
}

# Main function
main() {
  print_message "Starting vsftpd installation and configuration..."

  if prompt_user "Do you want to install vsftpd?"; then
    install_vsftpd
  fi

  if prompt_user "Do you want to configure vsftpd?"; then
    configure_vsftpd
  fi

  if prompt_user "Do you want to update firewall rules?"; then
    update_firewall
  fi

  if prompt_user "Do you want to restart vsftpd?"; then
    restart_vsftpd
  fi

  if prompt_user "Do you want to create a FTP User?"; then
    print_message "Creating an FTP user..."
    create_ftp_user
  fi

  if prompt_user "Do you want to Test?"; then
    print_message "Creating a test file..."
    create_test_file
  fi

  if prompt_user "Do you want to connect to the ftp?"; then
    print_message "Connecting to the FTP server via command line..."
    connect_to_ftp
  fi

  print_message "vsftpd setup completed."
}

# Call the main function
main
