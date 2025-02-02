#!/bin/sh

# Define root directory
ROOTFS_DIR=$(pwd)/rootfs
export PATH=$PATH:$HOME/.local/bin

# Constants
MAX_RETRIES=50
TIMEOUT=1
ARCH=$(uname -m)

# Determine alternative architecture name
case $ARCH in
  x86_64) ARCH_ALT=amd64 ;;
  aarch64) ARCH_ALT=arm64 ;;
  *)
    printf "Unsupported CPU architecture: %s\n" "$ARCH"
    exit 1
    ;;
esac

# Create rootfs directory if it doesn't exist
mkdir -p "$ROOTFS_DIR"

# Check if already installed
if [ ! -e "$ROOTFS_DIR/.installed" ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      Foxytoux * Prajwol"
  echo "#"
  echo "#                           Copyright (C) 2024, RecodeStudios.Cloud"
  echo "#"
  echo "#"
  echo "#######################################################################################"
  
  # Prompt for Ubuntu installation
  read -p "Do you want to install Ubuntu? (YES/no): " install_ubuntu
fi

# Install Ubuntu if requested
case $install_ubuntu in
  [yY][eE][sS])
    # Download and extract Ubuntu base tarball
    curl -o /tmp/rootfs.tar.gz "http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.4-base-${ARCH_ALT}.tar.gz"
    tar -xf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"
    
    # Avoid permission issues by creating necessary directories
    mkdir -p "$ROOTFS_DIR/var/lib/apt/lists/partial"
    mkdir -p "$ROOTFS_DIR/tmp"
    chmod 1777 "$ROOTFS_DIR/tmp"
    ;;
  *)
    echo "Skipping Ubuntu installation."
    ;;
esac

# Ensure necessary directories exist
mkdir -p "$ROOTFS_DIR/usr/local/bin"

# Download and set up proot
curl -o "$ROOTFS_DIR/usr/local/bin/proot" "https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH}"
chmod 755 "$ROOTFS_DIR/usr/local/bin/proot"

# Set up DNS resolution
printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > "$ROOTFS_DIR/etc/resolv.conf"

# Clean up temporary files
rm -rf /tmp/rootfs.tar.gz

# Mark as installed
touch "$ROOTFS_DIR/.installed"

# Color constants
CYAN='\e[0;36m'
WHITE='\e[0;37m'
RESET_COLOR='\e[0m'

# Display completion message
display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> Mission Completed ! <----${RESET_COLOR}"
}

# Clear screen and display completion message
clear
display_gg

# Start proot with fake root privileges
"$ROOTFS_DIR/usr/local/bin/proot" \
  --rootfs="$ROOTFS_DIR" \
  -0 -w "/root" \
  -b /dev \
  -b /sys \
  -b /proc \
  -b /etc/resolv.conf \
  --kill-on-exit \
  /bin/bash -c "apt-get update && apt-get install -y --no-install-recommends bash coreutils && bash"
