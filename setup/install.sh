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
  echo "Starting package installation..."

  echo "Upgrading OS"
  sudo pacman -Syu

  check_and_install_paru

  for pkg_file in "$(dirname "$0")/../pkg"/*; do
    if [[ -f "$pkg_file" ]]; then
      # Skip desktop packages if no desktop environment detected
      if [[ "$(basename "$pkg_file")" == "desktop" ]] && ! has_desktop_environment; then
        echo "No desktop environment detected, skipping desktop packages..."
        continue
      fi
      install_packages_from_file "$pkg_file"
    fi
  done

  echo "Package installation complete!"

}

main "$@"
