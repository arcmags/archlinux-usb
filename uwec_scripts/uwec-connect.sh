#!/bin/bash

##============================  uwec-connect.sh  =============================##
#  by Chris Magyar...                                 [c.magyar.ec@gmail.com]  #
#  Free as in speech...                                        use this shit!  #
##============================================================================##
# Connect to and mount various resources on the UWEC network.


##=============================  set_defaults()  =============================##
# Set user default values here:
set_defaults() {
    # user defaults
    username_linux=  # these
    username_uwec=   # values
    dir_mnt_H=       # need
    dir_mnt_W=       # to
    dir_mnt_yoda=    # be
    dir_mnt_thing=   # filled
    dir_mnt_bgsc=    # in
    str_mnt_options="defaults,username=${username_uwec},rw,users,nodfs,uid="
    str_mnt_options+="${username_linux}"
}


##=================================  main()  =================================##
main() {
    # main variables
    local username_linux=
    local username_uwec=
    local dir_mnt_H=
    local dir_mnt_W=
    local dir_mnt_yoda=
    local dir_mnt_thing=
    local dir_mnt_bgsc=
    local str_mnt_options=
    local flg_error=0
    # colors
    local clr_Red='\e[0;38;5;196m'
    local clr_RedB='\e[1;38;5;196m'
    local clr_Blue='\e[0;38;5;27m'
    local clr_BlueB='\e[1;38;5;27m'
    local clr_Green='\e[1;38;5;46m'
    local clr_GreenB='\e[1;38;5;46m'
    local clr_cyanB='\e[1;38;5;30m'
    local clr_Cyan='\e[0;38;5;14m'
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
    # set user defaults
    set_defaults
    # error check
    error_check
    # connect to vpn
    if (ps aux | grep -E 'openconnect.*vpn\.uwec\.edu' &>/dev/null); then
        printf "${ps_info}Already connected to vpn.uwec.edu.\n"
    else
        if prompt --no "Connect to vpn.uwec.edu?"; then
            printf "${ps_sh}sudo openconnect -b -u ${username_uwec} "
            printf "vpn.uwec.edu\n"
            sudo openconnect -b -u "${username_uwec}" vpn.uwec.edu &&
            sleep 2
        fi
    fi
    # mount H
    if (mountpoint -q "${dir_mnt_H}"); then
        printf "${ps_info}H drive already mounted.\n"
    else
        if prompt --no "Mount home H drive?"; then
            mkdir -p "${dir_mnt_H}"
            printf "${ps_sh}sudo mount -t cifs \'//students.uwec.edu/"
            printf "${username_uwec}\$/\' \"${dir_mnt_H}\" -o "
            printf "${str_mnt_options}\n"
            sudo mount -t cifs "//students.uwec.edu/${username_uwec}\$/" \
                       "${dir_mnt_H}" -o "${str_mnt_options}"
        fi
    fi
    # mount W
    if (mountpoint -q "${dir_mnt_W}"); then
        printf "${ps_info}W drive already mounted.\n"
    else    
        if prompt --no "Mount student/instructor W drive?"; then
        mkdir -p "${dir_mnt_W}"
            printf "${ps_sh}sudo mount -t cifs //students.uwec.edu/deptdir/ "
            printf "\"${dir_mnt_W}\" -o ${str_mnt_options}\n"
            sudo mount -t cifs //students.uwec.edu/deptdir/ "${dir_mnt_W}" \
                       -o "${str_mnt_options}"
        fi
    fi
    # mount yoda
    if (mountpoint -q "${dir_mnt_yoda}"); then
        printf "${ps_info}Yoda already mounted.\n"
    else        
        if prompt --no "Mount webserver yoda?"; then
            mkdir -p "${dir_mnt_yoda}"
            printf "${ps_sh}sudo mount -t cifs //yoda.cs.uwec.edu/CS318$/" 
            printf "students \"${dir_mnt_yoda}\" -o ${str_mnt_options}\n"
            sudo mount -t cifs //yoda.cs.uwec.edu/CS318$/students \
                 "${dir_mnt_yoda}" -o "${str_mnt_options}"
        fi
    fi
    # mount thing
    if (mountpoint -q "${dir_mnt_thing}"); then
        printf "${ps_info}Thing already mounted.\n"
    else
        if prompt --no "Mount thing-04.cs.uwec.edu:/?"; then
            mkdir -p "${dir_mnt_thing}"
            printf "${ps_sh}sshfs ${username_uwec}@thing1.cs.uwec.edu:/ "
            printf "\"${dir_mnt_thing}\"\n"
            sshfs magyarca@thing1.cs.uwec.edu:/ "${dir_mnt_thing}"
        fi
    fi
    # mount BGSC
    if (mountpoint -q "${dir_mnt_bgsc}"); then
        printf "${ps_info}BGSC already mounted.\n"
    else
        if prompt --no "Mount bgsc.uwec.edu:/?"; then
            mkdir -p "${dir_mnt_bgsc}"
            printf "${ps_sh}sshfs ${username_uwec}@bgsc.uwec.edu:/ "
            printf "\"${dir_mnt_bgsc}\"\n"
            sshfs "${username_uwec}@bgsc.uwec.edu:/" "${dir_mnt_bgsc}"
        fi
    fi
}


##=============================  error_check()  ==============================##
error_check() {
    if !(pacman -Qi openconnect &>/dev/null); then
        printf "${ps_error}Package ${clr_Red}openconnect${clr_white} required "
        printf "to connect to vpn.uwec.edu.\n"
        flg_error=1
    fi
    if !(pacman -Qi cifs-utils &>/dev/null); then
        printf "${ps_error}Package ${clr_Red}cifs-utils${clr_white} required "
        printf "to mount UWEC Windows shares.\n"
        flg_error=1
    fi
    if !(pacman -Qi sshfs &>/dev/null); then
        printf "${ps_error}Package ${clr_Red}sshfs${clr_white} required "
        printf "to mount UWEC Linux shares.\n"
        flg_error=1
    fi
    if [ -z "${username_linux}" ]; then
        printf "${ps_error}Username required for ${clr_Red}username_linux"
        printf "${clr_white} variable in script.\n"
        flg_error=1
    fi
    if [ -z "${username_uwec}" ]; then
        printf "${ps_error}Username required for ${clr_Red}username_uwec"
        printf "${clr_white} variable in script.\n"
        flg_error=1
    fi
    if [ -z "${dir_mnt_H}" ]; then
        printf "${ps_error}Directory path required for ${clr_Red}dir_mnt_H"
        printf "${clr_white} variable in script.\n"
        flg_error=1
    fi
    if [ -z "${dir_mnt_W}" ]; then
        printf "${ps_error}Directory path required for ${clr_Red}dir_mnt_W"
        printf "${clr_white} variable in script.\n"
        flg_error=1
    fi
    if [ -z "${dir_mnt_yoda}" ]; then
        printf "${ps_error}Directory path required for ${clr_Red}dir_mnt_yoda"
        printf "${clr_white} variable in script.\n"
        flg_error=1
    fi
    if [ -z "${dir_mnt_thing}" ]; then
        printf "${ps_error}Directory path required for ${clr_Red}dir_mnt_thing"
        printf "${clr_white} variable in script.\n"
        flg_error=1
    fi
    if [ -z "${dir_mnt_bgsc}" ]; then
        printf "${ps_error}Directory path required for ${clr_Red}dir_mnt_bgsc"
        printf "${clr_white} variable in script.\n"
        flg_error=1
    fi
    if [ ${flg_error} -eq 1 ]; then
        exit 1
    fi
}


##================================  prompt()  ================================##
# Basic Y/N prompt.  Returns 0 if user inputs [yes], returns 1 if [no].
# Default choice=[yes] can be changed with --no flag.
prompt() {
    local str_input=
    local str_yn="[Y/n]> "
    for arg in "$@"; do
        case ${arg} in
            --yes|-y|-Y)  shift;;
            --no|-n|-N)   str_yn="[y/N]> "; shift;;
        esac
    done
    printf "${ps_info}$1 ${clr_Green}${str_yn}${clr_white}"
    read -r str_input
    str_input="${str_input,,}"
    if [[ ${str_input} =~ ^(yes|y)$ ]] || 
       ([[ ! ${str_input} =~ ^(no|n)$ ]] && [[ "${str_yn}" == "[Y/n]> " ]]);then
        return 0
    else
        return 1
    fi
}


main
