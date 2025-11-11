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