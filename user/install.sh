#!/bin/bash

# Function to display messages in color
print_message() {
  echo -e "\e[1;32m$1\e[0m"
}

# Function to create user directories on xxcliw1002
create_user_directories() {
  local base_dir="/home"
  local users=("responsable" "secretaire" "benevole1" "benevole2")  # List of user names
  
  # Create base directories for each user
  for user in "${users[@]}"; do
    mkdir -p "$base_dir/$user"
    print_message "Created directory for user $user"
  done
}

# Function to create a shared directory with appropriate permissions
create_shared_directory() {
  local shared_dir="/shared"
  
  # Create the shared directory
  mkdir -p "$shared_dir"
  
  # Set permissions: volunteers can read and execute, secretary can modify, and manager has full control
  chmod 725 "$shared_dir"  # Default permissions for others
  
  # Set group ownership
  chgrp manager "$shared_dir"
  
  print_message "Shared directory created with appropriate permissions."
}

# Function to implement account lockout policy
implement_account_lockout() {
  local max_attempts=2
  local lockout_file="/var/log/login_attempts.log"
  
  # Check login attempts from the log file
  login_attempts=$(grep -c 'Failed password' "$lockout_file")
  
  # Lock account if max attempts exceeded
  if (( login_attempts >= max_attempts )); then
    print_message "Account locked due to multiple failed login attempts."
  fi
}

# Function to display permissions of /root directory
display_root_permissions() {
  ls -ld /root
}

# Function to change ownership of a file
change_ownership() {
  local file="$1"
  local owner="$2"
  local group="$3"
  
  chown "$owner:$group" "$file"
}

# Function to create a directory with specified permissions
create_directory_with_permissions() {
  local directory="$1"
  local owner="$2"
  local group="$3"
  local permissions="$4"
  
  mkdir -p "$directory"
  chown "$owner:$group" "$directory"
  chmod "$permissions" "$directory"
}

# Main function
main() {
  # Create user directories
  create_user_directories
  
  # Create shared directory
  create_shared_directory
  
  # Implement account lockout policy
  implement_account_lockout
  
  # Display permissions of /root directory
  print_message "Permissions of /root directory:"
  display_root_permissions
  
  # Example usage of change_ownership function
  change_ownership "/home/shared" "responsable" "admin"
  
  # Example usage of create_directory_with_permissions function
  create_directory_with_permissions "/path/to/directory" "owner" "group" "755"
}

# Call the main function
main
