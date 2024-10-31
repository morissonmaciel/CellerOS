#!/usr/bin/env bash

set -o errexit # Exit on non-zero status
set -o nounset # Error on unset variables

# List all root (physical) disks with a defined model and let user select one
echo "Select a root (physical) disk from the list below:"
lsblk -o NAME,TYPE,FSTYPE,MODEL,ID-LINK,SIZE,LABEL | grep 'disk' | grep -v '^\s*$'
read -p "Enter the disk name (e.g., sda): " disk_name

if [ -z "$disk_name" ]; then
    echo "No disk selected. Exiting."
    exit 1
fi

# Extract and echo the ID-LINK of the selected disk
id_link=$(lsblk -o NAME,ID-LINK | grep "^$disk_name" | awk '{print $2}')
if [ -z "$id_link" ]; then
    echo "ID-LINK not found for disk: $disk_name"
    exit 1
fi

echo "You selected disk: $disk_name"
echo "ID-LINK: $id_link"