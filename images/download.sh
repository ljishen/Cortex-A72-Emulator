#!/usr/bin/env bash

set -eu -o pipefail

# Source of Images
curl -O http://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-arm64-uefi1.img
curl -O https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_EFI.fd
