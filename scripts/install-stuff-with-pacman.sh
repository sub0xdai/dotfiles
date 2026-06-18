#/bin/bash

# Package installation script for Arch Linux
# This script installs a set of useful tools and development packages

# Exit immediately if a command exits with a non-zero status
set -e

# Function to install packages
install_packages() {
    local packages=(
        nmap jq yq pcgrep lynx make uidmap ruby python-is-python3
        libcurses build-essential libncurses-dev autoconf entr pip
        curl bash-completion skopeo buildah postgresql-client-common
        ca-certificates gpg shellcheck shfmt tree fio vault
    )

    echo "Installing packages..."
    if sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        echo "Package installation successful!"
    else
        echo "Error: Package installation failed." >&2
        exit 1
    fi
}

# Main execution
echo "Starting package installation process..."

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: This script should not be run as root. Please run without sudo." >&2
    exit 1
fi

# Check if pacman is available
if ! command -v pacman &> /dev/null; then
    echo "Error: pacman not found. This script is intended for Arch-based systems." >&2
    exit 1
fi

# Run the installation function
install_packages

echo "Script completed successfully."
