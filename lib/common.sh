#!/bin/bash

# VARIABLES _______________________________________________________________________________________
export debug_mode

# FUNCTIONS _______________________________________________________________________________________

#usage: log_info "$message"
#usage: log_info "$message" "title"
log_info() {
    gum log -s -t "timeonly" -l "info" --prefix "${2:-""}" "$1"
}

#usage: log_warn "$message"
#usage: log_warn "$message" "$title"
log_warn() {
    gum log -s -t "timeonly" -l "warn" --prefix "${2:-""}" "$1"
}

#usage: log_err "$message"
#usage: log_err "$message" "$title"
log_err() {
    gum log -s -t "timeonly" -l "error" --prefix "${2:-""}" "$1"
}

#usage: log_debug "$message"
#usage: log_debug "$message" "$title"
log_debug() {
    if $debug_mode; then
        gum log -s -t "timeonly" -l "debug" --prefix "${2:-""}" "$1"
    fi
}

#usage: display_usage
display_usage() {
    grep "^#/" "${0}" |
        sed "s/^#\/\($\| \)//;s/SCRIPTNAME/${0##*/}/"
}

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

#usage: exist_in_system "$package_name"
exist_in_system() {
    pacman -Qi "$1" &>/dev/null
}

#usage: clone_repo "$repo_url" "$local_path"
clone_repo() {
    local title="Clone repo"
    local args=()

    log_info "Starting." "$title"
    log_debug "Repo URL: $1. Local directory: $2" "$title"

    if ! exist_in_system git; then
        log_warn "git is needed, so it is going to be installed now." "$title"
        install_from_pacman git
    fi

    args+=('--spinner="dot"')
    args+=('--title="Running task..."')
    args+=('--show-error')
    if $debug_mode; then
        args+=('--show-output')
    fi
    gum spin "${args[@]}" \
        -- git clone --depth 1 "$1" "$2"

    log_info "Was done successfully." "$title"
}
