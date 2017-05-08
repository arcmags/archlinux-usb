#!/bin/bash

##===========================  uwec-disconnect.sh  ===========================##
#  by Chris Magyar...                                   c.magyar.ec@gmail.com  #
#  Free as in speech...                                 use/change this shit!  #
##============================================================================##


##=============================  set_defaults()  =============================##
# Set user default values here:
set_defaults() {
    # user defaults
    dir_mnt_H=     # these
    dir_mnt_W=     # values
    dir_mnt_yoda=  # need
    dir_mnt_thing= # to be
    dir_mnt_bgsc=  # filled in
}


##=================================  main()  =================================##
main() {
    # main variables
    local dir_mnt_H=
    local dir_mnt_W=
    local dir_mnt_yoda=
    local dir_mnt_thing=
    local dir_mnt_bgsc=
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
    # unmount BGSC
    if (mountpoint -q "${dir_mnt_bgsc}"); then
        if (prompt "Unmount BGSC?"); then
            fusermount -uq "${dir_mnt_bgsc}"
            printf "${ps_sh}fusermount -uq ${dir_mnt_bgsc}\n"
        fi
    fi
    # unmount thing
    if (mountpoint -q "${dir_mnt_thing}"); then
        if (prompt "Unmount the thing?"); then
            fusermount -uq "${dir_mnt_thing}"
            printf "${ps_sh}fusermount -uq ${dir_mnt_thing}\n"
        fi
    fi
    # unmount yoda
    if (mountpoint -q "${dir_mnt_yoda}"); then
        if (prompt "Unmount webserver yoda?"); then
            sudo umount -f "${dir_mnt_yoda}"
            printf "${ps_sh}sudo umount -f ${dir_mnt_yoda}\n"
        fi
    fi
    # unmount W
    if (mountpoint -q "${dir_mnt_W}"); then
        if (prompt "Unmount W drive?"); then
            sudo umount -f "${dir_mnt_W}"
            printf "${ps_sh}sudo umount -f ${dir_mnt_W}\n"
        fi
    fi
    # unmount H
    if (mountpoint -q "${dir_mnt_H}"); then
        if (prompt "Unmount H drive?"); then
            sudo umount -f "${dir_mnt_H}"
            printf "${ps_sh}sudo umount -f ${dir_mnt_H}\n"
        fi
    fi
    # disconnect from vpn.uwec.edu
    if (ps aux | grep -E 'openconnect.*vpn\.uwec\.edu' &>/dev/null); then
        if (prompt "Disconnect from vpn.uwec.edu?"); then
            local pid_vpn=`ps aux | grep -E 'openconnect.*vpn\.uwec\.edu' \
                          | awk '{print $2}'`
            printf "${ps_sh}sudo kill -9 ${pid_vpn}\n"
            sudo kill -9 ${pid_vpn}
        fi
    fi

}


##=============================  error_check()  ==============================##
error_check() {
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


main
