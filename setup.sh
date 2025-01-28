#!/bin/bash
#/ Usage: SCRIPTNAME [OPTIONS]...
#/
#/ Automatic setup script for my linux workstations (By Gilpe)
#/
#/ OPTIONS
#/   -h, --help
#/                Print this help message
#/   -d, --debug
#/                Enable debug mode for extra verbose
#/

# Bash settings
set -o errexit                                  # abort on nonzero exitstatus
set -o nounset                                  # abort on unbound variable
set -o pipefail                                 # don't hide errors within pipes
trap 'echo "Script failed at line $LINENO"' ERR # catch non controled exceptions

# Variables
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Prints the usage message
function print_usage() {
    grep "^#/" "$script_dir/${0}" | sed "s/^#\/\($\| \)//;s/SCRIPTNAME/${0##*/}/"
}

# Process the script arguments. Usage: process_args "${@}"
function process_args() {
    for arg in "${@}"; do
        case "${arg}" in
        -h | --help)
            print_usage
            exit 0
            ;;
        -d | --debug)
            break
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
    if [ ! -f /etc/arch-release ]; then
        echo "Sorry but this only runs in Arch-based distros :("
        exit 1
    fi
    process_args "${@}"
    if [ ! -f "$script_dir/install.sh" ]; then
        script_dir=$(mktemp -d)
        git clone --depth 1 https://github.com/gilpe/workstation-autosetup.git "$script_dir"
        cd "$script_dir"
    fi
    ./install.sh "$1"
}

# Run
main "${@}"
