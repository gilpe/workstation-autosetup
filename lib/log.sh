#!/bin/bash

#Display log info message and optional step title.
#usage: logI "$message" "$step_title"
logI() {
    gum log -s -t "timeonly" -l "info" --prefix "${2:-""}" "$1"
}

#Display log warning message and optional step title.
#usage: logW "$message" "$step_title"
logW() {
    gum log -s -t "timeonly" -l "warn" --prefix "${2:-""}" "$1"
}

#Display log error message and optional step title.
#usage: logE "$message" "$step_title"
logE() {
    gum log -s -t "timeonly" -l "error" --prefix "${2:-""}" "$1"
}

#Display log debug message and optional step title.
#usage: logD "$message" "$step_title"
logD() {
    gum log -s -t "timeonly" -l "debug" --prefix "${2:-""}" "$1"
}
