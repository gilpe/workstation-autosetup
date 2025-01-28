#!/bin/bash

# Bash settings
set -o errexit                                  # abort on nonzero exitstatus
set -o nounset                                  # abort on unbound variable
set -o pipefail                                 # don't hide errors within pipes
trap 'echo "Script failed at line $LINENO"' ERR # catch non controled exceptions

# Check if Arch-Based
if [ ! -f /etc/arch-release ]; then
    echo "Sorry but this only runs in Arch-based distros :("
    exit 1
fi

# Resolve git dependency
if ! pacman -Qi "git" &>/dev/null; then
    echo "==> Installing git dependency..."
    sudo pacman -S git
fi

# Clone the whole repo
echo "==> Downloading the whole repo..."
script_dir=$(mktemp -d)
git clone --depth 1 https://github.com/gilpe/workstation-autosetup.git "$script_dir"
cd "$script_dir"

# Check setup script permissions
if [ ! -x "$script_dir/setup.sh" ]; then
    echo "==> Granting execution permissions to setup.sh..."
    chmod +x "$script_dir/setup.sh"
fi

#launch
echo "==> Launching setup.sh..."
./setup.sh
