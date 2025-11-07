# Claude Code Workflow Templates

Production-ready templates for structured AI-assisted development with Claude Code. This repository provides a complete workflow system for maintaining context control, reproducibility, and high-quality implementation through a disciplined, phase-based process.

---

## Support This Project

If you find this workflow useful and it's helping you build better software, consider buying me a coffee! Your support helps maintain and improve these templates.

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow.svg?style=flat&logo=buy-me-a-coffee)](https://www.buymeacoffee.com/mpearmain)

Every contribution, no matter how small, is greatly appreciated and motivates continued development of helpful tools for the community. Thank you! ☕

---

## Quick Start

```bash
# Clone this repository
git clone https://github.com/mpearmain/claude-dev-kit.git

# Install into your project
cd claude-dev-kit
./install.sh ../your-project

# Start using
cd ../your-project
claude
> /research_codebase
```

## What This Provides

A four-phase workflow for structured development:

1. **Research** (`/research_codebase`) - Understand codebase, dependencies, and implementation context
2. **Plan** (`/create_plan`) - Create detailed step-by-step implementation plans
3. **Implement** (`/implement_plan`) - Execute plans in discrete sub-phases with validation
4. **Validate** (`/validate_plan`) - Verify implementation via automated and manual tests

Plus supporting commands for commits, PRs, debugging, and Linear integration.

## Installation

### Prerequisites

- Bash shell
- Git repository (recommended)
- Claude Code installed

### Interactive Installation (Recommended)

The installer auto-detects your project type and suggests sensible defaults:

```bash
./install.sh /path/to/your/project
```

You'll be prompted to confirm or customize:
- Project name (detected from directory/git)
- Source directory (detected from project structure)
- Test command (detected from package manager)
- Lint, build, and setup commands

### Non-Interactive Installation

Use environment variables for automation:

```bash
cd claude-dev-kit
./install.sh ../your-project --non-interactive
```

### What Gets Installed

```
your-project/
├── .claude/
│   ├── commands/          # 10 workflow slash commands
│   │   ├── research_codebase.md
│   │   ├── create_plan.md
│   │   ├── implement_plan.md
│   │   ├── validate_plan.md
│   │   ├── commit.md
│   │   ├── describe_pr.md
│   │   ├── linear.md
│   │   ├── local_review.md
│   │   ├── debug.md
│   │   └── founder_mode.md
│   └── agents/            # 6 specialized agents
│       ├── codebase-analyzer.md
│       ├── codebase-locator.md
│       ├── codebase-pattern-finder.md
│       ├── thoughts-analyzer.md
│       ├── thoughts-locator.md
│       └── web-search-researcher.md
├── thoughts/
│   ├── shared/            # Team artefacts (commit to git)
│   │   ├── research/      # Research documents
│   │   ├── plans/         # Implementation plans
│   │   └── prs/           # PR descriptions
│   ├── searchable/        # Auto-generated index (gitignored)
│   ├── .gitignore
│   └── README.md
└── [your existing project files]
```

## Supported Project Types

The installer automatically detects and configures for:

| Type | Detection | Defaults |
|------|-----------|----------|
| **Python + uv** | `uv.lock` | `uv run pytest`, `uv run ruff check` |
| **Python + Poetry** | `poetry.lock` | `poetry run pytest`, `poetry run ruff check` |
| **Python (standard)** | `pyproject.toml` | `pytest`, `ruff check` |
| **Node.js + pnpm** | `pnpm-lock.yaml` | `pnpm test`, `pnpm run lint` |
| **Node.js + Yarn** | `yarn.lock` | `yarn test`, `yarn lint` |
| **Node.js + npm** | `package.json` | `npm test`, `npm run lint` |
| **Go** | `go.mod` | `go test ./...`, `golangci-lint run` |
| **Rust** | `Cargo.toml` | `cargo test`, `cargo clippy` |
| **Terraform** | `main.tf` | `terraform validate`, `tflint` |

## Worked Example: Adding API Rate Limiting

This example demonstrates the complete workflow for a real feature implementation.

### Phase 1: Research

```bash
$ claude
> /research_codebase

I'm ready to research the your-project codebase. Please provide your research question.

> How does our current API authentication work? Where would rate limiting fit?

Analyzing and decomposing question using MECE principle...
- Dimension 1 (WHERE): Locate authentication files and middleware
- Dimension 2 (HOW): Understand authentication implementation
- Dimension 3 (WHAT): Find middleware patterns to follow

Spawning 3 agents in parallel:
✓ codebase-locator searching for auth files
✓ codebase-analyzer examining middleware implementation
✓ codebase-pattern-finder looking for middleware patterns

Waiting for all agents to complete... [10 seconds]

Synthesizing findings and identifying convergence...
```

**What happens:**
- **MECE decomposition**: Breaks research into orthogonal dimensions (WHERE, HOW, WHAT)
- **Parallel agents**: 3 Claude agents work simultaneously on different aspects
- **Convergence detection**: Identifies files found by multiple agents
- **Optional Gemini validation**: If installed, adds independent verification
- **Synthesis**: Highlights high-confidence findings

**Output:** `thoughts/shared/research/2025-01-15-api-auth-and-rate-limiting.md`

```markdown
---
date: 2025-01-15T10:23:00Z
researcher: mpearmain
git_commit: abc123
topic: "API Authentication and Rate Limiting Integration"
tags: [research, api, authentication, middleware]
---

# Research: API Authentication and Rate Limiting Integration

## Summary
Current API uses JWT middleware in `src/api/middleware/auth.py:15-45`.
Rate limiting would integrate at the same middleware layer...

## High-Confidence Findings (Convergent)

### src/api/middleware/auth.py - Found by 3 agents
- **codebase-locator**: File search for "middleware" → found as primary auth middleware
- **codebase-analyzer**: Import analysis from `src/api/app.py` → identified as critical component
- **pattern-finder**: Middleware pattern search → found implementing FastAPI middleware pattern
- **Significance**: Core authentication logic. Rate limiting must integrate with this stack.

### src/api/app.py - Found by 2 agents
- **codebase-locator**: Entry point search → FastAPI application setup
- **codebase-analyzer**: Middleware registration analysis → stack definition
- **Significance**: Middleware order defined here. Rate limiting added here.

## Detailed Findings

### Authentication Flow
- Entry point: `src/api/app.py:23` - FastAPI application setup
- JWT middleware: `src/api/middleware/auth.py:15-45`
- Token validation: `src/auth/jwt.py:67-89`

### Middleware Stack
Current order: CORS → Auth → Routes
Proposed: CORS → RateLimit → Auth → Routes

...
```

**Key insight**: Multiple agents converging on `auth.py` from different searches = validated architectural bottleneck.

### Phase 2: Plan

```bash
> /create_plan

I'll help you create a detailed implementation plan. Let me start by
understanding what we're building...

> Let's add rate limiting to our API. Use the research from 2025-01-15.
```

**What happens:**
- Reads research document
- Spawns agents to find similar patterns in codebase
- Interactive planning with you
- Creates detailed phase-by-phase plan

**Output:** `thoughts/shared/plans/2025-01-15-api-rate-limiting.md`

```markdown
# API Rate Limiting Implementation Plan

## Overview
Add Redis-backed rate limiting middleware to FastAPI application.

## Implementation Phases

### Phase 1: Redis Client Setup
**File**: `src/config/redis.py`
**Changes**: Create Redis connection pool...

### Success Criteria:
#### Automated Verification:
- [ ] Tests pass: `uv run pytest tests/test_redis.py`
- [ ] Type checking passes: `uv run mypy src/config/redis.py`

#### Manual Verification:
- [ ] Redis connection successful in development
- [ ] Connection pool size appropriate for load

**Implementation Note**: Pause after automated verification passes for
manual confirmation before proceeding to Phase 2.

### Phase 2: Rate Limit Middleware
...
```

### Phase 3: Implement

```bash
> /implement_plan thoughts/shared/plans/2025-01-15-api-rate-limiting.md
```

**What happens:**
- Reads plan file
- Implements Phase 1
- Runs automated tests
- Pauses for your manual verification
- Continues to Phase 2 only after confirmation

**Validation at each phase:**
```
Phase 1 automated verification:
✓ uv run pytest tests/test_redis.py - PASSED
✓ uv run mypy src/config/redis.py - OK

Ready for manual verification. Confirm to proceed to Phase 2? (y/n)
```

### Phase 4: Validate

```bash
> /validate_plan thoughts/shared/plans/2025-01-15-api-rate-limiting.md
```

**What happens:**
- Runs all automated tests from plan
- Generates validation report
- Lists manual verification checklist

**Output:** `thoughts/shared/plans/2025-01-15-api-rate-limiting-validation.md`

### Additional Commands

```bash
# Commit with structured message
> /commit

# Generate PR description
> /describe_pr

# Review changes before committing
> /local_review

# Debug issues
> /debug
```

## Core Workflow Principles

### 60% Context Rule
Never exceed roughly 60% of the context window. The workflow enforces this by:
- Spawning parallel agents for research
- Storing results in `thoughts/` files
- Referencing files instead of copying content

### Context Reset Between Phases
Clear context between major phases:
```bash
# After research
> /clear

# Start planning fresh
> /create_plan
```

### File References Over Copying
Commands reference saved files:
```bash
# Bad: Pasting entire research document
> /create_plan [paste 500 lines]

# Good: Reference the file
> /create_plan thoughts/shared/research/2025-01-15-api-auth.md
```

### Repeatable Artefacts
Each phase produces versioned files in `thoughts/shared/`:
- Research: `YYYY-MM-DD-topic.md`
- Plans: `YYYY-MM-DD-feature.md` or `YYYY-MM-DD-TICKET-1234-feature.md`
- PRs: Auto-generated from plans and commits

## Multi-Project Setup

For organizations with multiple repositories (e.g., backend, frontend, infrastructure):

```bash
# Install in each project independently
cd my-backend
../claude-dev-kit/install.sh .

cd ../my-frontend
../claude-dev-kit/install.sh .

cd ../my-infra
../claude-dev-kit/install.sh .
```

Each project gets:
- Customized commands for its technology (Python/Node/Terraform)
- Independent `thoughts/` directory
- Project-specific configuration

**Benefits:**
- Each project has appropriate defaults (pytest vs npm test)
- Research and plans stay in relevant repository
- Projects can diverge and customize templates
- No shared dependencies between projects

### Multi-Package Projects (Python uv workspaces)

For projects with structure like:
```
my-backend/
├── src/
│   ├── api/
│   ├── auth/
│   └── utils/
```

The installer configures `MAIN_SRC_DIR=src` and agents will search across all packages. For focused work on a specific package, context in your research/plan files guides agent attention.

## Customization

### Editing Installed Commands

All commands are markdown files in `.claude/commands/`. Edit directly:

```bash
# Example: Customize test command for specific needs
vim .claude/commands/validate_plan.md

# Change:
{{TEST_COMMAND}}

# To:
uv run pytest -v --cov=src tests/
```

### Adding Custom Commands

Create new `.md` files in `.claude/commands/`:

```markdown
# My Custom Command

Description of what this command does...

## Steps
1. Do something
2. Do something else
```

Access with: `/my_custom_command`

### Modifying Agents

Agents are defined in `.claude/agents/*.md` with YAML frontmatter:

```markdown
---
name: my-custom-agent
description: Does specialized analysis
tools: Grep, Read, Glob
model: sonnet
---

Agent instructions here...
```

## Git Integration

### What to Commit

```gitignore
# Commit these
.claude/
thoughts/shared/
thoughts/README.md
thoughts/.gitignore

# Don't commit these
thoughts/searchable/    # Auto-generated index
thoughts/personal/      # Private notes (optional)
```

The installer creates `thoughts/.gitignore` automatically.

### Workflow in Practice

```bash
# Research and plan happen in feature branch
git checkout -b feature/rate-limiting
claude
> /research_codebase
> /create_plan
git add thoughts/shared/research/ thoughts/shared/plans/
git commit -m "Research and plan for rate limiting"

# Implementation
> /implement_plan thoughts/shared/plans/2025-01-15-rate-limiting.md
# (makes code changes)

# Commit with structured message
> /commit

# Generate PR
> /describe_pr
git push origin feature/rate-limiting
# Use generated PR description
```

## Advanced Usage

### Context Management

Monitor context usage and reset when needed:
```bash
# Check context in Claude Code
> /context

# If over 60%, save state and reset
> /clear

# Continue with file references
> /implement_plan thoughts/shared/plans/2025-01-15-feature.md
```

### Specialized Agents

Agents run autonomously for specific tasks:

- **codebase-locator** - Finds WHERE code lives (files, directories)
- **codebase-analyzer** - Understands HOW code works (implementation details)
- **codebase-pattern-finder** - Finds examples of patterns
- **thoughts-locator** - Discovers existing research/plans
- **thoughts-analyzer** - Extracts insights from documents
- **web-search-researcher** - Gathers external documentation (when requested)

Commands spawn these automatically, but you can also invoke directly in Claude Code.

### Linear Integration

If using Linear for issue tracking:

```bash
> /linear

# Search tickets, create from plans, sync status
```

Configure Linear API token in your environment.

### Optional Enhancements

#### Gemini CLI Integration

**Why use Gemini with Claude?**

Gemini provides **independent validation** through **model diversity**. When Claude's agents converge on a finding, having Gemini independently verify from a different model perspective increases confidence exponentially.

**The principle**: Random errors don't align across different models. Convergent findings across Claude + Gemini = validated architectural signal.

**Installation**:

```bash
# Install Gemini CLI (optional)
# See: https://github.com/google-gemini/gemini-cli

# Installer detects availability
./install.sh /path/to/project
# Output: ✓ Detected Gemini CLI (optional enhanced analysis available)
```

**Strategic Economics**:

Most users have:
- **Claude MAX**: Unlimited usage
- **Gemini FREE**: ~1500 requests/day, rate limited

Strategy: Claude orchestrates (unlimited), Gemini validates (limited quota).

**When to Use Gemini**:

1. **Validate convergent findings** (best use)
   ```
   Claude agents converge on src/auth.py as critical bottleneck
   → Spawn gemini-analyzer to independently verify
   → If Gemini agrees = high-confidence architectural signal
   ```

2. **Quick feasibility checks** before planning
   ```
   > /research_codebase + gemini quick-check
   → Gemini: "Project configured correctly, no obvious blockers"
   → Proceed with planning
   ```

3. **Pattern searching in large directories**
   ```
   > /research_codebase
   → gemini pattern-search for "deprecated API usage"
   → Returns file list with line numbers
   → Claude agents analyze specific files
   ```

4. **Alternative perspective on architecture**
   ```
   Claude: "Middleware stack has coupling issues"
   Gemini: "State management creates temporal coupling"
   → Different models, same conclusion = validated
   ```

**When NOT to Use Gemini**:

- Every research task (wastes quota)
- Detailed implementation analysis (Claude is better with tools)
- Time-critical work (Gemini can be slower)
- When quota exhausted (workflow continues without it)

**Practical Example**:

```bash
> /research_codebase
> How does authentication work?

# Claude spawns 3 agents in parallel:
# 1. codebase-locator → finds auth files
# 2. codebase-analyzer → understands implementation
# 3. gemini-analyzer (if available) → independent validation

# Results converge on src/api/middleware/auth.py
# Confidence: HIGH (3 agents, including different model)
```

**Output with Gemini**:

```markdown
## High-Confidence Findings (Convergent)

### src/api/middleware/auth.py - Found by 3 agents (multi-model)
- **codebase-locator (Claude)**: File search for "middleware"
- **codebase-analyzer (Claude)**: Import analysis
- **gemini-analyzer (Gemini)**: Independent architecture scan
- **Significance**: Cross-model convergence = validated bottleneck
```

**Cost Management**:

```bash
# Gemini usage is tracked per-day
# Free tier: ~1500 requests/day
# Strategy: 2-3 Gemini calls per research task maximum

# Research task (typical):
# - Claude agents: 3-5 parallel (unlimited)
# - Gemini: 1-2 validation checks (counted against quota)
# - Cost: ~0.1-0.2% of daily Gemini quota per task
```

**Graceful Degradation**:

Workflow continues seamlessly if Gemini unavailable:

```bash
# Gemini not installed
⚠️  Gemini CLI not installed. Continuing with Claude-only analysis.
# Research proceeds normally

# Gemini quota exceeded
⚠️  Gemini quota exceeded. Skipping Gemini validation.
# Research proceeds with Claude agents only
```

**Installation**:

See: https://github.com/google-gemini/gemini-cli

```bash
# Install Gemini CLI
npm install -g @google/generative-ai-cli

# Or via pip
pip install google-generativeai-cli

# Configure API key
gemini config set api-key YOUR_API_KEY
```

#### Convergence Validation

When multiple agents independently find the same file/component:

```markdown
## High-Confidence Findings (Convergent)

### src/auth/middleware.py - Found by 3 agents
- **codebase-locator**: File search for "auth"
- **codebase-analyzer**: Import analysis from routes
- **pattern-finder**: Middleware pattern search
- **Significance**: Core authentication logic, high coupling
```

Convergent findings = validated signal, not coincidence.

#### MECE Decomposition

Research uses Mutually Exclusive, Collectively Exhaustive decomposition:

- **Mutually Exclusive**: Each agent analyzes different dimension (WHERE vs HOW vs WHAT)
- **Collectively Exhaustive**: Cover all relevant areas

This prevents redundant work and ensures thorough coverage.

## Troubleshooting

### Installer Issues

**Templates not found:**
```bash
# Ensure you're running from claude-dev-kit directory
cd /path/to/claude-dev-kit
./install.sh ../target-project
```

**Placeholder not replaced:**
Check `.claude/commands/*.md` files. If `{{VARIABLE}}` still present, the installer didn't run properly. Re-run:
```bash
./install.sh --force .
```

### Command Issues

**Command not found:**
```bash
# List available commands
ls .claude/commands/

# Ensure Claude Code can find them
claude --list-commands
```

**Wrong configuration:**
Edit commands directly in `.claude/commands/*.md` to fix test commands, paths, etc.

## Updates and Versioning

Projects diverge by design. Templates are starting points, not shared dependencies.

To update templates in an existing project:
1. Review changes in this repository
2. Manually update relevant `.claude/commands/*.md` files
3. Or re-run installer with `--force` (overwrites customizations)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Proposing new templates
- Testing template changes
- Submitting improvements

## Examples

See `examples/` directory for:
- Complete worked examples with all artefacts
- Multi-package Python project setup
- Language-specific configurations

## Documentation

- [Placeholder Reference](docs/PLACEHOLDERS.md) - All variables and detection
- [Customization Guide](docs/CUSTOMISATION.md) - Editing templates and agents
- [Team Adoption](docs/TEAM_ADOPTION.md) - Onboarding and best practices
- [Gemini Integration](docs/GEMINI_INTEGRATION.md) - Complete guide to multi-model validation

## Philosophy

This workflow structures collaboration between developers and AI systems. It enforces discipline in context management, creates persistent artefacts for each development phase, and enables reproducibility across projects and teams.

**Key insight**: AI-assisted development requires *more* structure, not less. These templates provide that structure while remaining flexible enough to customize for any project.
