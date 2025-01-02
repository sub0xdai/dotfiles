# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

# Set Oh My Zsh theme (though you're using starship, keep this as fallback)
ZSH_THEME="robbyrussell"

# ASDF
. /opt/asdf-vm/asdf.sh

# Oh My Zsh plugins
plugins=(
    git
    docker
    zoxide
    fzf
    tmux
    golang
    rust
    npm
    python
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# Source common configurations
source ~/.shell_common

# Zsh-specific settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history

# Initialize tools for zsh
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

# Deno
. "$HOME/.deno/env"



# Clean path (using zsh syntax)
typeset -U PATH path
