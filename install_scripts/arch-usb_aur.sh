#!/bin/bash
#
##============================  arch-usb_aur.sh  =============================##
#  by Chris Magyar...                                   c.magyar.ec@gmail.com  #
#  Free as in speech...                                 use/change this shit!  #
##============================================================================##
# Install selected Arch User Repository packages on your Arch Linux USB.

##=============================  get_arr_pkgs()  =============================##
# Set package list here.
get_arr_pkgs() {
arr_pkgs=(
    i3-gaps
    dropbox
    dropbox-cli
    geany-themes
    ttf-font-awesome
    ttf-ms-fonts
    ttf-openlogos-archupdate
    qt5-styleplugins
    cower
    pacaur )
}

##=================================  main()  =================================##
main() {
    # main variables
    local arr_pkgs=()
    local arr_pkgs_sel=()
    # colors
    local Red='\e[0;38;5;196m'
    local RedB='\e[1;38;5;196m'
    local Blue='\e[0;38;5;27m'
    local BlueB='\e[1;38;5;27m'
    local Green='\e[1;38;5;46m'
    local GreenB='\e[1;38;5;46m'
    local Yellow='\e[0;38;5;11m'
    local YellowB='\e[1;33m'
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
    local psWarn="${YellowB}:: ${white}"
    # get recommended packages
    get_arr_pkgs
    # print script information
    printf "${psHead}arch-usb_aur.sh${Violet} - "
    printf "Install some packages from the Arch User Repository.\n\n"
    # print package list
    printf "${psInfo}${BlueB}AUR Packages: ${white}"
    printb "${arr_pkgs[*]}\n" 17 0
    printf "\n"
    # prompt for user selection
    printf "${BlueB}1) ${white}Install all listed AUR packages.\n"
    printf "${BlueB}2) ${white}Display package description and prompt "
    printf "y/n for every package.\n"
    printf "${BlueB}0) ${white}Exit.\n"
    printf "${psPrompt}Enter a selection ${GreenB}> ${white}"
    read -r str_input
    str_input="${str_input,,}"
    if [[ "${str_input}" == '1' ]] || [[ "${str_input}" == '2' ]]; then
        if [[ "${str_input}" == '1' ]]; then
            # select all packages
            arr_pkgs_sel=${arr_pkgs[@]}
        elif [[ "${str_input}" == '2' ]]; then
            # select specific packages
            for pkg in ${arr_pkgs[@]}; do
                pkg_info ${pkg} & wait $!
                if prompt "Install ${pkg}${white}?"; then
                    arr_pkgs_sel+=( "${pkg}" )
                fi
            done
            printf "${psInfo}Installing selected packages...\n"
        fi
        # make temp directory
        printf "${psSh}mkdir /tmp/aur\n"
        mkdir -p /tmp/aur
        printf "${psSh}cd /tmp/aur\n"
        cd /tmp/aur
        for pkg in ${arr_pkgs_sel[@]}; do
            # download package snapshot
            printf "${psSh}curl -L -O \"https://aur.archlinux.org/cgit/\""
            printf "aur.git/snapshot/${pkg}.tar.gz\n"
            curl -L -O \
                "http://aur.archlinux.org/cgit/aur.git/snapshot/${pkg}.tar.gz"
            # uncompress package
            printf "${psSh}tar -xvf ${pkg}.tar.gz\n"
            tar -xvf "${pkg}.tar.gz"
            printf "${psSh}cd ${pkg}\n"
            cd "${pkg}"
            # check for required gpg keys
            flg_key=0
            key_code=`cat PKGBUILD | grep validpgpkeys`
            key=`echo ${key_code} | \
                grep -Po "^validpgpkeys=\( ?'?\K[A-Za-z0-9]+"`
            if [[ "${key}" =~ [A-Za-z0-9]+ ]]; then
                if [ `gpg --list-keys | grep "${key}" &>/dev/null` ]; then
                    printf "${psWarn}pgp key required:\n"
                    printf "${psWarn}${key_code}\n"
                    # prompt to add key
                    if prompt "Import key $Yellow$key${white}?"; then
                        printf "${psSh}gpg --recv-keys $key\n"
                        gpg --recv-keys "$key"
                    else
                        flg_key=1
                    fi
                fi
            fi
            # build and install package
            if [ $flg_key -eq 0 ]; then
                printf "${psSh}makepkg -sri\n"
                makepkg -sri
            else
                printf "${psError}Unable to install ${Red}$pkg${white} "
                printf "without valid gpg keys\n"
            fi
            # remove snapshot
            printf "${psSh}cd /tmp/aur\n"
            cd /tmp/aur
            printf "${psSh}rm -Rdf ${pkg} ${pkg}.tar.gz\n"
            rm -Rdf "${pkg}" "${pkg}.tar.gz"
        done
        # remove temp directory
        printf "${psSh}cd /tmp\n"
        cd /tmp
        printf "${psSh}rm -Rfd /tmp/aur\n"
        rm -Rfd /tmp/aur
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

##===============================  pkg_info()  ===============================##
# Print package description from the AUR.
pkg_info() {
    # main variables
    local str_description=
    # get description from AUR
    str_aur_description=`curl -s \
        "https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$1" \
        | grep --color=never -oP \
        '^pkgdesc=(\x27|\x22)\K.*(?=(\1))'`
    # if package exists in AUR; then
    if [ $? -eq 0 ]; then
        printf "${Cyan}$1 (AUR) ${white}"
        printf "${str_aur_description}\n"
    # if package does not exist in AUR; then
    else
        printf "${psError}no such package or group: "
        printf "${Red}$1\n"
    fi
}

main
