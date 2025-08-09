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

has_desktop_environment() {
  # Check for common desktop environment indicators
  if [[ -n "$XDG_CURRENT_DESKTOP" ]] || [[ -n "$DESKTOP_SESSION" ]]; then
    return 0
  fi

  # Check if X11 or Wayland is running
  if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    return 0
  fi

  # Check for common DE processes
  if pgrep -x "gnome-session\|kde-session\|xfce4-session\|lxsession\|mate-session" >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

main() {
  local ENV_TYPE="$1"
  echo "Starting package installation..."

  echo "Upgrading OS"
  sudo pacman -Syu

  check_and_install_paru

  # Install base packages
  BASE_PKG="$(dirname "$0")/../pkg/base"
  if [[ -f "$BASE_PKG" ]]; then
    install_packages_from_file "$BASE_PKG"
  fi

  # Install desktop packages if desktop environment detected
  if has_desktop_environment; then
    DESKTOP_PKG="$(dirname "$0")/../pkg/desktop"
    if [[ -f "$DESKTOP_PKG" ]]; then
      install_packages_from_file "$DESKTOP_PKG"
    fi
  else
    echo "No desktop environment detected, skipping desktop packages..."
  fi

  # Install environment-specific packages (home or work)
  if [[ -n "$ENV_TYPE" ]]; then
    ENV_PKG="$(dirname "$0")/../pkg/$ENV_TYPE"
    if [[ -f "$ENV_PKG" ]]; then
      echo "Installing $ENV_TYPE environment packages..."
      install_packages_from_file "$ENV_PKG"
    else
      echo "No $ENV_TYPE environment packages found, skipping..."
    fi
  fi

  # Install host-specific packages if available
  HOST_PKGS="$(dirname "$0")/../pkg/host/$(hostnamectl hostname)"
  if [[ -f "$HOST_PKGS" ]]; then
    echo "Installing host-specific packages from $HOST_PKGS..."
    install_packages_from_file "$HOST_PKGS"
  fi

  echo "Package installation complete!"

}

main "$@"
