# Claude Dev Kit

> Built following [Anthropic's Effective Context Engineering best practices](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) for AI agents.

## Context Engineering for Real Development Work

This kit transforms Claude from a stateless assistant into a development environment with persistent memory and cumulative knowledge. Unlike traditional prompt engineering that loses context between sessions, this approach builds a living knowledge base alongside your code. Every research session, architectural decision, and implementation plan becomes part of your project's intellectual infrastructure.

The core innovation is the `thoughts/` directory - a structured knowledge graph that persists across Claude sessions. When you research a complex codebase pattern, that analysis is stored and indexed. When you create an implementation plan, it references prior research. When a new team member needs to understand a decision made months ago, the rationale exists in searchable, contextual form. This isn't prompt stuffing or template expansion; it's genuine knowledge accumulation that compounds over time.

The power becomes obvious in practice. Start a new feature by running `/research_codebase` to analyse existing patterns. Claude stores findings in `thoughts/shared/research/`. Create your implementation plan with `/create_plan`, which references that research and stores the plan in `thoughts/shared/plans/`. Six months later, when debugging an issue, Claude can access the original research and reasoning. Your AI assistant retains institutional knowledge just like your team does.

## Installation

```bash
# Clone the repository
git clone https://github.com/mpearmain/claude-dev-kit.git
cd claude-dev-kit

# Run the installer
./install.sh

# The installer will:
# 1. Detect your project type and language
# 2. Set up the .claude/ configuration directory
# 3. Create the thoughts/ knowledge structure
# 4. Offer optional specialist agents based on your stack
```

## Why This Architecture Matters

**Persistent Memory Across Context Boundaries**
Traditional AI assistants reset with each conversation. This kit maintains continuity through the `thoughts/` directory, allowing Claude to reference research from previous sessions, understand past architectural decisions, and build upon existing knowledge rather than starting fresh each time.

**Reusable Knowledge That Compounds**
Every analysis, plan, and decision becomes part of your project's knowledge base. When implementing similar features later, Claude references existing patterns and standards. The system becomes more valuable over time as knowledge accumulates.

**True Team Collaboration**
The `thoughts/shared/` directory commits to version control, making AI-assisted development a team sport. Research conducted by one developer benefits everyone. Architectural decisions have traceable rationale. New team members inherit contextual understanding.

**Audit Trail for Future Understanding**
Months after implementation, you can trace why specific decisions were made. Each feature has associated research, planning documents, and validation criteria. This isn't just code history - it's decision history with full context.

## Core Workflow

The kit enforces systematic development through a research-first approach:

```
/research_codebase → /create_plan → /implement_plan → /validate_plan → /commit
```

### Essential Commands

| Command | Purpose |
|---------|---------|
| `/research_codebase` | Analyse codebase patterns, store findings in thoughts/shared/research/ |
| `/create_plan` | Design implementation with phases, checkpoints, and validation criteria |
| `/implement_plan` | Execute plan systematically with progress tracking |
| `/validate_plan` | Verify implementation against original criteria |
| `/commit` | Create atomic, well-documented commits |

### Additional Commands

| Command | Purpose |
|---------|---------|
| `/founder_mode` | Rapid iteration for experienced developers |
| `/describe_pr` | Generate comprehensive PR descriptions from commits and plans |
| `/debug` | Diagnostic helpers for logs, ports, processes |
| `/local_review` | Simulate code review before pushing |

## Project Structure

```
your-project/
├── .claude/
│   ├── commands/        # Customisable workflow commands
│   ├── agents/          # Specialist AI agents
│   └── *.md            # Configuration and standards
│
├── thoughts/            # Knowledge base (context engineering)
│   ├── shared/         # Version-controlled team knowledge
│   │   ├── research/   # Codebase analysis and findings
│   │   ├── plans/      # Implementation strategies
│   │   └── prs/        # Pull request documentation
│   └── .gitignore      # Excludes search indices
│
└── your-code/          # Your actual project files
```

## Specialist Agents

The installer offers domain experts based on your project:

- **Docker Specialist** - Container optimisation, multi-stage builds, security scanning
- **API Architect** - REST/GraphQL patterns, OpenAPI specs, versioning strategies
- **Database Specialist** - Schema design, query optimisation, migration patterns
- **Security Advisor** - OWASP compliance, vulnerability scanning, secure coding
- **Performance Analyst** - Profiling, optimisation, caching strategies
- **Testing Strategist** - Test architecture, coverage analysis, TDD workflows

## Workflow Philosophy

**Research Before Implementation**
Every feature starts with understanding. The `/research_codebase` command analyses existing patterns, identifies constraints, and documents findings. This research becomes reference material for current and future work.

**Plans Are Contracts**
The `/create_plan` command produces detailed implementation strategies with phases, validation criteria, and rollback procedures. Plans aren't suggestions - they're contracts that guide implementation and define success.

**Systematic Execution**
The `/implement_plan` command follows the plan phase by phase, validating at checkpoints. This isn't rigid - plans can adapt, but changes are deliberate and documented.

**Validation Is Non-Negotiable**
The `/validate_plan` command verifies implementation against original criteria. Tests pass. Documentation exists. Code standards are met. Validation isn't a suggestion - it's a gate.

## Customisation

Every aspect adapts to your workflow:

```bash
# Modify command workflows
vim .claude/commands/commit.md

# Adjust agent behaviour
vim .claude/agents/codebase-analyzer.md

# Define project standards
vim .claude/CODE_QUALITY_STANDARDS.md

# Configure commit scopes
vim .claude/COMMIT_SCOPES.yml
```

## Example Workflows

### Feature Development
```bash
# 1. Understand the codebase
/research_codebase authentication flow

# 2. Create implementation plan
/create_plan add OAuth2 support

# 3. Build systematically
/implement_plan

# 4. Verify completeness
/validate_plan

# 5. Create atomic commits
/commit

# 6. Document for review
/describe_pr
```

### Bug Investigation
```bash
# 1. Research the issue
/research_codebase payment processing error logs

# 2. Quick fix without ceremony
/founder_mode fix payment retry logic

# 3. Commit the fix
/commit fix: payment retry logic
```

## Documentation

- [Installation Guide](docs/INSTALLATION.md) - Platform-specific setup
- [Command Reference](docs/COMMANDS.md) - Detailed command documentation
- [Agent Documentation](docs/AGENTS.md) - Specialist agent capabilities
- [Customisation Guide](docs/CUSTOMISATION.md) - Adapting to your workflow
- [Examples](examples/) - Real-world usage patterns

## Requirements

- Claude Code CLI (latest version)
- Git repository
- Supported languages: Python, JavaScript/TypeScript, Go, Rust, Java
- Optional: Docker for containerised projects

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and contribution guidelines.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Support

- Issues: [GitHub Issues](https://github.com/mpearmain/claude-dev-kit/issues)
- Discussions: [GitHub Discussions](https://github.com/mpearmain/claude-dev-kit/discussions)

---

**Built for developers who understand that context is everything.**