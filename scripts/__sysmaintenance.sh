#!/bin/bash
# Arch Linux System Maintenance Script

set -uo pipefail
trap 'echo "Script failed at line $LINENO"' ERR

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

bytes_before=""
section_start() {
    bytes_before=$(du -sb "$1" 2>/dev/null | cut -f1)
}

section_report() {
    local label=$1
    local path=$2
    local after
    after=$(du -sb "$path" 2>/dev/null | cut -f1)
    local saved=$(( bytes_before - after ))
    if (( saved > 0 )); then
        log_action "$label - Space saved: $(numfmt --to=iec "$saved")"
    else
        log_action "$label - No space reclaimed"
    fi
}

run_sudo() {
    if command -v sudo &>/dev/null; then
        sudo "$@"
    else
        log_action "SKIP (no sudo): $*"
        return 1
    fi
}

main() {
    log_action "Starting system maintenance"
    local disk_before
    disk_before=$(df --output=used / | tail -1)

    # --- System update ---
    log_action "Updating system packages"
    yay -Syu --noconfirm || log_action "Update failed (continuing)"

    # --- Pacman cache (keep last 2 versions) ---
    log_action "Cleaning pacman cache"
    section_start /var/cache/pacman/pkg/
    run_sudo paccache -rk2 || log_action "paccache failed (needs sudo)"
    section_report "Pacman cache" /var/cache/pacman/pkg/

    # --- Orphan packages ---
    log_action "Removing orphan packages"
    local orphans
    orphans=$(yay -Qdtq 2>/dev/null || true)
    if [[ -n "$orphans" ]]; then
        yay -Rns --noconfirm $orphans || log_action "Orphan removal failed"
    else
        log_action "No orphans found"
    fi

    # --- Targeted cache cleanup ---
    log_action "Cleaning known heavy caches"
    section_start ~/.cache

    # npm
    if command -v npm &>/dev/null; then
        npm cache clean --force 2>/dev/null && log_action "Cleared npm cache"
    fi

    # go build cache
    if [[ -d ~/.cache/go-build ]]; then
        rm -rf ~/.cache/go-build
        log_action "Cleared go-build cache"
    fi

    # playwright browsers
    for d in ~/.cache/ms-playwright ~/.cache/ms-playwright-go; do
        if [[ -d "$d" ]]; then
            rm -rf "$d"
            log_action "Cleared $(basename "$d")"
        fi
    done

    # yay build cache
    if [[ -d ~/.cache/yay ]]; then
        rm -rf ~/.cache/yay
        log_action "Cleared yay build cache"
    fi

    # general stale cache files (skip browser profiles)
    find ~/.cache -maxdepth 3 -type f -atime +30 \
        -not -path "*/zen/*" \
        -not -path "*/chromium/*" \
        -not -path "*/mozilla/*" \
        -delete 2>/dev/null || true

    # remove empty directories left behind
    find ~/.cache -mindepth 1 -type d -empty -delete 2>/dev/null || true

    section_report "User cache" ~/.cache

    # --- Trash ---
    if [[ -d ~/.local/share/Trash ]] && [[ -n "$(ls -A ~/.local/share/Trash 2>/dev/null)" ]]; then
        local trash_size
        trash_size=$(du -sh ~/.local/share/Trash 2>/dev/null | cut -f1)
        rm -rf ~/.local/share/Trash/*
        log_action "Emptied trash ($trash_size)"
    fi

    # --- Old snap revisions ---
    if command -v snap &>/dev/null; then
        local snaps_removed=0
        while IFS= read -r line; do
            local snapname rev
            snapname=$(echo "$line" | awk '{print $1}')
            rev=$(echo "$line" | awk '{print $3}')
            if run_sudo snap remove "$snapname" --revision="$rev" 2>/dev/null; then
                ((snaps_removed++))
            fi
        done < <(snap list --all | awk '/disabled/{print $1, $2, $3}')
        (( snaps_removed > 0 )) && log_action "Removed $snaps_removed old snap revision(s)"
    fi

    # --- Orphaned claude processes ---
    local claude_count
    claude_count=$(pgrep -x claude 2>/dev/null | wc -l)
    if (( claude_count > 1 )); then
        log_action "Found $claude_count claude processes, keeping newest"
        local newest
        newest=$(pgrep -x claude | tail -1)
        pgrep -x claude | grep -v "^${newest}$" | xargs -r kill 2>/dev/null || true
        log_action "Killed $((claude_count - 1)) orphaned claude process(es)"
    fi

    # --- Journal logs ---
    log_action "Cleaning system logs (keeping 7 days, max 500M)"
    run_sudo journalctl --vacuum-time=7d --vacuum-size=500M 2>/dev/null \
        || log_action "Journal cleanup failed (needs sudo)"

    # --- Docker prune (if docker is running) ---
    if systemctl is-active --quiet docker 2>/dev/null; then
        log_action "Pruning unused docker resources"
        docker system prune -f --volumes 2>/dev/null \
            && log_action "Docker prune complete" \
            || log_action "Docker prune failed"
    fi

    # --- Summary ---
    local disk_after
    disk_after=$(df --output=used / | tail -1)
    local total_saved=$(( (disk_before - disk_after) * 1024 ))
    log_action "System maintenance completed successfully"
    if (( total_saved > 0 )); then
        log_action "Total disk reclaimed: $(numfmt --to=iec "$total_saved")"
    fi
}

main "$@"
