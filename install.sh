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
packages=()
packages_aur=()

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

updateInstalled() {
    log_i "Updating installed packages."
    gum spin --spinner dot --show-error --title "Running task..." \
        -- pacman -Syu --noconfirm --needed
}

isInstalled() {
    if [ -z "$1" ]; then return 1; fi
    pacman -Qi "$1" &>/dev/null
}

isAUR() {
    if [ -z "$1" ]; then return 1; fi
    ! pacman -Si "$1" &>/dev/null
}

loadPackageLists() {
    log_i "Loading package lists from file."
    local line_count=0
    local installed_packages=()
    log_i "Iterating lines." "󰘍"
    while read -r package_name || [ -n "${package_name}" ]; do
        line_count=$((line_count + 1))
        if isInstalled "$package_name"; then
            log_w "$package_name excluded, it's already installed." "󰘍"
            installed_packages+=("$package_name")
        else
            if isAUR "$package_name"; then
                packages_aur+=("$package_name")
            else
                packages+=("$package_name")
            fi
        fi
    done <"packages.txt"
    log_i "$line_count found. ${#installed_packages[@]} installed. ${#packages[@]} pending. ${#packages_aur[@]} pending(AUR)."
    if $debug_mode; then
        log_d "Installed pkgs [ ${installed_packages[*]/''/' '} ]."
        log_d "Regular pkgs [ ${packages[*]/''/' ' } ]."
        log_d "AUR pkgs [ ${packages_aur[*]/''/' ' } ]."
    fi
}

# Run program
parse_args "${@}"
if $debug_mode; then log_d "Script arguments: $*."; fi

updateInstalled
loadPackageLists
#installPacmanPackages "${packages[@]}"
#installYayPackages "${packages_aur[@]}"
#if gum confirm --timeout "1s" "Install godot extras?"; then
#    installGodot
#fi
#if gum confirm --timeout "1s" "Install VM extras?"; then
#    installVMUtils
#fi
#gum log -s -t "timeonly" -l "info" "Package install is over!"
