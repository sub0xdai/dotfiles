#!/usr/bin/env bash
# lattice_index.sh — Regenerate the Entry Points index in lattice.md.
#
# Invoked by: the agent (on discovery failure) or a human (after adding a skill).
# Reads the filesystem and rewrites the block between <!-- INDEX_START --> and
# <!-- INDEX_END -->. Anything outside that block is untouched.
#
# Three things this refuses to do, each of which an earlier version did:
#
#   1. Delete the Primitives table. It lives inside the index block but has no
#      machine-readable source (the schemas carry no `category` or `serves`
#      field), so it is carried through verbatim instead of being dropped.
#   2. Replace a real description with a placeholder. If the frontmatter cannot
#      be parsed, the existing description for that entry is kept and a warning
#      is printed. The map never gets quieter than it was.
#   3. Copy a YAML block scalar as text. `description: >-` used to be written out
#      literally as ">-", because only a single line was ever read.
#
# It also stops treating prompts/AGENTS.md as a prompt.
#
# Exits 0 on success, 1 if lattice.md is missing.
set -uo pipefail

LATTICE_MD="${LATTICE_MD:-$HOME/.pi/agent/lattice.md}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.pi/agent/skills}"
PROMPTS_DIR="${PROMPTS_DIR:-$HOME/.pi/agent/prompts}"
SCRIPTS_DIR="${SCRIPTS_DIR:-$HOME/dotfiles/scripts}"
# Longest a map row may be. A first sentence past this is cut at a word boundary.
MAX_MAP_DESC="${MAX_MAP_DESC:-200}"

die() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }
warn() { printf 'warn: %s\n' "$1" >&2; }

[[ -f "$LATTICE_MD" ]] || die "lattice.md not found at $LATTICE_MD"

# The description from the first frontmatter block, with folded and literal
# scalars joined into one line. Prints nothing when there is no description.
frontmatter_description() {
  awk '
    NR == 1 && /^---[ \t]*$/ { infm = 1; next }
    !infm { next }
    /^---[ \t]*$/ { exit }
    want {
      if ($0 == "") { next }
      if ($0 ~ /^[ \t]+/) { sub(/^[ \t]+/, ""); print; next }
      exit
    }
    /^description:/ {
      v = $0
      sub(/^description:[ \t]*/, "", v)
      if (v == "" || v == ">" || v == ">-" || v == "|" || v == "|-") { want = 1; next }
      print v
      exit
    }
  ' "$1"
}

# One line, no stray spaces. A pipe becomes the HTML entity rather than an escaped
# `\|`, because awk field splitting cannot tell an escaped pipe from a separator,
# which would corrupt the carry-through lookup below. Quotes are stripped only when
# they wrap the whole value, so a description that legitimately ends with a closing
# quote keeps it.
sanitize() {
  printf '%s' "$1" | tr '\n' ' ' \
    | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//' \
    | sed -E 's/^"(.*)"$/\1/' \
    | sed -E "s/^'(.*)'\$/\1/" \
    | sed 's/|/\&#124;/g'
}

# The map is a lookup table the agent reads often, so a row carries the
# description's first sentence, not all of it. Derived from the source, so it
# cannot drift out of sync the way a hand-written summary does. To shorten a row,
# shorten the first sentence in the frontmatter.
summarize() {
  printf '%s' "$1" | awk -v max="$MAX_MAP_DESC" -v ell="…" '
    {
      line = $0
      n = length(line)
      for (i = 1; i < n; i++) {
        c = substr(line, i, 1)
        if (c != "." && c != "!" && c != "?") continue
        if (substr(line, i + 1, 1) != " ") continue
        if (substr(line, i - 1, 1) ~ /[0-9]/) continue
        if (substr(line, i - 2, 1) == ".") continue
        if (substr(line, i + 2, 1) !~ /[A-Z0-9(]/) continue
        line = substr(line, 1, i)
        break
      }
      if (length(line) <= max) { print line; exit }
      cut = max
      while (cut > 1 && substr(line, cut, 1) != " ") cut--
      printf "%s%s\n", substr(line, 1, cut - 1), ell
    }
  '
}

# The description already in the map for this entry, used when parsing fails.
existing_description() {
  existing_field "$1" "$2" 3
}

# Column $3 of the existing row for entry $2, 1-based including the leading empty
# field. Used for columns that have no machine-readable source: a hand-written
# column must be carried through, never silently replaced with a placeholder.
existing_field() {
  printf '%s' "$1" | awk -F'|' -v want="/$2" -v col="$3" '
    { name = $2; gsub(/^[ \t]+|[ \t]+$/, "", name); gsub(/`/, "", name) }
    name == want { f = $(col + 1); gsub(/^[ \t]+|[ \t]+$/, "", f); print f; exit }
  '
}

# The hand-written Primitives section, from its heading to the next one.
carry_primitives() {
  printf '%s' "$1" | awk '
    /^## Primitives/ { p = 1; print; next }
    p && /^## / { exit }
    p { print }
  '
}

# --------------------------------------------------------------------- read map
map_now=$(cat "$LATTICE_MD")
primitives_section=$(carry_primitives "$map_now")

# Resolve a description for one entry, falling back to what the map already says.
describe() {
  local file="$1" name="$2" kind="$3" desc
  desc=$(summarize "$(sanitize "$(frontmatter_description "$file")")")
  if [[ -z "$desc" ]]; then
    desc=$(existing_description "$map_now" "$name")
    if [[ -n "$desc" ]]; then
      warn "$kind /$name: no description in frontmatter, kept the existing one"
    else
      desc="(no description)"
      warn "$kind /$name: no description in frontmatter"
    fi
  fi
  printf '%s' "$desc"
}

# ----------------------------------------------------------------------- skills
skill_entries=""
skill_count=0
if [[ -d "$SKILLS_DIR" ]]; then
  for dir in "$SKILLS_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    name=$(basename "$dir")
    skill_md="${dir}SKILL.md"
    [[ -f "$skill_md" ]] || continue
    desc=$(describe "$skill_md" "$name" "skill")
    scripts=$(find "$SCRIPTS_DIR" -maxdepth 1 -name "${name}*.sh" -printf '%f\n' 2>/dev/null \
      | sort | paste -sd ', ' -)
    [[ -z "$scripts" ]] && scripts="(none)"
    skill_entries+="| \`/$name\` | Skill | ${desc} | ${scripts} |"$'\n'
    skill_count=$(( skill_count + 1 ))
  done
fi

# ---------------------------------------------------------------------- prompts
prompt_entries=""
prompt_count=0
if [[ -d "$PROMPTS_DIR" ]]; then
  for f in "$PROMPTS_DIR"/*.md; do
    [[ -f "$f" ]] || continue
    name=$(basename "$f" .md)
    # AGENTS.md is a directory contract, not an invocable prompt.
    [[ "$name" == "AGENTS" || "$name" == "README" ]] && continue
    desc=$(describe "$f" "$name" "prompt")
    # Which primitives a prompt references has no machine-readable source, so the
    # column is carried through from the map. A new prompt starts at (none).
    prims=$(existing_field "$map_now" "$name" 4)
    [[ -z "$prims" ]] && prims="(none)"
    prompt_entries+="| \`/$name\` | Prompt | ${desc} | ${prims} |"$'\n'
    prompt_count=$(( prompt_count + 1 ))
  done
fi

# ------------------------------------------------------------------ write block
# Built in a file rather than an awk -v, so backslashes in a description cannot
# be reinterpreted as escape sequences.
blockfile=$(mktemp) || die "mktemp failed"
trap 'rm -f "$blockfile"' EXIT
{
  printf '<!-- INDEX_START -->\n'
  printf '## Skills\n\n'
  printf '| Invocation | Type | Description | Scripts |\n'
  printf '|------------|------|-------------|---------|\n'
  printf '%s\n' "$skill_entries"
  printf '%s\n' "$primitives_section"
  printf '## Extensions\n\n'
  printf 'Runtime hooks are indexed in `extensions/AGENTS.md`, where each one declares the\n'
  printf 'lattice criterion it satisfies. Not duplicated here; one source per table.\n\n'
  printf '## Prompts\n\n'
  printf '| Invocation | Type | Description | Primitives Referenced |\n'
  printf '|------------|------|-------------|----------------------|\n'
  printf '%s\n' "$prompt_entries"
  printf '<!-- INDEX_END -->\n'
} > "$blockfile"

tmp=$(mktemp) || die "mktemp failed"
awk -v bf="$blockfile" '
  BEGIN { while ((getline line < bf) > 0) block = block line "\n" }
  /^<!-- INDEX_START -->/ { printf "%s", block; inb = 1; printed = 1; next }
  /^<!-- INDEX_END -->/ { inb = 0; next }
  !inb { print }
  END { if (!printed) printf "%s", block }
' "$LATTICE_MD" > "$tmp" || die "rewrite failed"

if cmp -s "$tmp" "$LATTICE_MD"; then
  rm -f "$tmp"
  printf 'lattice.md already current: %d skills, %d prompts\n' "$skill_count" "$prompt_count"
  exit 0
fi

mv "$tmp" "$LATTICE_MD"
printf 'lattice.md index regenerated: %d skills, %d prompts, Primitives carried through\n' \
  "$skill_count" "$prompt_count"
