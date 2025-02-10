#!/bin/bash
#/
#/ Usage: SCRIPTNAME [flag]
#/
#/ Checks and obtains the resources required to start the setup processes.
#/
#/ Flags:
#/   -h, --help         Print this help message
#/   -d, --debug        Enable debug mode for extra verbose
#/

# SETTINGS ________________________________________________________________________________________
source lib/common.sh
set -o errexit  # abort on nonzero exitstatus
set -o pipefail # don't hide errors within pipes
set -o errtrace # ensure ERR trap is inherited
trap 'catch $? $LINENO' ERR

# VARIABLES _______________________________________________________________________________________
declare -rA menu_options=(
    ["Package installation"]="install.sh"
    ["Configuration import"]="config.sh"
)
declare -a menu_choices=()
script_name=""

# FUNCTIONS _______________________________________________________________________________________

#usage: display_welcome
display_welcome() {
    echo -e "\n"
    gum style --faint --italic --border none --align right --width 50 \
        "Be welcome to..."
    gum style --border double --align center --width 50 --padding "1 2" --border-foreground 212 \
        "$(
            gum style --bold --foreground 10 \
                "Gilpe"
        )'s package installer and dotfile setter" "for a new workstation"
    log_debug "Debug mode is enabled."
    log_warn "A brief advice:"
    gum format -- "" \
        "> This script runs incrementally and on priority." \
        "> Each step normally requires the execution of the previous one." \
        "> A good recomendation is to run it all at once." \
        "> Enjoy the ride! 🚀"
    echo -e "\n"
}

#usage: display_farewell
display_farewell() {
    log_info "The end."
    gum style --border none --align center --width 50 --padding "1 2" \
        "See $(
            gum style --bold --foreground 10 "you"
        ) later 🫡"
}

rebootSystem() {
    log_warn "Many things may happened in the system. Maybe it's a good idea to reboot it now."
    if gum confirm --timeout=10s --default=yes "Do you want to reboot system now?"; then
        gum spin --spinner dot --title "Rebooting..." -- sleep 3
        systemctl reboot
    fi
}

# MAIN PROGRAM ____________________________________________________________________________________
parse_args "${@}"
log_debug "Script arguments: $*."
display_welcome
readarray -t menu_choices < <(gum choose --cursor "👉 " --no-limit --header "Pick at least one process to be done:" \
    "${!menu_options[@]}")
if [ ${#menu_choices[@]} == 0 ]; then
    log_warn "It looks like you haven't selected anything."
else
    log_debug "Menu choices: ${menu_choices[*]}."
    for choice in "${menu_choices[@]}"; do
        log_info "Starting $choice sub-process..."
        script_name=${menu_options[$choice]}
        if [ ! -x "$script_name" ]; then
            log_info "Granting execution permissions to $script_name."
            chmod +x "$script_name"
        fi
        ./"$script_name" "${@}"
        log_info "Finishing $choice sub-process..."
    done
fi
display_farewell
rebootSystem
# END OF PROGRAM __________________________________________________________________________________
