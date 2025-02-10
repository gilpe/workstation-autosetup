#!/bin/bash

# SETTINGS ________________________________________________________________________________________
set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes
set -o errtrace # ensure ERR trap is inherited
trap 'catch $? $LINENO' ERR

# MAIN PROGRAM ____________________________________________________________________________________
if [ ! -f /etc/arch-release ]; then
    echo "Sorry but this only runs in Arch-based distros :("
    exit 1
fi
if ! pacman -Qi gum &>/dev/null; then
    echo "==> Installing gum dependency..."
    sudo pacman -S gum
fi
if ! pacman -Qi git &>/dev/null; then
    echo "==> Installing git dependency..."
    sudo pacman -S git
fi
echo "==> Downloading the whole repo..."
temp_dir=$(mktemp -d)
echo "==> Temporary directory created at $temp_dir"
git clone --depth 1 "https://github.com/gilpe/workstation-autosetup.git" "$temp_dir"
cd "$temp_dir"
echo "==> Changed to directory $(pwd)"
if [ ! -x setup.sh ]; then
    echo "==> Granting execution permissions to setup.sh..."
    chmod +x setup.sh
fi
echo "==> Launching setup.sh..."
./setup.sh
# END OF PROGRAM __________________________________________________________________________________
