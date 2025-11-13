# Customization Guide

This guide covers how to customize installed templates for project-specific needs.

## Philosophy

Templates are **starting points**, not rigid requirements. Customize freely to match your workflow, team practices, and project structure.

## What Can Be Customized

1. **Commands** - Modify workflow phase behavior
2. **Agents** - Adjust specialized agent instructions
3. **Directory structure** - Change `thoughts/` organization
4. **Success criteria** - Add project-specific validation

## Editing Commands

Commands live in `.claude/commands/*.md` as markdown files.

### Basic Command Structure

```markdown
# Command Name

Description of what this command does...

## Steps to follow:

1. First step
2. Second step
3. Third step

## Important notes:
- Note 1
- Note 2
```

### Example: Customize Test Command

**File**: `.claude/commands/validate_plan.md`

**Original**:
```markdown
- [ ] Tests pass: uv run pytest
```

**Customized for coverage**:
```markdown
- [ ] Tests pass with coverage: uv run pytest --cov=src --cov-report=html tests/
- [ ] Coverage above 80%: Check htmlcov/index.html
```

### Example: Add Pre-commit Hooks

**File**: `.claude/commands/commit.md`

**Add before commit creation**:
```markdown
## Before committing:

1. Run pre-commit hooks:
   ```bash
   pre-commit run --all-files
   ```

2. If hooks fail, fix issues and re-stage:
   ```bash
   git add .
   ```

3. Then proceed with commit...
```

### Example: Project-Specific Research

**File**: `.claude/commands/research_codebase.md`

**Add domain-specific patterns**:
```markdown
## Project-specific patterns to research:

### GraphQL Schema
- Look for `*.graphql` files in `src/schema/`
- Check resolver implementations in `src/resolvers/`
- Document type definitions and relationships

### Database Models
- Check SQLAlchemy models in `src/models/`
- Document table relationships
- Note migration files in `alembic/versions/`
```

## Editing Agents

Agents live in `.claude/agents/*.md` with YAML frontmatter.

### Agent Structure

```markdown
---
name: agent-name
description: Brief description
tools: Grep, Read, Glob
model: sonnet
---

Agent instructions...
```

### Example: Customize Codebase Locator

**File**: `.claude/agents/codebase-locator.md`

**Add project-specific search patterns**:
```markdown
## Project-Specific Patterns

### For this project, also check:
- GraphQL schema files: `*.graphql`
- Protobuf definitions: `*.proto`
- Database migrations: `alembic/versions/*.py`
- Configuration files: `config/*.yaml`
```

### Example: Add Custom Agent

**File**: `.claude/agents/database-analyzer.md` (new)

```markdown
---
name: database-analyzer
description: Analyzes database schema and migrations
tools: Read, Grep, Glob
model: sonnet
---

You are a specialist at analyzing database schemas and migrations.

## Your job:

1. Find database models and schema definitions
2. Map relationships between tables
3. Identify migration files and history
4. Document data flow and constraints

## Search patterns:

- SQLAlchemy models: `src/models/*.py`
- Migrations: `alembic/versions/*.py`
- Schema definitions: `*.sql` files
- Database config: Look for DATABASE_URL, connection strings

## Output format:

### Database Schema
- Table: users (src/models/user.py:10)
  - Columns: id, email, created_at
  - Relationships: has_many posts

...
```

## Specialist Auto-Trigger Patterns

Specialist agents can be automatically activated when you work on files matching specific patterns. This is configured in `.claude/.claude-specialists.yml`.

### How Auto-Triggers Work

When enabled, specialists activate based on file path patterns:

**Example**: Docker Specialist activates when editing:
- `Dockerfile`
- `docker-compose.yml`, `docker-compose.dev.yml`, etc.
- `.dockerignore`
- Any file in `*/containers/*` directories

### Configuration File Structure

**File**: `.claude/.claude-specialists.yml`

```yaml
specialists:
  docker:
    enabled: false                    # Set to true to enable
    agent: docker-specialist          # Agent file to activate
    auto_trigger_patterns:            # File patterns that trigger this agent
      - "Dockerfile"
      - "docker-compose*.yml"
      - ".dockerignore"
      - "*/containers/*"
```

### Default Trigger Patterns

The installer configures these default patterns:

| Specialist | Triggers On |
|---|---|
| **docker-specialist** | `Dockerfile`, `docker-compose*.yml`, `.dockerignore`, `*/containers/*` |
| **api-architect** | `*/api/*`, `*/routes/*`, `*/endpoints/*`, `*/controllers/*`, `*/graphql/*` |
| **database-specialist** | `*/models/*`, `*/schemas/*`, `*/migrations/*`, `*.sql`, `*/db/*` |
| **security-advisor** | `*/auth/*`, `*/security/*`, `*/permissions/*`, `*crypto*` |
| **performance-analyst** | `*/cache/*`, `*/optimization/*`, `*worker*`, `*queue*` |
| **testing-strategist** | `*/tests/*`, `*/test/*`, `*spec.js`, `*test.py` |

### Enabling Specialists

Set `enabled: true` for specialists you want to use:

```yaml
specialists:
  docker:
    enabled: true    # Now active for Docker-related files
    agent: docker-specialist
    auto_trigger_patterns:
      - "Dockerfile"
      - "docker-compose*.yml"
```

### Customizing Trigger Patterns

Add project-specific patterns to match your directory structure:

```yaml
specialists:
  api:
    enabled: true
    agent: api-architect
    auto_trigger_patterns:
      - "*/api/*"
      - "*/routes/*"
      - "*/endpoints/*"
      - "*/controllers/*"
      - "*/graphql/*"
      - "*/services/api-*"         # Add custom pattern
      - "*/backend/handlers/*"      # Add another pattern
```

### Pattern Syntax

Patterns use glob-style matching:
- `*` matches any characters within a directory
- `*/directory/*` matches any file in that directory at any depth
- `*.ext` matches any file with that extension
- `prefix*` matches files starting with prefix

### Adding Custom Specialists

1. Create agent file: `.claude/agents/custom-specialist.md`
2. Add configuration to `.claude/.claude-specialists.yml`:

```yaml
specialists:
  custom:
    enabled: true
    agent: custom-specialist
    auto_trigger_patterns:
      - "*/your-directory/*"
      - "*.your-extension"
```

### Disabling Auto-Triggers

Set `enabled: false` or remove patterns:

```yaml
specialists:
  docker:
    enabled: false    # Won't auto-trigger
    agent: docker-specialist
    auto_trigger_patterns: []    # Or clear patterns
```

### Testing Trigger Patterns

After customizing, verify patterns match expected files:

```bash
# List files that would trigger Docker specialist
find . -name "Dockerfile" -o -name "docker-compose*.yml"

# Check if your custom pattern matches
find . -path "*/your-directory/*"
```

### Best Practices

1. **Start conservative** - Enable only specialists you actively need
2. **Narrow patterns** - Use specific patterns to avoid false triggers
3. **Test in isolation** - Enable one specialist at a time initially
4. **Review performance** - Too many auto-triggers may slow workflow
5. **Document customizations** - Comment why you changed patterns

### Troubleshooting

**Specialist not triggering:**
- Check `enabled: true` is set
- Verify file path matches pattern exactly
- Test pattern with `find` command
- Check agent file exists at specified path

**Too many triggers:**
- Narrow patterns to specific directories
- Use exact filenames instead of wildcards
- Disable specialists not relevant to project

## Customizing Directory Structure

### Default Structure

```
thoughts/
├── shared/
│   ├── research/
│   ├── plans/
│   └── prs/
├── searchable/
└── personal/ (optional)
```

### Custom Structures

#### Feature-Based Organization

```
thoughts/
├── shared/
│   ├── features/
│   │   ├── authentication/
│   │   │   ├── research.md
│   │   │   ├── plan.md
│   │   │   └── pr.md
│   │   └── rate-limiting/
│   └── architecture/
```

Update commands to reference new structure:
```markdown
# In create_plan.md
Filename: `thoughts/shared/features/{feature-name}/plan.md`
```

#### Team Member Directories

```
thoughts/
├── shared/          # Team artefacts
├── alice/           # Alice's work
├── bob/             # Bob's work
└── searchable/
```

Update `.gitignore` if needed:
```gitignore
thoughts/*/          # Ignore personal directories
!thoughts/shared/    # But keep shared
```

## Success Criteria Customization

### Add Project-Specific Checks

**In validate_plan.md**:

```markdown
### Success Criteria:

#### Automated Verification:
- [ ] Unit tests pass: uv run pytest tests/unit/
- [ ] Integration tests pass: uv run pytest tests/integration/
- [ ] Type checking: uv run mypy src/
- [ ] Linting: uv run ruff check src/
- [ ] Security scan: uv run bandit -r src/
- [ ] Dependency check: uv run safety check

#### Manual Verification:
- [ ] Feature works in development environment
- [ ] API documentation updated
- [ ] Database migrations tested
- [ ] Performance acceptable (< 100ms response time)
```

### Add Environment-Specific Validation

```markdown
#### Staging Environment:
- [ ] Deploy to staging: kubectl apply -f k8s/staging/
- [ ] Smoke tests pass: ./scripts/smoke-test.sh staging
- [ ] Logs show no errors: kubectl logs -l app=myapp

#### Production Readiness:
- [ ] Feature flag configured
- [ ] Monitoring alerts set up
- [ ] Rollback plan documented
- [ ] On-call team notified
```

## Workflow Customization

### Add Custom Workflow Phases

Create new command files:

**File**: `.claude/commands/security_review.md`

```markdown
# Security Review

Perform security review of implementation before merge.

## Checks:

1. **Input Validation**
   - All user inputs sanitized
   - SQL injection prevention
   - XSS prevention

2. **Authentication/Authorization**
   - Endpoints properly protected
   - Permission checks in place
   - Token validation correct

3. **Data Protection**
   - Sensitive data encrypted
   - PII handled correctly
   - Secrets not in code

4. **Dependencies**
   - No known vulnerabilities: `npm audit` or `uv run safety check`
   - Dependencies up to date
   - License compliance checked

## Output:

Create security review document: `thoughts/shared/security/{feature}-review.md`
```

Usage: `/security_review` before creating PR.

### Modify Existing Phases

**Example: Add design review to planning**

**File**: `.claude/commands/create_plan.md`

Add section after initial planning:

```markdown
## Step X: Design Review (New)

Before finalizing plan:

1. **Generate architecture diagram** using Mermaid or similar
2. **Review with team lead** - get approval on approach
3. **Document trade-offs** in plan
4. **Update plan** based on feedback

Only proceed to final plan after design review approval.
```

## Team-Specific Customizations

### Add Team Conventions

**In commit.md**:

```markdown
## Commit Message Format

Follow team convention:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: feat, fix, docs, style, refactor, test, chore

Example:
```
feat(auth): add OAuth2 support

Implements OAuth2 authorization code flow with PKCE.
Adds new endpoints for authorization and token exchange.

Closes #123
```

### Add Review Checklist

**File**: `.claude/commands/pre_review.md` (new)

```markdown
# Pre-Review Checklist

Run before requesting code review.

## Code Quality:
- [ ] No commented-out code
- [ ] No debug print statements
- [ ] No hardcoded values (use config/env vars)
- [ ] Consistent naming conventions
- [ ] Functions < 50 lines
- [ ] Files < 500 lines

## Testing:
- [ ] New code has tests
- [ ] Tests are meaningful (not just for coverage)
- [ ] Edge cases covered
- [ ] Error paths tested

## Documentation:
- [ ] Public APIs documented
- [ ] Complex logic has comments
- [ ] README updated if needed
- [ ] CHANGELOG.md updated

## Security:
- [ ] No secrets in code
- [ ] Input validation present
- [ ] Error messages don't leak info
- [ ] Dependencies checked for vulnerabilities

If all boxes checked, ready for `/describe_pr`.
```

## Language/Framework-Specific Customization

### FastAPI Project

Add API-specific validations:

```markdown
### API-Specific Checks:
- [ ] OpenAPI schema generated correctly: Check /docs endpoint
- [ ] Response models defined with Pydantic
- [ ] Error responses use standard format
- [ ] API versioning consistent
- [ ] Rate limiting considered
```

### React Project

Add frontend-specific checks:

```markdown
### React-Specific Checks:
- [ ] Components follow naming conventions (PascalCase)
- [ ] Hooks used correctly (rules of hooks)
- [ ] Prop types defined (TypeScript interfaces)
- [ ] Accessibility tested (axe-core)
- [ ] Bundle size impact checked: `npm run analyze`
```

### Terraform Project

Add infrastructure-specific checks:

```markdown
### Terraform-Specific Checks:
- [ ] State file not in git
- [ ] Variables have descriptions
- [ ] Outputs documented
- [ ] Resources have tags
- [ ] Security groups follow principle of least privilege
- [ ] Cost estimate reviewed: `terraform cost`
```

## Advanced Customization: Conditional Logic

### Environment-Based Commands

**Example: Different test commands per environment**

```markdown
## Test Execution

Run appropriate tests for environment:

**Development**:
```bash
uv run pytest tests/unit/ -v
```

**CI**:
```bash
uv run pytest tests/ --cov=src --cov-report=xml --junitxml=results.xml
```

**Pre-production**:
```bash
uv run pytest tests/ --slow --integration
```
```

### Feature Flag Integration

```markdown
## Implementation with Feature Flags

Wrap new functionality:

```python
from src.feature_flags import is_enabled

if is_enabled("new_feature"):
    # New implementation
else:
    # Old implementation
```

Add to plan's success criteria:
- [ ] Feature flag configured in all environments
- [ ] Default to OFF in production
- [ ] Rollback plan: disable flag
```

## Sharing Customizations

### Document in Project

Create `.claude/README.md`:

```markdown
# Claude Code Workflow Customizations

This project has customized the following:

## Commands Modified:
- `validate_plan.md` - Added coverage requirements
- `commit.md` - Added team commit message format

## Custom Commands Added:
- `security_review.md` - Security checklist before merge
- `deploy_staging.md` - Automated staging deployment

## Custom Agents Added:
- `database-analyzer.md` - Database schema analysis

## Team Conventions:
- All plans must be reviewed by team lead
- Security review required for user-facing features
- Staging deployment required before production PR
```

### Version Control

Commit all `.claude/` customizations:

```bash
git add .claude/
git commit -m "chore: customize Claude Code workflow for project"
```

Team members get customizations when they clone/pull.

## Testing Customizations

### Verify Commands Work

```bash
# In Claude Code
> /your_custom_command

# Check output, behavior
```

### Validate Syntax

```bash
# Markdown validation
npx markdownlint .claude/commands/

# YAML validation (agent frontmatter)
yamllint .claude/agents/
```

## Rollback Customizations

### Restore Original Template

```bash
# From claude-dev-kit repo
./install.sh --force /path/to/project

# Overwrites with original templates
```

### Selective Restore

```bash
# Restore single command
cp claude-dev-kit/templates/commands/validate_plan.md \
   project/.claude/commands/validate_plan.md
```

## Best Practices

1. **Start minimal** - Use defaults first, customize only when needed
2. **Document changes** - Explain why you customized
3. **Team alignment** - Discuss customizations with team
4. **Version control** - Commit `.claude/` directory
5. **Test thoroughly** - Verify commands work after modification
6. **Keep it simple** - Complex customizations are hard to maintain
7. **Review periodically** - Remove unused customizations

## Get Help

If customization isn't working:
1. Check syntax (markdown formatting, YAML frontmatter)
2. Test commands incrementally
3. Review examples in this repo
4. Open issue with your use case
