@@ -0,0 +1,40 @@
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
# Source common configurations
source ~/.shell_common
# Bash-specific PS1 (backup in case starship fails)
PS1='[\u@\h \W]\$ '
# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# Clean up and set PATH
clean_path() {
  echo "$1" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//'
}
# Source bash-specific completions and tools
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
# ASDF
. /opt/asdf-vm/asdf.sh
# Deno
. "$HOME/.deno/env"
eval "$(deno completions bash)"
# Initialize tools for bash
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(atuin init bash)"
# Final PATH cleanup (remove duplicates)
export PATH=$(clean_path "$PATH")
export PATH=~/.npm-global/bin:$PATH
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
