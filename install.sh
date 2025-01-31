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
set -o pipefail # don't hide errors within pipes
set -o errtrace # ensure ERR trap is inherited
trap 'logE "Failed at line $LINENO."' ERR

# VARIABLES _______________________________________________________________________________________
#IFS=$'\n'
debug_mode=false
packages=()
packages_aur=()

# FUNCTIONS _______________________________________________________________________________________

#Prints the usage info from the first lines of this script
display_usage() {
    grep "^#/" "${0}" |
        sed "s/^#\/\($\| \)//;s/SCRIPTNAME/${0##*/}/"
}

#Parses user input arguments to perform the actions
#usage: parse_args "${@}"
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

#Update the local packages with the latest versions in repos
updateInstalled() {
    logI "Updating installed packages."
    if $debug_mode; then
        gum spin --spinner dot --show-error --show-output --title "Running task..." \
            -- pacman -Syu --noconfirm --needed
    else
        gum spin --spinner dot --show-error --title "Running task..." \
            -- pacman -Syu --noconfirm --needed
    fi
}

#Check if the package exists in the system.
#usage: isInstalled "$package_name"
isInstalled() {
    local result=1
    if [ -z "$1" ]; then
        if $debug_mode; then logD "isInstalled has no params."; fi
        return $result
    fi
    pacman -Qi "$1" &>/dev/null
    result=$?
    if $debug_mode; then logD "isInstalled for [ $1 ] ended with code $result."; fi
    return $result
}

#Check if the package doesn't exists in the Pacman repos.
#usage: isAUR "$package_name"
isAUR() {
    local result=1
    if [ -z "$1" ]; then
        if $debug_mode; then logD "isAUR has no params."; fi
        return $result
    fi
    pacman -Si "$1" &>/dev/null
    result=$((!$?))
    if $debug_mode; then logD "isAUR for [ $1 ] ended with code $result."; fi
    return $result
}

#Gets and classifies the packages listed in the file
loadPackageLists() {
    logI "Loading package lists from file."
    local line_count=0
    local installed_packages=()
    logI "Iterating lines." "󰘍"
    while read -r package_name || [ -n "${package_name}" ]; do
        line_count=$((line_count + 1))
        if isInstalled "$package_name"; then
            logW "$package_name excluded, it's already installed." "󰘍"
            installed_packages+=("$package_name")
        else
            if isAUR "$package_name"; then
                packages_aur+=("$package_name")
            else
                packages+=("$package_name")
            fi
        fi
    done <"packages.txt"
    logI "$line_count found. ${#installed_packages[@]} installed. ${#packages[@]} pending. ${#packages_aur[@]} pending(AUR)."
    if $debug_mode; then
        logD "Installed pkgs [ ${installed_packages[*]} ]."
        logD "Regular pkgs [ ${packages[*]} ]."
        logD "AUR pkgs [ ${packages_aur[*]} ]."
    fi
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
if $debug_mode; then logD "Script arguments: $*."; fi

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

# END OF PROGRAM __________________________________________________________________________________
