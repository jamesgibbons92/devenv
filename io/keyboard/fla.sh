#!/bin/bash

# 1. If folder ~/qmk_firmware/ doesn't exist then run `qmk setup`
if [ ! -d "$HOME/qmk_firmware" ]; then
  echo "QMK firmware not found. Running qmk setup..."
  qmk setup
fi

# 2. Run qmk flash keymap.json
qmk flash keymap.json
