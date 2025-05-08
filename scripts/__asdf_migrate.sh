#!/bin/bash

# Function to remove a system package
remove_package() {
    if pacman -Qi "$1" &> /dev/null; then
        echo "Removing system package: $1"
        sudo pacman -Rs "$1" --noconfirm
    else
        echo "Package $1 is not installed, skipping."
    fi
}

# Function to install a tool with asdf
install_asdf_tool() {
    if ! asdf plugin list | grep -q "^$1$"; then
        echo "Adding asdf plugin: $1"
        asdf plugin add "$1"
    fi
    echo "Installing latest version of $1"
    asdf install "$1" latest
    asdf global "$1" latest
}

# Array of tools to migrate
tools=(
    "go"
    "nodejs"
    "python"
    "ruby"
    "rust"
    "php"
    "lua"
    "postgresql"
    "zoxide"
)

echo "This script will remove system packages and install them via asdf."
echo "Please make sure you have asdf installed and configured."
read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

for tool in "${tools[@]}"; do
    case $tool in
        "go")
            remove_package "go"
            install_asdf_tool "golang"
            ;;
        "nodejs")
            remove_package "nodejs"
            remove_package "npm"
            install_asdf_tool "nodejs"
            ;;
        "python")
            remove_package "python"
            remove_package "python-pip"
            install_asdf_tool "python"
            ;;
        "ruby")
            remove_package "ruby"
            install_asdf_tool "ruby"
            ;;
        "rust")
            remove_package "rust"
            install_asdf_tool "rust"
            ;;
        "php")
            remove_package "php"
            install_asdf_tool "php"
            ;;
        "lua")
            remove_package "lua"
            install_asdf_tool "lua"
            ;;
        "postgresql")
            remove_package "postgresql"
            install_asdf_tool "postgres"
            ;;
        "zoxide")
            remove_package "zoxide"
            install_asdf_tool "zoxide"
            ;;
    esac
done

echo "Migration complete. Please restart your shell or source your shell configuration file."
echo "You may need to reinstall global packages for Node.js, Python, etc."
