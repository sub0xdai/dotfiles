#!/bin/bash
# Use /bin/bash as the shell interpreter for this script.
set -e -x
# `set -e` exits the script immediately if any command returns a non-zero status.
# `set -x` prints each command before executing it, useful for debugging.

update_plugins() {
  # Define a function to update all asdf plugins to their latest versions.
  
  for plugin in $(asdf plugin list); do
    # Loop through each installed asdf plugin.
    # `asdf plugin list` lists all installed plugins.
    
    latest_version=$(asdf latest "$plugin")
    # Get the latest available version for the plugin using `asdf latest`.
    
    asdf install "$plugin" "$latest_version"
    # Install the latest version of the plugin.
    
    asdf global "$plugin" "$latest_version"
    # Set the newly installed version as the global version for the plugin.
  done
}

# Ensure the script only runs the function if it's executed directly, not sourced.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  update_plugins
  # Call the function to update plugins if the script is executed directly.
fi


