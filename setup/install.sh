#!/bin/bash

set -e

check_and_install_paru() {
  if ! command -v paru &>/dev/null; then
    echo "Installing paru AUR helper..."
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/paru
  else
    echo "Updating paru..."
    paru -S --needed --noconfirm paru
  fi
}

install_packages_from_file() {
  local file="$1"
  local OFFICIAL=()
  local AUR=()

  if [[ ! -f "$file" ]]; then
    echo "Package file $file not found, skipping..."
    return
  fi

  echo "Processing packages from $file..."
  source "$file"

  if [[ ${#OFFICIAL[@]} -gt 0 ]]; then
    echo "Installing official packages: ${OFFICIAL[*]}"
    sudo pacman -S --needed --noconfirm "${OFFICIAL[@]}"
  fi

  if [[ ${#AUR[@]} -gt 0 ]]; then
    echo "Installing AUR packages: ${AUR[*]}"
    echo "Note: AUR packages will be reviewed during installation"
    paru -S --needed "${AUR[@]}"
  fi
}

main() {
  echo "Starting package installation..."

  check_and_install_paru

  for pkg_file in "$(dirname "$0")/../pkg"/*; do
    if [[ -f "$pkg_file" ]]; then
      install_packages_from_file "$pkg_file"
    fi
  done

  echo "Package installation complete!"

}

main "$@"
