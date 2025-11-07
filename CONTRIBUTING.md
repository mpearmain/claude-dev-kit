# Contributing to Claude Code Workflow Templates

Contributions are welcome. This document provides guidelines for proposing improvements, testing changes, and submitting contributions.

## Types of Contributions

1. **Bug Fixes** - Errors in templates, installer, or documentation
2. **New Templates** - Additional commands or agents
3. **Language Support** - Detection and defaults for new languages/frameworks
4. **Documentation** - Improvements to guides and examples
5. **Examples** - Real-world workflow demonstrations

## Before Contributing

### Check Existing Issues

Search [existing issues](https://github.com/mpearmain/claude-dev-kit/issues) to see if your idea or bug is already tracked.

### Discuss Major Changes

For significant changes, open an issue first to discuss:
- New workflow phases
- Major installer modifications
- Structural changes to templates
- New dependencies

This prevents wasted effort if the change doesn't align with project direction.

## Development Setup

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR-USERNAME/claude-dev-kit.git
cd claude-dev-kit
```

### 2. Create Test Project

Create a test project for validation:

```bash
# Python test project
mkdir -p test-projects/python-uv
cd test-projects/python-uv
uv init
cd ../..

# Node.js test project
mkdir -p test-projects/nodejs-npm
cd test-projects/nodejs-npm
npm init -y
cd ../..
```

### 3. Test Installer

```bash
# Test installation
./install.sh test-projects/python-uv

# Test dry-run mode
./install.sh --dry-run test-projects/nodejs-npm

# Test force overwrite
./install.sh --force test-projects/python-uv
```

## Making Changes

### Branch Naming

Use descriptive branch names:

- `fix/installer-detection-python` - Bug fixes
- `feat/add-go-support` - New features
- `docs/improve-quickstart` - Documentation
- `example/fastapi-crud` - New examples

### Template Changes

When modifying templates in `templates/commands/` or `templates/agents/`:

1. **Preserve placeholders**: Keep `{{VARIABLE}}` format
2. **Test with real values**: Verify templates work after placeholder replacement
3. **Update documentation**: If adding new placeholders, document in `docs/PLACEHOLDERS.md`
4. **Check all templates**: Ensure consistency across similar templates

### Installer Changes

When modifying `install.sh`:

1. **Maintain POSIX compatibility**: Use portable bash syntax
2. **Test detection logic**: Verify auto-detection works correctly
3. **Preserve dry-run mode**: Ensure `--dry-run` shows accurate preview
4. **Update help text**: Keep `usage()` function current
5. **Test error cases**: Missing directories, permission issues, etc.

### Adding Language Support

To add detection and defaults for a new language:

1. **Add detection in `install.sh`**:

```bash
# Go detection (example)
if [[ -f "$target_dir/go.mod" ]]; then
    info "  ✓ Detected Go project"
    MAIN_SRC_DIR="."
    TEST_COMMAND="go test ./..."
    LINT_COMMAND="golangci-lint run"
    BUILD_COMMAND="go build ./..."
    SETUP_COMMAND="go mod download"
    return
fi
```

2. **Add language config example**:

Create `examples/language-configs/{language}.txt` documenting:
- Detection trigger
- Default values
- Common project structures
- Typical customizations

3. **Update documentation**:

Add row to supported languages table in `README.md`.

4. **Test thoroughly**:

Create test project and verify:
- Detection works
- Placeholders replaced correctly
- Commands make sense for the language

### Adding New Commands

To add a new workflow command:

1. **Create template file**: `templates/commands/your_command.md`

```markdown
# Your Command Name

Description of what this command does...

## Steps to follow:

1. First step
2. Second step using {{PROJECT_NAME}}
3. Third step running {{TEST_COMMAND}}

## Important notes:
- Note about usage
- Note about when to use this command
```

2. **Add to README**: Document the new command in "Available Commands" section

3. **Create example**: Add example usage in `examples/` if applicable

4. **Test installation**: Verify command installs and placeholders replaced

### Adding New Agents

To add a new specialized agent:

1. **Create agent file**: `templates/agents/your-agent.md`

```markdown
---
name: your-agent
description: Brief description of what this agent does
tools: Grep, Read, Glob
model: sonnet
---

You are a specialist at [specific task].

## Your job:

1. [Responsibility 1]
2. [Responsibility 2]
3. [Responsibility 3]

## Search patterns:

- [Pattern 1]: `path/to/files`
- [Pattern 2]: `another/path`

## Output format:

### [Section 1]
- [Detail 1]
- [Detail 2]

...
```

2. **Document in README**: Add to "Specialized Agents" section

3. **Show example usage**: Demonstrate how commands spawn this agent

4. **Test functionality**: Create test case using the agent

## Testing

### Manual Testing Checklist

Before submitting PR:

- [ ] Installer runs without errors
- [ ] Dry-run mode shows accurate preview
- [ ] Force mode overwrites correctly
- [ ] Auto-detection works for target language
- [ ] Placeholders replaced in all templates
- [ ] Directory structure created correctly
- [ ] `.gitignore` files generated
- [ ] Help text is accurate

### Test Multiple Project Types

Test installer with:

- [ ] Python + uv project
- [ ] Python + Poetry project
- [ ] Node.js + npm project
- [ ] Empty directory (generic defaults)
- [ ] Existing `.claude/` directory (overwrite handling)

### Template Validation

- [ ] All markdown files valid syntax
- [ ] Agent YAML frontmatter valid
- [ ] Placeholders use correct format: `{{VARIABLE}}`
- [ ] No hardcoded project-specific values
- [ ] Consistent formatting and style

### Documentation Testing

- [ ] All links work
- [ ] Code examples are accurate
- [ ] Instructions can be followed successfully
- [ ] Examples match current templates

## Code Style

### Bash Script Style

```bash
# Use descriptive variable names
PROJECT_NAME="example"  # Good
pn="example"            # Bad

# Always quote variables
echo "$PROJECT_NAME"    # Good
echo $PROJECT_NAME      # Bad

# Check error conditions
if [[ ! -d "$target_dir" ]]; then
    error "Directory not found"
fi

# Use functions for repeated logic
detect_language() {
    # Function body
}
```

### Markdown Style

```markdown
# Use clear headers

## Section names should be descriptive

### Subsections for organization

**Bold for emphasis**, *italic sparingly*

`Code in backticks`

```bash
# Code blocks with language
command --flag value
```
```

### Template Style

- Use `{{PLACEHOLDER}}` for variables (all caps, with braces)
- Keep instructions clear and actionable
- Use markdown formatting for structure
- Include examples where helpful
- Add comments explaining complex steps

## Documentation Guidelines

### Clear and Concise

- Lead with what the user needs to know
- Use examples liberally
- Avoid jargon when possible
- Define terms when necessary

### Practical Examples

- Show real-world usage
- Include complete commands
- Demonstrate expected output
- Cover common edge cases

### Structure

- Use progressive disclosure (basic → advanced)
- Group related information
- Provide quick reference sections
- Link between related documents

## Submitting Changes

### Commit Messages

Follow conventional commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting (no code change)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:

```
feat(installer): add Rust project detection

Add detection for Cargo.toml and defaults for Rust projects.
Includes test command, lint with clippy, and build defaults.

Closes #45
```

```
fix(templates): correct placeholder in validate_plan.md

Changed {{BUILD_CMD}} to {{BUILD_COMMAND}} for consistency.
```

```
docs(readme): improve quick start instructions

Added step-by-step installation with expected output.
Clarified prerequisites and troubleshooting.
```

### Pull Request Process

1. **Update documentation**: If changing functionality, update relevant docs

2. **Add examples**: For new features, provide working examples

3. **Test thoroughly**: Follow testing checklist above

4. **Create PR with clear description**:

```markdown
## Summary

Brief description of changes

## Changes

- Added detection for Go projects
- Created go-specific examples
- Updated README with Go in supported languages

## Testing

- [x] Tested on Go project with go.mod
- [x] Verified placeholders replaced correctly
- [x] Checked dry-run mode
- [x] Tested on existing installation (overwrite)

## Screenshots (if applicable)

[Add screenshots of installer output, etc.]
```

5. **Link related issues**: Use "Closes #123" or "Relates to #456"

6. **Respond to feedback**: Address review comments promptly

### PR Review Criteria

PRs will be reviewed for:

- **Functionality**: Does it work as intended?
- **Quality**: Is the code/content well-written?
- **Consistency**: Does it match existing style and patterns?
- **Documentation**: Are changes documented?
- **Testing**: Has it been tested adequately?
- **Impact**: Does it improve the project?

## Community Guidelines

### Be Respectful

- Assume good intent
- Provide constructive feedback
- Accept feedback gracefully
- Help others learn

### Be Clear

- Explain your reasoning
- Provide context
- Use examples
- Ask clarifying questions

### Be Collaborative

- Discuss before implementing major changes
- Share knowledge and learnings
- Celebrate others' contributions
- Improve documentation as you learn

## Recognition

Contributors will be:
- Listed in GitHub contributors
- Mentioned in release notes for significant contributions
- Credited in documentation for major features

## Questions?

- Open an issue for discussion
- Check existing documentation
- Review examples for patterns
- Ask in PR comments

Thank you for contributing to make AI-assisted development more structured and effective!
