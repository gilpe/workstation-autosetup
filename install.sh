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

#usage: install_packages "pacman" "${packages_names[@]}"
#usage: install_packages "yay" "${packages_names[@]}"
install_packages() {
    local title="Install packages"
    local args=()
    local manager="$1"
    shift

    log_info "Starting." "$title"
    log_debug "Manager: $manager. Packages: ${*}." "$title"

    args+=('--spinner="dot"')
    args+=('--title="Running task..."')
    args+=('--show-error')
    if $debug_mode; then
        args+=('--show-output')
    fi
    gum spin "${args[@]}" \
        -- "$manager" -S "${@}" --noconfirm --needed

    log_info "${#@} packages installed successfully." "$title"
}

#usage: build_package "$source_dir"
build_package() {
    local title="Build package"
    local origin_dir
    local args=()

    log_info "Starting." "$title"
    log_debug "Sources dir: ${*}." "$title"

    origin_dir=$(
        cd "$(dirname "$0")"
        pwd
    )
    log_debug "Origin dir: $origin_dir." "$title"
    cd "$1"

    args+=('--spinner="dot"')
    args+=('--title="Running task..."')
    args+=('--show-error')
    if $debug_mode; then
        args+=('--show-output')
    fi
    gum spin "${args[@]}" \
        -- makepkg -si --noconfirm

    cd "$origin_dir"
    log_info "Was done successfully." "$title"
}

#usage: install_yay
install_yay() {
    local title="Install yay"
    local origin_dir
    local temp_dir
    local args=()

    log_info "Creating temporary directory." "$title"
    temp_dir=$(mktemp -d)
    log_debug "Created dir: $temp_dir." "$title"

    log_info "Downloading sources." "$title"
    clone_repo https://aur.archlinux.org/yay.git "$temp_dir"

    if ! exist_in_system base-devel; then
        log_info "Installing dependencies." "$title"
        install_from_pacman base-devel
    fi

    build_package "$temp_dir/yay"

    log_info "Was done successfully." "$title"
}

# MAIN PROGRAM ____________________________________________________________________________________
parse_args "${@}"
log_debug "Script arguments: $*."

update_system

readarray -t packages_names <"packages.txt"
classify_packages "${packages_names[@]}"

install_packages pacman "${packages_pacman[@]}"

if ! exist_in_system yay; then
    log_warn "This script uses Yay as AUR helper. Yay is going to be installed."
    install_yay
fi
install_packages yay "${packages_aur[@]}"

#if gum confirm --timeout "1s" "Install godot extras?"; then
#    installGodot
#fi
#if gum confirm --timeout "1s" "Install VM extras?"; then
#    installVMUtils
#fi
#gum log -s -t "timeonly" -l "info" "Package install is over!"

# END OF PROGRAM __________________________________________________________________________________
