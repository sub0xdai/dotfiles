# ─── Stabilize fpath BEFORE Oh My Zsh (prevents compdump invalidation loop) ───
skip_global_compinit=1
export ZSH_DISABLE_COMPFIX="true"

# Set ZSH early — needed for fpath injection below
export ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# ─── Runtime shims & completions — injected before framework init ───
export PATH="$HOME/.local/share/mise/shims:$PATH"
fpath=($HOME/.local/share/mise/completions $fpath $ZSH_CUSTOM/plugins/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-defer)

# ─── Source shared configuration ───
source ~/.shell_common

# ─── Oh My Zsh ───
ZSH_THEME="robbyrussell"

zmodload zsh/zprof

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
)
source $ZSH/oh-my-zsh.sh

# ─── Completion delegated to Oh My Zsh (native 24h dump invalidation, ZSH_COMPDUMP-aware) ───

# ─── Zsh options ───
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history

# ─── Async plugin loader (zsh-defer) ───
if [[ -f $ZSH_CUSTOM/plugins/zsh-defer/zsh-defer.plugin.zsh ]]; then
  source $ZSH_CUSTOM/plugins/zsh-defer/zsh-defer.plugin.zsh
  zsh-defer source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
  DEFER_ACTIVE=1
else
  source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
  DEFER_ACTIVE=0
fi

# ─── Fast tool initialization ───
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# ─── Keybindings ───
bindkey -s '^Xgc' 'git commit -m ""\C-b'

# ─── Deduplicate PATH ───
typeset -U PATH path

# ─── Additional PATH entries (zsh-only; shared PATH in .shell_common) ───
export PATH="/home/m0xu/.synapse-system/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/home/m0xu/.bun/_bun" ] && source "/home/m0xu/.bun/_bun"

# Pixi, Turso, Fly
export PATH="/home/m0xu/.pixi/bin:$PATH"
export PATH="$PATH:/home/m0xu/.turso"
export FLYCTL_INSTALL="/home/m0xu/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# ─── Syntax highlighting (MUST be last sourced plugin) ───
if (( DEFER_ACTIVE )); then
  zsh-defer source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
else
  source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
fi

# ─── Background byte-code compilation (never blocks the prompt) ───
(
  local dump_file="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump-${SHORT_HOST:-$HOST}-${ZSH_VERSION}}"
  if [[ -f "$dump_file" && "$dump_file" -nt "${dump_file}.zwc" ]]; then
    zcompile "$dump_file"
  fi
  if [[ ~/.zshrc -nt ~/.zshrc.zwc ]]; then
    zcompile ~/.zshrc
  fi
) &!

# ─── Aliases ───
alias claude-mem='bun "/home/m0xu/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
