#!/bin/bash

# Dotfiles and bootstrap installer
# Installs homebrew, core dependencies and chezmoi

set -euo pipefail

trap on_error ERR

e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Success reporter
info() {
  echo -e "${CYAN}${*}${RESET}"
}

# Error reporter
error() {
  echo -e "${RED}${*}${RESET}"
}

# Success reporter
success() {
  echo -e "${GREEN}${*}${RESET}"
}

# End section
finish() {
  success "Done!"
  echo
  sleep 1
}

# Set directory
GITHUB_REPO="willscottuk/dotfiles"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

on_start() {
  info "           __        __   ____ _  __           "
  info "      ____/ /____   / /_ / __/(_)/ /___   _____"
  info "     / __  // __ \ / __// /_ / // // _ \ / ___/"
  info "  _ / /_/ // /_/ // /_ / __// // //  __/(__  ) "
  info " (_)\__,_/ \____/ \__//_/  /_//_/ \___//____/  "
  info "                                               "
  info "              by @willscottuk                  "
  info "                                               "

  info "👋  This script will setup .dotfiles for you."
  echo "    It will not install anything without your direct agreement!"
  echo
  read -p "    Do you want to proceed with installation? [y/N] " -n 1 answer
  echo
  if [ "${answer}" != "y" ]; then
    exit 1
  fi
}

root_check() {

info "👮‍♂️  Checking user permissions"

if (( $EUID != 0 )); then
    return
else
  # We can't install Homebrew as root; we need to create a user
  if ! _exists brew; then
    read -p "Enter username : " username
    read -s -p "Enter password : " password
    #echo $username
    if id "$username" &>/dev/null; then
      error "user ${username} already exists"
      exit 1
    else
      echo 'user does not already exist'
      useradd -m -p $(openssl passwd -1 $password) $username
      [ $? -eq 0 ] && success "User has been added to system!" || error "Failed to add the user!"
      # Add them to sudoers
      echo $username'  ALL=(ALL:ALL) ALL' >> /etc/sudoers
      # Add ssh keys
        # Make directory
        sudo -u $username mkdir -p /home/$username/.ssh
        sudo -u $username touch /home/$username/.ssh/authorized_keys
        curl --output >(cat >> /home/$username/.ssh/authorized_keys) https://raw.githubusercontent.com/${GITHUB_REPO}/main/private_dot_ssh/authorized_keys
        IPV4_ADDRESS=$(curl -s checkip.amazonaws.com)
        error "🧑‍💻  Now ssh as the new user"
        echo "    ssh -A ${username}"

        exit 0

    fi
  fi
fi


}

install_homebrew() {
  info "🍺  Trying to detect installed Homebrew..."

  if ! _exists brew; then
    echo "    Seems like you don't have Homebrew installed!"
    read -p "    Proceed with Homebrew installation? [y/N] " -n 1 answer
    echo
    if [ "${answer}" != "y" ]; then
      exit 1
    fi

    info "    Installing Homebrew..."
    ## TODO - If Linux, install dependencies: sudo apt-get install build-essential
    ## TODO - 
    bash -c "$(curl -fsSL ${HOMEBREW_INSTALLER_URL})"
    if [ "$(uname)" = "Darwin" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
  else
    success "⏭️  You already have Homebrew installed. Skipping..."
  fi

  finish
}

install_git() {
  info "Trying to detect installed Git..."

  if ! _exists git; then
    echo "Seems like you don't have Git installed!"
    read -p "Do you agree to proceed with Git installation? [y/N] " -n 1 answer
    echo
    if [ "${answer}" != "y" ]; then
      exit 1
    fi

    info "Installing Git..."

    if [ "$(uname)" = "Darwin" ]; then
      brew install git
    elif [ "$(uname)" = "Linux" ]; then
      sudo apt-get install git
    else
      error "Error: Failed to install Git!"
      exit 1
    fi
  else
    success "⏭️  You already have Git installed. Skipping..."
  fi

  finish
}

install_zsh() {
  info "Trying to detect installed Zsh..."

  if ! _exists zsh; then
    echo "Seems like you don't have Zsh installed!"
    read -p "Do you agree to proceed with Zsh installation? [y/N] " -n 1 answer
    echo
    if [ "${answer}" != "y" ]; then
      exit 1
    fi

    info "Installing Zsh..."

    if [ "$(uname)" = "Darwin" ]; then
      brew install zsh zsh-completions
    elif [ "$(uname)" = "Linux" ]; then
      brew install zsh zsh-completions
    else
      error "Error: Failed to install Zsh!"
      exit 1
    fi
  else
    success "⏭️  You already have Zsh installed. Skipping..."
  fi

  if _exists zsh; then
    info "Setting up Zsh as default shell..."

    echo "The script will ask you the password for sudo:"
    echo
    echo "1) When changing your default shell via chsh -s"
    echo

    command -v zsh | sudo tee -a /etc/shells

    chsh -s "$(command -v zsh)" || error "Error: Cannot set Zsh as default shell!"
  fi

  finish
}

install_software() {
  if [ "$(uname)" != "Darwin" ]; then
    return
  fi

  info "🍻  Installing from Brewfile"

  # Homebrew Bundle
  if _exists brew; then
    brew bundle --file=./setup/Brewfile
  else
    error "🚨  Error: Brew is not available"
  fi

  finish
}

install_omzsh() {

  if [ ! -f ~/.oh-my-zsh/oh-my-zsh.sh ]; then

    info "💰  Installing oh-my-zsh"

    (yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")

  fi

  info "⏭️  You already have Oh My Zsh installed. Skipping..."

  finish
}


install_chezmoi() {

  if ! _exists chezmoi; then

    info "🏡  Installing chezmoi"

    brew install chezmoi

  else
    success "⏭️  You already have Chezmoi installed. Skipping..."
  fi

  if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    info "🚸  chezmoi already initialized, applying..."
  else
    info "🚀  Initializing chezmoi from ${GITHUB_REPO}..."
    chezmoi init "https://github.com/${GITHUB_REPO}.git"
  fi

  info "📦  Applying dotfiles..."
  chezmoi apply


  finish
}

on_finish() {
  echo
  success "Setup was successfully done!"
  success "Happy Coding!"
  echo
  echo -ne "$RED"'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  "$RESET""$BOLD"',------,'"$RESET"
  echo -ne "$YELLOW"'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  "$RESET""$BOLD"'|   /\_/\\'"$RESET"
  echo -ne "$GREEN"'-_-_-_-_-_-_-_-_-_-_-_-_-_-'
  echo -e  "$RESET""$BOLD"'~|__( ^ .^)'"$RESET"
  echo -ne "$CYAN"'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  "$RESET""$BOLD"'""  ""'"$RESET"
  echo
  info "P.S: Don't forget to restart a terminal :)"
  echo
}

on_error() {
  echo
  error "Wow... Something serious happened!"
  error "Though, I don't know what really happened :("
  error "In case, you want to help me fix this problem, raise an issue -> ${CYAN}https://github.com/${GITHUB_REPO}/issues/new${RESET}"
  echo
  exit 1
}

main() {
  on_start "$*"
  root_check "$*"
  install_homebrew "$*"
  install_git "$*"
  install_zsh "$*"
  install_software "$*"
  install_chezmoi "$*"
  on_finish "$*"
}

main "$*"