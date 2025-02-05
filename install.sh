#!/bin/bash
#/
#/ Usage: SCRIPTNAME [flag]
#/
#/ Installs the packages from the package list and its dependencies .
#/
#/ Flags:
#/   -h, --help         Print this help message
#/   -d, --debug        Enable debug mode for extra verbose
#/

# SETTINGS ________________________________________________________________________________________
source lib/log.sh

set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes
set -o errtrace # ensure ERR trap is inherited

trap 'logE "Failed at line $LINENO."' ERR

# VARIABLES _______________________________________________________________________________________
debug_mode=false
packages_pacman=()
packages_aur=()

# FUNCTIONS _______________________________________________________________________________________

#usage: update_system
update_system() {
    local title="Update system"
    local args=()

    log_info "Syncing repos and update packages." "$title"
    args+=('--spinner="dot"')
    args+=('--title="Running task..."')
    args+=('--show-error')
    if $debug_mode; then
        args+=('--show-output')
    fi

    gum spin "${args[@]}" \
        -- pacman -Syu --noconfirm --needed

    log_info "All up to date." "$title"
}

#usage: exist_in_repos "$package_name"
exist_in_repos() {
    pacman -Si "$1" &>/dev/null
}

#usage: classify_packages "$file_path"
classify_packages() {
    local title="Classify packages"
    local line_count=0
    local installed_count=0
    local package_names=()

    log_info "Extracting file content." "$title"
    log_debug "File path: $1." "$title"
    mapfile -t package_names <"$1"

    log_info "Iterating package list." "$title"
    for package_name in "${package_names[@]}"; do
        line_count=$((line_count + 1))
        if exist_in_system "$package_name"; then
            log_warn "$package_name excluded, it's already installed." "$title"
            installed_count=$((installed_count + 1))
        elif exist_in_repos "$package_name"; then
            packages_pacman+=("$package_name")
            log_debug "$package_name moved to Pacman list" "$title"
        else
            packages_aur+=("$package_name")
            log_debug "$package_name moved to AUR list." "$title"
        fi
    done

    log_info "$line_count found. $installed_count installed. ${#packages_pacman[@]} from pacman. ${#packages_aur[@]} from AUR." "$title"
}

#Install packages from Pacman package manager.
#usage: installPacmanPackages "${packages_names[@]}"
installPacmanPackages() {
    logI "Installing packages."
    if $debug_mode; then
        logD "Params [ ${*} ]." "󰘍"
    fi
    if [ ${#@} -eq 0 ]; then
        gum log -s -t "timeonly" -l "warn" --prefix "󰘍" "Nothing to be installed."
        return 1
    fi
    if ! gum spin --spinner dot --show-error --title "Running task..." \
        -- pacman -S "${@}" --noconfirm --needed; then
        gum log -s -t "timeonly" -l "error" --prefix "󰘍" "Something crashed."
        return 1
    fi
    gum log -s -t "timeonly" -l "info" --prefix "󰘍" "${#@} installed successfully."
    return 0
}

# MAIN PROGRAM ____________________________________________________________________________________
parse_args "${@}"
log_debug "Script arguments: $*."

update_system

readarray -t package_names <"packages.txt"
classify_packages "${package_names[@]}"
#installPacmanPackages "${packages[@]}"
#installYayPackages "${packages_aur[@]}"
#if gum confirm --timeout "1s" "Install godot extras?"; then
#    installGodot
#fi
#if gum confirm --timeout "1s" "Install VM extras?"; then
#    installVMUtils
#fi
#gum log -s -t "timeonly" -l "info" "Package install is over!"

# END OF PROGRAM __________________________________________________________________________________
