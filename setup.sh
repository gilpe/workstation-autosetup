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
set -o errexit  # abort on nonzero exitstatus
set -o pipefail # don't hide errors within pipes
set -o errtrace # ensure ERR trap is inherited

# Signal catching
trap 'log_e "Failed at line $LINENO."' ERR

# Variables
IFS=$'\n'
debug_mode=false
declare -rA menu_options=(
    ["Package installation"]="install.sh"
    ["Configuration import"]="config.sh"
)
menu_choices=""
script_name=""

# Functions
display_usage() {
    grep "^#/" "${0}" | sed "s/^#\/\($\| \)//;s/SCRIPTNAME/${0##*/}/"
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
    gum style --faint --italic --border none --align right --width 50 \
        "Be welcome to..."
    gum style --border double --align center --width 50 --padding "1 2" --border-foreground 212 \
        "$(
            gum style --bold --foreground 10 \
                "Gilpe"
        )'s package installer and dotfile setter" "for a new workstation"
    if $debug_mode; then log_d "Debug mode is enabled."; fi
    log_i "A brief advice:"
    gum format -- "" \
        "> This script runs incrementally and on priority." \
        "> Each step normally requires the execution of the previous one." \
        "> You can stop when you want and resume later." \
        "> But a recomendation is to run it all at once." \
        "> Enjoy the ride! 🚀"
    echo -e "\n"
}

display_farewell() {
    log_i "The end."
    gum style --border none --align center --width 50 --padding "1 2" \
        "See $(
            gum style --bold --foreground 10 "you"
        ) later 🫡"
}

# Run program
parse_args "${@}"

display_welcome

menu_choices=$(gum choose --cursor "👉 " --no-limit --header "Pick at least one process to be done:" "${!menu_options[@]}")
if $debug_mode; then log_d "Menu choices: [$menu_choices]."; fi
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
        sudo ./"$script_name" "${@}"
        log_i "Finishing $choice sub-process..."
    done
fi

display_farewell
#End program
