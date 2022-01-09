#!/bin/sh
# Linux Deploy Component
# (c) Anton Skshidlevsky <meefik@gmail.com>, GPLv3

[ -n "${PULSE_HOST}" ] || PULSE_HOST="127.0.0.1"
[ -n "${PULSE_PORT}" ] || PULSE_PORT="123456"

do_install()
{
    msg ":: Installing ${COMPONENT} ... "
    local packages=""
    case "${DISTRIB}:${ARCH}:${SUITE}" in
    debian:*|ubuntu:*|kali:*)
        packages="libasound2-plugins pulseaudio pavucontrol"
        apt_install ${packages}
    ;;
    archlinux:*)
        packages="pulseaudio-alsa"
        pacman_install ${packages}
    ;;
    fedora:*)
        packages="alsa-plugins-pulseaudio"
        dnf_install ${packages}
    ;;
    centos:*)
        packages="alsa-plugins-pulseaudio"
        yum_install ${packages}
    ;;
    esac
}

do_configure()
{
    msg ":: Configuring ${COMPONENT} ... "

    #if [ -e "${CHROOT_DIR}/etc/profile.d/" ]; then
    #    printf "PULSE_SERVER=${PULSE_HOST}:${PULSE_PORT}\nexport PULSE_SERVER\n" > "${CHROOT_DIR}/etc/profile.d/pulse.sh"
    #fi

    ####configure pulse
    local _str="load-module module-simple-protocol-tcp rate=44100 format=s16le channels=2 source=0 record=true port=12345"
    if [ -e "${CHROOT_DIR}/etc/pulse/default.pa.d"] ; then
        echo '##pulse configure' > "${CHROOT_DIR}/etc/pulse/default.pa.d/pulse.pa"
        echo ${_str} >> "${CHROOT_DIR}/etc/pulse/default.pa.d/pulse.pa"
    fi

    if [ ! -f "${CHROOT_DIR}/etc/asound.conf" ];then
        echo "pcm.!default { type pulse }" > "${CHROOT_DIR}/etc/asound.conf"
        echo "ctl.!default { type pulse }" >> "${CHROOT_DIR}/etc/asound.conf"
        echo "pcm.pulse { type pulse }" >> "${CHROOT_DIR}/etc/asound.conf"
        echo "ctl.pulse { type pulse }" >> "${CHROOT_DIR}/etc/asound.conf"
    fi
    
    return 0
}

do_start()
{
    msg -n ":: Starting ${COMPONENT} ... "
    ## exec audio-server
    chroot_exec -u ${USER_NAME} pulseaudio --start
    is_ok "fail" "done"
    return 0;
}

do_stop()
{
    msg -n ":: Stopping ${COMPONENT} ... "
    chroot_exec -u ${USER_NAME} pulseaudio -k
    is_ok "fail" "done"
    return 0
}

do_help()
{
cat <<EOF
   --pulse-host="${PULSE_HOST}"
     Host of PulseAudio server, default 127.0.0.1.

   --pulse-port="${PULSE_PORT}"
    Port of PulseAudio server, default 4712.

EOF
}
