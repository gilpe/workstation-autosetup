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
source lib/log.sh

set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes
set -o errtrace # ensure ERR trap is inherited

trap 'log_error "Failed at line $LINENO."' ERR

# VARIABLES _______________________________________________________________________________________
debug_mode=false
dotfiles_dir="$HOME/.dotfiles"

# FUNCTIONS _______________________________________________________________________________________

download_dotfiles() {
    local title="Download dotfiles"

    log_info "Starting." "$title"

    clone_repo https://www.github.com/gilpe/dotfiles.git "$dotfiles_dir"

    log_info "Was done successfully." "$title"
}

overwrite_config() {
    local title="Overwrite config"
    local origin_dir
    local args=()

    log_info "Starting." "$title"

    origin_dir=$(
        cd "$(dirname "$0")"
        pwd
    )
    log_debug "Origin dir: $origin_dir." "$title"
    cd "$dotfiles_dir"
    args+=('--spinner="dot"')
    args+=('--title="Running task..."')
    args+=('--show-error')
    if $debug_mode; then
        args+=('--show-output')
    fi
    gum spin "${args[@]}" \
        -- stow */
    cd "$origin_dir"

    log_info "Was done successfully." "$title"
}

change_shell() {
    local title="Change shell"
    local shell
    local args=()

    log_info "Starting." "$title"

    if ! exist_in_system zsh; then
        log_warn "zsh is needed, so it is going to be installed now." "$title"
        install_packages pacman zsh
    fi
    if ! exist_in_system oh-my-posh; then
        log_warn "oh-my-posh is needed, so it is going to be installed now." "$title"
        install_packages yay oh-my-posh
    fi
    shell=$(chsh -l | grep --max-count=1 "zsh")
    chsh -s "$shell"

    log_info "Was done successfully." "$title"
}

# MAIN PROGRAM ____________________________________________________________________________________
parse_args "${@}"
log_debug "Script arguments: $*."

log_info "Configuration import script started."

download_dotfiles

if gum confirm --timeout "5s" "Overwrite all the current configuration?"; then
    if ! exist_in_system stow; then
        log_warn "This script uses GNU Stow to create symlinks. stow is going to be installed."
        install_packages pacman stow
    fi
    overwrite_config
fi
if gum confirm --timeout "5s" "Change the current shell to zsh?"; then
    change_shell
fi

log_info "Configuration import is over!"
# END OF PROGRAM __________________________________________________________________________________
