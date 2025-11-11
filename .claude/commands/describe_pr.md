# Generate PR Description

You are tasked with generating a comprehensive pull request description following the repository's standard template.

## Steps to follow:

1. **Read the PR description template (if available):**
    - Check if a template exists at `thoughts/shared/pr_description.md` or `.github/pull_request_template.md`
    - If a template exists, read it carefully to understand all sections and requirements
    - If no template exists, use a standard PR description format (see below)

2. **Identify the PR to describe:**
    - Check if the current branch has an associated PR: `gh pr view --json url,number,title,state 2>/dev/null`
    - If no PR exists for the current branch, or if on main/master, list open PRs:
      `gh pr list --limit 10 --json number,title,headRefName,author`
    - Ask the user which PR they want to describe

3. **Check for existing description:**
    - Check if a description file already exists at `thoughts/shared/prs/{number}_description.md`
    - If it exists, read it and inform the user you'll be updating it
    - Consider what has changed since the last description was written

4. **Gather comprehensive PR information:**
    - Get the full PR diff: `gh pr diff {number}`
    - If you get an error about no default remote repository, instruct the user to run `gh repo set-default` and select
      the appropriate repository
    - Get commit history: `gh pr view {number} --json commits`
    - Review the base branch: `gh pr view {number} --json baseRefName`
    - Get PR metadata: `gh pr view {number} --json url,title,number,state`

5. **Analyze the changes thoroughly:** (ultrathink about the code changes, their architectural implications, and
   potential impacts)
    - Read through the entire diff carefully
    - For context, read any files that are referenced but not shown in the diff
    - Understand the purpose and impact of each change
    - Identify user-facing changes vs internal implementation details
    - Look for breaking changes or migration requirements

6. **Handle verification requirements:**
    - Look for any checklist items in the "How to verify it" section of the template
    - For each verification step:
        - If it's a command you can run (like `make test`, linting, build, etc.), run it
        - If it passes, mark the checkbox as checked: `- [x]`
        - If it fails, keep it unchecked and note what failed: `- [ ]` with explanation
        - If it requires manual testing (UI interactions, external services), leave unchecked and note for user
    - Document any verification steps you couldn't complete

7. **Generate the description:**
    - Fill out each section from the template thoroughly:
        - Answer each question/section based on your analysis
        - Be specific about problems solved and changes made
        - Focus on user impact where relevant
        - Include technical details in appropriate sections
        - Write a concise changelog entry
    - Ensure all checklist items are addressed (checked or explained)

   **Standard PR Description Format** (if no template exists):
   ```markdown
   ## What does this PR do?
   [Brief description of the changes]

   ## Why are we doing this?
   [Context and motivation]

   ## What changed?
   - [Key change 1]
   - [Key change 2]
   - [Key change 3]

   ## Breaking Changes
   [List any breaking changes, or "None"]

   ## How to verify it
   - [ ] Run tests: `make test`
   - [ ] Run linter: `npm run lint` (or equivalent)
   - [ ] Build succeeds: `npm run build` (or equivalent)
   - [ ] Manual testing: [specific steps]

   ## Screenshots (if applicable)
   [Add screenshots for UI changes]

   ## Related Issues/PRs
   - Closes #[issue-number]
   - Related to #[issue-number]

   ## Checklist
   - [ ] Tests added/updated
   - [ ] Documentation updated
   - [ ] Changelog entry added (if needed)
   ```

8. **Save the description:**
    - Write the completed description to `thoughts/shared/prs/{number}_description.md`
    - If using humanlayer, run `npx humanlayer thoughts sync` to sync
    - Show the user the generated description

9. **Update the PR:**
    - Update the PR description directly: `gh pr edit {number} --body-file thoughts/shared/prs/{number}_description.md`
    - Confirm the update was successful
    - If any verification steps remain unchecked, remind the user to complete them before merging

## Important notes:

- This command works across different repositories - always read the local template
- Be thorough but concise - descriptions should be scannable
- Focus on the "why" as much as the "what"
- Include any breaking changes or migration notes prominently
- If the PR touches multiple components, organize the description accordingly
- Always attempt to run verification commands when possible
- Clearly communicate which verification steps need manual testing
- If not using thoughts directory, you can save to a temporary file and update PR directly
