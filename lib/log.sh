#!/bin/bash

#Display log info message.
#arg1: Text to display
#arg2(opt): Step name
log_i() {
    gum log -s -t "timeonly" -l "info" --prefix "${2:-""}" "$1"
}

#Display log warning message.
#arg1: Text to display
#arg2(opt): Step name
log_w() {
    gum log -s -t "timeonly" -l "warn" --prefix "${2:-""}" "$1"
}

#Display log error message.
#arg1: Text to display
#arg2(opt): Step name
log_e() {
    gum log -s -t "timeonly" -l "error" --prefix "${2:-""}" "$1"
}

#Display log debug message.
#arg1: Text to display
#arg2(opt): Step name
log_d() {
    gum log -s -t "timeonly" -l "debug" --prefix "${2:-""}" "$1"
}
