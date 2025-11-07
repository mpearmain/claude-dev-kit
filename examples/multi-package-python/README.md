# Example: Multi-Package Python Project with uv

This example shows how the workflow handles Python projects with multiple packages in a monorepo structure.

## Project Structure

```
example-backend/
├── pyproject.toml          # Workspace configuration
├── uv.lock                 # Dependency lock file
├── src/
│   ├── api/                # FastAPI application
│   │   ├── __init__.py
│   │   ├── app.py
│   │   └── routes/
│   ├── auth/               # Authentication package
│   │   ├── __init__.py
│   │   ├── jwt.py
│   │   └── permissions.py
│   ├── utils/              # Shared utilities
│   │   ├── __init__.py
│   │   └── logging.py
│   └── models/             # Data models
│       ├── __init__.py
│       └── user.py
├── tests/
│   ├── api/
│   ├── auth/
│   └── utils/
└── .claude/
    ├── commands/
    └── agents/
```

## Installation Result

After running `./install.sh .` from the repository root:

```bash
$ cd claude-dev-kit
$ ./install.sh ../example-backend

Detecting project context...
  ✓ Detected Python project
  ✓ Detected uv package manager

Configuration:
Press Enter to accept detected defaults, or type custom values:

Project name [example-backend]:
Main source directory [src]:
Test command [uv run pytest]:
Lint command [uv run ruff check]:
Build command [uv build]:
Setup/install command [uv sync]:

Installing...
  ✓ Installed 10 commands
  ✓ Installed 6 agents
  ✓ Created thoughts/ structure
```

## How Agents Handle Multi-Package Structure

### Research Phase

When researching, agents search across ALL packages in `src/`:

```bash
> /research_codebase

> How does authentication work across the API and auth packages?
```

**Agent behavior**:
- `codebase-locator` searches in `src/api/` AND `src/auth/`
- Finds connections: API imports from auth
- Maps data flow across package boundaries
- Documents integration points

**Example findings**:
```markdown
### Authentication Flow

1. API Entry: `src/api/routes/users.py:15` imports `src/auth/jwt.py:validate_token`
2. JWT Validation: `src/auth/jwt.py:34-67` validates tokens
3. Permissions: `src/auth/permissions.py:12` checks user permissions
4. Models: `src/models/user.py:8` defines User model used across packages
```

### Planning Phase

Plans reference files across multiple packages:

```markdown
### Phase 1: Update Auth Package

**File**: `src/auth/jwt.py:34-67`
**Changes**: Add refresh token support...

**File**: `src/api/routes/auth.py:45`
**Changes**: Add refresh endpoint...

**File**: `tests/auth/test_jwt.py`
**Changes**: Add refresh token tests...
```

### Focused Work on Specific Package

While agents search across all packages, you can focus work by being specific in research questions:

```bash
# Broad research
> /research_codebase
> How does our API work?
# Agents search entire src/ directory

# Focused research
> /research_codebase
> How does the authentication JWT validation work in the auth package?
# Agents focus on src/auth/ but still see imports/usage
```

## Configuration

The installed commands use these values (from auto-detection):

```markdown
# In .claude/commands/*.md after installation

"research the example-backend codebase"
"look in src/ for relevant files"
"run uv run pytest to verify"
"run uv run ruff check for linting"
```

## Benefits of Multi-Package Support

1. **Cross-package research**: Agents find dependencies and integrations automatically
2. **Single workflow**: One set of commands for entire monorepo
3. **Consistent testing**: `uv run pytest` tests all packages
4. **Unified thoughts**: Research and plans in one `thoughts/` directory

## Alternative Structures Supported

The workflow also handles:

### Separate Package Directories
```
project/
├── packages/
│   ├── backend/
│   ├── shared/
│   └── cli/
```

Configure `MAIN_SRC_DIR=packages` during installation.

### Flat Structure
```
project/
├── api/
├── auth/
├── utils/
└── models/
```

Configure `MAIN_SRC_DIR=.` (current directory).

## Tips for Multi-Package Projects

1. **Be specific in research questions** when focusing on one package
2. **Let agents search broadly** to find cross-package dependencies
3. **Plan cross-package changes** in a single plan with multiple phases
4. **Test incrementally** - each package can have isolated tests
5. **Document integration points** in research documents

## Example Workflow

```bash
# Research authentication across API and auth packages
> /research_codebase
> How do the api and auth packages interact for user authentication?

# Plan changes to both packages
> /create_plan
> Add OAuth support to the auth package and update API endpoints

# Implement across packages
> /implement_plan thoughts/shared/plans/2025-01-15-oauth-support.md
# Phases cover changes to both src/auth/ and src/api/

# Validate entire system
> /validate_plan thoughts/shared/plans/2025-01-15-oauth-support.md
# Tests run across all packages
```

The workflow handles package boundaries intelligently while maintaining a single, cohesive development process.
