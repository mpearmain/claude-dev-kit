# Local Review

You are tasked with setting up a local review environment for a colleague's branch. 
This involves creating a worktree, setting up dependencies, and launching a new Claude Code session.

## Process

When invoked with a parameter like `gh_username:branchName`:

1. **Parse the input**:
    - Extract GitHub username and branch name from the format `username:branchname`
    - If no parameter provided, ask for it in the format: `gh_username:branchName`

2. **Extract ticket information**:
    - Look for ticket numbers in the branch name (e.g., `eng-1696`, `ENG-1696`)
    - Use this to create a short worktree directory name
    - If no ticket found, use a sanitized version of the branch name

3. **Set up the remote and worktree**:
    - Check if the remote already exists using `git remote -v`
    - If not, add it: `git remote add USERNAME git@github.com:USERNAME/{{PROJECT_NAME}}`
    - Fetch from the remote: `git fetch USERNAME`
    - Create worktree: `git worktree add -b BRANCHNAME ~/wt/{{PROJECT_NAME}}/SHORT_NAME USERNAME/BRANCHNAME`

4. **Configure the worktree**:
    - Copy Claude settings: `cp .claude/settings.local.json WORKTREE/.claude/`
    - Run setup: `{{SETUP_COMMAND}}`
    - Initialise thoughts (if using): `cd WORKTREE && npx humanlayer thoughts init --directory {{PROJECT_NAME}}`

   Note: The thoughts initialization step is optional. If you're not using the thoughts system, skip this step.

## Error Handling

- If worktree already exists, inform the user they need to remove it first
- If remote fetch fails, check if the username/repo exists
- If setup fails, provide the error but continue with the launch

## Example Usage

```
/local_review colleague_username:feature/add-new-api
```

This will:

- Add 'colleague_username' as a remote
- Create worktree at `~/wt/{{PROJECT_NAME}}/add-new-api` (or ticket number if found)
- Set up the environment
- Launch Claude Code in the new worktree

## Customization

Update the following based on your project:

- **Repository**: Replace git URL pattern if not using GitHub
- **Setup command**: Adjust `{{SETUP_COMMAND}}` to match your project (npm install, poetry install, etc.)
- **Worktree location**: Change `~/wt/{{PROJECT_NAME}}` if you prefer a different location
- **Claude settings**: Adjust settings copy command if you store settings elsewhere
