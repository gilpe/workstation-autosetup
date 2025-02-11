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
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes
set -o errtrace # ensure ERR trap is inherited
trap 'catch $? $LINENO' ERR

# VARIABLES _______________________________________________________________________________________
declare -rA menu_options=(
    ["Package installation"]="install.sh"
    ["Configuration import"]="config.sh"
)
declare -a menu_choices=()
reboot=false

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

#usage: readarray -t menu_choices < <(get_menu_choices)
get_menu_choices() {
    for choice in $(gum choose --cursor "👉 " --no-limit --header "Pick at least one process to be done:" \
        "${!menu_options[@]}"); do
        if [ -n "$choice" ]; then menu_choices+=("$choice"); fi
    done
    if [ ${#menu_choices[@]} -gt 0 ]; then
        log_debug "Selected choices: ${menu_choices[*]}."
        echo "${menu_choices[*]}."
    fi
}

#usage: execute_option "$option_name"
execute_option() {
    local option=$1
    local script_name
    log_info "Starting $option sub-process..."
    script_name=${menu_options[$option]}
    if [ ! -x "$script_name" ]; then
        log_info "Granting execution permissions to $script_name."
        chmod +x "$script_name"
    fi
    ./"$script_name" "${@}"
    log_info "Finishing $option sub-process..."
}

# MAIN PROGRAM ____________________________________________________________________________________
parse_args "${@}"
display_welcome
log_debug "Script arguments: $*."
readarray -t menu_choices < <(get_menu_choices)
if [ ${#menu_choices[@]} -eq 0 ]; then
    log_warn "It looks like you haven't selected anything."
else
    for choice in "${menu_choices[@]}"; do
        process_choice "$choice"
    done
    log_warn "Many things may have happened in the system. Maybe it's a good idea to reboot it now."
    reboot=$(gum confirm "Do you want to reboot system now?")
fi
display_farewell
if $reboot; then
    gum spin --spinner dot --title "Rebooting..." -- sleep 3
    sudo systemctl reboot
fi
# END OF PROGRAM __________________________________________________________________________________
