#!/bin/bash

argv=($@)
argc=$#

case ${argv[0]} in
    64)
        ARCH="amd64"
        FOLDER_INSTALL="install.amd"
    ;;

    32)
        ARCH="i386"
        FOLDER_INSTALL="install.386"
    ;;

    *)
        echo "usage: $0 <32|64>"
        exit
    ;;
esac

VERSION="6.0.5"
BOX="debian-${VERSION}-${ARCH}"

FOLDER_BASE=$(pwd)
FOLDER_BUILD="${FOLDER_BASE}/build"
FOLDER_ISO="${FOLDER_BUILD}/iso"
FOLDER_VBOX="${FOLDER_BUILD}/vbox"

DEBIAN_MIRROR="ftp.acc.umu.se"
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

# Check if VM name is occupied
if VBoxManage showvminfo "${BOX}" >/dev/null 2>/dev/null; then
    read -p "Do you want to delete offending ${BOX} VirtualBox VM (y/n)? "
    if [ "$REPLY" == "y" ]; then
        VBoxManage unregistervm "${BOX}" --delete > /dev/null
    else
        abort "VM ${BOX} already exist. Aborting."
    fi
fi

info "Cleaning build directories..."
mkdir -p "${FOLDER_BUILD}"
chmod -R u+w "${FOLDER_BUILD}"
rm -rf "${FOLDER_ISO}/custom"
rm -rf "${FOLDER_ISO}/initrd"

mkdir -p "${FOLDER_VBOX}"
mkdir -p "${FOLDER_ISO}"
mkdir -p "${FOLDER_ISO}/custom"
mkdir -p "${FOLDER_ISO}/initrd"

# Download ISO if needed
info "Downloading ${DEBIAN_ISO_NAME}..."
if [ ! -f "${DEBIAN_ISO_FILE}" ]; then
	curl --progress-bar -o "${DEBIAN_ISO_FILE}" -L "${DEBIAN_ISO_URL}"
fi

# Command to get MD5 hash from server
ISO_MD5=$(curl -s "${DEBIAN_URL}/MD5SUMS" | grep "${DEBIAN_ISO_NAME}" | awk '{ print $1 }')

# Check if hash is correct
if [ ! "${ISO_MD5}" ]; then
	info "Faild to download MD5 hash for ${DEBIAN_ISO_NAME}. Skipping."
else
	ISO_HASH=$(md5 -q "${DEBIAN_ISO_FILE}")
	if [ "${ISO_MD5}" != "${ISO_HASH}" ]; then
		abort "MD5 does not match - expected ${ISO_MD5}. Aborting."
	fi
fi

info "Unpacking ${DEBIAN_ISO_NAME}..."
bsdtar -xf "${DEBIAN_ISO_FILE}" -C "${FOLDER_ISO}/custom"

info "Customizing ISO files..."
chmod -R u+w "${FOLDER_ISO}/custom"

pushd "${FOLDER_ISO}/initrd"
	gunzip -c "${FOLDER_ISO}/custom/${FOLDER_INSTALL}/initrd.gz" | cpio -id
	cp "${FOLDER_BASE}/conf/preseed.cfg" "${FOLDER_ISO}/initrd/preseed.cfg"
	find . | cpio --create --format='newc' | gzip  > "${FOLDER_ISO}/custom/${FOLDER_INSTALL}/initrd.gz"
popd

cp "${FOLDER_BASE}/conf/late_command.sh" "${FOLDER_ISO}/custom/late_command.sh"
cp "${FOLDER_BASE}/conf/isolinux.${ARCH}.cfg" "${FOLDER_ISO}/custom/isolinux/isolinux.cfg"

info "Packing ISO files..."
mkisofs -r -V "Custom Debian Install CD" -cache-inodes -quiet -J -l \
	-b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
	-boot-load-size 4 -boot-info-table -o "${FOLDER_ISO}/custom.iso" \
	"${FOLDER_ISO}/custom"

chmod -R u-w "${FOLDER_ISO}/custom"

info "Creating VM..."
VBoxManage createvm \
	--name "${BOX}" \
	--ostype Debian \
	--register \
	--basefolder "${FOLDER_VBOX}"
	
VBoxManage modifyvm "${BOX}" \
	--memory 360 \
	--boot1 dvd \
	--boot2 disk \
	--boot3 none \
	--boot4 none \
	--vram 12 \
	--pae off \
	--rtcuseutc on
	
VBoxManage storagectl "${BOX}" \
	--name "IDE Controller" \
	--add ide \
	--controller PIIX4 \
	--hostiocache on
	
VBoxManage storageattach "${BOX}" \
	--storagectl "IDE Controller" \
	--port 1 \
	--device 0 \
	--type dvddrive \
	--medium "${FOLDER_ISO}/custom.iso"
	
VBoxManage storagectl "${BOX}" \
	--name "SATA Controller" \
	--add sata \
	--controller IntelAhci \
	--sataportcount 1 \
	--hostiocache off
	
VBoxManage createhd \
	--filename "${FOLDER_VBOX}/${BOX}/${BOX}.vdi" \
	--size 40960
	
VBoxManage storageattach "${BOX}" \
	--storagectl "SATA Controller" \
	--port 0 \
	--device 0 \
	--type hdd \
	--medium "${FOLDER_VBOX}/${BOX}/${BOX}.vdi"

info "Booting VM..."
VBoxManage startvm "${BOX}"

info "Waiting for installer..."
while VBoxManage list runningvms | grep "${BOX}" > /dev/null; do
	sleep 10
done

info "Building Vagrant box..."
vagrant package --base "${BOX}" --output "${BOX}.box"
