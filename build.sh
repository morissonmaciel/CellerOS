#!/usr/bin/env bash

set -o errexit # Exit on non-zero status
set -o nounset # Error on unset variables

# Assuring system has podman installed
if ! command -v podman &> /dev/null; then
    pacman --noconfirm --sync --needed podman
fi

# Delete existing image with the same tag if it exists
if podman images | grep -q 'ghcr.io/morissonmaciel/usblue-celleros'; then
    podman rmi ghcr.io/morissonmaciel/usblue-celleros:latest
fi

podman build -f Containerfile -t ghcr.io/morissonmaciel/usblue-celleros:latest .