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
declare -rA menu_options=(
    ["Package installation"]="install.sh"
    ["Configuration import"]="config.sh"
)
script_name=""

# Functions
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

display_welcome() {
    echo -e "\n"
    gum style --faint --border none --align right --width 50 \
        "Be welcome to..."
    gum style --border double --align center --width 50 --padding "1 2" --border-foreground 212 \
        "$(
            gum style --bold --foreground 85 \
                "Gilpe"
        )'s package installer and dotfile setter" "for a new workstation"
    log_i "A brief advice:"
    gum format -- "" \
        "> This script runs incrementally and on priority." \
        "> Each step normally requires the execution of the previous one." \
        "> You can stop when you want and resume later." \
        "> But a recomendation is to run it all at once." \
        "> Enjoy the ride! 🚀"
    echo -e "\n"
    if $debug_mode; then log_d "Debug mode is enabled."; fi
}

display_farewell() {
    log_i "The end."
    gum style --border none --align center --width 50 --padding "1 2" \
        "See $(
            gum style --bold --foreground 85 "you"
        ) later 🫡"
}

# Run program
if $debug_mode; then log_d "Script arguments: $*."; fi
parse_args "${@}"

display_welcome

menu_choices=$(gum choose --cursor "👉 " --no-limit --header "Pick at least one process to be done:" "${!menu_options[@]}")
if $debug_mode; then log_d "Menu choices: $menu_choices."; fi

if [ -z "$menu_choices" ]; then
    log_w "It looks like you haven't selected anything."
else
    for choice in "${menu_choices[@]}"; do
        log_i "Starting $choice sub-process..."
        script_name=${menu_options[$choice]}
        if [ ! -x "$script_name" ]; then
            log_i "Granting execution permissions to $script_name."
            chmod +x "$script_name"
        fi
        sudo ./"$script_name"
        log_i "Finishing $choice sub-process..."
    done
fi

display_farewell
#End program
