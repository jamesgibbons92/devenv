#!/bin/bash

# Function to detect if system is a laptop
is_laptop() {
  # Check for battery presence
  if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    return 0
  fi

  # Check DMI chassis type (9=Laptop, 10=Notebook, 14=Sub Notebook)
  if [[ -f /sys/class/dmi/id/chassis_type ]]; then
    chassis_type=$(cat /sys/class/dmi/id/chassis_type)
    if [[ "$chassis_type" == "9" || "$chassis_type" == "10" || "$chassis_type" == "14" ]]; then
      return 0
    fi
  fi

  return 1
}

if is_laptop; then
  echo "Laptop detected - disabling hibernate but keeping suspend for lid close"
  # On laptops: disable hibernate and hybrid-sleep, but keep suspend for lid functionality
  sudo systemctl mask hibernate.target hybrid-sleep.target

  # Ensure suspend is available for lid close events
  sudo systemctl unmask suspend.target sleep.target
else
  echo "Desktop detected - disabling all sleep/hibernate modes"
  # On desktops: disable all sleep modes
  sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
fi
