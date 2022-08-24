#!/bin/sh
# Linux Deploy Component
# (c) Anton Skshidlevsky <meefik@gmail.com>, GPLv3

# 31 doesn't support while rpm2cpio in busybox doesn't support zstd
[ -n "${SUITE}" ] || SUITE="34"

if [ -z "${ARCH}" ]
then
    case "$(get_platform)" in
    x86) ARCH="i386" ;;
    x86_64) ARCH="x86_64" ;;
    arm) ARCH="armhfp" ;;
    arm_64) ARCH="aarch64" ;;
    esac
fi

[ -n "${SOURCE_PATH}" ] || SOURCE_PATH="http://dl.fedoraproject.org/pub/"

dnf_install()
{
    local packages="$@"
    [ -n "${packages}" ] || return 1
    (set -e
        chroot_exec -u root dnf -y install ${packages}
    exit 0)
    return $?
}

dnf_repository()
{
    sed -i 's/enabled=1/enabled=0/g' "${CHROOT_DIR}/etc/yum.repos.d/fedora-cisco-openh264.repo"
    local repo_file="${CHROOT_DIR}/etc/yum.repos.d/fedora.repo"
    echo "[fedora]" > "${repo_file}"
    echo "name=Fedora \$releasever - \$basearch" >> "${repo_file}"
    echo "failovermethod=priority" >> "${repo_file}"
    echo "baseurl=${SOURCE_PATH}/releases/\$releasever/Everything/\$basearch/os/" >> "${repo_file}"
    echo "metadata_expire=28d" >> "${repo_file}"
    echo "gpgcheck=1" >> "${repo_file}"
    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch" >> "${repo_file}"
    echo "skip_if_unavailable=False" >> "${repo_file}"
    
    repo_file="${CHROOT_DIR}/etc/yum.repos.d/fedora-modular.repo"
    echo "[fedora-modular]" > "${repo_file}"
    echo "name=Fedora Modular \$releasever - \$basearch" >> "${repo_file}"
    echo "failovermethod=priority" >> "${repo_file}"
    echo "baseurl=${SOURCE_PATH}/releases/\$releasever/Modular/\$basearch/os/" >> "${repo_file}"
    echo "enabled=1" >> "${repo_file}"
    echo "metadata_expire=7d" >> "${repo_file}"
    echo "gpgcheck=1" >> "${repo_file}"
    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch" >> "${repo_file}"
    echo "skip_if_unavailable=False" >> "${repo_file}"

    repo_file="${CHROOT_DIR}/etc/yum.repos.d/fedora-updates.repo"
    echo "[updates]" > "${repo_file}"
    echo "name=Fedora \$releasever - \$basearch - Updates" >> "${repo_file}"
    echo "failovermethod=priority" >> "${repo_file}"
    echo "baseurl=${SOURCE_PATH}/updates/\$releasever/Everything/\$basearch/" >> "${repo_file}"
    echo "enabled=1" >> "${repo_file}"
    echo "gpgcheck=1" >> "${repo_file}"
    echo "metadata_expire=6h" >> "${repo_file}"
    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch" >> "${repo_file}"
    echo "skip_if_unavailable=False" >> "${repo_file}"
    
    repo_file="${CHROOT_DIR}/etc/yum.repos.d/fedora-updates-modular.repo"    
    echo "[updates-modular]" > "${repo_file}"
    echo "name=Fedora Modular \$releasever - \$basearch - Updates" >> "${repo_file}"
    echo "failovermethod=priority" >> "${repo_file}"
    echo "baseurl=${SOURCE_PATH}/updates/\$releasever/Modular/\$basearch/" >> "${repo_file}"
    echo "enabled=1" >> "${repo_file}"
    echo "gpgcheck=1" >> "${repo_file}"
    echo "metadata_expire=6h" >> "${repo_file}"
    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch" >> "${repo_file}"
    echo "skip_if_unavailable=False" >> "${repo_file}"
    
    
    
}

do_install()
{
    is_archive "${SOURCE_PATH}" && return 0

    msg ":: Installing ${COMPONENT} ... "

    local core_packages="iptables-libs libgcc crypto-policies fedora-release-identity-container tzdata python-setuptools-wheel pcre2-syntax ncurses-base libssh-config libreport-filesystem dnf-data fedora-gpg-keys fedora-release-container fedora-repos fedora-release-common setup filesystem basesystem glibc-minimal-langpack glibc-common glibc ncurses-libs bash zlib bzip2-libs xz-libs libzstd sqlite-libs libdb gmp libcap libcom_err libgpg-error libuuid libxcrypt popt libxml2 readline lua-libs elfutils-libelf file-libs expat libattr libacl libffi p11-kit libsmartcols libstdc++ libunistring libidn2 libassuan libgcrypt alternatives json-c keyutils-libs libcap-ng audit-libs libsepol libtasn1 p11-kit-trust lz4-libs pcre grep pcre2 libselinux sed libsemanage shadow-utils libutempter vim-minimal libpsl libcomps libmetalink libksba mpfr nettle gnutls elfutils-default-yama-scope elfutils-libs gdbm-libs libbrotli libeconf libgomp libnghttp2 libsigsegv gawk libsss_idmap libsss_nss_idmap libverto libyaml npth coreutils-common openssl-libs coreutils ca-certificates krb5-libs libtirpc libblkid libmount glib2 libnsl2 systemd-libs zchunk-libs libusb libfdisk cyrus-sasl-lib openldap gnupg2 gpgme libssh libcurl curl librepo tpm2-tss ima-evm-utils python-pip-wheel python3 python3-libs python3-libcomps python3-gpg gzip cracklib libpwquality pam libarchive rpm rpm-libs libmodulemd libsolv libdnf python3-libdnf python3-hawkey rpm-build-libs rpm-sign-libs python3-rpm python3-dnf dnf yum sssd-client sudo util-linux util-linux-user tar fedora-repos-modular rootfiles systemd-pam authselect-libs passwd libevent procps-ng findutils"
    
    case "${SUITE}" in
    "34");;
    "35") core_packages="${core_packages} libfsverity libusbx";;
    "36") core_packages="${core_packages} libfsverity pam-libs";;
    esac

    local repo_url
    if [ "${ARCH}" = "i386" ]
    then repo_url="${SOURCE_PATH%/}/fedora-secondary/releases/${SUITE}/Everything/${ARCH}/os"
    else repo_url="${SOURCE_PATH%/}/releases/${SUITE}/Everything/${ARCH}/os"
    fi

    msg -n "Preparing for deployment ... "
    tar xzf "${COMPONENT_DIR}/filesystem.tgz" -C "${CHROOT_DIR}"
    is_ok "fail" "done" || return 1

    msg -n "Retrieving packages list ... "
    local pkg_list="${CHROOT_DIR}/tmp/packages.list"
    (set -e
        repodata=$(wget -q -O - "${repo_url}/repodata/repomd.xml" | sed -n '/<location / s/^.*<location [^>]*href="\([^\"]*\-primary\.xml\.gz\)".*$/\1/p')
        [ -z "${repodata}" ] && exit 1
        wget -q -O - "${repo_url}/${repodata}" | gzip -dc | sed -n '/<location / s/^.*<location [^>]*href="\([^\"]*\)".*$/\1/p' > "${pkg_list}"
    exit 0)
    is_ok "fail" "done" || return 1

    msg "Retrieving packages: "
    local package i pkg_url pkg_file pkg_arch
    case "${ARCH}" in
    i386) pkg_arch="-e i686 -e noarch" ;;
    x86_64) pkg_arch="-e x86_64 -e noarch" ;;
    armhfp) pkg_arch="-e armv7hl -e noarch" ;;
    aarch64) pkg_arch="-e aarch64 -e noarch" ;;
    esac
    for package in ${core_packages}
    do
        msg -n "${package} ... "
        pkg_url=$(grep -e "^.*/${package}-[0-9r][0-9\.\-].*rpm$" "${pkg_list}" | grep -m1 ${pkg_arch})
        test "${pkg_url}"; is_ok "fail" || return 1
        pkg_file="${pkg_url##*/}"
        # download
        for i in 1 2 3
        do
            wget -q -c -O "${CHROOT_DIR}/tmp/${pkg_file}" "${repo_url}/${pkg_url}" && break
            sleep 30s
        done
        [ "${package}" = "filesystem" ] && { msg "done"; continue; }
        # unpack
        (cd "${CHROOT_DIR}"; rpm2cpio "./tmp/${pkg_file}" | cpio -idmu >/dev/null)
        is_ok "fail" "done" || return 1
    done
    
    component_exec core/emulator

    msg "Installing packages ... "
    chroot_exec /bin/rpm -i --force --nosignature --nodeps /tmp/*.rpm    
    is_ok || return 1

    msg -n "Clearing cache ... "
    rm -rf "${CHROOT_DIR}"/tmp/*
    is_ok "skip" "done"

    component_exec core/mnt core/net

    msg -n "Setting dnf excludes ..."
    echo "exclude=grubby" >> "${CHROOT_DIR}"/etc/dnf/dnf.conf
    is_ok "fail" "done"

    msg -n "Upgrading repository ..."
    dnf_repository
    is_ok "fail" "done"
    
    if [ "${SUITE}" = "36" ]; then 
        cp "${COMPONENT_DIR}"/*-auth "${CHROOT_DIR}"/etc/authselect/
        cp "${COMPONENT_DIR}"/postlogin "${CHROOT_DIR}"/etc/authselect/
        cp "${COMPONENT_DIR}"/dconf-* "${CHROOT_DIR}"/etc/authselect/
        cp "${COMPONENT_DIR}"/authselect.conf "${COMPONENT_DIR}"/nsswitch.conf "${CHROOT_DIR}"/etc/authselect/
        cp "${COMPONENT_DIR}"/*-auth "${CHROOT_DIR}/etc/pam.d/" 
        cp "${COMPONENT_DIR}"/postlogin "${CHROOT_DIR}/etc/pam.d/"
    fi

    msg -n "Upgrading packages ..."
    chroot_exec -u root dnf -y upgrade --refresh --nogpgcheck --skip-broken
    is_ok "fail" "done"

    msg -n "Installing minimal environment ..."
    chroot_exec -u root dnf -y groupinstall "Minimal Install" --nogpgcheck --skip-broken
    is_ok "fail" "done"

    if [ -n "${EXTRA_PACKAGES}" ]; then
      msg "Installing extra packages: "
      dnf_install ${EXTRA_PACKAGES}
      is_ok || return 1
    fi

    return 0
}

do_help()
{
cat <<EOF
   --arch="${ARCH}"
     Architecture of Linux distribution, supported "armhfp", "aarch64", "i386" and "x86_64".

   --suite="${SUITE}"
     Version of Linux distribution, supported version "28".

   --source-path="${SOURCE_PATH}"
     Installation source, can specify address of the repository or path to the rootfs archive.

   --extra-packages="${EXTRA_PACKAGES}"
     List of optional installation packages, separated by spaces.

EOF
}
