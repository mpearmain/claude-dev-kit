# Claude Dev Kit

> Built following [Anthropic's Effective Context Engineering best practices](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) for AI agents.

Professional software development workflow powered by Claude.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/mpearmain/claude-dev-kit/main/install.sh | bash
```

## Core Workflow

The kit provides a structured development flow:

```
/research_codebase → /create_plan → /implement_plan → /validate_plan → /commit
```

### Essential Commands

| Command | Purpose |
|---------|---------|
| `/research_codebase` | Deep dive into codebase to understand implementation |
| `/create_plan` | Create detailed implementation plan with phases |
| `/implement_plan` | Execute plan phase-by-phase with validation |
| `/validate_plan` | Verify implementation meets all criteria |
| `/commit` | Create properly formatted commits |

### Additional Commands

| Command | Purpose |
|---------|---------|
| `/founder_mode` | Fast iteration without heavy process |
| `/describe_pr` | Generate PR descriptions |
| `/debug` | Debug helpers (logs, ports, etc) |
| `/local_review` | Local code review workflow |

## Philosophy

- **Research First**: Understand before implementing
- **Plan Thoroughly**: Think through approach before coding
- **Implement Systematically**: Follow the plan with checkpoints
- **Validate Everything**: Ensure quality before committing

## Installation Features

The installer auto-detects your project type and offers:

### Optional Specialist Agents
During installation, select from domain experts:
- Docker Specialist - Container optimization
- API Architect - REST/GraphQL design patterns
- Database Specialist - Schema design & optimization
- Security Advisor - Security best practices
- Performance Analyst - Performance optimization
- Testing Strategist - Test architecture & coverage

### Workflow Enhancements
- **Pre-commit validation** - 9-step workflow for complete commits
- **Code quality standards** - Language-specific documentation & cleanup
- **Commitlint integration** - Conventional commit format enforcement
- **Architectural consultation** - Automatic specialist invocation during planning

## Project Structure

After installation:

```
.claude/
├── commands/       # Slash commands (customizable)
├── agents/         # AI agents (including specialists)
└── *.md           # Configuration files

thoughts/
├── shared/         # Team artifacts (committed)
│   ├── research/  # Research documents
│   ├── plans/     # Implementation plans
│   └── prs/       # PR descriptions
└── .gitignore     # Excludes searchable index
```

## Customization

All templates are customizable:
- Edit `.claude/commands/*.md` to modify workflows
- Adjust `.claude/agents/*.md` to change agent behavior
- Configure `.claude/CODE_QUALITY_STANDARDS.md` for your standards
- Update `.claude/COMMIT_SCOPES.yml` for project-specific scopes

## Examples

### Feature Development
```bash
/research_codebase    # Understand existing code
/create_plan         # Design implementation approach
/implement_plan      # Build phase by phase
/validate_plan       # Verify correctness
/commit             # Create atomic commits
/describe_pr        # Generate PR description
```

### Quick Fix (Founder Mode)
```bash
/founder_mode       # Skip ceremony, fix quickly
/commit            # Commit the fix
```

## Documentation

- [Installation Guide](docs/INSTALLATION.md) - Detailed setup instructions
- [Command Reference](docs/COMMANDS.md) - Full command documentation
- [Agent Documentation](docs/AGENTS.md) - Understanding AI agents
- [Customisation Guide](docs/CUSTOMISATION.md) - Tailoring to your needs
- [Examples](examples/) - Detailed workflow examples

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Support

- Issues: [GitHub Issues](https://github.com/mpearmain/claude-dev-kit/issues)
- Discussions: [GitHub Discussions](https://github.com/mpearmain/claude-dev-kit/discussions)

---

**Built for developers who value quality, consistency, and systematic thinking.**