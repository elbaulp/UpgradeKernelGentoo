#!/usr/bin/env bash

## Upgrade gentoo kernel

# The first and only argument must be the folder name of the new kernel.

# Stop script when an error occurs
set -o errexit
set -o pipefail
set -o nounset
# For debugging purposes
set -o xtrace

readonly kernel_path='/usr/src/'

_usage () {
    local script_name="$0"
    echo "Usage: $0 <newkernelfolder>"
}

_main () {
    echo "Backing up old kernel..."
    cd "${kernel_path}/linux/"
    cp .config ~/kernel-config-"$(uname -r)"
    echo "Copying old configuration..."
    cp /usr/src/linux/.config /tmp/.config
    echo "Setting new kernel as default..."
    ln -sf /usr/src/"$1" /usr/src/linux
    cp /tmp/.config /usr/src/linux/
    eselect kernel set 2
    cd /usr/src/linux/
    echo "Building..."
    make -j4 olddefconfig
    make -j4 modules_prepare
    emerge --ask @module-rebuild
    make -j4
    make install
    make -j4 modules_install
    echo "Please, update your EFI entry: cp /boot/vmlinuz-*-gentoo /boot/efi/boot/bootx64.efi"
}


if [[ $# -eq 1 ]]
then
    _main $1
else
    _usage
fi
