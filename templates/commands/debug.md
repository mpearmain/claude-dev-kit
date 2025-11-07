# Debug

You are tasked with helping debug issues during manual testing or implementation. This command allows you to investigate
problems by examining logs, database state, and git history without editing files. Think of this as a way to bootstrap a
debugging session without using the primary window's context.

## Initial Response

When invoked WITH a plan/ticket file:

```
I'll help debug issues with [file name]. Let me understand the current state.

What specific problem are you encountering?
- What were you trying to test/implement?
- What went wrong?
- Any error messages?

I'll investigate the logs, database, and git state to help figure out what's happening.
```

When invoked WITHOUT parameters:

```
I'll help debug your current issue.

Please describe what's going wrong:
- What are you working on?
- What specific problem occurred?
- When did it last work?

I can investigate logs, database state, and recent changes to help identify the issue.
```

## Environment Information

You have access to these key debugging locations and tools:

**Logs** (commonly in these locations):

- Application logs: Check project-specific log directories
- System logs: `/var/log/` (Linux/Mac) or event viewer (Windows)
- Development server logs: Usually in project root or `.log` files
- Service logs: Check where your services write logs

**Database**:

- Location: Project-specific (check config files)
- Type: SQLite, PostgreSQL, MySQL, MongoDB, etc.
- Can query directly with appropriate CLI tools

**Git State**:

- Check current branch, recent commits, uncommitted changes
- Similar to how `commit` and `describe_pr` commands work

**Service Status**:

- Check if services are running: `ps aux | grep [service-name]`
- Check ports: `lsof -i :[port]` or `netstat -an | grep [port]`
- Check process status

## Process Steps

### Step 1: Understand the Problem

After the user describes the issue:

1. **Read any provided context** (plan or ticket file):
    - Understand what they're implementing/testing
    - Note which phase or step they're on
    - Identify expected vs actual behavior

2. **Quick state check**:
    - Current git branch and recent commits
    - Any uncommitted changes
    - When the issue started occurring

### Step 2: Investigate the Issue

Spawn parallel Task agents for efficient investigation:

```
Task 1 - Check Recent Logs:
Find and analyze the most recent logs for errors:
1. Identify log file locations (check config or common locations)
2. Search for errors, warnings, or issues around the problem timeframe
3. Look for stack traces or repeated errors
4. Check timestamp correlation with when issue occurred
5. Note any unusual patterns
Return: Key errors/warnings with timestamps and context
```

```
Task 2 - Database State (if applicable):
Check the current database state:
1. Connect to database using appropriate tool
2. Check schema and relevant tables
3. Query recent data related to the issue
4. Look for stuck states, anomalies, or missing data
5. Check for constraint violations or foreign key issues
Return: Relevant database findings
```

```
Task 3 - Git and File State:
Understand what changed recently:
1. Check git status and current branch
2. Look at recent commits: git log --oneline -10
3. Check uncommitted changes: git diff
4. Verify expected files exist
5. Look for any file permission issues
6. Check if dependencies are up to date
Return: Git state and any file issues
```

```
Task 4 - Environment and Dependencies (if relevant):
Check environment configuration:
1. Verify environment variables are set correctly
2. Check dependency versions: package.json, requirements.txt, go.mod, etc.
3. Look for conflicting versions
4. Check build artifacts are up to date
5. Verify configuration files are correct
Return: Environment and dependency status
```

### Step 3: Present Findings

Based on the investigation, present a focused debug report:

```markdown
## Debug Report

### What's Wrong
[Clear statement of the issue based on evidence]

### Evidence Found

**From Logs**:
- [Error/warning with timestamp]
- [Pattern or repeated issue]
- [Stack trace or error message]

**From Database** (if applicable):
```sql
-- Relevant query and result
[Finding from database]
```

**From Git/Files**:

- [Recent changes that might be related]
- [File state issues]
- [Dependency or build issues]

### Root Cause

[Most likely explanation based on evidence]

### Next Steps

1. **Try This First**:
   ```bash
   [Specific command or action]
   ```

2. **If That Doesn't Work**:
    - Restart services
    - Clear cache/build artifacts
    - Check browser console (for web apps)
    - Run with debug/verbose logging
    - Verify environment configuration

3. **Additional Investigation**:
    - [Specific area to look into]
    - [Alternative hypothesis to test]

### Can't Access?

Some issues might be outside my reach:

- Browser console errors (F12 in browser)
- Network requests (check browser Network tab)
- System-level issues (permissions, firewall, etc.)
- External service outages

Would you like me to investigate something specific further?

```

## Important Notes

- **Focus on manual testing scenarios** - This is for debugging during implementation
- **Always require problem description** - Can't debug without knowing what's wrong
- **Read files completely** - No limit/offset when reading context
- **Think like `commit` or `describe_pr`** - Understand git state and changes
- **Guide back to user** - Some issues (browser console, network, external services) are outside reach
- **No file editing** - Pure investigation only
- **Use parallel tasks** - Investigate multiple areas concurrently for efficiency

## Quick Reference

**Find Latest Logs** (adjust paths for your project):
```bash
# Find recent log files
find . -name "*.log" -type f -mtime -1

# Tail log file
tail -f /path/to/app.log

# Search for errors
grep -i error /path/to/app.log
```

**Database Queries** (examples for common databases):

```bash
# SQLite
sqlite3 database.db ".tables"
sqlite3 database.db "SELECT * FROM table_name ORDER BY created_at DESC LIMIT 5;"

# PostgreSQL
psql -d database_name -c "SELECT * FROM table_name ORDER BY created_at DESC LIMIT 5;"

# MySQL
mysql -u user -p database_name -e "SELECT * FROM table_name ORDER BY created_at DESC LIMIT 5;"
```

**Service Check**:

```bash
# Check if service is running
ps aux | grep [service-name]

# Check port usage
lsof -i :[port-number]

# Check listening ports
netstat -tuln | grep [port-number]
```

**Git State**:

```bash
git status
git log --oneline -10
git diff
git diff --staged
```

**Environment Check**:

```bash
# Check Node.js version
node --version

# Check Python version
python --version

# Check installed packages
npm list (Node.js)
pip list (Python)
go list -m all (Go)
```

Remember: This command helps you investigate without burning the primary window's context. Perfect for when you hit an
issue during manual testing and need to dig into logs, database, or git state.
