#!/bin/bash

##========================  arch-usb_recommended.sh  =========================##
#  by Chris Magyar...                                   c.magyar.ec@gmail.com  #
#  Free as in speech...                                 use/change this shit!  #
##============================================================================##
# Install selected packages on your Arch Linux USB.


##=============================  get_arr_pkgs()  =============================##
# Set package list here.
get_arr_pkgs() {
arr_pkgs=(
    alsa-utils
    arandr
    arch-install-scripts
    arch-wiki-docs
    arch-wiki-lite
    bash-docs
    bc
    cifs-utils
    cmake
    compton
    conky
    cppcheck
    dmenu
    dmidecode
    dosfstools
    eclipse-java
    elinks
    enchant
    eog
    feh
    ffmpeg
    file-roller
    firefox
    flac
    flashplugin
    geany
    geany-plugins
    geogebra
    gftp
    gimp
    git
    gnupg
    gparted
    gptfdisk
    gvfs
    htop
    hunspell-en
    i3
    imagemagick
    imagemagick-doc
    inxi
    libreoffice-fresh
    libvorbis
    lm_sensors
    lxappearance
    moc
    mpg123
    mtools
    mysql-workbench
    ntfs-3g
    okular
    openconnect
    p7zip
    python-docs
    qt4
    qt5ct
    sagemath
    sagemath-doc
    smbclient
    sshfs
    sysstat
    texlive-most
    tidy
    transmission-cli
    transmission-qt
    tumbler
    unrar
    unzip
    valgrind
    vim
    vlc
    wavpack
    wget
    xdotool
    xfce4
    xfce4-screenshooter
    xorg-server
    xorg-xinit
    xorg-xprop
    xterm
    zsh )
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

    # print package information
    printf "${ps_head}arch-usb_recommended.sh${clr_Violet} - "
    printf "Install (my)recommended packages on your Arch Linux USB.\n"
    printf "${clr_white}Edit this script to fit your needs...\n\n"

    # print package list
    printf "${ps_info}${clr_BlueB}Recommended Packages: ${clr_white}"
    printb "${arr_pkgs[*]}\n" 25 0
    printf "\n"

    # prompt for user selection
    printf "${clr_BlueB}1) ${clr_white}Install all recommended packages.\n"
    printf "${clr_BlueB}2) ${clr_white}Display package description and prompt "
    printf "y/n for every package.\n"
    printf "${clr_BlueB}0) ${clr_white}Exit.\n"
    printf "${ps_prompt}Enter a selection ${clr_GreenB}> ${clr_white}"
    read -r str_input
    str_input="${str_input,,}"

    # install all packages
    if [[ ${str_input} == "1" ]]; then
        printf "${ps_sh}sudo pacman --color=always -S ${arr_pkgs[*]}"
        printf "${clr_white}\n"
        sudo pacman --color=always -S "${arr_pkgs[@]}"

    # select packages to install
    elif [[ ${str_input} == "2" ]]; then
        for pkg in ${arr_pkgs[@]}; do
            pkg_info ${pkg} & wait $!
            if prompt "Install ${pkg}${clr_white}?"; then
                arr_pkgs_sel+=( "${pkg}" )
            fi
        done
        printf "${ps_info}Installing selected packages...\n"
        printf "${ps_sh}sudo pacman --color=always -S ${arr_pkgs_sel[*]}"
        printf "${clr_white}\n"
        # install selected packages
        sudo pacman --color=always -S "${arr_pkgs_sel[@]}"
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
# Print package or package group description from official repos.
pkg_info() {
    # main variables
    local str_description=
    local lst_pkgs=
    local pkg=
    # if argument given; then
    if [ ! -z "$1" ]; then
        # get description from Official repositories
        str_description=`pacman -Si $1 2>/dev/null | \
                         grep --color=never -Po "Description     : \K.*"`
        # if package exists in Official repositories; then
        if [ $? -eq 0 ]; then
            printf "${clr_Cyan}$1 ${clr_white}${str_description}\n"
        # if no package description exists in the repositories; then
        else
            # get package group listing from Official repositories
            lst_pkgs=`pacman -Sgqg $1 2>/dev/null`
            # if package group exists in the repositories; then
            if [ $? -eq 0 ]; then
                printf "${clr_CyanB}$1 ${clr_whiteB}(group):\n"
                # call pacman -Si for each package in group
                local IFS=$'\n'
                for pkg in `pacman -Sgqg $1`; do
                    str_description=`pacman -Si ${pkg} 2>/dev/null | \
                         grep --color=never -Po "Description     : \K.*"`
                    printf "${clr_Cyan}${pkg} ${clr_white}${str_description}\n"
                done
            # if package group does not exist in official repositories; then
            else
                printf "${ps_error}No such package or group in Arch Linux "
                printf "official repositories: ${clr_Red}$1\n"
            fi
        fi
    fi
}


main
