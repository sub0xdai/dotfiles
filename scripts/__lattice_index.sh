#!/usr/bin/env bash
# __lattice_index.sh — Regenerate the Entry Points index in lattice.md.
# Idempotent. Reads the filesystem and rewrites the <!-- INDEX_START --> block.
# Invoked by: agent (on discovery failure) or human (after creating a SKILL.md).

set -euo pipefail

LATTICE_MD="$HOME/.pi/agent/lattice.md"
SKILLS_DIR="$HOME/.pi/agent/skills"
PROMPTS_DIR="$HOME/.pi/agent/prompts"

die() { echo "ERROR: $*" >&2; exit 1; }

# ── Gather skills ──────────────────────────────────────────────────────────
skill_entries=""
if [[ -d "$SKILLS_DIR" ]]; then
    for dir in "$SKILLS_DIR"/*/; do
        [[ -d "$dir" ]] || continue
        skill_name=$(basename "$dir")
        skill_md="${dir}SKILL.md"
        if [[ -f "$skill_md" ]]; then
            desc=$(head -5 "$skill_md" | grep -i '^description:' | head -1 | sed 's/^[^:]*:\s*//' | sed 's/^"//;s/"$//')
            [[ -z "$desc" ]] && desc="(no description)"
            # Find companion scripts
            scripts=$(find "$HOME/dotfiles/scripts" -maxdepth 1 -name "__${skill_name}*.sh" -printf '%f ' 2>/dev/null || true)
            [[ -z "$scripts" ]] && scripts="(none)"
            skill_entries+="| \`/${skill_name}\` | Skill | ${desc} | ${scripts} |"$'\n'
        fi
    done
fi

# ── Gather prompts ─────────────────────────────────────────────────────────
prompt_entries=""
if [[ -d "$PROMPTS_DIR" ]]; then
    for f in "$PROMPTS_DIR"/*.md; do
        [[ -f "$f" ]] || continue
        prompt_name=$(basename "$f" .md)
        desc=$(head -5 "$f" | grep -i '^description:' | head -1 | sed 's/^[^:]*:\s*//' | sed 's/^"//;s/"$//')
        [[ -z "$desc" ]] && desc="(no description)"
        prompt_entries+="| \`/${prompt_name}\` | Prompt | ${desc} | N/A |"$'\n'
    done
fi

# ── Assemble the index block ───────────────────────────────────────────────
index_block="<!-- INDEX_START -->
## Skills

| Invocation | Type | Description | Scripts |
|------------|------|-------------|---------|
${skill_entries}
## Prompts

| Invocation | Type | Description | Scripts |
|------------|------|-------------|---------|
${prompt_entries}
<!-- INDEX_END -->"

# ── Write to lattice.md ────────────────────────────────────────────────────
[[ -f "$LATTICE_MD" ]] || die "lattice.md not found at $LATTICE_MD"

tmp=$(mktemp)
awk -v block="$index_block" '
    BEGIN { in_block = 0; printed = 0 }
    /^<!-- INDEX_START -->/ {
        print block
        in_block = 1
        printed = 1
        next
    }
    /^<!-- INDEX_END -->/ {
        in_block = 0
        next
    }
    !in_block { print }
    END { if (!printed) print block }
' "$LATTICE_MD" > "$tmp"

mv "$tmp" "$LATTICE_MD"
echo "✓ lattice.md index regenerated"
