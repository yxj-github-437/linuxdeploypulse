#!/bin/sh
# Linux Deploy Component

do_install()
{
    msg ":: Installing ${COMPONENT} ... "
    local packages=""
    case "${DISTRIB}:${ARCH}:${SUITE}" in
    debian:*|ubuntu:*|kali:*)
        packages="fcitx"
        chroot_exec -u root apt install -y ${packages}
    ;;
    archlinux:*)
        packages="fcitx"
        pacman_install ${packages}
    ;;
    fedora:*)
        packages="fcitx"
        dnf_install ${packages}
    ;;
    centos:*)
        packages="fcitx"
        yum_install ${packages}
    ;;
    esac
}

do_configure()
{
    msg ":: Configuring ${COMPONENT} ... "
    local _str="fcitx"
    if ! grep -q "${_str}" "${CHROOT_DIR}/etc/environment" ; then
        echo '##fcitx configure' >> "${CHROOT_DIR}/etc/environment"
        echo 'export GTK_IM_MODULE="fcitx"' >> "${CHROOT_DIR}/etc/environment"
        echo 'export QT_IM_MODULE="fcitx"' >> "${CHROOT_DIR}/etc/environment"
        echo 'export XMODIFIERS="@im=fcitx"' >> "${CHROOT_DIR}/etc/environment"
    fi
    return 0
}
