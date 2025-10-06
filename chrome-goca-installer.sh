#!/bin/bash
# Chrome GOCA Installer v1.0
# (Graphical One-Click App)
# Made by mgpx-now 💻

set -e

APP_VERSION="1.0"
APP_NAME="Chrome GOCA Installer"

# Check for Zenity
if ! command -v zenity &>/dev/null; then
    echo "Installing Zenity..."
    sudo apt update && sudo apt install -y zenity
fi

# Welcome Screen
zenity --info \
  --title="$APP_NAME v$APP_VERSION" \
  --width=400 \
  --text="🌐 Welcome to *Chrome GOCA Installer v$APP_VERSION!*\n\nThis app will automatically detect your system architecture and install the correct version of Google Chrome for Ubuntu.\n\nMade by *mgpx-now*.\n\nClick OK to continue."

# Detect system architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
elif [ "$ARCH" = "aarch64" ]; then
    DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_arm64.deb"
else
    zenity --error \
      --title="Unsupported Architecture" \
      --text="❌ Your system architecture ($ARCH) is not supported.\n\nSupported: x86_64 or ARM64 only."
    exit 1
fi

# Confirm Installation
zenity --question \
  --title="Confirm Installation" \
  --width=350 \
  --text="Detected: *$ARCH*\n\nProceed with installing Google Chrome?"

if [ $? -ne 0 ]; then
    zenity --info \
      --title="$APP_NAME" \
      --text="Installation cancelled by user."
    exit 0
fi

# Download and Install with Progress + Cancel Support
(
    echo "10"
    echo "# Downloading Chrome package..."
    wget -q "$DEB_URL" -O /tmp/chrome.deb || exit 1

    echo "60"
    echo "# Installing Google Chrome..."
    sudo apt install -y /tmp/chrome.deb > /dev/null 2>&1 || exit 1

    echo "90"
    echo "# Cleaning up..."
    rm -f /tmp/chrome.deb

    echo "100"
    echo "# Installation complete!"
) | zenity --progress \
            --title="$APP_NAME v$APP_VERSION" \
            --width=450 \
            --auto-kill \
            --percentage=0 \
            --ok-label="Close" \
            --cancel-label="Cancel Installation"

# Handle user cancel during progress
if [ $? -ne 0 ]; then
    zenity --warning \
      --title="Installation Cancelled" \
      --text="❗ Installation was cancelled.\nPartial files (if any) have been cleaned up."
    rm -f /tmp/chrome.deb
    exit 1
fi

# Completion Message
zenity --info \
  --title="$APP_NAME v$APP_VERSION" \
  --width=400 \
  --text="🎉 Google Chrome has been successfully installed!\n\nLaunch it from your app menu or run:\n\ngoogle-chrome-stable\n\n© mgpx-now | Version $APP_VERSION"
