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