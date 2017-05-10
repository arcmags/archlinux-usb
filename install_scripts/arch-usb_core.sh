#!/bin/bash
#
##============================  arch-usb_core.sh  ============================##
#  by Chris Magyar...                                 [c.magyar.ec@gmail.com]  #
#  Free as in speech...                                        use this shit!  #
##============================================================================##
# Reinstall core packages on your Arch Linux USB.

##=============================  get_arr_pkgs()  =============================##
get_arr_pkgs() {
arr_pkgs=(
    acpi
    alsa-utils
    dialog
    efibootmgr
    grub
    ifplugd
    iw
    sudo
    wpa_supplicant
    xf86-input-synaptics
    xf86-video-ati
    xf86-video-intel
    xf86-video-nouveau
    xf86-video-vesa )
}

##=================================  main()  =================================##
main() {
    # main variables
    local arr_pkgs=()
    # colors
    local Red='\e[0;38;5;196m'
    local RedB='\e[1;38;5;196m'
    local Blue='\e[0;38;5;27m'
    local BlueB='\e[1;38;5;27m'
    local Green='\e[1;38;5;46m'
    local GreenB='\e[1;38;5;46m'
    local Cyan='\e[0;38;5;14m'
    local CyanB='\e[1;36m'
    local Violet='\e[0;38;5;13m'
    local VioletB='\e[1;35m'
    local Gray='\e[0;37m'
    local white='\e[0;38;5;15m'
    local whiteB='\e[1;37m'
    # strings
    local psError="${RedB}:: ${white}"
    local psHead="${VioletB}:: ${BlueB}"
    local psInfo="${BlueB}:: ${white}"
    local psPrompt="${GreenB}:: ${white}"
    local psSh="${BlueB}\$ ${Gray}"
    # get recommended packages
    get_arr_pkgs
    # print script information
    printf "${psHead}arch-usb_core.sh ${Violet}- "
    printf "Reinstall core packages on your Arch Linux USB.\n"
    printf "${white}If you followed the guide at http://valleycat.org/foo/"
    printf "arch-usb.html, these packages will already be installed.\n\n"
    # print package list
    printf "${psInfo}${BlueB}Core Packages: ${white}"
    printb "${arr_pkgs[*]}\n" 18 0
    printf "\n"
    # prompt for user confirmation
    if prompt --no "Reinstall core packages?"; then
        printf "${psSh}sudo pacman --color=always -S ${arr_pkgs[*]}"
        printf "${white}\n"
        # install packages
        sudo pacman --color=always -S "${arr_pkgs[@]}"
    fi
}

##================================  prompt()  ================================##
# Basic Y/N prompt.  Returns 0 if user inputs [yes], 1 if [no].
# Default choice[yes] can be changed with --no flag.
prompt() {
    local str_input=
    local str_yn="[Y/n]> "
    for arg in "$@"; do
        case ${arg} in
            --yes|-y|-Y)  shift;;
            --no|-n|-N)   str_yn="[y/N]> "; shift;;
        esac
    done
    printf "${psPrompt}$1 ${Green}${str_yn}${white}"
    read -r str_input
    str_input="${str_input,,}"
    if [[ ${str_input} =~ ^(yes|y)$ ]] ||
       ([[ ! ${str_input} =~ ^(no|n)$ ]] && [[ "${str_yn}" == "[Y/n]> " ]]);then
        return 0
    else
        return 1
    fi
}

##================================  printb()  ================================##
# Prints a block of indented text.
#   $1=[string] - text to print
#   $2=[int] - indent length (default=4)
#   $3=[int] - indent length of first line (default=$2)
printb() {
    local int_indent_block=${2:-4}
    local int_indent_line=${3:-${int_indent_block}}
    local int_line=$(( `tput cols` - ${int_indent_block} ))
    local IFS=$'\n'
    for line in `printf "$1\n" | fold -s -w ${int_line}`; do
        if [ ${int_indent_line} -gt 0 ]; then
            printf "%-${int_indent_line}s" " "
        fi
        printf "${line}\n"
        int_indent_line=${int_indent_block}
    done
}

main
