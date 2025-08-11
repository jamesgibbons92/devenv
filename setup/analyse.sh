#!/bin/bash
set -e

packages=$(pacman -Qe | awk '{print $1}')
echo "Scanning"

for pkg in $packages; do
  # Check if package is in ignore file
  ignore_file="$(dirname "$0")/../pkg/.ignore"
  if [ -f "$ignore_file" ] && grep -q "^$pkg$" "$ignore_file"; then
    continue
  fi

  found=false
  for file in "$(dirname "$0")/../pkg"/*; do
    if [ "$(basename "$file")" = ".ignore" ]; then
      continue
    fi
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
    echo "3. Ignore (add to .ignore file)"

    # Dynamically list group files
    #group_files=(./group/$HOST/*)
    #for i in "${!group_files[@]}"; do
    #  echo "$((i + 4)). Add to ${group_files[$i]##*/}"
    #done

    read -p "Enter your choice (1-3): " choice

    case $choice in
    1)
      echo "Skipped '$pkg'"
      ;;
    2)
      sudo pacman -D --asdeps "$pkg"
      echo "Removed '$pkg'"
      ;;
    3)
      ignore_file="$(dirname "$0")/../pkg/.ignore"
      mkdir -p "$(dirname "$ignore_file")"
      read -p "Reason for ignoring '$pkg' (optional): " reason
      if [ -n "$reason" ]; then
        echo "$pkg # $reason" >> "$ignore_file"
      else
        echo "$pkg" >> "$ignore_file"
      fi
      echo "Added '$pkg' to ignore list"
      ;;
    *)
      #if [ "$choice" -ge 4 ] && [ "$choice" -le $((${#group_files[@]}+3)) ]; then
      #    selected_file="${group_files[$((choice-4))]}"
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
