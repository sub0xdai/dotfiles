#!/bin/bash
#
# Ralph Wiggum Scaffold - Setup autonomous AI development in any project
# Based on: https://github.com/ghuntley/how-to-ralph-wiggum
#
# Usage:
#   __setup_ralph.sh              # Setup in current directory
#   __setup_ralph.sh <path>       # Setup in specific path
#   __setup_ralph.sh --force      # Overwrite existing .specify/
#   __setup_ralph.sh --help       # Show help
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
    echo "Ralph Wiggum Scaffold - Setup autonomous AI development"
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
    echo "  ├── IMPLEMENTATION_PLAN.md # Task tracking"
    echo "  ├── AGENTS.md              # Operational learnings"
    echo "  ├── PROMPT_plan.md         # Planning mode instructions"
    echo "  └── PROMPT_build.md        # Build mode instructions"
    echo "  scripts/"
    echo "  └── ralph-loop.sh          # The autonomous loop"
    echo ""
    echo "After setup:"
    echo "  1. Edit .specify/memory/constitution.md for your project"
    echo "  2. Create specs in .specify/specs/<name>/spec.md"
    echo "  3. Run: ./scripts/ralph-loop.sh plan <spec-name>"
    echo "  4. Run: ./scripts/ralph-loop.sh build <spec-name>"
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

echo -e "${BLUE}Setting up Ralph Wiggum in: $TARGET_DIR${NC}"
echo ""

mkdir -p "$TARGET_DIR/.specify/memory"
mkdir -p "$TARGET_DIR/.specify/specs"
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

<!-- Ralph will add discoveries here as implementation progresses -->

### Blockers

<!-- Document any blockers encountered -->

---

## Completed Specs

| Spec | Completion Date |
|------|-----------------|
| | |

---

*This file is persistent state. Ralph updates it each iteration.*
EOF

# --- AGENTS.md ---
cat > "$TARGET_DIR/.specify/AGENTS.md" << 'EOF'
# Operational Learnings

> Ralph's accumulated knowledge. Loaded each iteration.

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

<!-- Ralph adds discoveries here during implementation -->

---

*This file grows as Ralph learns. Never delete entries.*
EOF

# --- PROMPT_plan.md ---
cat > "$TARGET_DIR/.specify/PROMPT_plan.md" << 'EOF'
# Ralph Wiggum - PLANNING Mode

You are Ralph, an autonomous developer. You are in PLANNING mode.

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
# Ralph Wiggum - BUILD Mode

You are Ralph, an autonomous developer. You are in BUILD mode.

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

# --- ralph-loop.sh ---
cat > "$TARGET_DIR/scripts/ralph-loop.sh" << 'EOF'
#!/bin/bash
#
# Ralph Loop - Autonomous AI Development Loop
# Based on the Ralph Wiggum Technique: https://github.com/ghuntley/how-to-ralph-wiggum
#
# Usage:
#   ./scripts/ralph-loop.sh plan <spec-name>    # Planning mode (no code)
#   ./scripts/ralph-loop.sh build <spec-name>   # Building mode (one task per iteration)
#   ./scripts/ralph-loop.sh --help              # Show help
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
NC='\033[0m' # No Color

# --- HELPER FUNCTIONS ---

print_help() {
    echo "Ralph Loop - Autonomous AI Development"
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

    echo "# Context for Ralph"
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
    echo "Ralph Wiggum: PLANNING MODE"
    echo "Spec: $spec"
    echo -e "==========================================${NC}"

    if ! spec_exists "$spec"; then
        echo -e "${RED}ERROR: Spec not found: $SPECS_DIR/$spec/spec.md${NC}"
        list_specs
        return 1
    fi

    echo ""
    echo -e "${YELLOW}Waking up Ralph for planning...${NC}"
    echo ""

    # Build context and pipe to claude
    local output
    output=$(build_context "$spec" "plan" | $AGENT_CMD -p --dangerously-skip-permissions 2>&1) || true

    echo "$output"

    echo ""
    echo -e "${GREEN}Planning complete. Review IMPLEMENTATION_PLAN.md${NC}"
    echo "Next: ./scripts/ralph-loop.sh build $spec"
}

run_building() {
    local spec="$1"
    local iteration=0

    echo -e "${BLUE}=========================================="
    echo "Ralph Wiggum: BUILD MODE"
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
        echo -e "${YELLOW}Waking up Ralph...${NC}"

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
echo "Ralph Loop - Autonomous AI Development"
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

# --- MAKE EXECUTABLE ---
chmod +x "$TARGET_DIR/scripts/ralph-loop.sh"

# --- SUCCESS ---

echo ""
echo -e "${GREEN}=========================================="
echo "Ralph Wiggum scaffold complete!"
echo -e "==========================================${NC}"
echo ""
echo "Created:"
echo "  $TARGET_DIR/.specify/"
echo "  ├── memory/constitution.md"
echo "  ├── specs/"
echo "  ├── IMPLEMENTATION_PLAN.md"
echo "  ├── AGENTS.md"
echo "  ├── PROMPT_plan.md"
echo "  └── PROMPT_build.md"
echo "  $TARGET_DIR/scripts/ralph-loop.sh"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit .specify/memory/constitution.md for your project"
echo "  2. Create a spec: mkdir -p .specify/specs/001-my-feature"
echo "  3. Write: .specify/specs/001-my-feature/spec.md"
echo "  4. Plan: ./scripts/ralph-loop.sh plan 001-my-feature"
echo "  5. Build: ./scripts/ralph-loop.sh build 001-my-feature"
