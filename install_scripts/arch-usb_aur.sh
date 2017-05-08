#!/bin/bash

##============================  arch-usb_aur.sh  =============================##
#  by Chris Magyar...                                   c.magyar.ec@gmail.com  #
#  Free as in speech...                                 use/change this shit!  #
##============================================================================##
# Install selected Arch User Repository packages on your Arch Linux USB.


##=============================  get_arr_pkgs()  =============================##
# Set package list here.
get_arr_pkgs() {
arr_pkgs=(
    dropbox
    dropbox-cli
    geany-themes
    ttf-font-awesome
    ttf-ms-fonts
    ttf-openlogos-archupdate )
}


##=================================  main()  =================================##
main() {
    # main variables
    local arr_pkgs=()
    local arr_pkgs_sel=()
    # colors
    local clr_Red='\e[0;38;5;196m'
    local clr_RedB='\e[1;38;5;196m'
    local clr_Blue='\e[0;38;5;27m'
    local clr_BlueB='\e[1;38;5;27m'
    local clr_Green='\e[1;38;5;46m'
    local clr_GreenB='\e[1;38;5;46m'
    local clr_Cyan='\e[0;38;5;14m'
    local clr_CyanB='\e[1;36m'
    local clr_Violet='\e[0;38;5;13m'
    local clr_VioletB='\e[1;35m'
    local clr_Gray='\e[0;37m'
    local clr_white='\e[0;38;5;15m'
    local clr_whiteB='\e[1;37m'
    # strings
    local ps_error="${clr_RedB}:: ${clr_white}"
    local ps_head="${clr_VioletB}:: ${clr_BlueB}"
    local ps_info="${clr_BlueB}:: ${clr_white}"
    local ps_prompt="${clr_GreenB}:: ${clr_white}"
    local ps_sh="${clr_BlueB}\$ ${clr_Gray}"

    # get recommended packages
    get_arr_pkgs

    # print script information
    printf "${ps_head}arch-usb_aur.sh${clr_Violet} - "
    printf "Install some packages from the Arch User Repository.\n\n"

    # print package list
    printf "${ps_info}${clr_BlueB}AUR Packages: ${clr_white}"
    printb "${arr_pkgs[*]}\n" 17 0
    printf "\n"

    # prompt for user selection
    printf "${clr_BlueB}1) ${clr_white}Install all listed AUR packages.\n"
    printf "${clr_BlueB}2) ${clr_white}Display package description and prompt "
    printf "y/n for every package.\n"
    printf "${clr_BlueB}0) ${clr_white}Exit.\n"
    printf "${ps_prompt}Enter a selection ${clr_GreenB}> ${clr_white}"
    read -r str_input
    str_input="${str_input,,}"

    if [[ ${str_input} == "1" ]] || [[ ${str_input} == "2" ]]; then
        if [[ ${str_input} == "1" ]]; then
            # select all packages
            arr_pkgs_sel=${arr_pkgs[@]}
        elif [[ ${str_input} == "2" ]]; then
            # select specific packages
            for pkg in ${arr_pkgs[@]}; do
                pkg_info ${pkg} & wait $!
                if prompt "Install ${pkg}${clr_white}?"; then
                    arr_pkgs_sel+=( "${pkg}" )
                fi
            done
            printf "${ps_info}Installing selected packages...\n"
        fi

        # make temp directory
        printf "${ps_sh}mkdir /tmp/aur\n"
        mkdir -p /tmp/aur
        printf "${ps_sh}cd /tmp/aur\n"
        cd /tmp/aur
        for pkg in ${arr_pkgs_sel[@]}; do
            # download package snapshot
            printf "${ps_sh}curl -L -O \"https://aur.archlinux.org/cgit/\""
            printf "aur.git/snapshot/${pkg}.tar.gz\n"
            curl -L -O \
                "http://aur.archlinux.org/cgit/aur.git/snapshot/${pkg}.tar.gz"
            # uncompress package
            printf "${ps_sh}tar -xvf ${pkg}.tar.gz\n"
            tar -xvf "${pkg}.tar.gz"
            printf "${ps_sh}cd ${pkg}\n"
            cd "${pkg}"
            # build and install package
            printf "${ps_sh}makepkg -sri\n"
            makepkg -sri
            # remove snapshot
            printf "${ps_sh}cd /tmp/aur\n"
            cd /tmp/aur
            printf "${ps_sh}rm -Rdf ${pkg} ${pkg}.tar.gz\n"
            rm -Rdf "${pkg}" "${pkg}.tar.gz"
        done
        # remove temp directory
        printf "${ps_sh}cd /tmp\n"
        cd /tmp
        printf "${ps_sh}rm -Rfd /tmp/aur\n"
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
    printf "${ps_prompt}$1 ${clr_Green}${str_yn}${clr_white}"
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
        'pkgdesc.*(quot|apos);\K.*(?=&(quot|apos);)'`
    # if package exists in AUR; then
    if [ $? -eq 0 ]; then
        printf "${clr_Cyan}$1 (AUR) ${clr_white}"
        printf "${str_aur_description}\n"
    # if package does not exist in AUR; then
    else
        printf "${ps_error}no such package or group: "
        printf "${clr_Red}$1\n"
    fi
}


main
