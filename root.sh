#!/bin/sh

# Variables globales
ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
MAX_RETRIES=50
TIMEOUT=1
ARCH=$(uname -m)
INSTALL_MARKER="$ROOTFS_DIR/.installed"

# Detectar arquitectura
case "$ARCH" in
  x86_64) ARCH_ALT="amd64" ;;
  aarch64) ARCH_ALT="arm64" ;;
  *) 
    echo "Unsupported CPU architecture: ${ARCH}"
    exit 1
    ;;
esac

# Función para descargar archivos con reintentos
download_with_retries() {
  local url="$1"
  local output="$2"
  local retries=0
  while [ $retries -lt $MAX_RETRIES ]; do
    wget --tries=1 --timeout=$TIMEOUT --no-hsts -O "$output" "$url"
    if [ $? -eq 0 ] && [ -s "$output" ]; then
      return 0
    fi
    retries=$((retries + 1))
    sleep 1
  done
  echo "Failed to download $url after $MAX_RETRIES attempts."
  return 1
}

# Verificar si ya está instalado
if [ ! -e "$INSTALL_MARKER" ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      Foxytoux INSTALLER"
  echo "#"
  echo "#                           Copyright (C) 2024, RecodeStudios.Cloud"
  echo "#"
  echo "#"
  echo "#######################################################################################"
  read -p "Do you want to install Ubuntu? (YES/no): " install_ubuntu
fi

# Instalar Ubuntu si el usuario lo solicita
case "$install_ubuntu" in
  [yY][eE][sS])
    UBUNTU_VERSION="20.04"
    UBUNTU_URL="http://cdimage.ubuntu.com/ubuntu-base/releases/${UBUNTU_VERSION}/release/ubuntu-base-${UBUNTU_VERSION}-base-${ARCH_ALT}.tar.gz"
    TMP_TAR="/tmp/rootfs.tar.gz"

    echo "Downloading Ubuntu base system (${UBUNTU_VERSION}) for ${ARCH_ALT}..."
    if ! download_with_retries "$UBUNTU_URL" "$TMP_TAR"; then
      echo "Failed to download Ubuntu base system."
      exit 1
    fi

    echo "Extracting root filesystem..."
    tar -xf "$TMP_TAR" -C "$ROOTFS_DIR"
    rm -f "$TMP_TAR"
    ;;
  *)
    echo "Skipping Ubuntu installation."
    ;;
esac

# Configurar PRoot si no está instalado
if [ ! -e "$INSTALL_MARKER" ]; then
  mkdir -p "$ROOTFS_DIR/usr/local/bin"
  PROOT_URL="https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH}"
  PROOT_BIN="$ROOTFS_DIR/usr/local/bin/proot"

  echo "Downloading PRoot binary for ${ARCH}..."
  if ! download_with_retries "$PROOT_URL" "$PROOT_BIN"; then
    echo "Failed to download PRoot binary."
    exit 1
  fi

  chmod 755 "$PROOT_BIN"
fi

# Configurar resolv.conf y marcar como instalado
if [ ! -e "$INSTALL_MARKER" ]; then
  echo "Configuring DNS settings..."
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1\n" > "${ROOTFS_DIR}/etc/resolv.conf"
  touch "$INSTALL_MARKER"
fi

# Función para mostrar mensaje de finalización
display_completion_message() {
  CYAN='\e[0;36m'
  WHITE='\e[0;37m'
  RESET_COLOR='\e[0m'
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> Mission Completed! <----${RESET_COLOR}"
}

# Limpiar pantalla y mostrar mensaje final
clear
display_completion_message

# Ejecutar PRoot
echo "Starting PRoot environment..."
$ROOTFS_DIR/usr/local/bin/proot \
  --rootfs="${ROOTFS_DIR}" \
  -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit
