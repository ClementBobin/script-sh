#!/bin/bash

# Define variables
RPi_IP=$(hostname -I | awk '{print $1}')
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

# Function to install Apache2
install_apache() {
  apt install apache2 -y
  print_message "Apache2 installed."
}

# Function to install PHP
install_php() {
  apt install php -y
  print_message "PHP installed."
}

# Function to remove index.html and create index.php
create_index_php() {
  rm "$web_root/index.html"
  tee "$web_root/index.php" > /dev/null <<EOF
<?php echo "hello world"; ?>
EOF
  print_message "index.php created."
}

# Function to restart Apache2
restart_apache() {
  service apache2 restart
  print_message "Apache2 restarted."
}

# Function to install MySQL (MariaDB)
install_mysql() {
  apt install mariadb-server php-mysql -y
  mysql_secure_installation
  print_message "MySQL installed."
}

# Function to install phpMyAdmin
install_phpmyadmin() {
  apt install phpmyadmin -y
  phpenmod mysqli
  service apache2 restart
  ln -s /usr/share/phpmyadmin "$web_root/phpmyadmin"
  print_message "phpMyAdmin installed."
}

# Function to change permissions for $web_root
change_permissions() {
  sudo chown -R pi:www-data "$web_root"
  sudo chmod -R 770 "$web_root"
  print_message "Permissions for $web_root changed."
}

# Main function
main() {
  print_message "Starting LAMP server setup on Raspberry Pi..."

  if prompt_user "Do you want to install Apache2?"; then
    install_apache
  fi

  if prompt_user "Do you want to install PHP?"; then
    install_php
  fi

  if prompt_user "Do you want to create index.php?"; then
    create_index_php
  fi

  if prompt_user "Do you want to restart Apache2?"; then
    restart_apache
  fi

  if prompt_user "Do you want to install MySQL (MariaDB)?"; then
    install_mysql
  fi

  if prompt_user "Do you want to install phpMyAdmin?"; then
    install_phpmyadmin
  fi

  if prompt_user "Do you want to change permissions for $web_root? (recommended)"; then
    change_permissions
  fi

  print_message "LAMP server setup completed."

  echo "You can access your server at: http://$RPi_IP"
}

# Call the main function
main
