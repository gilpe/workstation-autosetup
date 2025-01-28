#!/bin/bash
#/ Automatic setup script for my linux workstations (By Gilpe)
#/ Usage: SCRIPTNAME [--help|-h] [--debug|-d]

# Bash settings
set -o errexit                                  # abort on nonzero exitstatus
set -o nounset                                  # abort on unbound variable
set -o pipefail                                 # don't hide errors within pipes
trap 'echo "Script failed at line $LINENO"' ERR # catch non controled exceptions

# Variables
IFS=$'\t\n' # Split on newlines and tabs (but not on spaces)

# Prints the usage message
function print_usage() {
    local script_dir, script_name
    script_name=$(basename "${0}")
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    grep '^#/' "${script_dir}/${script_name}" | sed 's/^#\/\($\| \)//'
}

# Process the script arguments. Usage: process_args "${@}"
function process_args() {
    for arg in "${@}"; do
        case "${arg}" in
        -h | --help)
            print_usage
            exit 0
            ;;
        -*)
            echo "Unknown option: ${arg}"
            print_usage
            exit 2
            ;;
        *)
            break
            ;;
        esac
    done
}

#Main program logic
function main() {
    if [ -f /etc/arch-release ]; then
        echo "Sorry but this only runs in Arch-based distros :("
        exit 1
    fi
    if [ "$EUID" -ne 0 ]; then
        echo "Sorry but this will need to install some things. Please, re-run it as sudo :)"
        exit 1
    fi
    process_args "${@}"
    git clone --depth 1 https://github.com/gilpe/workstation-autosetup.git
    cd workstation-autosetup
    sudo ./install.sh "$1"
}

# Run
main "${@}"
