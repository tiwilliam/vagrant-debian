#!/bin/bash

txtblk=$'\e[0;30m' # Black - Regular
txtred=$'\e[0;31m' # Red
txtgrn=$'\e[0;32m' # Green
txtylw=$'\e[0;33m' # Yellow
txtblu=$'\e[0;34m' # Blue
txtpur=$'\e[0;35m' # Purple
txtcyn=$'\e[0;36m' # Cyan
txtwht=$'\e[0;37m' # White
txtrst=$'\e[0m'    # Text Reset

function abort {
    echo -e >&2 "${txtred}ERROR: $1${txtrst}"
    exit 1
}

function info {
    echo -e "${txtpur}INFO: $1${txtrst}"
}

function warn {
    echo -e "${txtylw}WARN: $1${txtrst}"
}

function debugecho {
    echo -e "${txtcyn}DEBUG: $1${txtrst}"
}
