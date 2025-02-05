#!/bin/bash

# SETTINGS ________________________________________________________________________________________
set -o errexit                                  # abort on nonzero exitstatus
set -o nounset                                  # abort on unbound variable
set -o pipefail                                 # don't hide errors within pipes
trap 'echo "Script failed at line $LINENO"' ERR # catch non controled exceptions

# MAIN PROGRAM ____________________________________________________________________________________
if [ ! -f /etc/arch-release ]; then
    echo "Sorry but this only runs in Arch-based distros :("
    exit 1
fi

# Resolve git dependency
if ! pacman -Qi gum &>/dev/null; then
    echo "==> Installing gum dependency..."
    sudo pacman -S gum
fi

# Resolve git dependency
if ! pacman -Qi git &>/dev/null; then
    echo "==> Installing git dependency..."
    sudo pacman -S git
fi

# Clone the whole repo
echo "==> Downloading the whole repo..."
temp_dir=$(mktemp -d)
git clone --depth 1 https://github.com/gilpe/workstation-autosetup.git "$temp_dir="
cd "$temp_dir"

# Check setup script permissions
if [ ! -x setup.sh ]; then
    echo "==> Granting execution permissions to setup.sh..."
    chmod +x setup.sh
fi

#launch
echo "==> Launching setup.sh..."
sudo ./setup.sh
# END OF PROGRAM __________________________________________________________________________________
