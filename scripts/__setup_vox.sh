#!/bin/bash
#
# Vox Scaffold - Setup autonomous AI development in any project
# Builder + Optimizer dual-loop system
#
# Usage:
#   __setup_vox.sh              # Setup in current directory
#   __setup_vox.sh <path>       # Setup in specific path
#   __setup_vox.sh --force      # Overwrite existing .specify/
#   __setup_vox.sh --help       # Show help
#

set -euo pipefail

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- DEFAULTS ---
TARGET_DIR="."
FORCE=false

# --- HELPER FUNCTIONS ---

print_help() {
    echo "Vox Scaffold - Setup autonomous AI development"
    echo ""
    echo "Usage:"
    echo "  $0              Setup in current directory"
    echo "  $0 <path>       Setup in specific directory"
    echo "  $0 --force      Overwrite existing .specify/ directory"
    echo "  $0 --help       Show this help"
    echo ""
    echo "Creates:"
    echo "  .specify/"
    echo "  ├── memory/"
    echo "  │   └── constitution.md    # Project standards template"
    echo "  ├── specs/                 # Your specifications go here"
    echo "  ├── optimize/              # Optimization targets"
    echo "  ├── IMPLEMENTATION_PLAN.md # Task tracking"
    echo "  ├── AGENTS.md              # Operational learnings"
    echo "  ├── PROMPT_plan.md         # Planning mode instructions"
    echo "  ├── PROMPT_build.md        # Build mode instructions"
    echo "  └── PROMPT_optimize.md     # Optimizer instructions"
    echo "  scripts/"
    echo "  ├── vox.sh                 # The autonomous builder loop"
    echo "  └── vox-optimize.sh        # The optimization loop"
    echo ""
    echo "After setup:"
    echo "  1. Edit .specify/memory/constitution.md for your project"
    echo "  2. Create specs in .specify/specs/<name>/spec.md"
    echo "  3. Run: ./scripts/vox.sh plan <spec-name>"
    echo "  4. Run: ./scripts/vox.sh build <spec-name>"
    echo ""
    echo "For optimization:"
    echo "  1. Create .specify/optimize/<target>/program.md"
    echo "  2. Run: ./scripts/vox-optimize.sh <target>"
}

# --- PARSE ARGUMENTS ---

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            print_help
            exit 0
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# --- VALIDATION ---

# Resolve to absolute path (create if doesn't exist)
if [[ ! -d "$TARGET_DIR" ]]; then
    mkdir -p "$TARGET_DIR"
fi
TARGET_DIR=$(realpath "$TARGET_DIR")

if [[ -d "$TARGET_DIR/.specify" ]] && [[ "$FORCE" == false ]]; then
    echo -e "${RED}ERROR: .specify/ already exists in $TARGET_DIR${NC}"
    echo "Use --force to overwrite"
    exit 1
fi

# --- CREATE STRUCTURE ---

echo -e "${BLUE}Setting up Vox in: $TARGET_DIR${NC}"
echo ""

mkdir -p "$TARGET_DIR/.specify/memory"
mkdir -p "$TARGET_DIR/.specify/specs"
mkdir -p "$TARGET_DIR/.specify/optimize"
mkdir -p "$TARGET_DIR/scripts"

# --- WRITE TEMPLATE FILES ---

echo -e "${YELLOW}Creating template files...${NC}"

# --- constitution.md ---
cat > "$TARGET_DIR/.specify/memory/constitution.md" << 'EOF'
# Project Constitution

> This document defines the core principles, standards, and governance for autonomous AI development.

---

## 1. Core Principles

### Simplicity & YAGNI
- Start simple. Avoid over-engineering. Build exactly what's needed, nothing more.
- Delete dead code. No backwards-compatibility hacks unless explicitly required.
- Three similar lines of code is better than a premature abstraction.

### Autonomous Agent Development
- Make decisions without asking for approval on implementation details.
- Commit, push, and deploy autonomously when tests pass.
- Iterate until acceptance criteria are met, then signal completion.

### Quality Over Speed
- All code must pass linting and tests before commit.
- No shortcuts that compromise security or reliability.

---

## 2. Technology Stack

<!-- Customize for your project -->

### Languages & Frameworks
- **Primary**: [Your language/framework]
- **Build**: [Your build tool]
- **Linting**: [Your linter command]
- **Testing**: [Your test command]

### Path Context
- All paths in this document are relative to the repository root.
- The agent is assumed to be executing commands from the root.

---

## 3. Development Standards

### Code Style
<!-- Add language-specific guidelines -->
- Follow existing patterns in the codebase
- Document public APIs
- Explicit error handling

### Git Workflow
- Atomic commits with descriptive messages
- Format: `type: description` (feat, fix, refactor, docs, test)
- Always include `Co-Authored-By: Claude <noreply@anthropic.com>` for AI commits

### Testing Requirements
- Tests for all public functions
- Never delete a failing test to make the pipeline pass. Fix the implementation.

### Test-Driven Development (TDD) Protocol
- If a spec references an existing failing test, do not modify the test. Make the implementation satisfy it.
- If no test exists, create unit tests to verify your work.
- Red -> Green -> Refactor: Write failing test, make it pass, then clean up.

---

## 4. Verification Commands

<!-- Customize for your project -->
```bash
# Example verification commands
# lint && test
```

All commands must exit with code 0.

---

## 5. Completion Protocol

### When Implementing Specs
1. Read the specification completely
2. Implement all functional requirements
3. Run all verification commands
4. Commit and push changes
5. Output `<promise>DONE</promise>` only when ALL criteria pass

### Iteration Workflow
If any check fails:
1. Identify the issue from error output
2. Fix the code
3. Commit the fix
4. Re-run verification
5. Repeat until all checks pass

### Recovery Protocol
If verification fails for >3 iterations on the same error:
1. Stop modifying the implementation.
2. Check if the test expectation itself is incorrect.
3. If truly stuck, document the blocker and signal for human review.

---

## 6. Key Files Reference

<!-- Customize for your project -->

| Purpose | Location |
|---------|----------|
| Main entry | [path] |
| Config | [path] |
| Tests | [path] |

---

*Last updated: $(date +%Y-%m-%d)*
EOF

# --- IMPLEMENTATION_PLAN.md ---
cat > "$TARGET_DIR/.specify/IMPLEMENTATION_PLAN.md" << 'EOF'
# Implementation Plan

> Last updated: [date]
> Current spec: [spec-name]
> Phase: PLANNING

---

## Active Spec: [spec-name]

### Tasks

| ID | Task | Status | Notes |
|----|------|--------|-------|
| T1 | [first task] | pending | |

### Discoveries

<!-- Vox will add discoveries here as implementation progresses -->

### Blockers

<!-- Document any blockers encountered -->

---

## Completed Specs

| Spec | Completion Date |
|------|-----------------|
| | |

---

*This file is persistent state. Vox updates it each iteration.*
EOF

# --- AGENTS.md ---
cat > "$TARGET_DIR/.specify/AGENTS.md" << 'EOF'
# Operational Learnings

> Vox's accumulated knowledge. Loaded each iteration.

---

## Codebase Patterns

<!-- Add patterns as you discover them -->

### [Language/Framework]

- Pattern 1
- Pattern 2

### File Locations

- Key file 1: `path/to/file`
- Key file 2: `path/to/file`

---

## Anti-Patterns (Don't Do This)

<!-- Add things to avoid -->

- Don't [bad pattern]
- Don't [another bad pattern]

---

## Signs (Discoverable Patterns)

### When you see "[symptom]"
-> [what it means and how to fix]

---

## Discoveries Log

<!-- Vox adds discoveries here during implementation -->

---

*This file grows as Vox learns. Never delete entries.*
EOF

# --- PROMPT_plan.md ---
cat > "$TARGET_DIR/.specify/PROMPT_plan.md" << 'EOF'
# Vox - PLANNING Mode

You are Vox, an autonomous developer. You are in PLANNING mode.

## Your Mission

Study the specification and codebase to create a detailed implementation plan.

**Do NOT implement anything. Do NOT write code. Do NOT edit files.**

---

## Context Files (Study These)

1. **Constitution**: `.specify/memory/constitution.md`
2. **Specification**: `.specify/specs/{SPEC_NAME}/spec.md`
3. **Operational Learnings**: `.specify/AGENTS.md`
4. **Current Plan**: `.specify/IMPLEMENTATION_PLAN.md`

---

## Planning Process

### Step 1: Study the Specification
- Read the spec completely
- Identify all functional requirements (FR-1, FR-2, etc.)
- Note acceptance criteria
- Don't assume anything is "not implemented" - verify first

### Step 2: Gap Analysis
- Search the codebase for existing implementations
- Use `grep` and `find` to locate relevant code
- Document what exists vs what's missing
- Identify files that need modification

### Step 3: Break Down Tasks
- Decompose requirements into atomic tasks
- Each task should be completable in one iteration
- Order tasks by dependency (what must come first?)
- Estimate complexity: simple / medium / complex

### Step 4: Update IMPLEMENTATION_PLAN.md
- Add tasks with IDs (T1, T2, T3...)
- Set all new tasks to `pending`
- Add any discoveries to the Discoveries section
- Document blockers if found

---

## Output Format

After updating IMPLEMENTATION_PLAN.md, summarize:

```
PLANNING COMPLETE

Spec: {spec_name}
Total Tasks: {N}
Ready for BUILD mode.

Next task: T1 - {task description}
```

---

## Critical Rules

- **Ultrathink** before adding tasks
- **Capture the why** - document reasoning in Discoveries
- **Don't assume** - always verify with codebase search
- **One concern per task** - keep tasks atomic
- **No code** - planning only

---

*When planning is complete, switch to BUILD mode.*
EOF

# --- PROMPT_build.md ---
cat > "$TARGET_DIR/.specify/PROMPT_build.md" << 'EOF'
# Vox - BUILD Mode

You are Vox, an autonomous developer. You are in BUILD mode.

## Your Mission

Complete exactly ONE task from the implementation plan, then exit.

---

## Context Files (Study These First)

1. **Constitution**: `.specify/memory/constitution.md`
2. **Specification**: `.specify/specs/{SPEC_NAME}/spec.md`
3. **Operational Learnings**: `.specify/AGENTS.md`
4. **Implementation Plan**: `.specify/IMPLEMENTATION_PLAN.md`

---

## Build Process

### Step 1: Identify Your Task
- Read IMPLEMENTATION_PLAN.md
- Find the first task with status `pending`
- This is YOUR task. Complete only this task.

### Step 2: Study Before Coding
- Read relevant existing code
- Understand the patterns in use
- Check AGENTS.md for learnings
- Don't assume - verify

### Step 3: Implement
- Write clean, idiomatic code
- Follow constitution standards
- Use existing patterns from codebase
- Implement functionality completely

### Step 4: Validate
- Run verification commands from constitution
- Fix any failures before proceeding

### Step 5: Update State
- Mark your task as `complete` in IMPLEMENTATION_PLAN.md
- Add any discoveries to AGENTS.md
- Document blockers if encountered

### Step 6: Commit
```bash
git add -A
git commit -m "feat: {task description}

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Output Format

After completing your task:

```
BUILD ITERATION COMPLETE

Task: T{N} - {description}
Status: complete
Files modified: {list}

Validation:
- lint: pass/fail
- tests: pass/fail

Next task: T{N+1} - {description}
```

If all tasks complete and validation passes:
```
<promise>DONE</promise>
```

---

## Critical Rules

- **One task only** - complete one, then exit
- **Validate before commit** - no broken commits
- **Update state files** - plan and learnings
- **Capture discoveries** - help future iterations
- **Use parallel subagents** for expensive searches
- **Only 1 subagent for build/tests** - avoid conflicts

---

## When Stuck

If validation fails for >3 attempts on same error:
1. Document the blocker in IMPLEMENTATION_PLAN.md
2. Add learnings to AGENTS.md
3. Exit and let next iteration try fresh

---

*Each iteration: one task, validate, commit, exit.*
EOF

# --- PROMPT_optimize.md ---
cat > "$TARGET_DIR/.specify/PROMPT_optimize.md" << 'EOF'
# Vox - OPTIMIZE Mode

You are Vox, an autonomous developer. You are in OPTIMIZE mode.

## Your Mission

Apply exactly ONE experimental improvement to the target file(s), then exit.

## Context Files (Study These First)

1. **Constitution**: `.specify/memory/constitution.md`
2. **Program**: `.specify/optimize/{TARGET}/program.md`
3. **Operational Learnings**: `.specify/AGENTS.md`
4. **Experiment History**: `.specify/optimize/{TARGET}/results.tsv`

## Optimization Process

### Step 1: Understand the Goal
- Read program.md for the optimization target, constraints, and strategy hints
- Read results.tsv to see what has been tried and what worked/failed
- Do NOT retry approaches marked as `discarded` or `failed`

### Step 2: Hypothesize
- Form a specific hypothesis: "Changing X should improve Y because Z"
- The change must be isolated and reversible

### Step 3: Implement
- Edit ONLY the files listed in program.md Target Files
- Make exactly one conceptual change
- Follow constitution standards

### Step 4: Validate
- Run verification commands from constitution
- If validation fails, your change is invalid

### Step 5: Commit
```bash
git add -A
git commit -m "experiment: {description of change}

Hypothesis: {why this should help}

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Critical Rules

- ONE change per iteration — small, isolated, testable
- NEVER modify files outside the Target Files whitelist
- NEVER retry a discarded/failed approach from results.tsv
- NEVER change test files or benchmarks
- Capture learnings in AGENTS.md if you discover something useful
EOF

# --- vox.sh (builder loop) ---
cat > "$TARGET_DIR/scripts/vox.sh" << 'EOF'
#!/bin/bash
#
# Vox - Autonomous AI Development Loop (Builder)
#
# Usage:
#   ./scripts/vox.sh plan <spec-name>    # Planning mode (no code)
#   ./scripts/vox.sh build <spec-name>   # Building mode (one task per iteration)
#   ./scripts/vox.sh --help              # Show help
#

set -euo pipefail

# --- CONFIGURATION ---
SPECS_DIR=".specify/specs"
MEMORY_DIR=".specify/memory"
PROMPT_PLAN=".specify/PROMPT_plan.md"
PROMPT_BUILD=".specify/PROMPT_build.md"
IMPLEMENTATION_PLAN=".specify/IMPLEMENTATION_PLAN.md"
AGENTS_MD=".specify/AGENTS.md"
CONSTITUTION=".specify/memory/constitution.md"

MAX_ITERATIONS=30
AGENT_CMD="claude"

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- HELPER FUNCTIONS ---

print_help() {
    echo "Vox - Autonomous AI Development (Builder)"
    echo ""
    echo "Usage:"
    echo "  $0 plan <spec-name>     Run planning mode (gap analysis, no code)"
    echo "  $0 build <spec-name>    Run build mode (one task per iteration)"
    echo "  $0 --help               Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 plan 001-first-feature"
    echo "  $0 build 001-first-feature"
    echo ""
    echo "Options:"
    echo "  --max-iterations N      Set max iterations (default: 30)"
    echo ""
    echo "Available specs:"
    list_specs
}

list_specs() {
    if [[ -d "$SPECS_DIR" ]]; then
        ls -1 "$SPECS_DIR" 2>/dev/null | sort
    fi
}

spec_exists() {
    [[ -f "$SPECS_DIR/$1/spec.md" ]]
}

build_context() {
    local spec="$1"
    local mode="$2"

    echo "# Context for Vox"
    echo ""
    echo "## Mode: ${mode^^}"
    echo "## Spec: $spec"
    echo ""

    # Include constitution
    if [[ -f "$CONSTITUTION" ]]; then
        echo "---"
        echo "## Constitution"
        echo ""
        cat "$CONSTITUTION"
        echo ""
    fi

    # Include spec
    if [[ -f "$SPECS_DIR/$spec/spec.md" ]]; then
        echo "---"
        echo "## Specification: $spec"
        echo ""
        cat "$SPECS_DIR/$spec/spec.md"
        echo ""
    fi

    # Include operational learnings
    if [[ -f "$AGENTS_MD" ]]; then
        echo "---"
        echo "## Operational Learnings"
        echo ""
        cat "$AGENTS_MD"
        echo ""
    fi

    # Include implementation plan
    if [[ -f "$IMPLEMENTATION_PLAN" ]]; then
        echo "---"
        echo "## Implementation Plan"
        echo ""
        cat "$IMPLEMENTATION_PLAN"
        echo ""
    fi

    # Include mode-specific prompt
    echo "---"
    echo "## Instructions"
    echo ""
    if [[ "$mode" == "plan" ]]; then
        cat "$PROMPT_PLAN"
    else
        cat "$PROMPT_BUILD"
    fi
}

check_done_signal() {
    local output="$1"
    if echo "$output" | grep -q "<promise>DONE</promise>"; then
        return 0
    fi
    return 1
}

run_planning() {
    local spec="$1"

    echo -e "${BLUE}=========================================="
    echo "Vox: PLANNING MODE"
    echo "Spec: $spec"
    echo -e "==========================================${NC}"

    if ! spec_exists "$spec"; then
        echo -e "${RED}ERROR: Spec not found: $SPECS_DIR/$spec/spec.md${NC}"
        list_specs
        return 1
    fi

    echo ""
    echo -e "${YELLOW}Waking up Vox for planning...${NC}"
    echo ""

    # Build context and pipe to claude
    local output
    output=$(build_context "$spec" "plan" | $AGENT_CMD -p --dangerously-skip-permissions 2>&1) || true

    echo "$output"

    echo ""
    echo -e "${GREEN}Planning complete. Review IMPLEMENTATION_PLAN.md${NC}"
    echo "Next: ./scripts/vox.sh build $spec"
}

run_building() {
    local spec="$1"
    local iteration=0

    echo -e "${BLUE}=========================================="
    echo "Vox: BUILD MODE"
    echo "Spec: $spec"
    echo "Max iterations: $MAX_ITERATIONS"
    echo -e "==========================================${NC}"

    if ! spec_exists "$spec"; then
        echo -e "${RED}ERROR: Spec not found: $SPECS_DIR/$spec/spec.md${NC}"
        list_specs
        return 1
    fi

    while [[ $iteration -lt $MAX_ITERATIONS ]]; do
        iteration=$((iteration + 1))

        echo ""
        echo -e "${YELLOW}--- Iteration $iteration of $MAX_ITERATIONS ---${NC}"
        echo ""
        echo -e "${YELLOW}Waking up Vox...${NC}"

        # Build context and pipe to claude
        local output
        output=$(build_context "$spec" "build" | $AGENT_CMD -p --dangerously-skip-permissions 2>&1) || true

        echo "$output"

        # Check for DONE signal
        if check_done_signal "$output"; then
            echo ""
            echo -e "${GREEN}=========================================="
            echo "SPEC COMPLETE: $spec"
            echo -e "==========================================${NC}"
            return 0
        fi

        # Git safety check
        if [[ -n $(git status --porcelain 2>/dev/null || true) ]]; then
            echo ""
            echo -e "${YELLOW}Uncommitted changes after iteration:${NC}"
            git status --short
        fi

        echo ""
        echo -e "${BLUE}Iteration $iteration complete. Continuing...${NC}"

        # Small delay to avoid rate limiting
        sleep 2

    done

    echo ""
    echo -e "${RED}WARNING: Reached max iterations ($MAX_ITERATIONS) for $spec${NC}"
    return 1
}

# --- MAIN ---

MODE=""
SPEC_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        plan|build)
            MODE="$1"
            shift
            ;;
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            if [[ -z "$SPEC_NAME" ]]; then
                SPEC_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$MODE" ]]; then
    echo -e "${RED}ERROR: Mode required (plan or build)${NC}"
    echo ""
    print_help
    exit 1
fi

if [[ -z "$SPEC_NAME" ]]; then
    echo -e "${RED}ERROR: Spec name required${NC}"
    echo ""
    print_help
    exit 1
fi

# Check required files exist
if [[ ! -f "$PROMPT_PLAN" ]]; then
    echo -e "${RED}ERROR: Missing $PROMPT_PLAN${NC}"
    exit 1
fi

if [[ ! -f "$PROMPT_BUILD" ]]; then
    echo -e "${RED}ERROR: Missing $PROMPT_BUILD${NC}"
    exit 1
fi

# Run appropriate mode
echo "Vox - Autonomous AI Development (Builder)"
echo "Agent: $AGENT_CMD"
echo ""

if [[ "$MODE" == "plan" ]]; then
    run_planning "$SPEC_NAME"
elif [[ "$MODE" == "build" ]]; then
    run_building "$SPEC_NAME"
else
    echo -e "${RED}ERROR: Unknown mode: $MODE${NC}"
    print_help
    exit 1
fi
EOF

# --- vox-optimize.sh (optimizer loop) ---
cat > "$TARGET_DIR/scripts/vox-optimize.sh" << 'OPTIMIZE_EOF'
#!/bin/bash
#
# Vox Optimize - Autonomous Optimization Loop
# Runs sequential experiments in a git worktree with batched human review.
#
# Usage:
#   ./scripts/vox-optimize.sh <target> [--batch N]
#   ./scripts/vox-optimize.sh --help
#

set -euo pipefail

# --- CONFIGURATION ---
OPTIMIZE_DIR=".specify/optimize"
CONSTITUTION=".specify/memory/constitution.md"
AGENTS_MD=".specify/AGENTS.md"
PROMPT_OPTIMIZE=".specify/PROMPT_optimize.md"
AGENT_CMD="claude"
BATCH_SIZE=5

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- HELPER FUNCTIONS ---

print_help() {
    echo "Vox Optimize - Autonomous Optimization Loop"
    echo ""
    echo "Usage:"
    echo "  $0 <target> [--batch N]   Run optimization (default batch: 5)"
    echo "  $0 --help                 Show this help"
    echo ""
    echo "Prerequisite:"
    echo "  .specify/optimize/<target>/program.md must exist"
    echo ""
    echo "Options:"
    echo "  --batch N    Experiments per checkpoint (default: 5)"
}

median() {
    local -a sorted
    sorted=($(printf '%s\n' "$@" | sort -n))
    local n=${#sorted[@]}
    if [[ $n -eq 0 ]]; then
        echo ""
        return
    fi
    echo "${sorted[$((n / 2))]}"
}

run_benchmark() {
    if [[ "$HAS_BENCHMARK" != true ]]; then
        echo ""
        return
    fi

    local -a values
    values=()
    local i result
    for ((i = 1; i <= BENCHMARK_RUNS; i++)); do
        result=$(bash "$BENCHMARK_SH" 2>&1 | tail -1 | grep -oE '[0-9]+\.?[0-9]*' | tail -1) || true
        if [[ -n "$result" ]]; then
            values+=("$result")
        fi
    done

    if [[ ${#values[@]} -eq 0 ]]; then
        echo ""
        return
    fi

    median "${values[@]}"
}

parse_last_commit() {
    COMMIT_HASH=$(git log -1 --format="%h")
    local subject
    subject=$(git log -1 --format="%s")
    COMMIT_DESC="${subject#experiment: }"
}

run_verification() {
    if [[ ! -f "$CONSTITUTION" ]]; then
        return 0
    fi

    local in_section=false
    local in_block=false

    while IFS= read -r line; do
        if [[ "$line" =~ "Verification Commands" ]]; then
            in_section=true
            continue
        fi
        # Stop at the next section header
        if [[ "$in_section" == true ]] && [[ "$line" =~ ^##\  ]] && [[ ! "$line" =~ "Verification" ]]; then
            break
        fi
        # Detect code block boundaries
        if [[ "$in_section" == true ]]; then
            if [[ "$line" =~ ^\`\`\` ]]; then
                if [[ "$in_block" == false ]]; then
                    in_block=true
                    continue
                else
                    break
                fi
            fi
        fi
        # Execute non-comment, non-empty lines
        if [[ "$in_block" == true ]] && [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "${line// /}" ]]; then
            echo -e "  ${CYAN}→ $line${NC}"
            if ! eval "$line"; then
                echo -e "  ${RED}✗ Failed: $line${NC}"
                return 1
            fi
        fi
    done < "$CONSTITUTION"

    return 0
}

append_result() {
    local ts="$1" batch="$2" eid="$3" hash="$4" desc="$5" metric="$6" bl="$7" status="$8"

    # Create header if file doesn't exist
    if [[ ! -f "$RESULTS_TSV" ]]; then
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
            "timestamp" "batch" "exp_id" "commit_hash" "description" "metric" "baseline" "status" \
            > "$RESULTS_TSV"
    fi

    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
        "$ts" "$batch" "$eid" "$hash" "$desc" "$metric" "$bl" "$status" \
        >> "$RESULTS_TSV"
}

print_scoreboard() {
    local batch_num="$1"

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${BOLD}║            OPTIMIZATION SCOREBOARD — Batch %-3s              ║${NC}\n" "$batch_num"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ "$HAS_BENCHMARK" == true ]] && [[ -n "${BATCH_START_METRIC:-}" ]]; then
        echo -e "  ${CYAN}Baseline: ${BATCH_START_METRIC}${NC}"
        echo ""
    fi

    local i num desc hash metric bl status
    for ((i = 0; i < ${#BATCH_DESCS[@]}; i++)); do
        num=$((i + 1))
        desc="${BATCH_DESCS[$i]}"
        hash="${BATCH_HASHES[$i]}"
        metric="${BATCH_METRICS[$i]:-}"
        bl="${BATCH_BASELINES[$i]:-}"
        status="${BATCH_STATUSES[$i]}"

        if [[ "$status" == "failed" ]]; then
            printf "  ${RED}#%-2d %-45s  ✗ failed${NC}\n" "$num" "$desc"
        elif [[ "$HAS_BENCHMARK" == true ]] && [[ -n "$metric" ]] && [[ -n "$bl" ]] && [[ "$bl" != "0" ]]; then
            local pct is_better pct_str
            pct=$(awk "BEGIN {printf \"%.1f\", (($metric - $bl) / $bl) * 100}")
            is_better=false
            if [[ "$METRIC_DIRECTION" == "MINIMIZE" ]]; then
                (( $(awk "BEGIN {print ($metric < $bl) ? 1 : 0}") )) && is_better=true
            else
                (( $(awk "BEGIN {print ($metric > $bl) ? 1 : 0}") )) && is_better=true
            fi
            if (( $(awk "BEGIN {print ($pct >= 0) ? 1 : 0}") )); then
                pct_str="+${pct}"
            else
                pct_str="${pct}"
            fi
            if [[ "$is_better" == true ]]; then
                printf "  ${GREEN}#%-2d %-40s  %s  (%s%%)  %s${NC}\n" "$num" "$desc" "$metric" "$pct_str" "$hash"
            else
                printf "  ${RED}#%-2d %-40s  %s  (%s%%)  %s  ← regression${NC}\n" "$num" "$desc" "$metric" "$pct_str" "$hash"
            fi
        else
            printf "  ${BOLD}#%-2d${NC} %-45s  %s\n" "$num" "$desc" "$hash"
        fi
    done

    echo ""
}

mark_batch_discarded() {
    local batch="$1"
    if [[ -f "$RESULTS_TSV" ]]; then
        awk -F'\t' -v OFS='\t' -v b="$batch" \
            'NR==1 {print; next} $2==b && $8!="failed" {$8="discarded"} {print}' \
            "$RESULTS_TSV" > "${RESULTS_TSV}.tmp" && mv "${RESULTS_TSV}.tmp" "$RESULTS_TSV"
    fi
}

mark_after_discarded() {
    local batch="$1" after="$2"
    if [[ -f "$RESULTS_TSV" ]]; then
        awk -F'\t' -v OFS='\t' -v b="$batch" -v a="$after" \
            'NR==1 {print; next} $2==b && $3>a && $8!="failed" {$8="discarded"} {print}' \
            "$RESULTS_TSV" > "${RESULTS_TSV}.tmp" && mv "${RESULTS_TSV}.tmp" "$RESULTS_TSV"
    fi
}

build_optimize_context() {
    echo "# Context for Vox"
    echo ""
    echo "## Mode: OPTIMIZE"
    echo "## Target: $TARGET"
    echo ""

    if [[ -f "$CONSTITUTION" ]]; then
        echo "---"
        echo "## Constitution"
        echo ""
        cat "$CONSTITUTION"
        echo ""
    fi

    if [[ -f "$PROGRAM_MD" ]]; then
        echo "---"
        echo "## Program"
        echo ""
        cat "$PROGRAM_MD"
        echo ""
    fi

    if [[ -f "$AGENTS_MD" ]]; then
        echo "---"
        echo "## Operational Learnings"
        echo ""
        cat "$AGENTS_MD"
        echo ""
    fi

    if [[ -f "$RESULTS_TSV" ]]; then
        echo "---"
        echo "## Experiment History"
        echo ""
        cat "$RESULTS_TSV"
        echo ""
    fi

    echo "---"
    echo "## Instructions"
    echo ""
    sed "s|{TARGET}|$TARGET|g" "$PROMPT_OPTIMIZE"
}

# --- PARSE ARGUMENTS ---

TARGET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --batch)
            BATCH_SIZE="$2"
            shift 2
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            if [[ -z "$TARGET" ]]; then
                TARGET="$1"
            fi
            shift
            ;;
    esac
done

# --- VALIDATION ---

if [[ -z "$TARGET" ]]; then
    echo -e "${RED}ERROR: Target required${NC}"
    echo ""
    print_help
    exit 1
fi

PROGRAM_MD="$OPTIMIZE_DIR/$TARGET/program.md"
if [[ ! -f "$PROGRAM_MD" ]]; then
    echo -e "${RED}ERROR: Program not found: $PROGRAM_MD${NC}"
    echo "Create it first, or use /vox-optimize to set up interactively."
    exit 1
fi

RESULTS_TSV="$OPTIMIZE_DIR/$TARGET/results.tsv"
BENCHMARK_SH="$OPTIMIZE_DIR/$TARGET/benchmark.sh"

HAS_BENCHMARK=false
if [[ -f "$BENCHMARK_SH" ]]; then
    HAS_BENCHMARK=true
    chmod +x "$BENCHMARK_SH"
fi

# Parse config from program.md
BENCHMARK_RUNS=$(grep -oP 'BENCHMARK_RUNS=\K\d+' "$PROGRAM_MD" 2>/dev/null || echo "3")
METRIC_DIRECTION=$(grep -oP 'METRIC_DIRECTION=\K\w+' "$PROGRAM_MD" 2>/dev/null || echo "MINIMIZE")

# --- WORKTREE SETUP ---

MAIN_DIR="$(pwd)"
REPO_NAME="$(basename "$MAIN_DIR")"
WORKTREE_DIR="$(dirname "$MAIN_DIR")/${REPO_NAME}-optimize-${TARGET}"

if [[ -d "$WORKTREE_DIR" ]]; then
    echo -e "${YELLOW}Worktree already exists at $WORKTREE_DIR${NC}"
    echo -e "${YELLOW}Resuming optimization...${NC}"
else
    echo -e "${BLUE}Creating worktree at $WORKTREE_DIR${NC}"
    if git show-ref --verify --quiet "refs/heads/optimize/$TARGET"; then
        git worktree add "$WORKTREE_DIR" "optimize/$TARGET"
    else
        git worktree add "$WORKTREE_DIR" -b "optimize/$TARGET"
    fi
fi

cd "$WORKTREE_DIR"

# Ensure .specify/ exists in worktree (handles untracked case)
if [[ ! -d ".specify" ]]; then
    cp -r "$MAIN_DIR/.specify/" ".specify/"
fi

# Ensure optimize target dir and program exist
mkdir -p "$OPTIMIZE_DIR/$TARGET"
if [[ ! -f "$PROGRAM_MD" ]]; then
    cp "$MAIN_DIR/$PROGRAM_MD" "$PROGRAM_MD"
fi
if [[ -f "$MAIN_DIR/$BENCHMARK_SH" ]] && [[ ! -f "$BENCHMARK_SH" ]]; then
    cp "$MAIN_DIR/$BENCHMARK_SH" "$BENCHMARK_SH"
    chmod +x "$BENCHMARK_SH"
fi

# --- ESTABLISH BASELINE ---

BASELINE_COMMIT=$(git log -1 --format="%H")
BASELINE_METRIC=""

if [[ "$HAS_BENCHMARK" == true ]]; then
    echo -e "${YELLOW}Running baseline benchmark ($BENCHMARK_RUNS runs, median)...${NC}"
    BASELINE_METRIC=$(run_benchmark)
    if [[ -n "$BASELINE_METRIC" ]]; then
        echo -e "${GREEN}Baseline metric: ${BASELINE_METRIC}${NC}"
    else
        echo -e "${RED}WARNING: Benchmark produced no metric — switching to qualitative mode${NC}"
        HAS_BENCHMARK=false
    fi
fi

# --- MAIN LOOP ---

echo ""
echo -e "${BLUE}Vox Optimize — Target: $TARGET${NC}"
echo -e "${BLUE}Batch size: $BATCH_SIZE | Benchmark: $HAS_BENCHMARK${NC}"
echo ""

BATCH_NUM=1
TOTAL_EXPERIMENTS=0

while true; do
    echo -e "${BLUE}=========================================="
    echo "Vox: OPTIMIZE MODE — Batch $BATCH_NUM"
    echo "Target: $TARGET"
    echo -e "==========================================${NC}"

    BATCH_START_COMMIT=$(git log -1 --format="%H")
    BATCH_START_METRIC="$BASELINE_METRIC"

    # Reset batch tracking arrays
    BATCH_HASHES=()
    BATCH_DESCS=()
    BATCH_METRICS=()
    BATCH_BASELINES=()
    BATCH_STATUSES=()

    for ((exp = 1; exp <= BATCH_SIZE; exp++)); do
        TOTAL_EXPERIMENTS=$((TOTAL_EXPERIMENTS + 1))

        echo ""
        echo -e "${YELLOW}--- Experiment $exp/$BATCH_SIZE (total: $TOTAL_EXPERIMENTS) ---${NC}"

        PRE_COMMIT=$(git log -1 --format="%H")

        # Build context and pipe to Claude
        build_optimize_context | $AGENT_CMD -p --dangerously-skip-permissions 2>&1 || true

        POST_COMMIT=$(git log -1 --format="%H")

        # Check if Claude made a commit
        if [[ "$PRE_COMMIT" == "$POST_COMMIT" ]]; then
            echo -e "${RED}No commit made — skipping${NC}"
            BATCH_HASHES+=("none")
            BATCH_DESCS+=("(no commit)")
            BATCH_METRICS+=("")
            BATCH_BASELINES+=("$BASELINE_METRIC")
            BATCH_STATUSES+=("failed")
            append_result "$(date -Iseconds | cut -d+ -f1)" "$BATCH_NUM" "$exp" \
                "none" "no-commit" "" "$BASELINE_METRIC" "failed"
            continue
        fi

        parse_last_commit

        # Run constitution verification
        echo -e "${CYAN}Running verification...${NC}"
        if ! run_verification; then
            echo -e "${RED}Verification failed — reverting${NC}"
            git reset --hard HEAD~1
            BATCH_HASHES+=("$COMMIT_HASH")
            BATCH_DESCS+=("$COMMIT_DESC")
            BATCH_METRICS+=("")
            BATCH_BASELINES+=("$BASELINE_METRIC")
            BATCH_STATUSES+=("failed")
            append_result "$(date -Iseconds | cut -d+ -f1)" "$BATCH_NUM" "$exp" \
                "$COMMIT_HASH" "$COMMIT_DESC" "" "$BASELINE_METRIC" "failed"
            continue
        fi
        echo -e "${GREEN}Verification passed.${NC}"

        # Run benchmark if available
        METRIC=""
        if [[ "$HAS_BENCHMARK" == true ]]; then
            echo -e "${YELLOW}Running benchmark ($BENCHMARK_RUNS runs, median)...${NC}"
            METRIC=$(run_benchmark)
            if [[ -n "$METRIC" ]]; then
                echo -e "${CYAN}Metric: $METRIC (baseline: ${BASELINE_METRIC:-n/a})${NC}"
            fi
        fi

        BATCH_HASHES+=("$COMMIT_HASH")
        BATCH_DESCS+=("$COMMIT_DESC")
        BATCH_METRICS+=("$METRIC")
        BATCH_BASELINES+=("$BASELINE_METRIC")
        BATCH_STATUSES+=("kept")
        append_result "$(date -Iseconds | cut -d+ -f1)" "$BATCH_NUM" "$exp" \
            "$COMMIT_HASH" "$COMMIT_DESC" "$METRIC" "$BASELINE_METRIC" "kept"

        # Update rolling baseline for next experiment
        if [[ -n "$METRIC" ]]; then
            BASELINE_METRIC="$METRIC"
        fi

        sleep 2
    done

    # --- CHECKPOINT ---
    print_scoreboard "$BATCH_NUM"

    echo -n "Keep through which experiment? (#, 'all', or 'none'): "
    read -r KEEP_CHOICE < /dev/tty

    case "$KEEP_CHOICE" in
        none)
            echo -e "${YELLOW}Reverting all experiments in batch $BATCH_NUM...${NC}"
            git reset --hard "$BATCH_START_COMMIT"
            BASELINE_METRIC="$BATCH_START_METRIC"
            mark_batch_discarded "$BATCH_NUM"
            ;;
        all)
            echo -e "${GREEN}Keeping all experiments.${NC}"
            ;;
        [0-9]*)
            keep_n="$KEEP_CHOICE"
            if [[ $keep_n -gt 0 ]] && [[ $keep_n -le ${#BATCH_HASHES[@]} ]]; then
                # Find last valid commit at or before keep_n
                target_hash=""
                for ((k = keep_n - 1; k >= 0; k--)); do
                    if [[ "${BATCH_STATUSES[$k]}" == "kept" ]]; then
                        target_hash="${BATCH_HASHES[$k]}"
                        break
                    fi
                done

                if [[ -n "$target_hash" ]] && [[ "$target_hash" != "none" ]]; then
                    echo -e "${YELLOW}Keeping through #$keep_n, reverting rest...${NC}"
                    git reset --hard "$target_hash"
                    # Restore baseline to the kept experiment's metric
                    for ((k = keep_n - 1; k >= 0; k--)); do
                        if [[ -n "${BATCH_METRICS[$k]:-}" ]]; then
                            BASELINE_METRIC="${BATCH_METRICS[$k]}"
                            break
                        fi
                    done
                    mark_after_discarded "$BATCH_NUM" "$keep_n"
                else
                    echo -e "${RED}No valid experiments at or before #$keep_n — reverting all${NC}"
                    git reset --hard "$BATCH_START_COMMIT"
                    BASELINE_METRIC="$BATCH_START_METRIC"
                    mark_batch_discarded "$BATCH_NUM"
                fi
            else
                echo -e "${RED}Invalid choice: $keep_n (expected 1-${#BATCH_HASHES[@]})${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Invalid choice: $KEEP_CHOICE${NC}"
            ;;
    esac

    echo ""
    echo -n "Continue optimizing? (y/n): "
    read -r CONTINUE < /dev/tty

    if [[ "$CONTINUE" != "y" ]]; then
        break
    fi

    BATCH_NUM=$((BATCH_NUM + 1))
done

# --- COMPLETION ---

echo ""
echo -e "${GREEN}=========================================="
echo "Optimization complete!"
echo "Total experiments: $TOTAL_EXPERIMENTS"
if [[ "$HAS_BENCHMARK" == true ]] && [[ -n "$BASELINE_METRIC" ]]; then
    echo "Final metric: $BASELINE_METRIC"
fi
echo -e "==========================================${NC}"
echo ""

echo -n "Merge optimize/$TARGET to main? (y/n): "
read -r MERGE < /dev/tty

if [[ "$MERGE" == "y" ]]; then
    cd "$MAIN_DIR"
    echo -e "${BLUE}Merging optimize/$TARGET...${NC}"
    git merge "optimize/$TARGET" --no-edit
    echo -e "${BLUE}Cleaning up worktree...${NC}"
    git worktree remove "$WORKTREE_DIR" --force
    git branch -d "optimize/$TARGET" 2>/dev/null || true
    echo -e "${GREEN}Merged and cleaned up.${NC}"
else
    echo -e "${YELLOW}Worktree left at: $WORKTREE_DIR${NC}"
    echo "To merge later:"
    echo "  cd $MAIN_DIR"
    echo "  git merge optimize/$TARGET"
    echo "  git worktree remove $WORKTREE_DIR"
fi
OPTIMIZE_EOF

# --- MAKE EXECUTABLE ---
chmod +x "$TARGET_DIR/scripts/vox.sh"
chmod +x "$TARGET_DIR/scripts/vox-optimize.sh"

# --- SUCCESS ---

echo ""
echo -e "${GREEN}=========================================="
echo "Vox scaffold complete!"
echo -e "==========================================${NC}"
echo ""
echo "Created:"
echo "  $TARGET_DIR/.specify/"
echo "  ├── memory/constitution.md"
echo "  ├── specs/"
echo "  ├── optimize/"
echo "  ├── IMPLEMENTATION_PLAN.md"
echo "  ├── AGENTS.md"
echo "  ├── PROMPT_plan.md"
echo "  ├── PROMPT_build.md"
echo "  └── PROMPT_optimize.md"
echo "  $TARGET_DIR/scripts/"
echo "  ├── vox.sh"
echo "  └── vox-optimize.sh"
echo ""
echo -e "${YELLOW}Builder loop:${NC}"
echo "  1. Edit .specify/memory/constitution.md for your project"
echo "  2. Create a spec: mkdir -p .specify/specs/001-my-feature"
echo "  3. Write: .specify/specs/001-my-feature/spec.md"
echo "  4. Plan: ./scripts/vox.sh plan 001-my-feature"
echo "  5. Build: ./scripts/vox.sh build 001-my-feature"
echo ""
echo -e "${YELLOW}Optimizer loop:${NC}"
echo "  1. Create: mkdir -p .specify/optimize/my-target"
echo "  2. Write: .specify/optimize/my-target/program.md"
echo "  3. Optional: .specify/optimize/my-target/benchmark.sh"
echo "  4. Run: ./scripts/vox-optimize.sh my-target"
