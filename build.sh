#!/bin/bash

ARCH="amd64"
VERSION="6.0.5"
BOX="debian-${VERSION}-${ARCH}"

DEBIAN_MIRROR="ftp.acc.umu.se"
DEBIAN_URL="http://${DEBIAN_MIRROR}/debian-cd/${VERSION}/${ARCH}/iso-cd"
DEBIAN_ISO_NAME="debian-${VERSION}-${ARCH}-netinst.iso"
DEBIAN_ISO_URL="${DEBIAN_URL}/${DEBIAN_ISO_NAME}"

FOLDER_BASE=`pwd`
FOLDER_BUILD="${FOLDER_BASE}/build"
FOLDER_VBOX="${FOLDER_BUILD}/vbox"
FOLDER_ISO="${FOLDER_BUILD}/iso"
FOLDER_ISO_CUSTOM="${FOLDER_ISO}/custom"
FOLDER_ISO_INITRD="${FOLDER_ISO}/initrd"
FOLDER_ISO_CUSTOM_INSTALL="${FOLDER_ISO_CUSTOM}/install.amd"

ISO_FILEPATH="${FOLDER_ISO}/${DEBIAN_ISO_NAME}"

function abort {
	echo >&2 "ERROR: $1"
	exit 1
}

function info {
	echo "INFO: $1"
}

function check_deps {
	which -s mkisofs || {
		abort "mkisofs not found. Aborting."
	}
	
	which -s bsdtar || {
		abort "bsdtar not found. Aborting."
	}

	if VBoxManage showvminfo "${BOX}" >/dev/null 2>/dev/null; then
		abort "VM ${BOX} already exist. Aborting."
	fi
}

info "Checking for dependencies..."
check_deps

info "Cleaning build directories..."
mkdir -p "${FOLDER_BUILD}"
chmod -R u+w "${FOLDER_BUILD}"
rm -rf "${FOLDER_ISO_CUSTOM}"
rm -rf "${FOLDER_ISO_INITRD}"

mkdir -p "${FOLDER_VBOX}"
mkdir -p "${FOLDER_ISO}"
mkdir -p "${FOLDER_ISO_CUSTOM}"
mkdir -p "${FOLDER_ISO_INITRD}"

# Download ISO if needed
info "Downloading ${DEBIAN_ISO_NAME}..."
if [ ! -f "${ISO_FILEPATH}" ]; then
	curl --progress-bar -o "${ISO_FILEPATH}" -L "${DEBIAN_ISO_URL}"
fi

# Command to get MD5 hash from server
ISO_MD5=$(curl -s "${DEBIAN_URL}/MD5SUMS" | grep "${DEBIAN_ISO_NAME}" | awk '{ print $1 }')

# Check if hash is correct
if [ ! "${ISO_MD5}" ]; then
	info "Faild to download MD5 hash for ${DEBIAN_ISO_NAME}. Skipping."
else
	ISO_HASH=`md5 -q "${ISO_FILEPATH}"`
	if [ "${ISO_MD5}" != "${ISO_HASH}" ]; then
		abort "MD5 does not match - expected ${ISO_MD5}. Aborting."
	fi
fi

info "Unpacking ${DEBIAN_ISO_NAME}..."
bsdtar -xf "${ISO_FILEPATH}" -C "${FOLDER_ISO_CUSTOM}"

info "Customizing ISO files..."
chmod -R u+w "${FOLDER_ISO_CUSTOM}"

cd "${FOLDER_ISO_INITRD}"
	gunzip -c "${FOLDER_ISO_CUSTOM_INSTALL}/initrd.gz" | cpio -id
	cp "${FOLDER_BASE}/conf/preseed.cfg" "${FOLDER_ISO_INITRD}/preseed.cfg"
	find . | cpio --create --format='newc' | gzip  > "${FOLDER_ISO_CUSTOM_INSTALL}/initrd.gz"
cd "${FOLDER_BASE}"

cp "${FOLDER_BASE}/conf/late_command.sh" "${FOLDER_ISO_CUSTOM}/late_command.sh"
cp "${FOLDER_BASE}/conf/isolinux.cfg" "${FOLDER_ISO_CUSTOM}/isolinux/isolinux.cfg"

info "Packing ISO files..."
mkisofs -r -V "Custom Debian Install CD" -cache-inodes -quiet -J -l \
	-b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
	-boot-load-size 4 -boot-info-table -o "${FOLDER_ISO}/custom.iso" \
	"${FOLDER_ISO_CUSTOM}"

chmod -R u-w "${FOLDER_ISO_CUSTOM}"

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
while VBoxManage list runningvms | grep "${BOX}" >/dev/null; do
	sleep 10
done

info "Building Vagrant box..."
vagrant package --base "${BOX}" --output "${BOX}.box"
