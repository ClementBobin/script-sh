#!/bin/bash

# Function to display messages in color
print_message() {
  echo -e "\e[1;32m$1\e[0m"
}

# Function to print warning messages
print_warning() {
  echo -e "\e[1;33mWARNING: $1\e[0m"
}

# Function to install a component
install_component() {
  cd "$1" || exit
  ./install.sh
  cd ..
}

# Function to check if Zenity is installed
install_zenity() {
  if ! command -v zenity &>/dev/null; then
    echo "Zenity is not installed."
    read -p "Do you want to install Zenity? (y/n): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      # Install Zenity based on the package manager of the system
      if command -v apt-get &>/dev/null; then
        sudo apt-get install zenity
      elif command -v yum &>/dev/null; then
        sudo yum install zenity
      elif command -v pacman &>/dev/null; then
        sudo pacman -S zenity
      elif command -v nix-shell &>/dev/null; then
        nix-shell -p gnome.zenity
      else
        echo "Unsupported package manager. Please install Zenity manually."
      fi
    else
      echo "Zenity is required for this script. Exiting."
      exit 1
    fi
  fi
}

# Function to check if Zenity is installed
check_zenity() {
  if command -v zenity &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Function to prompt user with Zenity dialog
prompt_with_zenity() {
  zenity --question --title="Installation Script" --text="$1" --no-wrap
  return $?
}

# Function to prompt user without Zenity
prompt_without_zenity() {
  read -p "$1 (y/n): " response
  [[ "$response" =~ ^[Yy]$ ]]
}

# Function to prompt user for component installation
prompt_user() {
  local message="$1"
  local response

  if check_zenity; then
    prompt_with_zenity "$message"
  else
    prompt_without_zenity "$message"
  fi
}

# Main function
main() {
  clear
  print_message "Welcome to the installation script!"

  if prompt_user "Do you want to install zenity (don't work with only terminal)?"; then
    print_warning "Zenity will be used for interactive dialogs."
    install_zenity
  fi

  # Check if Zenity is installed
  if ! check_zenity; then
    print_message "Zenity is not installed. Proceeding with text-based interface."
  fi

  # Array to store options
  options=("FTP" "LAMP" "Website SSL")
  paths=("FTP" "LAMP" "site-web")

  # Array to store selected options
  selected_options=()

  # Iterate through options
  for ((i=0; i<${#options[@]}; i++)); do
    # Prompt user for installation
    if prompt_user "Do you want to install ${options[i]}?"; then
      # Install component
      install_component "${paths[i]}"
      selected_options+=("${options[i]}")
    fi
  done

  # Display selected options
  print_message "Selected options: ${selected_options[*]}"
}

# Call the main function
main