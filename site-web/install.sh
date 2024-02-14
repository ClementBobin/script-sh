#!/bin/bash

# Define variables
path_source=("index.html" "cible.php" "000-default.conf" "apache2.conf")
path_destination=("/var/www/html" "/var/www/html" "/etc/apache2/sites-enabled/" "/etc/apache2/")
sites=("site1" "site2")
domains=("www.site1.fr" "www.site2.fr")
web_root="/var/www/html"

# Function to display messages in color
print_message() {
  echo -e "\e[1;32m$1\e[0m"
}

# Function to prompt the user with Zenity if available, else in the terminal
prompt_user() {
  local message="$1"
  if command -v zenity &>/dev/null; then
    zenity --question --title="LAMP Server Setup" --text="$message" --no-wrap
    [[ $? -eq 0 ]]
  else
    read -p "$message (y/n): " response
    [[ "$response" =~ ^[Yy]$ ]]
  fi
}

# Function to create directories
create_directory() {
  sudo mkdir -p "$1"
}

# Function to create HTML pages
create_html_page() {
  cat <<EOF > "$1/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to $2</title>
</head>
<body>
    <h1>Welcome to $2</h1>
    <p>This is the landing page for $2.</p>
</body>
</html>
EOF
}

# Function to create Apache virtual host configuration
create_virtual_host() {
  cat <<EOF | sudo tee "/etc/apache2/sites-available/$1.conf" > /dev/null
<VirtualHost *:80>
    ServerName $2
    DocumentRoot $3
    ErrorLog \${APACHE_LOG_DIR}/$1-error.log
    CustomLog \${APACHE_LOG_DIR}/$1-access.log combined
</VirtualHost>
EOF
}

# Function to check if a file exists
file_exists() {
  [[ -f "$1" ]]
}

# Function to update VirtualHost configuration
update_virtualhost() {
  local domain="$1"
  local ssl_cert="$2"
  local ssl_key="$3"
  local virtualhost_file="/etc/apache2/sites-available/${domain}.conf"

  if file_exists "$virtualhost_file"; then
    print_message "Updating VirtualHost configuration for $domain..."
    sudo sed -i "s|^SSLCertificateFile.*|SSLCertificateFile $ssl_cert|" "$virtualhost_file"
    sudo sed -i "s|^SSLCertificateKeyFile.*|SSLCertificateKeyFile $ssl_key|" "$virtualhost_file"
    print_message "VirtualHost configuration updated successfully."
  else
    print_message "Error: VirtualHost configuration file not found for $domain."
  fi
}

# Copy required files to destination paths
for ((i = 0; i < ${#path_source[@]}; i++)); do
  cp "${path_source[i]}" "${path_destination[i]}"
done

# Display success message
print_message "Required files are present."

# Install necessary software packages
if prompt_user "Do you want to install necessary software packages (e.g., Apache, PHP)?"; then
  sudo apt-get update -y
  sudo apt-get install -y apache2 php --fix-missing
  sudo apt-get update -y

  print_message "Software packages installed."
else
  print_message "Software installation skipped."
fi

# Check if Apache is installed
if ! command -v apache2 &>/dev/null; then
  print_message "Error: Apache web server is not installed."
  exit 1
fi

# Check if required directories exist, create if not
for site in "${sites[@]}"; do
  site_directory="$web_root/$site"
  if [[ ! -d "$site_directory" ]]; then
    create_directory "$site_directory"
    create_html_page "$site_directory" "$site"
  fi
done

# Create Apache virtual host configurations
for ((i=0; i<${#sites[@]}; i++)); do
  create_virtual_host "${sites[i]}" "${domains[i]}" "$web_root/${sites[i]}"
  sudo a2ensite "${sites[i]}.conf"
done

# Prompt user for username and set up Apache basic authentication
auth=$(zenity --entry --title="Apache Basic Authentication" --text="Enter username:")
htpasswd -c /etc/apache2/.htpasswd "$auth"

# Start Apache service
sudo systemctl start apache2

# Display completion message
print_message "Configuration tasks completed."

# Step 1: Setting up a Web Server on Azure
print_message "Setting Up a Web Server on Azure:"
print_message "1. Concepts du cloud computing:"
# open_url "https://docs.microsoft.com/fr-fr/learn/modules/principles-cloud-computing/"
prompt_user "Press Enter once you have completed reading."

print_message "2. Créer une machine virtuelle Linux dans Azure:"
# open_url "https://docs.microsoft.com/fr-fr/learn/modules/create-linux-virtual-machine-in-azure/"
prompt_user "Press Enter once you have completed creating the Linux VM."

print_message "3. Créer une machine virtuelle Windows dans Azure:"
# open_url "https://docs.microsoft.com/fr-fr/learn/modules/create-windows-virtual-machine-in-azure/"
prompt_user "Press Enter once you have completed creating the Windows VM."

# Step 2: Setting Up a Web Server on Google Cloud Platform
print_message "Setting Up a Web Server on Google Cloud Platform:"
print_message "1. Visit Google Cloud Platform: https://cloud.google.com/"
# open_url "https://cloud.google.com/"
prompt_user "Press Enter once you have signed in or created an account on GCP."

print_message "2. Follow the documentation to create a Linux VM on GCP."
prompt_user "Press Enter once you have created the Linux VM."

# Step 3: Reproducing the Work Done in Step 1
print_message "Reproducing the Work Done in Step 1:"
# You can add commands here to set up your web server on the Azure and GCP VMs

# Step 4: Testing Access to the Web Server from a Client
print_message "Testing Access to the Web Server from a Client:"
# You can add commands here to test access to the web server from a client machine

print_message "Setup completed."
