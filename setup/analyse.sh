#!/bin/bash
set -e

packages=$(pacman -Qe | awk '{print $1}')
echo "Scanning"

for pkg in $packages; do
  found=false
  for file in "$(dirname "$0")/../pkg"/*; do
    if grep -q "^$pkg$" "$file"; then
      found=true
      break
    fi
  done

  if ! $found; then
    echo "Package '$pkg' not found in any group file."
    echo "Options:"
    echo "1. Skip"
    echo "2. Remove"

    # Dynamically list group files
    #group_files=(./group/$HOST/*)
    #for i in "${!group_files[@]}"; do
    #  echo "$((i + 3)). Add to ${group_files[$i]##*/}"
    #done

    read -p "Enter your choice (1-$((${#group_files[@]} + 2))): " choice

    case $choice in
    1)
      echo "Skipped '$pkg'"
      ;;
    2)
      sudo pacman -D --asdeps "$pkg"
      echo "Removed '$pkg'"
      ;;
    *)
      #if [ "$choice" -ge 3 ] && [ "$choice" -le $((${#group_files[@]}+2)) ]; then
      #    selected_file="${group_files[$((choice-3))]}"
      #    echo "$pkg" >> "$selected_file"
      #    echo "Added '$pkg' to ${selected_file##*/}"
      #else
      echo "Invalid choice. Skipped '$pkg'"
      #fi
      ;;
    esac
    echo "----------------------------------------"
  fi
done
