#!/usr/bin/env bash

set -o errexit # Exit on non-zero status
set -o nounset # Error on unset variables

# Assuring system has podman installed
if ! command -v podman &> /dev/null; then
    pacman --noconfirm --sync --needed podman
fi

# Delete existing image with the same tag if it exists
if podman images | grep -q 'ghcr.io/morissonmaciel/gamer-archos'; then
    podman rmi ghcr.io/morissonmaciel/gamer-archos:latest
fi

podman build -f Dockerfile -t ghcr.io/morissonmaciel/gamer-archos:latest .

# Delete existing image with the same tag if it exists for Gnome.dockerfile
if podman images | grep -q 'ghcr.io/morissonmaciel/gnome-gamer-archos'; then
    podman rmi ghcr.io/morissonmaciel/gnome-gamer-archos:latest
fi

podman build -f Gnome.dockerfile -t ghcr.io/morissonmaciel/gnome-gamer-archos:latest .