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

trap 'log_error "Failed at line $LINENO."' ERR

# VARIABLES _______________________________________________________________________________________
debug_mode=false
packages_names=()
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

#usage: install_from_pacman "${packages_pacman[@]}"
install_from_pacman() {
    local title="Install pacman packages"
    local args=()

    log_info "Starting." "$title"
    log_debug "Packages: ${*}." "$title"

    args+=('--spinner="dot"')
    args+=('--title="Running task..."')
    args+=('--show-error')
    if $debug_mode; then
        args+=('--show-output')
    fi
    gum spin "${args[@]}" \
        -- pacman -S "${@}" --noconfirm --needed

    log_info "${#@} packages installed successfully."
}

# MAIN PROGRAM ____________________________________________________________________________________
parse_args "${@}"
log_debug "Script arguments: $*."

update_system

readarray -t packages_names <"packages.txt"
classify_packages "${packages_names[@]}"

install_from_pacman "${packages_pacman[@]}"

if ! exist_in_system yay; then
    log_warn "This script uses Yay as AUR helper. Yay is going to be installed."
    install_yay
fi

#installYayPackages "${packages_aur[@]}"
#if gum confirm --timeout "1s" "Install godot extras?"; then
#    installGodot
#fi
#if gum confirm --timeout "1s" "Install VM extras?"; then
#    installVMUtils
#fi
#gum log -s -t "timeonly" -l "info" "Package install is over!"

# END OF PROGRAM __________________________________________________________________________________
