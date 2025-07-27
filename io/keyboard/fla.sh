#!/bin/bash

# 1. If folder ~/qmk_firmware/ doesn't exist then run `qmk setup`
if [ ! -d "$HOME/qmk_firmware" ]; then
  echo "QMK firmware not found. Running qmk setup..."
  qmk setup
fi

# 2. Prompt user to input keymap file name 
read -p "Confirm flash? (y/n): " choice
if [[ $choice == [Yy] ]]; then
  read -p "Enter the keymap file name (or press enter for default keymap.json): " keymap_file
  keymap_file=${keymap_file:-keymap.json}
  qmk flash "$keymap_file"
else
  echo "Flash canceled."
fi
