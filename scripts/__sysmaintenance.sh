#!/bin/bash
# Arch Linux System Maintenance Script

set -euo pipefail
trap 'echo "Script failed at line $LINENO"' ERR

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

calculate_space_saved() {
    local before=$1
    local after=$2
    local saved=$((before - after))
    numfmt --to=iec $saved
}

main() {
    log_action "Starting system maintenance"
   
    # System update
    log_action "Updating system packages"
    yay -Syu --noconfirm
    
    # Pacman cache cleanup
    log_action "Cleaning pacman cache"
    local pacman_before=$(du -sb /var/cache/pacman/pkg/ | cut -f1)
    paccache -r
    local pacman_after=$(du -sb /var/cache/pacman/pkg/ | cut -f1)
    log_action "Pacman cache - Space saved: $(calculate_space_saved $pacman_before $pacman_after)"
    
    # Orphan package removal
    log_action "Removing orphan packages"
    local orphans=$(yay -Qdtq 2>/dev/null || true)
    [[ -n "$orphans" ]] && yay -Rns $orphans --noconfirm || log_action "No orphans found"
    
    # User cache cleanup
    if [[ -d ~/.cache ]]; then
        local cache_before=$(du -sb ~/.cache | cut -f1)
        find ~/.cache -type f -atime +7 -delete 2>/dev/null || true
        local cache_after=$(du -sb ~/.cache | cut -f1)
        log_action "User cache - Space saved: $(calculate_space_saved $cache_before $cache_after)"
    fi
    
    # System logs cleanup
    log_action "Cleaning system logs (keeping 7 days)"
    journalctl --vacuum-time=7d
    
    log_action "System maintenance completed successfully"
}

main "$@"
