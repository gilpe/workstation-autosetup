#!/bin/bash
#/
#/ Usage: SCRIPTNAME [flag]
#/
#/ Checks and get the necesary resources for launching the setup process
#/
#/ Flags:
#/   -h, --help         Print this help message
#/   -d, --debug        Enable debug mode for extra verbose
#/

# Imports
source lib/log.sh

# Bash settings
set -o errexit                                    # abort on nonzero exitstatus
set -o nounset                                    # abort on unbound variable
set -o pipefail                                   # don't hide errors within pipes
trap 'echo "Script failed at line $LINENO: "' ERR # catch non controled exceptions

# Variables
IFS=$'\n'
debug_mode=false
current_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Display the usage message
display_usage() {
    grep "^#/" "$current_dir/${0}" | sed "s/^#\/\($\| \)//;s/SCRIPTNAME/${0##*/}/"
}

parse_args() {
    for arg in "${@}"; do
        case "${arg}" in
        -h | --help)
            display_usage
            exit 0
            ;;
        -d | --debug)
            debug_mode=true
            break
            ;;
        *)
            display_usage
            echo "UNKNOWN FLAG: $arg. Check the usage info above."
            exit 2
            ;;
        esac
    done
}

# Run program
parse_args "${@}"

gum log -s -t "timeonly" -l "info" "Starting $option2."
downloadDotfiles
if gum confirm --timeout "1s" "Overwrite all the current configuration?"; then
    applyDotfiles
fi
if gum confirm --timeout "1s" "Change the current shell to zsh?"; then
    changeShell
fi
if gum confirm --timeout "1s" "Reboot now?"; then
    reboot=true
fi
gum log -s -t "timeonly" -l "info" "$option2 is over!"

if $reboot; then
    rebootSystem
fi
