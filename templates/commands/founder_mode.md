# Founder Mode - Quick Iteration Workflow

You're working on an experimental feature that didn't get the proper ticketing and PR workflow set up. This command
guides you through retroactively organizing the work.

Assuming you just made a commit, here are the next steps:

1. Get the SHA of the commit you just made (if you didn't make one, read `.claude/commands/commit.md` and make one)

2. Create a ticket about what you just implemented:
    - Think deeply about what you just did
    - Write a clear ticket with:
        - **Problem to solve**: What user need does this address?
        - **Proposed solution**: Brief overview of your implementation
    - Set the ticket to 'in dev' or appropriate status
    - If using Linear or similar: Create the ticket and get the recommended branch name

3. Move to proper branch structure:
   ```bash
   git checkout main  # Switch to main branch
   git checkout -b BRANCH_NAME  # Create new feature branch
   git cherry-pick COMMIT_SHA  # Apply your commit to the new branch
   git push -u origin BRANCH_NAME  # Push to remote
   ```

4. Create a pull request:
   ```bash
   gh pr create --fill  # Create PR with commit message
   ```

5. Write proper PR description:
    - Read `.claude/commands/describe_pr.md` and follow the instructions
    - Generate comprehensive PR description
    - Update the PR with the description

## Why This Matters

This workflow helps you:

- Keep git history clean with proper branch structure
- Document the reasoning behind experimental work
- Make code review easier with proper context
- Track features properly in your project management system

## When to Use This

Use this command when you've been working directly on `main` or a shared branch and need to retroactively organize your
experimental work into proper branches and tickets.
