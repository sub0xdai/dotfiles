#!/bin/bash
#
# Vox Scaffold - Setup autonomous AI development + optimization in any project
# "God spoke and it was."
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
    echo "Vox Scaffold - Setup autonomous AI development + optimization"
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
    echo "  ├── optimize/              # Optimization targets go here"
    echo "  ├── AGENTS.md              # Operational learnings"
    echo "  ├── PROMPT_plan.md         # Planning mode instructions"
    echo "  ├── PROMPT_build.md        # Build mode instructions"
    echo "  └── PROMPT_optimize.md     # Optimize mode instructions"
    echo "  scripts/"
    echo "  ├── vox.sh                 # The builder loop"
    echo "  └── vox-optimize.sh        # The optimization loop"
    echo ""
    echo "After setup:"
    echo "  1. Edit .specify/memory/constitution.md for your project"
    echo "  2. Create specs in .specify/specs/<name>/spec.md"
    echo "  3. Run: ./scripts/vox.sh plan <spec-name>"
    echo "  4. Run: ./scripts/vox.sh build <spec-name>"
    echo "  5. Create optimization targets in .specify/optimize/<target>/"
    echo "  6. Run: ./scripts/vox-optimize.sh <target>"
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

### Step 4: Write plan.md
- Create `.specify/specs/{SPEC_NAME}/plan.md` alongside the spec
- Add tasks with IDs (T1, T2, T3...)
- Set all new tasks to `pending`
- Add any discoveries
- Document blockers if found

---

## Output Format

After writing plan.md, summarize:

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
3. **Plan**: `.specify/specs/{SPEC_NAME}/plan.md`
4. **Operational Learnings**: `.specify/AGENTS.md`

---

## Build Process

### Step 1: Identify Your Task
- Read `.specify/specs/{SPEC_NAME}/plan.md`
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
- Mark your task as `complete` in plan.md
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
1. Document the blocker in plan.md
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

---

## Context Files (Study These First)

1. **Constitution**: `.specify/memory/constitution.md`
2. **Program**: `.specify/optimize/{TARGET}/program.md`
3. **Operational Learnings**: `.specify/AGENTS.md`
4. **Experiment History**: `.specify/optimize/{TARGET}/results.tsv`

---

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

---

## Critical Rules

- ONE change per iteration — small, isolated, testable
- NEVER modify files outside the Target Files whitelist
- NEVER retry a discarded/failed approach from results.tsv
- NEVER change test files or benchmarks
- Capture learnings in AGENTS.md if you discover something useful

---

*Each iteration: one hypothesis, one change, validate, commit, exit.*
EOF

# --- vox.sh (builder loop) ---
cat > "$TARGET_DIR/scripts/vox.sh" << 'VOX_BUILD_EOF'
#!/bin/bash
#
# Vox Builder Loop - Autonomous AI Development
# "God spoke and it was."
#
# Usage:
#   ./scripts/vox.sh plan <spec-name>    # Planning mode (no code)
#   ./scripts/vox.sh build <spec-name>   # Building mode (one task per iteration)
#   ./scripts/vox.sh --help              # Show help
#

set -euo pipefail

# --- CONFIGURATION ---
SPECS_DIR=".specify/specs"
PROMPT_PLAN=".specify/PROMPT_plan.md"
PROMPT_BUILD=".specify/PROMPT_build.md"
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
    echo "Vox Builder Loop - Autonomous AI Development"
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

    if [[ -f "$CONSTITUTION" ]]; then
        echo "---"
        echo "## Constitution"
        echo ""
        cat "$CONSTITUTION"
        echo ""
    fi

    if [[ -f "$SPECS_DIR/$spec/spec.md" ]]; then
        echo "---"
        echo "## Specification: $spec"
        echo ""
        cat "$SPECS_DIR/$spec/spec.md"
        echo ""
    fi

    if [[ -f "$AGENTS_MD" ]]; then
        echo "---"
        echo "## Operational Learnings"
        echo ""
        cat "$AGENTS_MD"
        echo ""
    fi

    local plan_file="$SPECS_DIR/$spec/plan.md"
    if [[ -f "$plan_file" ]]; then
        echo "---"
        echo "## Implementation Plan"
        echo ""
        cat "$plan_file"
        echo ""
    fi

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
    echo -e "${YELLOW}Vox speaks...${NC}"
    echo ""

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
        echo -e "${YELLOW}Vox speaks...${NC}"

        local output
        output=$(build_context "$spec" "build" | $AGENT_CMD -p --dangerously-skip-permissions 2>&1) || true

        echo "$output"

        if check_done_signal "$output"; then
            echo ""
            echo -e "${GREEN}=========================================="
            echo "SPEC COMPLETE: $spec"
            echo -e "==========================================${NC}"
            return 0
        fi

        if [[ -n $(git status --porcelain 2>/dev/null || true) ]]; then
            echo ""
            echo -e "${YELLOW}Uncommitted changes after iteration:${NC}"
            git status --short
        fi

        echo ""
        echo -e "${BLUE}Iteration $iteration complete. Continuing...${NC}"

        sleep 2

    done

    echo ""
    echo -e "${RED}WARNING: Reached max iterations ($MAX_ITERATIONS) for $spec${NC}"
    return 1
}

# --- MAIN ---

MODE=""
SPEC_NAME=""

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

if [[ ! -f "$PROMPT_PLAN" ]]; then
    echo -e "${RED}ERROR: Missing $PROMPT_PLAN${NC}"
    exit 1
fi

if [[ ! -f "$PROMPT_BUILD" ]]; then
    echo -e "${RED}ERROR: Missing $PROMPT_BUILD${NC}"
    exit 1
fi

echo "Vox Builder Loop"
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
VOX_BUILD_EOF

# --- vox-optimize.sh (optimizer loop) ---
cat > "$TARGET_DIR/scripts/vox-optimize.sh" << 'VOX_OPT_EOF'
#!/bin/bash
#
# Vox Optimizer Loop - Iterative experimentation with batched human review
# "God spoke and it was."
#
# Usage:
#   ./scripts/vox-optimize.sh <target>              # Run with default batch size (5)
#   ./scripts/vox-optimize.sh <target> --batch 3    # Custom batch size
#   ./scripts/vox-optimize.sh --help                # Show help
#

set -euo pipefail

# --- CONFIGURATION ---
OPTIMIZE_DIR=".specify/optimize"
CONSTITUTION=".specify/memory/constitution.md"
AGENTS_MD=".specify/AGENTS.md"
PROMPT_OPTIMIZE=".specify/PROMPT_optimize.md"

BATCH_SIZE=5
AGENT_CMD="claude"

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
    echo "Vox Optimizer Loop - Iterative Experimentation"
    echo ""
    echo "Usage:"
    echo "  $0 <target>              Run optimization (default batch: 5)"
    echo "  $0 <target> --batch N    Set experiments per checkpoint"
    echo "  $0 --help                Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 matching-engine"
    echo "  $0 matching-engine --batch 3"
    echo ""
    echo "Available targets:"
    list_targets
    echo ""
    echo "Create a new target:"
    echo "  mkdir -p .specify/optimize/<target>"
    echo "  Write .specify/optimize/<target>/program.md"
    echo "  Optionally add .specify/optimize/<target>/benchmark.sh"
}

list_targets() {
    if [[ -d "$OPTIMIZE_DIR" ]]; then
        for d in "$OPTIMIZE_DIR"/*/; do
            [[ -d "$d" ]] || continue
            if [[ -f "${d}program.md" ]]; then
                basename "$d"
            fi
        done | sort
    fi
}

# Run benchmark N times, return median
run_benchmark_median() {
    local benchmark_script="$1"
    local runs="${2:-3}"
    local values=()

    for ((i=1; i<=runs; i++)); do
        local result
        result=$("$benchmark_script" 2>/dev/null | grep -oP 'METRIC=\K[0-9.]+' || echo "")
        if [[ -n "$result" ]]; then
            values+=("$result")
        fi
    done

    if [[ ${#values[@]} -eq 0 ]]; then
        echo ""
        return 1
    fi

    # Sort and pick median
    IFS=$'\n' sorted=($(sort -g <<<"${values[*]}")); unset IFS
    local mid=$(( ${#sorted[@]} / 2 ))
    echo "${sorted[$mid]}"
}

# Parse benchmark runs from program.md
get_benchmark_runs() {
    local program="$1"
    grep -oP 'BENCHMARK_RUNS=\K[0-9]+' "$program" 2>/dev/null || echo "3"
}

# Parse metric direction from program.md
get_metric_direction() {
    local program="$1"
    grep -oP 'METRIC_DIRECTION=\K\w+' "$program" 2>/dev/null || echo "MINIMIZE"
}

# Extract experiment description from last commit message
get_experiment_description() {
    git log -1 --format='%s' | sed 's/^experiment: //'
}

# Append a row to results.tsv (bash-owned, never written by Claude)
append_tsv() {
    local tsv_file="$1"
    local batch="$2"
    local exp_id="$3"
    local commit_hash="$4"
    local description="$5"
    local metric="$6"
    local baseline="$7"
    local status="$8"
    local timestamp
    timestamp=$(date -Iseconds)

    # Create header if file doesn't exist
    if [[ ! -f "$tsv_file" ]]; then
        printf "timestamp\tbatch\texp_id\tcommit_hash\tdescription\tmetric\tbaseline\tstatus\n" > "$tsv_file"
    fi

    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
        "$timestamp" "$batch" "$exp_id" "$commit_hash" "$description" "$metric" "$baseline" "$status" \
        >> "$tsv_file"
}

# Print the scoreboard at checkpoint
print_scoreboard() {
    local tsv_file="$1"
    local batch_num="$2"
    local baseline_metric="$3"
    local has_metric="$4"
    local direction="$5"

    echo ""
    echo -e "${BOLD}${CYAN}=======================================================${NC}"
    echo -e "${BOLD}${CYAN}  CHECKPOINT — Batch $batch_num Results${NC}"
    echo -e "${BOLD}${CYAN}=======================================================${NC}"
    echo ""

    if [[ "$has_metric" == "true" ]]; then
        echo -e "  ${BOLD}Baseline: $baseline_metric${NC}"
        echo ""
    fi

    while IFS=$'\t' read -r ts batch eid hash desc metric bl status; do
        [[ "$batch" == "$batch_num" ]] || continue
        [[ "$status" == "failed" ]] && {
            printf "  ${RED}#%-2s  %-40s  FAILED${NC}\n" "$eid" "$desc"
            continue
        }

        if [[ "$has_metric" == "true" && -n "$metric" && "$metric" != "-" && -n "$bl" && "$bl" != "-" ]]; then
            local delta
            delta=$(awk "BEGIN { printf \"%.1f\", (($metric - $bl) / $bl) * 100 }")

            # Color based on direction: for MINIMIZE, negative delta = good
            local sign="" color="$GREEN" marker=""
            if [[ "$direction" == "MINIMIZE" ]]; then
                if (( $(awk "BEGIN { print ($delta > 0) }") )); then
                    sign="+"
                    color="$RED"
                    if (( $(awk "BEGIN { print ($delta > 5) }") )); then
                        marker="  <- regression"
                    fi
                fi
            else
                # MAXIMIZE: positive delta = good
                if (( $(awk "BEGIN { print ($delta < 0) }") )); then
                    color="$RED"
                    if (( $(awk "BEGIN { print ($delta < -5) }") )); then
                        marker="  <- regression"
                    fi
                else
                    sign="+"
                fi
            fi
            printf "  ${color}#%-2s  %-40s  %-10s  (%s%s%%)  %s%s${NC}\n" \
                "$eid" "$desc" "$metric" "$sign" "$delta" "$hash" "$marker"
        else
            printf "  #%-2s  %-40s  %s\n" "$eid" "$desc" "$hash"
        fi
    done < <(tail -n +2 "$tsv_file")

    echo ""
    echo -e "${BOLD}${CYAN}=======================================================${NC}"
}

# Build context for Claude in optimize mode
build_optimize_context() {
    local target="$1"
    local target_dir="$OPTIMIZE_DIR/$target"

    echo "# Context for Vox"
    echo ""
    echo "## Mode: OPTIMIZE"
    echo "## Target: $target"
    echo ""

    if [[ -f "$CONSTITUTION" ]]; then
        echo "---"
        echo "## Constitution"
        echo ""
        cat "$CONSTITUTION"
        echo ""
    fi

    if [[ -f "$target_dir/program.md" ]]; then
        echo "---"
        echo "## Optimization Program"
        echo ""
        cat "$target_dir/program.md"
        echo ""
    fi

    if [[ -f "$AGENTS_MD" ]]; then
        echo "---"
        echo "## Operational Learnings"
        echo ""
        cat "$AGENTS_MD"
        echo ""
    fi

    if [[ -f "$target_dir/results.tsv" ]]; then
        echo "---"
        echo "## Experiment History"
        echo ""
        cat "$target_dir/results.tsv"
        echo ""
    fi

    echo "---"
    echo "## Instructions"
    echo ""
    sed "s/{TARGET}/$target/g" "$PROMPT_OPTIMIZE"
}

# --- MAIN LOGIC ---

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

if [[ -z "$TARGET" ]]; then
    echo -e "${RED}ERROR: Target name required${NC}"
    echo ""
    print_help
    exit 1
fi

TARGET_DIR_PATH="$OPTIMIZE_DIR/$TARGET"
PROGRAM_FILE="$TARGET_DIR_PATH/program.md"
BENCHMARK_SCRIPT="$TARGET_DIR_PATH/benchmark.sh"
RESULTS_FILE="$TARGET_DIR_PATH/results.tsv"

if [[ ! -f "$PROGRAM_FILE" ]]; then
    echo -e "${RED}ERROR: program.md not found at $PROGRAM_FILE${NC}"
    echo ""
    echo "Create the target first:"
    echo "  mkdir -p $TARGET_DIR_PATH"
    echo "  Write $PROGRAM_FILE"
    exit 1
fi

if [[ ! -f "$PROMPT_OPTIMIZE" ]]; then
    echo -e "${RED}ERROR: Missing $PROMPT_OPTIMIZE${NC}"
    exit 1
fi

# --- DETERMINE BENCHMARK SETTINGS ---
HAS_BENCHMARK=false
BENCHMARK_RUNS=3
METRIC_DIRECTION="MINIMIZE"

if [[ -f "$BENCHMARK_SCRIPT" && -x "$BENCHMARK_SCRIPT" ]]; then
    HAS_BENCHMARK=true
    BENCHMARK_RUNS=$(get_benchmark_runs "$PROGRAM_FILE")
    METRIC_DIRECTION=$(get_metric_direction "$PROGRAM_FILE")
fi

# --- SETUP WORKTREE ---
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
WORKTREE_PATH="$(dirname "$REPO_ROOT")/${REPO_NAME}-optimize-${TARGET}"
BRANCH_NAME="optimize/$TARGET"

echo -e "${BLUE}=========================================="
echo "Vox: OPTIMIZE MODE"
echo "Target: $TARGET"
echo "Batch size: $BATCH_SIZE"
echo "Benchmark: $(if $HAS_BENCHMARK; then echo "yes ($METRIC_DIRECTION, ${BENCHMARK_RUNS} runs)"; else echo "none (qualitative)"; fi)"
echo -e "==========================================${NC}"
echo ""

# Check if worktree already exists
if [[ -d "$WORKTREE_PATH" ]]; then
    echo -e "${YELLOW}Worktree already exists at $WORKTREE_PATH${NC}"
    echo -e "${YELLOW}Resuming optimization session...${NC}"
else
    echo -e "${YELLOW}Creating worktree at $WORKTREE_PATH${NC}"

    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
        git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
    else
        git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"
    fi
fi

# Work in the worktree
cd "$WORKTREE_PATH"

echo -e "${GREEN}Working in: $WORKTREE_PATH${NC}"
echo ""

# --- ESTABLISH BASELINE ---
BASELINE_METRIC="-"
BASELINE_COMMIT=$(git rev-parse --short HEAD)

if $HAS_BENCHMARK; then
    echo -e "${YELLOW}Running baseline benchmark ($BENCHMARK_RUNS runs)...${NC}"
    BASELINE_METRIC=$(run_benchmark_median "$BENCHMARK_SCRIPT" "$BENCHMARK_RUNS")
    if [[ -n "$BASELINE_METRIC" ]]; then
        echo -e "${GREEN}Baseline metric: $BASELINE_METRIC${NC}"
    else
        echo -e "${RED}WARNING: Benchmark produced no output. Continuing without metrics.${NC}"
        HAS_BENCHMARK=false
    fi
fi

# --- OPTIMIZATION LOOP ---
BATCH_NUM=1
TOTAL_EXPERIMENTS=0
TOTAL_KEPT=0

while true; do
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Starting Batch $BATCH_NUM ($BATCH_SIZE experiments)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    BATCH_BASELINE_COMMIT=$(git rev-parse --short HEAD)
    CURRENT_BASELINE="$BASELINE_METRIC"

    for ((exp=1; exp<=BATCH_SIZE; exp++)); do
        TOTAL_EXPERIMENTS=$((TOTAL_EXPERIMENTS + 1))

        echo ""
        echo -e "${YELLOW}--- Experiment $exp of $BATCH_SIZE (total: $TOTAL_EXPERIMENTS) ---${NC}"
        echo -e "${YELLOW}Vox speaks...${NC}"

        # Snapshot commit before Claude runs
        PRE_COMMIT=$(git rev-parse HEAD)

        # Run Claude with optimization context
        local_output=$(build_optimize_context "$TARGET" | $AGENT_CMD -p --dangerously-skip-permissions 2>&1) || true

        echo "$local_output"

        # Check if Claude made a new commit
        POST_COMMIT=$(git rev-parse HEAD)
        if [[ "$PRE_COMMIT" == "$POST_COMMIT" ]]; then
            echo -e "${RED}No commit detected — Claude may have failed. Logging as failed.${NC}"
            append_tsv "$RESULTS_FILE" "$BATCH_NUM" "$exp" "-" "no commit produced" "-" "$CURRENT_BASELINE" "failed"
            continue
        fi

        LATEST_COMMIT=$(git rev-parse --short HEAD)
        DESCRIPTION=$(get_experiment_description)

        # Run benchmark if available
        EXP_METRIC="-"
        if $HAS_BENCHMARK; then
            echo -e "${YELLOW}Running benchmark ($BENCHMARK_RUNS runs)...${NC}"
            EXP_METRIC=$(run_benchmark_median "$BENCHMARK_SCRIPT" "$BENCHMARK_RUNS")
            if [[ -z "$EXP_METRIC" ]]; then
                EXP_METRIC="-"
            fi
            echo -e "${CYAN}Metric: $EXP_METRIC (baseline: $CURRENT_BASELINE)${NC}"
        fi

        append_tsv "$RESULTS_FILE" "$BATCH_NUM" "$exp" "$LATEST_COMMIT" "$DESCRIPTION" "$EXP_METRIC" "$CURRENT_BASELINE" "pending"

        echo -e "${GREEN}Experiment $exp committed: $LATEST_COMMIT${NC}"

        sleep 2
    done

    # --- CHECKPOINT ---
    print_scoreboard "$RESULTS_FILE" "$BATCH_NUM" "$BASELINE_METRIC" "$HAS_BENCHMARK" "$METRIC_DIRECTION"

    echo ""
    echo -n -e "  ${BOLD}Keep through which experiment? (#, 'all', or 'none'): ${NC}"
    read -r choice < /dev/tty

    case "$choice" in
        none)
            echo -e "${YELLOW}Reverting all experiments in batch $BATCH_NUM...${NC}"
            git reset --hard "$BATCH_BASELINE_COMMIT" >/dev/null 2>&1
            # Mark all pending as discarded
            if [[ -f "$RESULTS_FILE" ]]; then
                awk -F'\t' -v OFS='\t' -v batch="$BATCH_NUM" '
                    NR == 1 { print; next }
                    $2 == batch && $8 == "pending" { $8 = "discarded"; print; next }
                    { print }
                ' "$RESULTS_FILE" > "${RESULTS_FILE}.tmp" && mv "${RESULTS_FILE}.tmp" "$RESULTS_FILE"
            fi
            echo -e "${GREEN}Reverted to baseline.${NC}"
            ;;
        all)
            echo -e "${GREEN}Keeping all experiments.${NC}"
            if [[ -f "$RESULTS_FILE" ]]; then
                awk -F'\t' -v OFS='\t' -v batch="$BATCH_NUM" '
                    NR == 1 { print; next }
                    $2 == batch && $8 == "pending" { $8 = "kept"; print; next }
                    { print }
                ' "$RESULTS_FILE" > "${RESULTS_FILE}.tmp" && mv "${RESULTS_FILE}.tmp" "$RESULTS_FILE"
            fi
            if $HAS_BENCHMARK; then
                LAST_METRIC=$(tail -1 "$RESULTS_FILE" | cut -f6)
                if [[ "$LAST_METRIC" != "-" ]]; then
                    BASELINE_METRIC="$LAST_METRIC"
                fi
            fi
            TOTAL_KEPT=$((TOTAL_KEPT + BATCH_SIZE))
            ;;
        [0-9]*)
            KEEP_THROUGH=$choice
            echo -e "${YELLOW}Keeping through experiment #$KEEP_THROUGH, discarding rest...${NC}"

            KEEP_HASH=$(awk -F'\t' -v batch="$BATCH_NUM" -v eid="$KEEP_THROUGH" \
                '$2 == batch && $3 == eid { print $4 }' "$RESULTS_FILE")

            if [[ -n "$KEEP_HASH" && "$KEEP_HASH" != "-" ]]; then
                git reset --hard "$KEEP_HASH" >/dev/null 2>&1

                awk -F'\t' -v OFS='\t' -v batch="$BATCH_NUM" -v keep="$KEEP_THROUGH" '
                    NR == 1 { print; next }
                    $2 == batch && $3+0 <= keep+0 && $8 == "pending" { $8 = "kept"; print; next }
                    $2 == batch && $3+0 > keep+0 && $8 == "pending" { $8 = "discarded"; print; next }
                    { print }
                ' "$RESULTS_FILE" > "${RESULTS_FILE}.tmp" && mv "${RESULTS_FILE}.tmp" "$RESULTS_FILE"

                if $HAS_BENCHMARK; then
                    KEPT_METRIC=$(awk -F'\t' -v batch="$BATCH_NUM" -v eid="$KEEP_THROUGH" \
                        '$2 == batch && $3 == eid { print $6 }' "$RESULTS_FILE")
                    if [[ "$KEPT_METRIC" != "-" ]]; then
                        BASELINE_METRIC="$KEPT_METRIC"
                    fi
                fi
                TOTAL_KEPT=$((TOTAL_KEPT + KEEP_THROUGH))
            else
                echo -e "${RED}Could not find commit for experiment #$KEEP_THROUGH${NC}"
            fi

            echo -e "${GREEN}Done. New baseline: $(git rev-parse --short HEAD)${NC}"
            ;;
        *)
            echo -e "${RED}Invalid choice. Keeping all by default.${NC}"
            if [[ -f "$RESULTS_FILE" ]]; then
                awk -F'\t' -v OFS='\t' -v batch="$BATCH_NUM" '
                    NR == 1 { print; next }
                    $2 == batch && $8 == "pending" { $8 = "kept"; print; next }
                    { print }
                ' "$RESULTS_FILE" > "${RESULTS_FILE}.tmp" && mv "${RESULTS_FILE}.tmp" "$RESULTS_FILE"
            fi
            ;;
    esac

    echo ""
    echo -n -e "  ${BOLD}Continue optimizing? (y/n): ${NC}"
    read -r continue_choice < /dev/tty

    if [[ "$continue_choice" != "y" && "$continue_choice" != "Y" ]]; then
        break
    fi

    BATCH_NUM=$((BATCH_NUM + 1))
done

# --- COMPLETION ---
echo ""
echo -e "${GREEN}=========================================="
echo "  Vox Optimization Complete"
echo "==========================================${NC}"
echo ""
echo "  Target:      $TARGET"
echo "  Batches:     $BATCH_NUM"
echo "  Experiments: $TOTAL_EXPERIMENTS"
echo "  Kept:        $TOTAL_KEPT"
if $HAS_BENCHMARK; then
    echo "  Final metric: $BASELINE_METRIC"
fi
echo "  Worktree:    $WORKTREE_PATH"
echo "  Branch:      $BRANCH_NAME"
echo ""

echo -n -e "  ${BOLD}Merge worktree branch to main? (y/n): ${NC}"
read -r merge_choice < /dev/tty

if [[ "$merge_choice" == "y" || "$merge_choice" == "Y" ]]; then
    cd "$REPO_ROOT"
    echo -e "${YELLOW}Merging $BRANCH_NAME...${NC}"
    git merge "$BRANCH_NAME" --no-ff -m "feat: merge optimization results for $TARGET

Experiments: $TOTAL_EXPERIMENTS, Kept: $TOTAL_KEPT
$(if $HAS_BENCHMARK; then echo "Final metric: $BASELINE_METRIC"; fi)

Co-Authored-By: Claude <noreply@anthropic.com>"

    echo -e "${YELLOW}Cleaning up worktree...${NC}"
    git worktree remove "$WORKTREE_PATH"
    echo -e "${GREEN}Merged and cleaned up.${NC}"
else
    echo ""
    echo "  Worktree preserved at: $WORKTREE_PATH"
    echo "  To merge later:  cd $REPO_ROOT && git merge $BRANCH_NAME"
    echo "  To discard:      git worktree remove $WORKTREE_PATH && git branch -D $BRANCH_NAME"
fi
VOX_OPT_EOF

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
echo "  ├── AGENTS.md"
echo "  ├── PROMPT_plan.md"
echo "  ├── PROMPT_build.md"
echo "  └── PROMPT_optimize.md"
echo "  $TARGET_DIR/scripts/"
echo "  ├── vox.sh"
echo "  └── vox-optimize.sh"
echo ""
echo -e "${YELLOW}Builder workflow:${NC}"
echo "  1. Edit .specify/memory/constitution.md for your project"
echo "  2. Create a spec: mkdir -p .specify/specs/001-my-feature"
echo "  3. Write: .specify/specs/001-my-feature/spec.md"
echo "  4. Plan: ./scripts/vox.sh plan 001-my-feature"
echo "  5. Build: ./scripts/vox.sh build 001-my-feature"
echo ""
echo -e "${YELLOW}Optimizer workflow:${NC}"
echo "  1. Create a target: mkdir -p .specify/optimize/my-target"
echo "  2. Write: .specify/optimize/my-target/program.md"
echo "  3. Optional: .specify/optimize/my-target/benchmark.sh"
echo "  4. Optimize: ./scripts/vox-optimize.sh my-target"
