#!/bin/bash

argv=($@)
argc=$#

case ${argv[0]} in
    64)
        ARCH="amd64"
    ;;
    32)
        ARCH="i386"
    ;;
    *)
        echo "usage: $0 <32|64>"
        exit
    ;;
esac

VERSION="7.1.0"
BOX="debian-${VERSION}-${ARCH}"

FOLDER_BASE=$(pwd)
FOLDER_ISO="${FOLDER_BASE}/iso"
FOLDER_BUILD="${FOLDER_BASE}/build"
FOLDER_VBOX="${FOLDER_BUILD}/vbox"

DEBIAN_MIRROR="ftp.fr.debian.org"
DEBIAN_URL="http://${DEBIAN_MIRROR}/debian-cd/${VERSION}/${ARCH}/iso-cd"
DEBIAN_ISO_NAME="debian-${VERSION}-${ARCH}-netinst.iso"
DEBIAN_ISO_URL="${DEBIAN_URL}/${DEBIAN_ISO_NAME}"
DEBIAN_ISO_FILE="${FOLDER_ISO}/${DEBIAN_ISO_NAME}"

function abort {
    echo >&2 "ERROR: $1"
    exit 1
}

function info {
    echo "INFO: $1"
}

function warn {
    echo "WARN: $1"
}

function wait_for_shutdown {
    info "Waiting for installer..."
    while VBoxManage list runningvms | grep "${BOX}" > /dev/null; do
        sleep 10
    done
}

# Make sure guest additions are available.
VBOX_GUESTADDITIONS=$(find / -name VBoxGuestAdditions.iso 2>/dev/null)
if [ "$VBOX_GUESTADDITIONS" == "" ]; then
    abort "VirtualBox Guest Additions not found. Aborting."
fi

# Check if VM name is occupied
if VBoxManage showvminfo "${BOX}" >/dev/null 2>/dev/null; then
    read -p "Are you sure you want to destroy the '${BOX}' VM? [y/n] "
    if [ "$REPLY" == "y" ]; then
        VBoxManage unregistervm "${BOX}" --delete > /dev/null
    else
        abort "VM ${BOX} already exist. Aborting."
    fi
fi

mkdir -p "${FOLDER_ISO}"
mkdir -p "${FOLDER_VBOX}"
mkdir -p "${FOLDER_BUILD}/custom"
mkdir -p "${FOLDER_BUILD}/initrd"

# Download ISO if needed
if [ ! -f "${DEBIAN_ISO_FILE}" ]; then
    info "Downloading ${DEBIAN_ISO_NAME}..."
    curl --progress-bar -o "${DEBIAN_ISO_FILE}" -L "${DEBIAN_ISO_URL}"
fi

# Command to get MD5 hash from server
ISO_MD5=$(curl -s "${DEBIAN_URL}/MD5SUMS" | grep "${DEBIAN_ISO_NAME}" | awk '{ print $1 }')

# Check if hash is correct
if [ ! "${ISO_MD5}" ]; then
    info "Failed to download MD5 hash for ${DEBIAN_ISO_NAME}. Skipping."
else
    MD5=$(which md5)
    if [ -n "$MD5" ]; then
        ISO_HASH=$(md5 -q "${DEBIAN_ISO_FILE}")
    else
        ISO_HASH=$(md5sum "${DEBIAN_ISO_FILE}" | grep -o "^[a-z0-9]*")
    fi

    if [ "${ISO_MD5}" != "${ISO_HASH}" ]; then
        abort "MD5 does not match - expected ${ISO_MD5}. Aborting."
    fi
fi

info "Unpacking ${DEBIAN_ISO_NAME}..."
BSDTAR="$(which bsdtar)"
if [ ! -a "$BSDTAR" ]; then
    warn "Using system libarchive. May fail on OSX."
    BSDTAR="bsdtar"
fi
$BSDTAR -xf "${DEBIAN_ISO_FILE}" -C "${FOLDER_BUILD}/custom"

info "Grant write permission..."
chmod -R u+w "${FOLDER_BUILD}/custom"

info "Customizing ISO files..."
FOLDER_INSTALL=$(ls -1 -d "${FOLDER_BUILD}/custom/install."* | sed 's/^.*\///')
cp -r "${FOLDER_BUILD}/custom/${FOLDER_INSTALL}/"* "${FOLDER_BUILD}/custom/install/"

pushd "${FOLDER_BUILD}/initrd"
    FAKEROOT=$(which fakeroot)
    if [ -z "$FAKEROOT" ]; then
        gunzip -c "${FOLDER_BUILD}/custom/install/initrd.gz" | cpio -id
        cp "${FOLDER_BASE}/src/preseed.cfg" "${FOLDER_BUILD}/initrd/preseed.cfg"
        find . | cpio --create --format='newc' | gzip > "${FOLDER_BUILD}/custom/install/initrd.gz"
    else
        gunzip -c "${FOLDER_BUILD}/custom/install/initrd.gz" | ${FAKEROOT} cpio -id
        cp "${FOLDER_BASE}/src/preseed.cfg" "${FOLDER_BUILD}/initrd/preseed.cfg"
        find . | ${FAKEROOT} cpio --create --format='newc' | gzip > "${FOLDER_BUILD}/custom/install/initrd.gz"
    fi
popd

cp "${FOLDER_BASE}/src/poststrap.sh" "${FOLDER_BUILD}/custom/"
cp "${FOLDER_BASE}/src/bootstrap.sh" "${FOLDER_BUILD}/custom/"
cp "${FOLDER_BASE}/src/isolinux.cfg" "${FOLDER_BUILD}/custom/isolinux/"

info "Setting permissions on bootstrap scripts..."
chmod 755 "${FOLDER_BUILD}/custom/poststrap.sh"
chmod 755 "${FOLDER_BUILD}/custom/bootstrap.sh"

info "Packing ISO files..."
MKISOFS=$(which mkisofs || which genisoimage)
$MKISOFS -r -V "Custom Debian Install CD" -cache-inodes -quiet -J -l \
    -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
    -boot-load-size 4 -boot-info-table -o "${FOLDER_BUILD}/custom.iso" \
    "${FOLDER_BUILD}/custom"

info "Creating VM..."
VBoxManage createvm --name "${BOX}" --ostype Debian --register --basefolder "${FOLDER_VBOX}"

VBoxManage modifyvm "${BOX}" --memory 360 --boot1 dvd --boot2 disk \
    --boot3 none --boot4 none --vram 12 --pae off --rtcuseutc on

VBoxManage storagectl "${BOX}" --name "IDE Controller" --add ide \
    --controller PIIX4 --hostiocache on

VBoxManage storagectl "${BOX}" --name "SATA Controller" --add sata \
    --controller IntelAhci --sataportcount 1 --hostiocache off

VBoxManage createhd --filename "${FOLDER_VBOX}/${BOX}/${BOX}.vdi" --size 40960

VBoxManage storageattach "${BOX}" --storagectl "SATA Controller" --port 0 \
    --device 0 --type hdd --medium "${FOLDER_VBOX}/${BOX}/${BOX}.vdi"

VBoxManage storageattach "${BOX}" --storagectl "IDE Controller" \
    --port 0 --device 0 --type dvddrive --medium "${FOLDER_BUILD}/custom.iso"

info "Booting VM..."
VBoxManage startvm "${BOX}"
wait_for_shutdown

info "Installing guest additions..."
VBoxManage storageattach "${BOX}" --storagectl "IDE Controller" --port 0 \
    --device 0 --type dvddrive --medium "${VBOX_GUESTADDITIONS}"

VBoxManage startvm "${BOX}"
wait_for_shutdown

info "Building Vagrant box..."
vagrant package --base "${BOX}" --output "${BOX}.box"
