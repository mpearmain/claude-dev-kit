# Placeholder Reference

This document describes all placeholders used in templates and how they are detected/replaced during installation.

## Overview

Templates contain placeholder variables in the format `{{VARIABLE_NAME}}`. During installation, the `install.sh` script:

1. Auto-detects values based on project structure
2. Prompts for confirmation or custom values
3. Replaces all placeholders in `.claude/commands/*.md` and `.claude/agents/*.md`

## Complete Placeholder List

### {{PROJECT_NAME}}

**Description**: Name of the project being developed

**Auto-detection**:
1. Git repository name: `basename $(git rev-parse --show-toplevel)`
2. Directory name: `basename $PWD`

**Used in**: All commands and agents

**Example values**:
- `my-backend`
- `my-api-service`
- `react-frontend`

**Usage in templates**:
```markdown
"research the {{PROJECT_NAME}} codebase"
"I'm analyzing {{PROJECT_NAME}} to understand..."
```

---

### {{MAIN_SRC_DIR}}

**Description**: Primary source code directory

**Auto-detection**:
- Python projects: `src`
- Node.js projects: `src`
- Go projects: `.` (current directory)
- Rust projects: `src`
- Terraform: `modules`

**Used in**: Research, plan, and implement commands

**Example values**:
- `src`
- `lib`
- `pkg`
- `modules`
- `.` (for Go)

**Usage in templates**:
```markdown
"look in {{MAIN_SRC_DIR}}/ for relevant files"
"search {{MAIN_SRC_DIR}}/ directory for..."
```

---

### {{TEST_COMMAND}}

**Description**: Command to run project tests

**Auto-detection by project type**:
- Python + uv: `uv run pytest`
- Python + Poetry: `poetry run pytest`
- Python (standard): `pytest`
- Node.js + pnpm: `pnpm test`
- Node.js + Yarn: `yarn test`
- Node.js + npm: `npm test`
- Go: `go test ./...`
- Rust: `cargo test`
- Terraform: `terraform validate`

**Used in**: Validate and implement commands

**Example values**:
- `uv run pytest`
- `npm test`
- `cargo test`
- `go test ./...`

**Usage in templates**:
```markdown
"run {{TEST_COMMAND}} to verify"
"execute {{TEST_COMMAND}} and check output"
```

---

### {{LINT_COMMAND}}

**Description**: Command to run linting/code quality checks

**Auto-detection by project type**:
- Python + uv: `uv run ruff check`
- Python + Poetry: `poetry run ruff check`
- Python (standard): `ruff check`
- Node.js + pnpm: `pnpm run lint`
- Node.js + Yarn: `yarn lint`
- Node.js + npm: `npm run lint`
- Go: `golangci-lint run`
- Rust: `cargo clippy`
- Terraform: `tflint`

**Used in**: Validate command

**Example values**:
- `uv run ruff check`
- `npm run lint`
- `cargo clippy`

**Usage in templates**:
```markdown
"run {{LINT_COMMAND}} for linting"
"execute {{LINT_COMMAND}} and fix any issues"
```

---

### {{BUILD_COMMAND}}

**Description**: Command to build/compile the project

**Auto-detection by project type**:
- Python + uv: `uv build`
- Python + Poetry: `poetry build`
- Python (standard): `python -m build`
- Node.js + pnpm: `pnpm run build`
- Node.js + Yarn: `yarn build`
- Node.js + npm: `npm run build`
- Go: `go build ./...`
- Rust: `cargo build`
- Terraform: `terraform plan`

**Used in**: Validate command

**Example values**:
- `uv build`
- `npm run build`
- `cargo build --release`

**Usage in templates**:
```markdown
"run {{BUILD_COMMAND}} to compile"
"execute {{BUILD_COMMAND}} successfully"
```

---

### {{SETUP_COMMAND}}

**Description**: Command to install dependencies/setup environment

**Auto-detection by project type**:
- Python + uv: `uv sync`
- Python + Poetry: `poetry install`
- Python (standard): `pip install -e .`
- Node.js + pnpm: `pnpm install`
- Node.js + Yarn: `yarn install`
- Node.js + npm: `npm install`
- Go: `go mod download`
- Rust: `cargo fetch`
- Terraform: `terraform init`

**Used in**: Implementation commands

**Example values**:
- `uv sync`
- `npm install`
- `go mod download`

**Usage in templates**:
```markdown
"run {{SETUP_COMMAND}} to install dependencies"
"execute {{SETUP_COMMAND}} if needed"
```

---

## Detection Logic

The installer uses this detection sequence:

### 1. Check for Lock Files (Most Specific)

```bash
if [[ -f "uv.lock" ]]; then
    # Python + uv detected
elif [[ -f "poetry.lock" ]]; then
    # Python + Poetry detected
elif [[ -f "pnpm-lock.yaml" ]]; then
    # Node.js + pnpm detected
# ... etc
```

### 2. Check for Configuration Files

```bash
if [[ -f "pyproject.toml" ]]; then
    # Python project
elif [[ -f "package.json" ]]; then
    # Node.js project
elif [[ -f "go.mod" ]]; then
    # Go project
# ... etc
```

### 3. Use Generic Defaults

If no specific detection matches:
```bash
MAIN_SRC_DIR="src"
TEST_COMMAND="make test"
LINT_COMMAND="make lint"
BUILD_COMMAND="make build"
SETUP_COMMAND="make install"
```

## Customizing Detected Values

### During Installation

When prompted, modify any detected value:

```bash
Project name [my-backend]: my-custom-name
Main source directory [src]: lib/src
Test command [uv run pytest]: uv run pytest -v --cov
```

### After Installation

Edit `.claude/commands/*.md` files directly:

```bash
# Original (after installation)
run uv run pytest to verify

# Customized
run uv run pytest -v --cov=src --cov-report=html to verify
```

## Adding Custom Placeholders

To add project-specific placeholders:

### 1. Define in Commands

Create custom placeholder in command files:

```markdown
# .claude/commands/my_custom_command.md
Run {{MY_CUSTOM_TOOL}} to analyze the code
```

### 2. Document Values

Create `.claude/config.json` to document:

```json
{
  "MY_CUSTOM_TOOL": "custom-analyzer --verbose"
}
```

### 3. Replace Manually

Since these aren't in `install.sh`, replace manually or add to installer.

## Troubleshooting

### Placeholder Not Replaced

**Symptom**: See `{{PROJECT_NAME}}` in installed commands

**Solution**:
```bash
# Re-run installer with force flag
./install.sh --force /path/to/project
```

### Wrong Detection

**Symptom**: Incorrect commands detected (e.g., npm instead of pnpm)

**Solution**:
1. During installation, override detected values
2. Or edit `.claude/commands/*.md` after installation

### Custom Project Structure

**Symptom**: Standard detection doesn't match your setup

**Solution**:
1. Run installer with defaults
2. Edit `.claude/commands/*.md` to customize
3. Update `MAIN_SRC_DIR` paths as needed

## Best Practices

1. **Accept defaults first**: Try auto-detected values before customizing
2. **Document changes**: If you customize, document in project README
3. **Team consistency**: Share customized commands in git
4. **Minimal customization**: Only change what's necessary
5. **Test after changes**: Verify commands work after customization

## Reference Implementation

See `install.sh:detect_project_context()` for complete detection logic.

See `install.sh:replace_placeholders()` for replacement implementation.
