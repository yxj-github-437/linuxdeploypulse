#!/bin/sh
# Linux Deploy Component
# (c) Anton Skshidlevsky <meefik@gmail.com>, GPLv3

[ -n "${SUITE}" ] || SUITE="7"

SUITE="9-stream"

if [ -z "${ARCH}" ]
then
    case "$(get_platform)" in
    x86) ARCH="i386" ;;
    x86_64) ARCH="x86_64" ;;
    arm) ARCH="armhfp" ;;
    arm_64) ARCH="aarch64" ;;
    esac
fi

if [ -z "${SOURCE_PATH}" ]
then
    case "$(get_platform ${ARCH})" in
    x86|arm*) SOURCE_PATH="http://mirror.centos.org/altarch/" ;;
    x86_64) SOURCE_PATH="http://mirror.centos.org/centos/" ;;
    esac
fi

yum_install()
{
    local packages="$@"
    [ -n "${packages}" ] || return 1
    (set -e
        chroot_exec -u root yum install ${packages} --nogpgcheck --skip-broken -y
        chroot_exec -u root yum clean all
    exit 0)
    return $?
}

yum_groupinstall()
{
    local groupname="$@"
    [ -n "${groupname}" ] || return 1
    (set -e
        chroot_exec -u root yum groups install ${groupname} --nogpgcheck --skip-broken -y
        chroot_exec -u root yum clean all
    exit 0)
    return $?
}

yum_repository()
{
    local repo_file repo_url
    case "${SUITE}" in
    7)
    chroot_exec -u root yum-config-manager --disable '*' >/dev/null
    repo_file="${CHROOT_DIR}/etc/yum.repos.d/CentOS-${SUITE}-${ARCH}.repo"
    repo_url="${SOURCE_PATH%/}/${SUITE}/os/${ARCH}"
    echo "[centos-${SUITE}-${ARCH}]" > "${repo_file}"
    echo "name=CentOS ${SUITE} - ${ARCH}" >> "${repo_file}"
    echo "failovermethod=priority" >> "${repo_file}"
    echo "baseurl=${repo_url}" >> "${repo_file}"
    echo "enabled=1" >> "${repo_file}"
    echo "metadata_expire=7d" >> "${repo_file}"
    echo "gpgcheck=0" >> "${repo_file}"
    chmod 644 "${repo_file}"
    ;;
    *-stream)
    repo_file="${CHROOT_DIR}/etc/yum.repos.d/centos.repo"
    repo_url="${SOURCE_PATH%/}/${SUITE}/BaseOS/${ARCH}/os"
    echo "[baseos]" > "${repo_file}"
    echo 'name=CentOS Stream $releasever - BaseOS' >> "${repo_file}"
    echo "baseurl=${repo_url}" >> "${repo_file}"
    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial" >> "${repo_file}"
    echo "gpgcheck=1" >> "${repo_file}"
    echo "repo_gpgcheck=0" >> "${repo_file}"
    echo "metadata_expire=6h" >> "${repo_file}"
    echo "countme=1" >> "${repo_file}"
    echo "enabled=1" >> "${repo_file}"

    echo "" >> "${repo_file}"

    repo_url="${SOURCE_PATH%/}/${SUITE}/AppStream/${ARCH}/os"
    echo "[appstream]" >> "${repo_file}"
    echo 'name=CentOS Stream $releasever - AppStream' >> "${repo_file}"
    echo "baseurl=${repo_url}" >> "${repo_file}"
    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial" >> "${repo_file}"
    echo "gpgcheck=1" >> "${repo_file}"
    echo "repo_gpgcheck=0" >> "${repo_file}"
    echo "metadata_expire=6h" >> "${repo_file}"
    echo "countme=1" >> "${repo_file}"
    echo "enabled=1" >> "${repo_file}"
    chmod 644 "${repo_file}"
    ;;
    esac
}

do_install()
{
    is_archive "${SOURCE_PATH}" && return 0

    msg ":: Installing ${COMPONENT} ... "

    local core_packages
    case "${SUITE}" in
    *-stream) core_packages="alternatives audit-libs basesystem bash bzip2-libs ca-certificates centos-gpg-keys centos-stream-release centos-stream-repos chkconfig coreutils cpio cracklib cracklib-dicts cryptsetup-libs curl cyrus-sasl-lib dbus dbus-libs dnf dnf-automatic dnf-data dnf-plugins-core diffutils elfutils-libelf elfutils-libs expat file-libs filesystem gawk gdbm-libs glib2 glibc glibc-common glibc-gconv-extra gmp gnupg2 gpgme grep gzip ima-evm-utils-1.4 info json-c keyutils-libs kmod kmod-libs krb5-libs libacl libassuan libattr libblkid libcap libcap-ng libcomps libcom_err libcurl libdb libbrotli libdnf libeconf libffi libgcc libgcrypt libgomp libgpg-error libidn2 libmodulemd libmount libnghttp2 libpsl libpwquality librepo libseccomp libselinux libsemanage libsepol libsigsegv libsmartcols libsolv libssh libssh-config libstdc++ libtasn1 libunistring libuuid libverto libxcrypt libxml2 libyaml libzstd lua-libs lz4 lz4-libs ncurses ncurses-base ncurses-libs openldap openssl-libs p11-kit p11-kit-trust pam pcre pcre2 pkgconf popt python3 python3-dnf python3-gpg python3-hawkey python3-iniparse python3-libcomps python3-libdnf python3-libs python3-rpm readline rootfiles rpm rpm-build-libs rpm-libs rpm-sign-libs sed setup shadow-utils shared-mime-info sqlite-libs sudo systemd systemd-libs tar tpm2-tss tzdata usermode util-linux util-linux-core util-linux-user vim-minimal which xz xz-libs yum yum-utils zchunk-libs zlib zstd"
    ;;
    7) core_packages="audit-libs basesystem bash bzip2-libs ca-certificates chkconfig coreutils cpio cracklib cracklib-dicts cryptsetup-libs curl cyrus-sasl-lib dbus dbus-libs diffutils elfutils-libelf elfutils-libs expat file-libs filesystem gawk gdbm glib2 glibc glibc-common gmp gnupg2 gpgme grep gzip info keyutils-libs kmod kmod-libs krb5-libs libacl libassuan libattr libblkid libcap libcap-ng libcom_err libcurl libdb libdb-utils libffi libgcc libgcrypt libgpg-error libidn libmount libpwquality libselinux libsemanage libsepol libssh2 libstdc++ libtasn1 libuuid libverto libxml2 lua lz4 ncurses ncurses-base ncurses-libs nspr nss nss-pem nss-softokn nss-softokn-freebl nss-sysinit nss-tools nss-util openldap openssl-libs p11-kit p11-kit-trust pam pcre pinentry pkgconfig popt pth pygpgme pyliblzma python python-iniparse python-libs python-pycurl python-urlgrabber pyxattr qrencode-libs readline rootfiles rpm rpm-build-libs rpm-libs rpm-python sed setup shadow-utils shared-mime-info sqlite sudo systemd systemd-libs tzdata ustr util-linux vim-minimal which xz-libs yum yum-metadata-parser yum-plugin-fastestmirror yum-utils zlib"
    ;;
    esac

    local repo_url
    case "${SUITE}" in
    *-stream) repo_url="${SOURCE_PATH%/}/${SUITE}/BaseOS/${ARCH}/os"
    ;;
    7) repo_url="${SOURCE_PATH%/}/${SUITE}/os/${ARCH}"
    ;;
    esac

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
        pkg_url=$(grep -e "^.*/${package}-[0-9][0-9\.\-].*rpm$" "${pkg_list}" | grep -m1 ${pkg_arch})
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

    msg -n "Updating repository ... "
    yum_repository
    is_ok "fail" "done"

    msg -n "Upgrading packages ..."
    chroot_exec -u root yum -y upgrade --refresh --nogpgcheck
    is_ok "fail" "done"

    msg "Installing minimal environment: "
    case "${SUITE}" in
    *-stream) yum_groupinstall "Minimal Install" --exclude filesystem,linux-firmware,openssh-server
    ;;
    7)  yum_groupinstall "Minimal Install" --exclude filesystem,linux-firmware,openssh-server &&
    chroot_exec -u root yum-config-manager --disable centos-kernel >/dev/null
    ;;
    esac
    is_ok || return 1

    if [ -n "${EXTRA_PACKAGES}" ]; then
      msg "Installing extra packages: "
      yum_install ${EXTRA_PACKAGES}
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
     Version of Linux distribution, supported version "7".

   --source-path="${SOURCE_PATH}"
     Installation source, can specify address of the repository or path to the rootfs archive.

   --extra-packages="${EXTRA_PACKAGES}"
     List of optional installation packages, separated by spaces.

EOF
}