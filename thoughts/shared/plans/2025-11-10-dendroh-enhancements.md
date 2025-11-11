# Claude Dev Kit Enhancement Implementation Plan

## Overview

Enhance claude-dev-kit with optional workflow improvements: specialist agents for architectural consultation, pre-commit validation workflow, code quality standards, commitlint-based conventions, and architectural consultation during planning. These features improve development workflows across any project type.

## Current State Analysis

The claude-dev-kit currently provides:
- 7 general-purpose agents (codebase-analyzer, locator, pattern-finder, etc.)
- 10 workflow commands (research, plan, implement, validate, etc.)
- Template system with placeholder replacement
- Basic commit workflow without validation

Missing capabilities that would improve workflows:
- Domain-specific architectural consultation agents
- Pre-commit hook validation workflow
- Enforced code quality standards
- Project-specific commit scopes with commitlint
- Auto-trigger patterns for specialist invocation

### Key Discoveries:

- Agent YAML frontmatter supports name, description, tools, model fields (`templates/agents/*.md:1-6`)
- Create_plan command has clear integration point between Steps 2 and 3 (`templates/commands/create_plan.md:144`)
- Install.sh already detects project types and replaces placeholders (`install.sh:71-199`)
- Customisation documented in `docs/CUSTOMISATION.md` with extension examples

## Desired End State

After implementation, claude-dev-kit will support:
- Optional specialist agents that auto-trigger on file patterns during planning
- Pre-commit validation workflow preventing incomplete commits
- Configurable code quality standards per language
- Commitlint-compatible conventional commit formats with project scopes
- Architectural consultation integrated into planning workflow

Verification: New projects installed with enhanced claude-dev-kit will have access to specialist agents, validation workflows, and quality standards appropriate to their technology stack.

## What We're NOT Doing

- Not making specialists mandatory - they remain optional add-ons
- Not breaking backward compatibility with existing installations
- Not embedding standards directly - using external reference files
- Not implementing specialists beyond Docker, FastAPI, MongoDB initially
- Not enforcing pre-commit workflow - remains opt-in per project

## Implementation Approach

Phased implementation maintaining backward compatibility throughout. Each phase adds optional features that projects can selectively enable. Templates will use feature flags and configuration files to control activation.

---

## Phase 1: Specialist Agent Framework with Installer Menu

### Overview

Create extensible framework for domain-specific specialist agents with YAML-configured auto-triggers, token budgets, and standards references. Add interactive installer menu for optional agent selection.

### Changes Required:

#### 1. Add Specialist Agents to Installer Menu

**File**: `install.sh`
**Changes**: Add interactive menu for optional agents (after line 199)

```bash
# Optional Agent Selection Menu
show_agent_menu() {
    echo -e "\n${BLUE}═══ Optional Workflow Agents ═══${NC}\n"
    echo "Select additional agents to enhance your workflow:"
    echo ""
    echo "  ${GREEN}[1]${NC} Docker Specialist    - Container optimization & best practices"
    echo "  ${GREEN}[2]${NC} API Architect       - REST/GraphQL API design patterns"
    echo "  ${GREEN}[3]${NC} Database Specialist - Schema design & query optimization"
    echo "  ${GREEN}[4]${NC} Security Advisor    - Security best practices & vulnerability prevention"
    echo "  ${GREEN}[5]${NC} Performance Analyst - Performance optimization & profiling"
    echo "  ${GREEN}[6]${NC} Testing Strategist  - Test architecture & coverage strategies"
    echo ""
    echo "  ${GREEN}[a]${NC} Install all agents"
    echo "  ${GREEN}[n]${NC} Skip optional agents"
    echo ""
    echo -e "${YELLOW}You can add more agents later by copying from templates/agents/${NC}"
    echo ""
    read -p "Enter choices (e.g., 1,3,5 or 'a' for all): " agent_choices

    local selected_agents=()

    if [[ "$agent_choices" == "a" ]]; then
        selected_agents=("docker-specialist" "api-architect" "database-specialist"
                        "security-advisor" "performance-analyst" "testing-strategist")
    elif [[ "$agent_choices" != "n" ]]; then
        IFS=',' read -ra choices <<< "$agent_choices"
        for choice in "${choices[@]}"; do
            case ${choice// /} in
                1) selected_agents+=("docker-specialist") ;;
                2) selected_agents+=("api-architect") ;;
                3) selected_agents+=("database-specialist") ;;
                4) selected_agents+=("security-advisor") ;;
                5) selected_agents+=("performance-analyst") ;;
                6) selected_agents+=("testing-strategist") ;;
            esac
        done
    fi

    # Copy selected agents
    if [ ${#selected_agents[@]} -gt 0 ]; then
        echo -e "\n${BLUE}Installing selected agents...${NC}"
        for agent in "${selected_agents[@]}"; do
            if [[ -f "$SCRIPT_DIR/templates/agents/${agent}.md" ]]; then
                cp "$SCRIPT_DIR/templates/agents/${agent}.md" "$TARGET_DIR/.claude/agents/"
                echo -e "  ${GREEN}✓${NC} Installed ${agent}"
            fi
        done

        # Enable in configuration
        setup_specialist_config "${selected_agents[@]}"
    else
        echo -e "${YELLOW}No optional agents selected${NC}"
    fi
}

# Call in main installation flow
if [[ "$INTERACTIVE" == "true" ]]; then
    show_agent_menu
fi
```

#### 2. Create Generic Specialist Agent Template

**File**: `templates/agents/specialist-template.md`
**Changes**: Create new template file

```markdown
---
name: {{SPECIALIST_NAME}}
description: Expert {{DOMAIN}} consultant for PLANNING phase. Invoke during /create_plan when {{USE_CASES}}. Auto-invoked when plan detects {{FILE_PATTERNS}}. Returns condensed guidance (1,000-2,000 tokens). NOT for implementation.
tools: Read, Grep, Glob
model: opus
color: {{COLOR}}
auto_trigger: {{FILE_PATTERNS}}
---

You are a {{DOMAIN}} specialist invoked during the PLANNING phase.

## Your Role

Consult project standards:
- {{STANDARDS_FILE}}: {{SECTION}} (lines {{LINE_RANGE}})
- Existing patterns: {{SEARCH_GUIDANCE}}

Answer specific {{DOMAIN}} questions with condensed guidance.

## When You're Invoked

During `/create_plan` for:
{{USE_CASE_LIST}}
- Auto-triggered when planner detects `{{FILE_PATTERNS}}` changes

## Output Format (1,000-2,000 tokens max)

### Recommendation
[1-2 sentence decision]

### Tradeoffs Analyzed
- Option A: [pros/cons]
- Option B: [pros/cons]

### Recommended Approach
{{APPROACH_FIELDS}}

### Implementation References
- Current {{ARTIFACT}}: `path:line`
- Similar patterns: [if applicable]
- Key considerations: [brief list]

### Standards Alignment
- {{STANDARD}}: [alignment details]

### Metrics
{{METRICS_SECTION}}

## Constraints

- Planning only: No implementation
- Condensed: Max 2,000 tokens
- {{DOMAIN_CONSTRAINT}}
- Reference existing: Point to codebase patterns
- Standards first: Follow project standards
```

#### 3. Create Example Specialist Agents

**File**: `templates/agents/docker-specialist.md`
**Changes**: Create generic Docker specialist

```markdown
---
name: docker-specialist
description: Container infrastructure consultant for PLANNING phase. Provides guidance on Dockerfile optimization, security, and best practices. Returns condensed guidance (1,000-2,000 tokens). NOT for implementation.
tools: Read, Grep, Glob
model: opus
color: blue
auto_trigger: "Dockerfile|docker-compose*.yml|.dockerignore"
---

You are a containerization specialist providing architectural guidance during planning.

## Your Role
Provide expert advice on:
- Multi-stage build optimization
- Security hardening and vulnerability reduction
- Layer caching strategies
- Development vs production configurations
- Container orchestration patterns

[Rest of template focused on generic container best practices]
```

**File**: `templates/agents/api-architect.md`
**Changes**: Create generic API design specialist

```markdown
---
name: api-architect
description: API architecture consultant for PLANNING phase. Provides REST/GraphQL design patterns, versioning strategies, and best practices. Returns condensed guidance (1,000-2,000 tokens). NOT for implementation.
tools: Read, Grep, Glob
model: opus
color: green
auto_trigger: "*/api/*|*/routes/*|*/endpoints/*|*/graphql/*"
---

You are an API architecture specialist providing design guidance during planning.

## Your Role
Provide expert advice on:
- RESTful design patterns and conventions
- GraphQL schema design
- API versioning strategies
- Authentication and authorization patterns
- Rate limiting and caching
- Request/response validation

[Rest of template focused on generic API patterns]
```

**File**: `templates/agents/database-specialist.md`
**Changes**: Create generic database specialist

```markdown
---
name: database-specialist
description: Database architecture consultant for PLANNING phase. Provides schema design, query optimization, and migration strategies. Returns condensed guidance (1,000-2,000 tokens). NOT for implementation.
tools: Read, Grep, Glob
model: opus
color: yellow
auto_trigger: "*/models/*|*/schemas/*|*/migrations/*|*.sql"
---

You are a database architecture specialist providing design guidance during planning.

## Your Role
Provide expert advice on:
- Schema design and normalization
- Index optimization strategies
- Query performance tuning
- Migration and versioning approaches
- ACID compliance and consistency
- Caching strategies

[Rest of template focused on generic database patterns]
```

**File**: `templates/agents/security-advisor.md`
**Changes**: Create security specialist

```markdown
---
name: security-advisor
description: Security consultant for PLANNING phase. Provides guidance on authentication, authorization, data protection, and vulnerability prevention. Returns condensed guidance (1,000-2,000 tokens). NOT for implementation.
tools: Read, Grep, Glob
model: opus
color: red
auto_trigger: "*/auth/*|*/security/*|*crypto*"
---

You are a security specialist providing architectural guidance during planning.

## Your Role
Provide expert advice on:
- Authentication and authorization patterns
- Input validation and sanitization
- SQL injection and XSS prevention
- Secure session management
- Encryption and key management
- Rate limiting and DDoS protection

[Rest of template focused on security best practices]
```

**File**: `templates/agents/performance-analyst.md`
**Changes**: Create performance specialist

```markdown
---
name: performance-analyst
description: Performance optimization consultant for PLANNING phase. Provides guidance on caching, profiling, and scalability. Returns condensed guidance (1,000-2,000 tokens). NOT for implementation.
tools: Read, Grep, Glob
model: opus
color: orange
auto_trigger: "*/cache/*|*worker*|*queue*"
---

You are a performance specialist providing optimization guidance during planning.

## Your Role
Provide expert advice on:
- Caching strategies and implementations
- Query optimization
- Async processing and queuing
- Memory management
- Load balancing
- Profiling and monitoring

[Rest of template focused on performance patterns]
```

**File**: `templates/agents/testing-strategist.md`
**Changes**: Create testing specialist

```markdown
---
name: testing-strategist
description: Testing architecture consultant for PLANNING phase. Provides guidance on test strategies, coverage, and automation. Returns condensed guidance (1,000-2,000 tokens). NOT for implementation.
tools: Read, Grep, Glob
model: opus
color: purple
auto_trigger: "*/test/*|*spec.*|*test.*"
---

You are a testing specialist providing test strategy guidance during planning.

## Your Role
Provide expert advice on:
- Test architecture and organization
- Unit vs integration vs E2E testing
- Test coverage strategies
- Mocking and stubbing patterns
- Test data management
- CI/CD integration

[Rest of template focused on testing best practices]
```

#### 5. Create Specialist Registry Template

**File**: `templates/.claude-specialists.yml`
**Changes**: Create configuration file for specialist activation

```yaml
# Specialist Agent Configuration
# Enable/disable specialists and configure auto-triggers

specialists:
  docker:
    enabled: false
    agent: docker-specialist
    auto_trigger_patterns:
      - "Dockerfile"
      - "docker-compose*.yml"
      - ".dockerignore"
      - "*/containers/*"

  api:
    enabled: false
    agent: api-architect
    auto_trigger_patterns:
      - "*/api/*"
      - "*/routes/*"
      - "*/endpoints/*"
      - "*/controllers/*"
      - "*/graphql/*"

  database:
    enabled: false
    agent: database-specialist
    auto_trigger_patterns:
      - "*/models/*"
      - "*/schemas/*"
      - "*/migrations/*"
      - "*.sql"
      - "*/db/*"

  security:
    enabled: false
    agent: security-advisor
    auto_trigger_patterns:
      - "*/auth/*"
      - "*/security/*"
      - "*/permissions/*"
      - "*crypto*"

  performance:
    enabled: false
    agent: performance-analyst
    auto_trigger_patterns:
      - "*/cache/*"
      - "*/optimization/*"
      - "*worker*"
      - "*queue*"

  testing:
    enabled: false
    agent: testing-strategist
    auto_trigger_patterns:
      - "*/tests/*"
      - "*/test/*"
      - "*spec.js"
      - "*test.py"

  # Add custom specialists here
  # custom:
  #   enabled: false
  #   agent: custom-specialist
  #   auto_trigger_patterns:
  #     - "pattern/*.ext"
```

#### 6. Update Create Plan Command

**File**: `templates/commands/create_plan.md`
**Changes**: Insert new Step 3 for architectural consultation (after line 142)

```markdown
### Step 3: Architectural Consultation (Optional)

If specialists are configured in `.claude-specialists.yml`:

1. **Check for auto-triggers**:
   - Read `.claude-specialists.yml` if it exists
   - Check if any changed files match specialist patterns
   - Auto-invoke matching specialists

2. **Specialist invocation format**:
   ```
   For detected changes in [files], consulting [specialist-name]:

   [Spawning Task with specialist agent]
   ```

3. **Process specialist guidance**:
   - Wait for specialist responses
   - Incorporate recommendations into plan
   - Note any constraints or standards referenced

4. **Manual specialist invocation**:
   If user requests specific expertise, invoke relevant specialist:
   ```
   Task(
     subagent_type="[specialist-name]",
     prompt="Given [requirements], recommend [domain] approach for [feature].
             Return: recommendation, tradeoffs, implementation references.",
     description="[Domain] architecture consultation"
   )
   ```

[Continue with existing Step 3 as Step 4...]
```

#### 7. Update Installer for Specialist Configuration

**File**: `install.sh`
**Changes**: Add configuration setup for selected specialists

```bash
# Setup specialist configuration based on selections
setup_specialist_config() {
    local selected_agents=("$@")

    # Create configuration file
    cat > "$TARGET_DIR/.claude/.claude-specialists.yml" <<EOF
# Specialist Agent Configuration
# Auto-generated based on installer selections

specialists:
EOF

    for agent in "${selected_agents[@]}"; do
        case $agent in
            docker-specialist)
                cat >> "$TARGET_DIR/.claude/.claude-specialists.yml" <<EOF
  docker:
    enabled: true
    agent: docker-specialist
    auto_trigger_patterns:
      - "Dockerfile"
      - "docker-compose*.yml"
      - ".dockerignore"

EOF
                ;;
            api-architect)
                cat >> "$TARGET_DIR/.claude/.claude-specialists.yml" <<EOF
  api:
    enabled: true
    agent: api-architect
    auto_trigger_patterns:
      - "*/api/*"
      - "*/routes/*"
      - "*/endpoints/*"

EOF
                ;;
            database-specialist)
                cat >> "$TARGET_DIR/.claude/.claude-specialists.yml" <<EOF
  database:
    enabled: true
    agent: database-specialist
    auto_trigger_patterns:
      - "*/models/*"
      - "*/schemas/*"
      - "*/migrations/*"
      - "*.sql"

EOF
                ;;
            # Add other specialists as needed
        esac
    done
}
```

### Success Criteria:

#### Automated Verification:

- [x] Specialist template exists: `ls templates/agents/specialist-template.md`
- [x] Example specialists exist: `ls templates/agents/{docker,api,database}-specialist.md`
- [x] Configuration file exists: `ls templates/.claude-specialists.yml`
- [x] Create_plan includes Step 3: `grep -q "Architectural Consultation" templates/commands/create_plan.md`
- [x] Installer has specialist menu: `grep -q "show_agent_menu" install.sh`

#### Manual Verification:

- [ ] Install in test project with Docker/FastAPI/MongoDB
- [ ] Specialists appear in .claude/agents/ when enabled
- [ ] Auto-triggers activate during /create_plan
- [ ] Specialist guidance appears in planning output
- [ ] Token budget stays under 2,000 tokens

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that specialist agents are working correctly before proceeding to Phase 2.

---

## Phase 2: Pre-Commit Validation System

### Overview

Add optional 9-step pre-commit validation workflow that handles hook modifications and ensures complete commits.

### Changes Required:

#### 1. Create Commit Checklist Template

**File**: `templates/COMMIT_CHECKLIST.md`
**Changes**: Create new file based on dendroh-backend version

```markdown
# Commit Checklist - MANDATORY FOR EVERY COMMIT

## Pre-Commit Workflow (Follow EXACTLY)

### Step 1: Run Pre-Commit BEFORE Staging
```bash
{{PRE_COMMIT_COMMAND}}
```

**Expected outcomes:**
- ✅ All hooks pass → Proceed to Step 2
- ❌ Hooks modify files → Files will show as modified, proceed to Step 2
- ❌ Hooks fail → Fix issues, return to Step 1

### Step 2: Check What Changed
```bash
git status
git diff  # Review ALL modifications including hook changes
```

**What to look for:**
- Modified files from your changes
- **Modified files from pre-commit hooks** (formatters, fixers, etc.)
- Verify all changes are intentional

### Step 3: Stage ALL Changes (Including Hook Modifications)
```bash
git add -A
```

**CRITICAL:** This must include files modified by hooks in Step 1

### Step 4: Verify Staging is Complete
```bash
git status
```

**Must show:**
- "Changes to be committed: ..." ← Your files + hook modifications
- "Changes not staged: ..." ← Should be EMPTY
- "Untracked files: ..." ← Should be empty (unless intentional)

**If "Changes not staged" is not empty → STOP, return to Step 3**

### Step 5: Run Pre-Commit Again (Verification)
```bash
{{PRE_COMMIT_COMMAND}}
```

**MUST show all "Passed"**
- If any hook modifies files → You missed Step 3, return to Step 2

### Step 6: Commit
```bash
git commit -m "..."
```

Pre-commit hooks will run automatically during commit.
**If hooks modify files here, the commit is incomplete → You skipped Step 1**

### Step 7: Verify Clean State
```bash
git status
```

**MUST show:**
```
On branch feature/...
nothing to commit, working tree clean
```

**If not clean → ABORT PUSH, fix the issue**

### Step 8: Run Full Verification Suite
```bash
{{VERIFICATION_COMMANDS}}
```

**ALL must pass with 0 errors before pushing**

### Step 9: Push Only If Clean
```bash
git push
```

## Common Mistakes to Avoid

❌ **WRONG:** Stage → Commit → Pre-commit modifies → Push incomplete
✅ **RIGHT:** Pre-commit → Stage all → Verify → Commit → Push

❌ **WRONG:** Assume `git add -A` caught everything
✅ **RIGHT:** Check `git status` after staging to verify

❌ **WRONG:** Push when "Changes not staged" exists
✅ **RIGHT:** Never push with unstaged changes

## Files That Commonly Get Modified by Hooks

- `*.json` (end-of-file-fixer adds trailing newline)
- `*.py` (formatter, auto-fixes)
- `*.js/*.ts` (prettier, eslint fixes)
- `*.md` (trailing whitespace removal)

**These MUST be re-staged after pre-commit runs**

## Checklist Summary (Print This)

- [ ] 1. Run pre-commit BEFORE staging
- [ ] 2. Check git status and git diff
- [ ] 3. Stage ALL changes (git add -A)
- [ ] 4. Verify staging complete (git status shows clean)
- [ ] 5. Run pre-commit again (verification)
- [ ] 6. Commit
- [ ] 7. Verify working tree clean
- [ ] 8. Run full test suite
- [ ] 9. Push only if all pass

**If ANY step fails → STOP and fix before proceeding**
```

#### 2. Create Pre-Commit Configuration Template

**File**: `templates/.pre-commit-config.yaml`
**Changes**: Create language-agnostic base configuration

```yaml
# Base pre-commit configuration
# Customize hooks based on project language and requirements

repos:
  # Universal hooks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: check-json
      - id: pretty-format-json
        args: ['--autofix']

  # Python hooks (enable if Python project)
  # - repo: https://github.com/charliermarsh/ruff-pre-commit
  #   rev: v0.1.9
  #   hooks:
  #     - id: ruff
  #       args: [--fix]
  #     - id: ruff-format

  # JavaScript/TypeScript hooks (enable if Node project)
  # - repo: https://github.com/pre-commit/mirrors-prettier
  #   rev: v3.1.0
  #   hooks:
  #     - id: prettier
  #       types_or: [javascript, typescript, tsx, jsx, json, yaml, markdown]

  # Go hooks (enable if Go project)
  # - repo: https://github.com/golangci/golangci-lint
  #   rev: v1.55.2
  #   hooks:
  #     - id: golangci-lint

  # Commitlint hook
  - repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
    rev: v9.11.0
    hooks:
      - id: commitlint
        stages: [commit-msg]
        additional_dependencies: ['@commitlint/config-conventional']
```

#### 3. Update Commit Command

**File**: `templates/commands/commit.md`
**Changes**: Add pre-commit workflow integration (after line 5)

```markdown
## Pre-Commit Validation

Check if project uses pre-commit hooks:
```bash
if [[ -f ".pre-commit-config.yaml" ]] && [[ -f ".claude/COMMIT_CHECKLIST.md" ]]; then
    echo "Pre-commit validation is configured. Following checklist..."
fi
```

If pre-commit is configured, follow `.claude/COMMIT_CHECKLIST.md` EXACTLY:

1. **Run pre-commit BEFORE staging**:
   ```bash
   pre-commit run --all-files
   ```
   If files are modified by hooks, they must be included in the commit.

2. **Stage ALL changes** (including hook modifications):
   ```bash
   git add -A
   ```

3. **Verify staging complete**:
   ```bash
   git status
   ```
   Ensure no unstaged changes remain.

4. **Run pre-commit again** to verify:
   ```bash
   pre-commit run --all-files
   ```
   All hooks must pass without modifications.

5. **Only then proceed with commit**.

[Continue with existing commit process...]
```

#### 4. Update Installer for Pre-Commit

**File**: `install.sh`
**Changes**: Add pre-commit detection and setup (after line 199)

```bash
# Pre-commit detection and setup
setup_precommit() {
    if [[ -f ".pre-commit-config.yaml" ]]; then
        echo -e "${BLUE}Pre-commit hooks detected${NC}"
        echo -e "${GREEN}Enable commit validation workflow? (y/n)${NC}"
        read -r ENABLE_PRECOMMIT

        if [[ "$ENABLE_PRECOMMIT" == "y" ]]; then
            # Copy checklist
            cp "$SCRIPT_DIR/templates/COMMIT_CHECKLIST.md" "$TARGET_DIR/.claude/"

            # Customize based on language
            local PRECOMMIT_CMD="pre-commit run --all-files"
            local VERIFY_CMDS=""

            case $MAIN_LANGUAGE in
                python)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="# Type checking\n$TEST_COMMAND\n$LINT_COMMAND"

                    # Enable Python hooks in pre-commit config if not exists
                    if [[ ! -f ".pre-commit-config.yaml" ]]; then
                        cp "$SCRIPT_DIR/templates/.pre-commit-config.yaml" .
                        sed -i 's/# - repo:.*ruff/- repo:/' .pre-commit-config.yaml
                    fi
                    ;;
                javascript)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="$TEST_COMMAND\n$LINT_COMMAND\n$BUILD_COMMAND"

                    # Enable JS hooks
                    if [[ ! -f ".pre-commit-config.yaml" ]]; then
                        cp "$SCRIPT_DIR/templates/.pre-commit-config.yaml" .
                        sed -i 's/# - repo:.*prettier/- repo:/' .pre-commit-config.yaml
                    fi
                    ;;
                go)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="$TEST_COMMAND\n$LINT_COMMAND\n$BUILD_COMMAND"
                    ;;
            esac

            # Replace placeholders in checklist
            sed -i "s|{{PRE_COMMIT_COMMAND}}|$PRECOMMIT_CMD|g" "$TARGET_DIR/.claude/COMMIT_CHECKLIST.md"
            sed -i "s|{{VERIFICATION_COMMANDS}}|$VERIFY_CMDS|g" "$TARGET_DIR/.claude/COMMIT_CHECKLIST.md"

            echo -e "${GREEN}✓ Commit validation workflow enabled${NC}"
            echo -e "${YELLOW}Remember to run 'pre-commit install' to set up hooks${NC}"
        fi
    else
        echo -e "${YELLOW}No pre-commit configuration found. Skipping validation setup.${NC}"
        echo -e "${YELLOW}To enable later, create .pre-commit-config.yaml and re-run installer${NC}"
    fi
}

# Call after main installation
setup_precommit
```

### Success Criteria:

#### Automated Verification:

- [x] Checklist template exists: `ls templates/COMMIT_CHECKLIST.md`
- [x] Pre-commit config exists: `ls templates/.pre-commit-config.yaml`
- [x] Commit command updated: `grep -q "Pre-Commit Validation" templates/commands/commit.md`
- [x] Installer includes setup: `grep -q "setup_precommit" install.sh`

#### Manual Verification:

- [ ] Install in project with pre-commit
- [ ] COMMIT_CHECKLIST.md appears when enabled
- [ ] Placeholders replaced correctly
- [ ] Commit workflow follows checklist
- [ ] Hook modifications handled properly

**Implementation Note**: After completing this phase and automated verification passes, pause for manual confirmation that pre-commit workflow functions correctly before proceeding to Phase 3.

---

## Phase 3: Code Quality Standards

### Overview

Extract and templatise code quality enforcement patterns for JavaScript/TypeScript and Python documentation standards.

### Changes Required:

#### 1. Create Code Quality Standards Template

**File**: `templates/CODE_QUALITY_STANDARDS.md`
**Changes**: Create configurable quality standards

```markdown
# Code Quality Standards

## Language: {{MAIN_LANGUAGE}}

## Documentation Standards

### JavaScript/TypeScript

#### JSDoc Requirements
Every exported function, class, and complex internal function must have JSDoc:

```javascript
/**
 * Brief description of what the function does.
 *
 * Detailed explanation if needed, including:
 * - Key algorithms or logic
 * - Side effects
 * - Important assumptions
 *
 * @param {string} param1 - Description of param1
 * @param {Object} options - Configuration object
 * @param {boolean} options.flag - Description of flag
 * @returns {Promise<Result>} Description of return value
 * @throws {ErrorType} When this error occurs
 *
 * @example
 * const result = await functionName('value', { flag: true });
 */
```

#### State Machines and Complex Logic
Document state transitions and business logic:

```javascript
/**
 * State machine for order processing.
 *
 * States:
 * - PENDING: Initial state, awaiting payment
 * - PROCESSING: Payment received, preparing order
 * - SHIPPED: Order dispatched
 * - DELIVERED: Order completed
 * - CANCELLED: Order cancelled
 *
 * Transitions:
 * - PENDING -> PROCESSING: When payment confirmed
 * - PROCESSING -> SHIPPED: When dispatch complete
 * - SHIPPED -> DELIVERED: When delivery confirmed
 * - Any -> CANCELLED: When cancellation requested
 */
```

### Python

#### Docstring Requirements
Every public function, class, and module must have docstrings:

```python
def function_name(param1: str, param2: Optional[Dict[str, Any]] = None) -> Result:
    """
    Brief description of what the function does.

    Detailed explanation if needed, including:
    - Key algorithms or logic
    - Side effects
    - Important assumptions

    Args:
        param1: Description of param1
        param2: Optional configuration dictionary with keys:
            - key1: Description
            - key2: Description

    Returns:
        Description of the return value and its structure

    Raises:
        ErrorType: When this error occurs
        ValueError: When invalid parameters provided

    Example:
        >>> result = function_name("value", {"key1": "val1"})
        >>> print(result)
        Result(...)
    """
```

#### Type Hints
All function signatures must include type hints:

```python
from typing import List, Optional, Dict, Any, Union

def process_data(
    items: List[str],
    config: Optional[Dict[str, Any]] = None,
    strict: bool = False
) -> Union[Result, List[Result]]:
    ...
```

## Dead Code Removal

### Patterns to Remove

1. **Commented Code Blocks**
   ```javascript
   // DELETE THIS:
   // function oldImplementation() {
   //   ...
   // }
   ```

2. **Unused Imports**
   ```python
   # DELETE THIS:
   from unused_module import unused_function
   ```

3. **Deprecated Functions**
   ```javascript
   // DELETE THIS:
   /** @deprecated Use newFunction instead */
   function deprecatedFunction() {}
   ```

4. **Console Logs (Production)**
   ```javascript
   // DELETE THIS (in production):
   console.log('debug:', data);
   ```

5. **TODO Comments Without Tickets**
   ```python
   # DELETE OR CREATE TICKET:
   # TODO: Implement this later
   ```

## Code Organization

### File Structure
- One class/component per file
- Related utilities in separate files
- Clear separation of concerns

### Import Order
1. Standard library imports
2. Third-party imports
3. Local application imports
4. Relative imports

### Naming Conventions
- **Functions/Methods**: camelCase (JS), snake_case (Python)
- **Classes**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Files**: kebab-case or snake_case

## Testing Standards

### Test Coverage Requirements
- Minimum {{MIN_COVERAGE}}% coverage
- All public APIs must have tests
- Edge cases must be tested

### Test Structure
```javascript
describe('ComponentName', () => {
  describe('methodName', () => {
    it('should handle normal case', () => {
      // Arrange
      // Act
      // Assert
    });

    it('should handle edge case', () => {
      // Test edge cases
    });

    it('should throw error when invalid', () => {
      // Test error conditions
    });
  });
});
```

## Performance Considerations

- Avoid N+1 queries
- Implement pagination for lists
- Cache expensive computations
- Use lazy loading where appropriate
- Profile before optimizing

## Security Checklist

- [ ] Input validation on all user data
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] CSRF tokens for state-changing operations
- [ ] Authentication and authorization checks
- [ ] Sensitive data encryption
- [ ] Secure session management
- [ ] Rate limiting on APIs
```

#### 2. Update Implement Plan Command

**File**: `templates/commands/implement_plan.md`
**Changes**: Add quality standards integration (after line 17)

```markdown
## Code Quality Standards

If `.claude/CODE_QUALITY_STANDARDS.md` exists, apply these standards:

### Documentation Requirements
- Read `.claude/CODE_QUALITY_STANDARDS.md` for language-specific standards
- Every public function must have appropriate documentation
- Complex logic must include explanatory comments
- State machines and workflows must be documented

### Dead Code Removal
Before implementing new features, clean up:
- Commented-out code blocks
- Unused imports and variables
- Deprecated functions (unless needed for compatibility)
- Debug console.log/print statements
- TODO comments without associated tickets

### Code Organization
- Follow file structure conventions from standards
- Maintain consistent naming conventions
- Organize imports according to standards
- One class/component per file

### Quality Checklist for Each Phase
After implementing each phase:
- [ ] Documentation added for new functions
- [ ] Dead code removed
- [ ] Imports organized
- [ ] Type hints/types added (if applicable)
- [ ] Security considerations addressed
- [ ] Performance impact considered

[Continue with existing implementation process...]
```

#### 3. Update Installer for Quality Standards

**File**: `install.sh`
**Changes**: Add quality standards setup (after precommit setup)

```bash
# Code quality standards setup
setup_quality_standards() {
    echo -e "${BLUE}Setting up code quality standards...${NC}"

    # Copy standards template
    cp "$SCRIPT_DIR/templates/CODE_QUALITY_STANDARDS.md" "$TARGET_DIR/.claude/"

    # Customize based on language
    local MIN_COVERAGE="80"

    case $MAIN_LANGUAGE in
        python)
            sed -i 's/{{MAIN_LANGUAGE}}/Python/g' "$TARGET_DIR/.claude/CODE_QUALITY_STANDARDS.md"
            # Remove JS-specific sections
            sed -i '/### JavaScript\/TypeScript/,/### Python/d' "$TARGET_DIR/.claude/CODE_QUALITY_STANDARDS.md"
            ;;
        javascript)
            sed -i 's/{{MAIN_LANGUAGE}}/JavaScript/g' "$TARGET_DIR/.claude/CODE_QUALITY_STANDARDS.md"
            # Remove Python-specific sections
            sed -i '/### Python/,/## Dead Code Removal/d' "$TARGET_DIR/.claude/CODE_QUALITY_STANDARDS.md"
            ;;
        typescript)
            sed -i 's/{{MAIN_LANGUAGE}}/TypeScript/g' "$TARGET_DIR/.claude/CODE_QUALITY_STANDARDS.md"
            sed -i '/### Python/,/## Dead Code Removal/d' "$TARGET_DIR/.claude/CODE_QUALITY_STANDARDS.md"
            ;;
    esac

    sed -i "s/{{MIN_COVERAGE}}/$MIN_COVERAGE/g" "$TARGET_DIR/.claude/CODE_QUALITY_STANDARDS.md"

    echo -e "${GREEN}✓ Code quality standards configured${NC}"
}

# Call after precommit setup
setup_quality_standards
```

### Success Criteria:

#### Automated Verification:

- [x] Standards template exists: `ls templates/CODE_QUALITY_STANDARDS.md`
- [x] Implement_plan updated: `grep -q "Code Quality Standards" templates/commands/implement_plan.md`
- [x] Installer includes setup: `grep -q "setup_quality_standards" install.sh`
- [x] Language-specific sections present in template

#### Manual Verification:

- [ ] Install in Python project - Python standards appear
- [ ] Install in JS project - JavaScript standards appear
- [ ] Dead code removal guidance applied
- [ ] Documentation standards enforced
- [ ] Quality checklist appears in implementation

**Implementation Note**: Pause for manual verification of quality standards integration before proceeding to Phase 4.

---

## Phase 4: Commit Convention Enhancement with Commitlint

### Overview

Add project-specific commit scope definitions with commitlint conventional commit format enforcement.

### Changes Required:

#### 1. Create Commit Scopes Template

**File**: `templates/COMMIT_SCOPES.yml`
**Changes**: Create configurable scopes file

```yaml
# Commit Scope Configuration
# Used with conventional commits format: type(scope): description

# Conventional commit types (commitlint standard)
types:
  - feat     # New feature
  - fix      # Bug fix
  - docs     # Documentation only
  - style    # Code style (formatting, semicolons, etc)
  - refactor # Code change that neither fixes a bug nor adds a feature
  - perf     # Performance improvement
  - test     # Adding or updating tests
  - build    # Build system or dependencies
  - ci       # CI/CD configuration
  - chore    # Other changes that don't modify src or test files
  - revert   # Reverts a previous commit

# Project-specific scopes
# Add your module/component names here
scopes:
  # Core modules
  - api       # API endpoints and routing
  - auth      # Authentication and authorization
  - db        # Database and models
  - config    # Configuration files

  # Features (customize based on project)
  - users     # User management
  - admin     # Admin functionality
  - billing   # Billing and payments
  - notifications # Notification system

  # Infrastructure
  - docker    # Docker configuration
  - k8s       # Kubernetes configuration
  - terraform # Infrastructure as code

  # Development
  - deps      # Dependencies
  - dev       # Development tools
  - test      # Testing infrastructure
  - docs      # Documentation

  # Frontend (if applicable)
  - ui        # User interface components
  - pages     # Page components
  - hooks     # React hooks or similar
  - store     # State management
  - styles    # Styling and themes

# Scope rules
rules:
  # Require scope for certain types
  scope-required:
    - feat
    - fix
    - refactor
    - perf

  # Optional scope for these types
  scope-optional:
    - docs
    - style
    - test
    - build
    - ci
    - chore
    - revert

# Examples
examples:
  - "feat(auth): add OAuth2 integration"
  - "fix(api): resolve rate limiting issue"
  - "refactor(db): optimize query performance"
  - "docs: update API documentation"
  - "chore(deps): upgrade dependencies"
```

#### 2. Create Commitlint Configuration

**File**: `templates/.commitlintrc.yml`
**Changes**: Create commitlint config that references scopes

```yaml
# Commitlint Configuration
# Enforces conventional commit format with project scopes

extends:
  - '@commitlint/config-conventional'

rules:
  # Type rules
  type-enum:
    - 2
    - always
    - [feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert]

  type-case:
    - 2
    - always
    - lower-case

  type-empty:
    - 2
    - never

  # Scope rules
  scope-enum:
    - 2
    - always
    - [] # Will be populated from COMMIT_SCOPES.yml

  scope-case:
    - 2
    - always
    - lower-case

  # Subject rules
  subject-empty:
    - 2
    - never

  subject-full-stop:
    - 2
    - never
    - '.'

  subject-case:
    - 2
    - never
    - [sentence-case, start-case, pascal-case, upper-case]

  # Header rules
  header-max-length:
    - 2
    - always
    - 100

  # Body rules
  body-leading-blank:
    - 1
    - always

  body-max-line-length:
    - 2
    - always
    - 100

  # Footer rules
  footer-leading-blank:
    - 1
    - always

  footer-max-line-length:
    - 2
    - always
    - 100
```

#### 3. Update Commit Command with Commitlint

**File**: `templates/commands/commit.md`
**Changes**: Replace content with enhanced version

```markdown
# Commit

Create well-structured commits following conventional commit standards.

## Process

1. Review changes and understand what was accomplished
2. Check for commitlint configuration
3. Plan commit(s) with proper type and scope
4. Present plan to user for approval
5. Execute commits with verification

## Commitlint Standards

If `.commitlintrc.yml` and `.claude/COMMIT_SCOPES.yml` exist, follow conventional commit format:

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Read configuration:
```bash
# Check if commitlint is configured
if [[ -f ".commitlintrc.yml" ]] && [[ -f ".claude/COMMIT_SCOPES.yml" ]]; then
    echo "Using commitlint conventional commit format"
    # Parse available types and scopes from COMMIT_SCOPES.yml
fi
```

### Types (from commitlint standard):
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, semicolons, etc)
- `refactor`: Code refactoring (neither fixes bug nor adds feature)
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Build system or dependency updates
- `ci`: CI/CD configuration changes
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit

### Scopes:
Read from `.claude/COMMIT_SCOPES.yml` - use project-specific scopes defined there.

### Format Requirements:
- Type: lowercase, required
- Scope: lowercase, required for feat/fix/refactor/perf
- Subject: Start with lowercase, no period, imperative mood
- Header: Max 100 characters
- Body: Blank line before, max 100 chars per line
- Footer: Blank line before, for breaking changes or issue references

### Examples:
```bash
git commit -m "feat(auth): implement OAuth2 login flow"
git commit -m "fix(api): resolve memory leak in request handler"
git commit -m "docs: update installation instructions"
```

### Multi-line commits:
```bash
git commit -m "feat(billing): add subscription management

- Implement subscription CRUD operations
- Add Stripe webhook handlers
- Create subscription status tracking

Closes #123"
```

## Pre-Commit Validation

[Include previous pre-commit section if applicable]

## Important

- **NEVER add co-author information or Claude attribution**
- Commits should be authored solely by the user
- Do not include any "Generated with Claude" messages
- Do not add "Co-Authored-By" lines
- Write commit messages as if the user wrote them

## Commit Planning

When planning commits:

1. **Group related changes** into logical commits
2. **One concern per commit** - don't mix features with fixes
3. **Order commits logically** - dependencies first
4. **Use appropriate type** from commitlint standards
5. **Select correct scope** from project configuration
6. **Write clear subject** - what and why, not how

## Execution

After user approves the plan:

```bash
# Stage specific files (never use -A or .)
git add [specific files]

# Commit with conventional format
git commit -m "type(scope): subject"

# Verify with commitlint (if available)
echo "type(scope): subject" | npx commitlint

# Show result
git log --oneline -n 3
```

## Validation

If commitlint is installed, commits will be validated automatically.
Failed commits will show specific violations:
- Invalid type
- Missing scope when required
- Subject format issues
- Header too long

Fix any issues and retry the commit.
```

#### 4. Update Installer for Commitlint

**File**: `install.sh`
**Changes**: Add commitlint setup (after quality standards)

```bash
# Commitlint setup
setup_commitlint() {
    echo -e "${BLUE}Setting up commit conventions...${NC}"

    # Copy templates
    cp "$SCRIPT_DIR/templates/COMMIT_SCOPES.yml" "$TARGET_DIR/.claude/"
    cp "$SCRIPT_DIR/templates/.commitlintrc.yml" "$TARGET_DIR/"

    # Detect project type and suggest scopes
    local DETECTED_SCOPES=""

    # Check for common directories/files to suggest scopes
    [[ -d "api" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - api\n"
    [[ -d "auth" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - auth\n"
    [[ -d "components" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - components\n"
    [[ -d "pages" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - pages\n"
    [[ -d "models" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - models\n"
    [[ -d "routes" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - routes\n"
    [[ -d "services" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - services\n"
    [[ -d "utils" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - utils\n"
    [[ -f "Dockerfile" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - docker\n"
    [[ -d "k8s" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - k8s\n"
    [[ -d "terraform" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - terraform\n"

    if [[ -n "$DETECTED_SCOPES" ]]; then
        echo -e "${GREEN}Detected project scopes:${NC}"
        echo -e "$DETECTED_SCOPES"

        # Add to COMMIT_SCOPES.yml
        sed -i "/# Features/a\\$DETECTED_SCOPES" "$TARGET_DIR/.claude/COMMIT_SCOPES.yml"
    fi

    # Check if package.json exists for npm setup
    if [[ -f "package.json" ]]; then
        echo -e "${YELLOW}To complete commitlint setup:${NC}"
        echo "1. Install commitlint:"
        echo "   npm install --save-dev @commitlint/cli @commitlint/config-conventional"
        echo "2. Add to package.json scripts:"
        echo '   "commitlint": "commitlint --edit"'
        echo "3. Configure git hook:"
        echo "   npx husky add .husky/commit-msg 'npx commitlint --edit $1'"
    fi

    # For Python projects
    if [[ -f "pyproject.toml" ]]; then
        echo -e "${YELLOW}To complete commitlint setup:${NC}"
        echo "1. Install commitizen:"
        echo "   pip install commitizen"
        echo "2. Add to pyproject.toml:"
        echo "   [tool.commitizen]"
        echo "   name = 'cz_conventional_commits'"
        echo "3. Use 'cz commit' for interactive commits"
    fi

    echo -e "${GREEN}✓ Commit conventions configured${NC}"
    echo -e "${YELLOW}Remember to customize scopes in .claude/COMMIT_SCOPES.yml${NC}"
}

# Call after quality standards
setup_commitlint
```

### Success Criteria:

#### Automated Verification:

- [x] Scopes template exists: `ls templates/COMMIT_SCOPES.yml`
- [x] Commitlint config exists: `ls templates/.commitlintrc.yml`
- [x] Commit command updated: `grep -q "Commitlint Standards" templates/commands/commit.md`
- [x] Installer includes setup: `grep -q "setup_commitlint" install.sh`

#### Manual Verification:

- [ ] Install in test project
- [ ] COMMIT_SCOPES.yml populated with detected scopes
- [ ] Commit command uses conventional format
- [ ] Commitlint validates commit messages
- [ ] Invalid commits are rejected with clear errors

**Implementation Note**: Pause for manual verification before proceeding to Phase 5.

---

## Phase 5: Architectural Consultation Integration

### Overview

Integrate specialist agents into create_plan workflow with auto-detection and manual invocation.

### Changes Required:

#### 1. Create Specialist Integration Module

**File**: `templates/commands/modules/specialist-consultation.md`
**Changes**: Create reusable consultation module

```markdown
# Specialist Consultation Module

## Auto-Detection Logic

```python
def detect_specialist_triggers(changed_files, specialists_config):
    """
    Detect which specialists should be invoked based on file changes.

    Args:
        changed_files: List of modified file paths
        specialists_config: Parsed .claude-specialists.yml

    Returns:
        List of specialist names to invoke
    """
    triggered_specialists = []

    for specialist_name, config in specialists_config['specialists'].items():
        if not config.get('enabled', False):
            continue

        for pattern in config['auto_trigger_patterns']:
            if any(fnmatch(file, pattern) for file in changed_files):
                triggered_specialists.append(config['agent'])
                break

    return triggered_specialists
```

## Invocation Template

When invoking specialists, use this format:

```
Task(
  subagent_type="[specialist-name]",
  prompt="""
    Context: [Current task description]
    Changed files: [List of relevant files]
    Specific question: [What architectural guidance needed]

    Provide condensed guidance on:
    1. Recommended approach
    2. Key tradeoffs
    3. Implementation references from codebase
    4. Standards alignment

    Keep response under 2,000 tokens.
  """,
  description="[Domain] architecture consultation"
)
```

## Processing Specialist Output

After specialists complete:

1. **Extract recommendations** from each specialist
2. **Identify conflicts** between specialists
3. **Incorporate into plan** with attribution
4. **Note constraints** for implementation phase
5. **Reference standards** mentioned by specialists

## Integration Points

### In create_plan.md Step 2.5 (after research, before plan structure):

```markdown
#### Architectural Consultation

Check for specialist configuration:
```bash
if [[ -f ".claude-specialists.yml" ]]; then
    # Parse enabled specialists
    # Check changed files against patterns
    # Invoke matching specialists
fi
```

If specialists are triggered or manually requested:

**Auto-triggered specialists:**
Based on files that will be modified:
- [List of triggered specialists and why]

**Spawning consultations:**
[Multiple Task invocations in parallel]

**Wait for all specialists to complete**

**Process specialist guidance:**
- [Specialist 1]: [Key recommendation]
- [Specialist 2]: [Key recommendation]

**Architectural constraints for plan:**
- [Constraint from specialist]
- [Standard to follow]
```

### Manual Invocation

User can request specific specialist:
```
"Consult the docker specialist about this"
"Get mongodb guidance for this schema"
"What would the fastapi architect recommend?"
```

Respond with:
```
I'll consult the [specialist-name] for architectural guidance...

[Spawn Task with specialist agent]
```
```

#### 2. Update Create Plan Command - Final Integration

**File**: `templates/commands/create_plan.md`
**Changes**: Integrate consultation between Steps 2 and 3 (around line 142)

```markdown
### Step 2.5: Architectural Consultation (Optional)

If `.claude-specialists.yml` exists with enabled specialists:

1. **Detect triggers for consultation**:
   ```python
   # Read specialist configuration
   specialists_config = read_yaml('.claude-specialists.yml')

   # Identify files that will be modified based on research
   planned_changes = [files identified from research]

   # Check for auto-triggers
   triggered = detect_specialist_triggers(planned_changes, specialists_config)
   ```

2. **Announce consultations**:
   ```
   Based on the planned changes, I'll consult these specialists:
   - docker-specialist (triggered by Dockerfile changes)
   - fastapi-architect (triggered by routers/ changes)
   ```

3. **Spawn parallel consultations**:
   ```python
   consultations = []
   for specialist in triggered:
       consultations.append(
           Task(
               subagent_type=specialist,
               prompt=build_consultation_prompt(context, specialist),
               description=f"{specialist} consultation"
           )
       )

   # Execute all consultations in parallel
   results = await gather(*consultations)
   ```

4. **Process and incorporate guidance**:
   ```
   Architectural guidance received:

   **Docker Specialist:**
   - Multi-stage build recommended for 50% size reduction
   - Use build cache mounts for dependency layers
   - Reference: Current Dockerfile uses similar pattern at line 23

   **FastAPI Architect:**
   - Implement dependency injection for service layer
   - Use Pydantic models for validation
   - Reference: Similar endpoint at routers/users.py:45
   ```

5. **Note constraints for implementation**:
   These architectural decisions will be enforced during implementation:
   - [Specific constraint from specialist]
   - [Standard to maintain]
   - [Pattern to follow]

[Continue with Step 3: Plan Structure Development...]
```

#### 3. Add Specialist Detection Utility

**File**: `templates/utils/specialist-detector.sh`
**Changes**: Create bash utility for specialist detection

```bash
#!/bin/bash
# Specialist detection utility

detect_specialists() {
    local changed_files="$1"
    local config_file=".claude-specialists.yml"
    local triggered=""

    if [[ ! -f "$config_file" ]]; then
        return
    fi

    # Parse YAML and check patterns
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([a-z_]+): ]]; then
            current_specialist="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ enabled:[[:space:]]*true ]]; then
            specialist_enabled=true
        elif [[ "$line" =~ agent:[[:space:]]*(.+) ]]; then
            agent_name="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ -[[:space:]]*\"(.+)\" ]] && [[ "$specialist_enabled" == true ]]; then
            pattern="${BASH_REMATCH[1]}"

            # Check if any changed file matches pattern
            for file in $changed_files; do
                if [[ "$file" == $pattern ]]; then
                    triggered="$triggered $agent_name"
                    break
                fi
            done
        fi
    done < "$config_file"

    echo "$triggered" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Usage
if [[ "$#" -eq 1 ]]; then
    detect_specialists "$1"
fi
```

#### 4. Documentation Update

**File**: `docs/SPECIALISTS.md`
**Changes**: Create new documentation

```markdown
# Specialist Agents

Specialist agents provide domain-specific architectural consultation during the planning phase.

## Available Specialists

### Docker Specialist
- **Purpose**: Container infrastructure optimization
- **Triggers**: Dockerfile, docker-compose*.yml
- **Guidance**: Multi-stage builds, security, caching

### FastAPI Architect
- **Purpose**: API design and patterns
- **Triggers**: */routers/*.py, */api/*.py
- **Guidance**: Endpoints, validation, dependency injection

### MongoDB Specialist
- **Purpose**: Database schema and queries
- **Triggers**: *_mongo*.py, */models/mongo*.py
- **Guidance**: Schema design, aggregations, indexing

## Configuration

Enable specialists in `.claude-specialists.yml`:

```yaml
specialists:
  docker:
    enabled: true
    agent: docker-specialist
    auto_trigger_patterns:
      - "Dockerfile"
      - "docker-compose*.yml"
```

## Creating Custom Specialists

1. Copy `templates/agents/specialist-template.md`
2. Customize for your domain
3. Add to `.claude-specialists.yml`
4. Set auto-trigger patterns

## Integration with Planning

Specialists are invoked during `/create_plan`:
- Automatically when file patterns match
- Manually when requested
- Output incorporated into plan

## Token Budgets

All specialists operate under strict token limits:
- Maximum 2,000 tokens output
- Focus on key decisions only
- Reference existing code patterns

## Best Practices

1. **Enable selectively** - Only enable relevant specialists
2. **Customize triggers** - Adjust patterns for your project
3. **Reference standards** - Point specialists to your docs
4. **Review guidance** - Specialists advise, you decide
```

### Success Criteria:

#### Automated Verification:

- [ ] Consultation module exists: `ls templates/commands/modules/specialist-consultation.md`
- [ ] Create_plan updated: `grep -q "Architectural Consultation" templates/commands/create_plan.md`
- [ ] Detection utility exists: `ls templates/utils/specialist-detector.sh`
- [ ] Documentation exists: `ls docs/SPECIALISTS.md`
- [ ] Integration preserves existing flow

#### Manual Verification:

- [ ] Install with specialists enabled
- [ ] Auto-triggers activate correctly
- [ ] Manual invocation works
- [ ] Guidance incorporated into plans
- [ ] Token limits respected

**Implementation Note**: This completes the implementation plan. All phases should be tested together in an integrated test project.

---

## Testing Strategy

### Unit Tests:

- Specialist trigger detection with various file patterns
- Placeholder replacement in installer
- YAML configuration parsing
- Commit message validation

### Integration Tests:

- Full installation flow with all features
- Specialist invocation during planning
- Pre-commit workflow execution
- Quality standards enforcement

### Manual Testing Steps:

1. Install in fresh Python project with FastAPI
2. Enable all features during installation
3. Create a plan that triggers specialists
4. Implement plan with quality checks
5. Commit with pre-commit validation
6. Verify commitlint enforcement

## Performance Considerations

- Specialist agents use Opus model (higher cost/latency)
- Parallel invocation minimizes planning time
- Token limits prevent context explosion
- Optional features avoid overhead when not needed

## Phase 6: README Simplification

### Overview

Dramatically simplify the README to focus on core workflow, moving detailed documentation to separate files.

### Changes Required:

#### 1. Create Simplified README

**File**: `README.md`
**Changes**: Replace with concise version

```markdown
# Claude Dev Kit

Professional software development workflow powered by Claude.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/[org]/claude-dev-kit/main/install.sh | bash
```

## Core Workflow

The kit provides a structured development flow:

```
/research_codebase → /create_plan → /implement_plan → /validate_plan → /commit
```

### Essential Commands

| Command | Purpose |
|---------|---------|
| `/research_codebase` | Deep dive into codebase to understand implementation |
| `/create_plan` | Create detailed implementation plan with phases |
| `/implement_plan` | Execute plan phase-by-phase with validation |
| `/validate_plan` | Verify implementation meets all criteria |
| `/commit` | Create properly formatted commits |

### Additional Commands

| Command | Purpose |
|---------|---------|
| `/founder_mode` | Fast iteration without heavy process |
| `/describe_pr` | Generate PR descriptions |
| `/debug` | Debug helpers (logs, ports, etc) |
| `/local_review` | Local code review workflow |

## Philosophy

- **Research First**: Understand before implementing
- **Plan Thoroughly**: Think through approach before coding
- **Implement Systematically**: Follow the plan with checkpoints
- **Validate Everything**: Ensure quality before committing

## Examples

See `examples/` directory for detailed workflows:
- `examples/feature-development.md` - Standard feature workflow
- `examples/bug-fixing.md` - Debugging and fix workflow
- `examples/refactoring.md` - Large refactoring approach
- `examples/founder-mode.md` - Rapid prototyping

## Configuration

The installer detects your project type and configures automatically. Optional features:
- Specialist agents for architectural guidance
- Pre-commit validation workflows
- Code quality standards
- Commit conventions

See `docs/CUSTOMISATION.md` for customization options.

## Learn More

- [Installation Guide](docs/INSTALLATION.md)
- [Command Reference](docs/COMMANDS.md)
- [Agent Documentation](docs/AGENTS.md)
- [Customisation Guide](docs/CUSTOMISATION.md)
- [Team Adoption](docs/TEAM_ADOPTION.md)
```

#### 2. Create Example Files

**File**: `examples/feature-development.md`
**Changes**: Create detailed workflow example

```markdown
# Feature Development Workflow

This example shows developing a rate limiting feature.

## 1. Research Phase

```
You: /research_codebase
Assistant: Ready to research. What would you like to explore?
You: How does the current API middleware work? I need to add rate limiting.
```

The assistant will:
- Find all middleware files
- Analyze request flow
- Identify integration points
- Document findings in `thoughts/shared/research/`

## 2. Planning Phase

```
You: /create_plan
You: Add rate limiting to API endpoints. Max 100 requests per minute per user.
```

The assistant will:
- Research existing patterns
- Consult specialist agents if enabled
- Create phased implementation plan
- Get your approval before finalizing

## 3. Implementation Phase

```
You: /implement_plan thoughts/shared/plans/2025-01-15-rate-limiting.md
```

The assistant will:
- Implement phase by phase
- Run tests after each phase
- Pause for your verification
- Update plan checkboxes

## 4. Validation Phase

```
You: /validate_plan
```

The assistant will:
- Run all automated tests
- Verify success criteria
- Generate validation report
- List manual testing needed

## 5. Commit Phase

```
You: /commit
```

The assistant will:
- Review all changes
- Create logical commits
- Follow commit conventions
- Show commit history

## Complete Example

[Full conversation example with actual output]
```

**File**: `examples/founder-mode.md`
**Changes**: Create rapid iteration example

```markdown
# Founder Mode - Rapid Iteration

When you need to move fast without heavy process.

## What is Founder Mode?

Skip the ceremony, focus on shipping:
- No detailed plans
- Direct implementation
- Quick iterations
- Fast feedback loops

## When to Use

- Prototyping new ideas
- Quick fixes
- Exploratory coding
- Time-critical changes

## Example Usage

```
You: /founder_mode
You: Add a simple health check endpoint that returns server status
```

The assistant will:
- Skip research phase
- Jump straight to implementation
- Make it work first
- Refine if needed

## Transitioning Out

Once prototype is working:
```
You: /research_codebase
You: Let's understand what we just built and document it properly
```

Then create proper plan for production-ready version.
```

#### 3. Move Detailed Documentation

**File**: `docs/COMMANDS.md`
**Changes**: Move detailed command documentation here

```markdown
# Command Reference

Complete documentation for all claude-dev-kit commands.

## Research Commands

### /research_codebase
[Move detailed documentation from current README]

## Planning Commands

### /create_plan
[Move detailed documentation from current README]

## Implementation Commands

### /implement_plan
[Move detailed documentation from current README]

[Continue for all commands...]
```

### Success Criteria:

#### Automated Verification:

- [x] New README under 150 lines
- [x] Examples directory exists
- [x] Detailed docs available in docs/
- [x] Core workflow clearly presented
- [x] Quick start prominent

#### Manual Verification:

- [ ] README provides clear value proposition
- [ ] New user can understand workflow in 2 minutes
- [ ] Examples cover common scenarios
- [ ] Documentation is discoverable
- [ ] No information lost, just reorganized

---

## Migration Notes

For existing claude-dev-kit installations:
1. Re-run installer to add new features
2. Select optional agents from menu
3. Configure pre-commit if desired
4. No breaking changes to existing workflows

## References

- Original research: `thoughts/shared/research/2025-11-10-dendroh-enhancement-analysis.md`
- Current templates: `/Users/mpearmain/gitpackages/claude-dev-kit/templates/`
- Customisation guide: `docs/CUSTOMISATION.md`