# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Custom prompt
PS1='[\u@\h \W]\$ '

# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='exa -lah --color=auto --group-directories-first'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Additional aliases
alias ll='exa -alF'
alias la='exa -A'
alias l='exa -CF'
alias vim='nvim'
alias alert='/home/sub0x/dotfiles/scripts/alert.sh'
alias fetch='neofetch'
alias shutdown='sync; shutdown -h now'
alias tor='cd ~/Documents/tor-browser && ./start-tor-browser.desktop'
alias commit='git add -A; git commit -m'
alias ssha='eval $(ssh-agent) && ssh-add'
alias virt='virt-manager'
alias tm="tmux"
alias powerm="xfce4-power-manager-settings"
alias update='sudo pacman -Syu'
alias reload='source ~/.bashrc'
alias weather='curl wttr.in/melbourne'
alias fman='compgen -c | fzf | xargs man'
alias fzf='fzf --preview="bat --color=always {}"'
alias speed='speedtest-cli'
alias pomo='pomo start -t'
alias repo='~/dotfiles/scripts/repo.sh'
alias goproj='~/dotfiles/scripts/setup_go.sh'
#alias silverbullet='~/.deno/bin/silverbullet ~/1-projects/vaults/silverbullet'
alias installed='~/dotfiles/scripts/installed.sh'



# Tmux aliases
alias tns='tmux new-session -s'
alias trs='tmux rename-session -t'
alias tas='tmux attach-session -t'
alias tls='tmux list-sessions'
alias tks='tmux kill-session -t'
alias tsave='tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh'
alias trestore='tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh'
alias tn='tmux new-session -s $(basename $PWD)'
alias tsd='tsave && tmux detach'
alias tx='tmuxinator'
alias tds='tmux detach'

# Activate el-ai
alias l-ai='source ~/1-projects/sandbox/venv/bin/activate'


# Start tmux automatically
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

# shell fn to create zettel note from terminal
zk() {
    read -p "title: " filename
    nvim ~/1-projects/vaults/sub0x_vault/0-zettel/"$filename".md
}

# Function to add a log entry to today's note
zkl() {
    notes_path=~/1-projects/vaults/sub0x_vault/5-notes
    today=$(date +%Y-%m-%d)
    todays_note="$notes_path/$today.md"
    if [ ! -f "$todays_note" ]; then
        create_daily_note
    fi
    read -p "Log: " log_entry
    sed -i '/# Log/,/^---/{/^---/!s/$/\n- '"$log_entry"'/;:a;n;ba}' "$todays_note"
    echo "Log added"
}

# Function to add a todo item to today's note
zkt() {
    notes_path=~/1-projects/vaults/sub0x_vault/5-notes
    today=$(date +%Y-%m-%d)
    todays_note="$notes_path/$today.md"
    if [ ! -f "$todays_note" ]; then
        create_daily_note
    fi
    read -p "Todo: " todo_item
    sed -i '/# Todo/,/^---/{/^---/!s/$/\n- [ ] '"$todo_item"'/;:a;n;ba}' "$todays_note"
    echo "Todo added"
}

# Function to create a new daily note with the template
create_daily_note() {
    cat << EOF > "$todays_note"
---
id: $(uuidgen)
title: $today
desc: journal and log with tasks
alias: []
tags: [daily, journal]
---
---
>  [[$(date -d "yesterday" +%Y-%m-%d)]] <=> [[$(date -d "tomorrow" +%Y-%m-%d)]]
---
# Log

-
---
# Todo

- [ ] 
---
> [[5-notes]]
EOF
}

# Starship prompt
eval "$(starship init bash)"
eval "$(zoxide init bash)"

# FZF default command
export FZF_DEFAULT_COMMAND='fd --type f'
export TERM=xterm-256color


# Clean up and set PATH
clean_path() {
  echo "$1" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//'
}
# Set PATH
export PATH=$(clean_path "$HOME/perl5/bin:$HOME/.local/share/gem/ruby/3.2.0/bin:$HOME/.npm-global/bin:$HOME/.atuin/bin:$HOME/.luarocks/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$HOME/.local/bin:$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/go/bin:$PATH")
# Ensure Go binaries are in PATH
export PATH="$HOME/go/bin:$PATH"
# Set default browser
export BROWSER=zen-browser
# Cargo (Rust) environment
. "$HOME/.cargo/env"
# Ruby Gems
export PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
# Pipx
export PATH="$PATH:$HOME/.local/bin"
# .NET Core
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools
# Perl
export PATH="/home/sub0x/perl5/bin${PATH:+:${PATH}}"
export PERL5LIB="/home/sub0x/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="/home/sub0x/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"/home/sub0x/perl5\""
export PERL_MM_OPT="INSTALL_BASE=/home/sub0x/perl5"
# Luarocks
eval "$(luarocks path --bin)"
# Atuin
export PATH="$HOME/.atuin/bin:$PATH"
# Scripts
export PATH="$PATH:$HOME/dotfiles/scripts"
# Snap
export PATH=$PATH:/var/lib/snapd/snap/bin
# Final PATH cleanup (remove duplicates)
export PATH=$(clean_path "$PATH")
# Source preexec if available
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

# Tmuxinator environment variables
export EDITOR='nvim' 
export SHELL='/bin/bash'

source ~/dotfiles/scripts/grep_open.sh

# Export openapi key
if [ -f "$HOME/dotfiles/.env" ]; then
    export $(grep -v '^#' $HOME/dotfiles/.env | xargs)
fi


# Bash completion
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# ASDF
export PATH="$HOME/.asdf/shims:$PATH"
. /opt/asdf-vm/asdf.sh
#. /opt/asdf-vm/completions/asdf.bash

. "/home/sub0x/.deno/env"

eval "$(deno completions bash)"

