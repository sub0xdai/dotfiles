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

# Function to install a tool with mise (auto-manages backends, no manual plugin step)
install_mise_tool() {
    echo "Installing latest version of $1 via mise"
    mise use -g "$1@latest"
}

# Array of tools to migrate
# Format: "pacman_pkg:mise_tool" (mise tool name, auto-resolved backend)
tools=(
    "go:go"
    "nodejs|npm:node"
    "python|python-pip:python"
    "ruby:ruby"
    "rust:rust"
    "php:php"
    "lua:lua"
    "postgresql:postgres"
    "zoxide:zoxide"
)

if ! command -v mise &> /dev/null; then
    echo "mise is not installed. Install it first: https://mise.jdx.dev"
    exit 1
fi

echo "This script will remove system packages and install them via mise."
echo "Please make sure mise is configured in your shell (~/.config/mise/config.toml)."
read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

for entry in "${tools[@]}"; do
    pacman_pkgs="${entry%%:*}"
    mise_tool="${entry##*:}"

    # Remove system packages (pipe-separated for multi-package entries like nodejs|npm)
    IFS='|' read -ra pkgs <<< "$pacman_pkgs"
    for pkg in "${pkgs[@]}"; do
        remove_package "$pkg"
    done

    install_mise_tool "$mise_tool"
done

echo "Migration complete. Restart your shell or run 'exec \$SHELL -l' to pick up mise shims."
echo "You may need to reinstall global packages for Node.js, Python, etc."
