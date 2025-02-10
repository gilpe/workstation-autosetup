#!/bin/bash
#/
#/ Usage: SCRIPTNAME [flag]
#/
#/ Installs the packages from the package list, its dependencies and extras.
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

    log_info "Starting." "$title"

    args+=("--spinner=dot")
    args+=("--title='Running task...'")
    args+=("--show-error")
    if $debug_mode; then
        args+=("--show-output")
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

    log_info "Starting." "$title"
    log_debug "File path: $1." "$title"

    log_info "Extracting file content." "$title"
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

#usage: build_package "$source_dir"
build_package() {
    local title="Build package"
    local origin_dir
    local args=()

    log_info "Starting." "$title"
    log_debug "Sources dir: ${*}." "$title"

    if ! exist_in_system base-devel; then
        log_warn "base-devel is needed, so it is going to be installed now." "$title"
        install_packages pacman base-devel
    fi

    origin_dir=$(
        cd "$(dirname "$0")"
        pwd
    )
    log_debug "Origin dir: $origin_dir." "$title"
    cd "$1"
    args+=("--spinner=dot")
    args+=("--title='Running task...'")
    args+=("--show-error")
    if $debug_mode; then
        args+=("--show-output")
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

    log_info "Starting." "$title"

    if exist_in_system yay-sdk; then
        log_warn "yay is already installed." "$title"
    else
        log_info "Creating temporary directory." "$title"
        temp_dir=$(mktemp -d)
        log_debug "Created dir: $temp_dir." "$title"
        log_info "Downloading sources." "$title"
        clone_repo https://aur.archlinux.org/yay.git "$temp_dir"
        build_package "$temp_dir/yay"
    fi

    log_info "Was done successfully." "$title"
}

#usage: add_to_path "$path"
add_to_path() {
    local title="Add to Path"

    log_info "Starting." "$title"
    log_debug "Path to add: $1." "$title"

    if ! [[ ":$PATH:" != *":$1:"* ]]; then
        log_warn "Nothing to do. Path is already added." "$title"
        return 0
    fi
    PATH="${PATH:+"$PATH:"}$1"

    log_info "Was done successfully." "$title"
}

#usage: install_dotnet
install_dotnet() {
    local title="Install dotnet"

    log_info "Starting." "$title"

    if exist_in_system dotnet-sdk; then
        log_warn "dotnet-sdk is already installed." "$title"
    else
        install_packages pacman dotnet-sdk
        add_to_path "$HOME/.dotnet/tools"
    fi

    log_info "Was done successfully." "$title"
}

#usage: install_godotenv
install_godotenv() {
    local title="Install GodotEnv"
    local args=()

    log_info "Starting." "$title"

    if ! exist_in_system dotnet-sdk; then
        log_warn "dotnet-sdk is needed, so it is going to be installed now." "$title"
        install_dotnet
    fi

    args+=("--spinner=dot")
    args+=("--title='Running task...'")
    args+=("--show-error")
    if $debug_mode; then
        args+=("--show-output")
    fi
    gum spin "${args[@]}" \
        -- dotnet tool install -g Chickensoft.GodotEnv

    log_info "Was done successfully." "$title"
}

#usage: install_godot
install_godot() {
    local title="Install Godot"
    local latest_version
    local args=()

    log_info "Starting." "$title"

    if ! dotnet tool list -g Chickensoft.GodotEnv &>/dev/null; then
        log_warn "godotenv is needed so it is going to be installed now." "$title"
        install_godotenv
    fi
    log_info "Querying the latest version." "$title"
    latest_version=$(godotenv godot list -r | grep --max-count=1 "stable" | sed 's/-stable//')
    log_debug "Latest version: $latest_version." "$title"
    log_info "Downloading the latest version." "$title"
    args+=("--spinner=dot")
    args+=("--title='Running task...'")
    args+=("--show-error")
    if $debug_mode; then
        args+=("--show-output")
    fi
    gum spin "${args[@]}" \
        -- godotenv godot install "$latest_version"

    log_info "Was done successfully." "$title"
}

#usage: install_vm_utils
install_vm_utils() {
    local title="Install VM Utils"

    log_info "Starting." "$title"

    install_packages pacman virtualbox-guest-utils foot

    log_info "Was done successfully." "$title"
}

# MAIN PROGRAM ____________________________________________________________________________________
parse_args "${@}"
log_debug "Script arguments: $*."

log_info "Package installation script started."

update_system

readarray -t packages_names <"packages.txt"
classify_packages "${packages_names[@]}"

install_packages pacman "${packages_pacman[@]}"

if ! exist_in_system yay; then
    log_warn "This script uses Yay as AUR helper. yay is going to be installed."
    install_yay
fi
install_packages yay "${packages_aur[@]}"

log_warn "Ahead comes some additional steps to install optional extras. \
    Please make your choice o wait for default (Yes)."
if gum confirm --timeout "5s" "Do you want to install Godot extras?"; then
    install_dotnet
    install_godotenv
    install_godot
fi
if gum confirm --timeout "5s" "VMs maybe needs extra packages. Is this a VM? "; then
    install_vm_utils
fi

log_info "Package installation is over!"
# END OF PROGRAM __________________________________________________________________________________
