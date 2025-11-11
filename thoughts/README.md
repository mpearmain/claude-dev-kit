# Thoughts Directory

Development artefacts from the Claude Code workflow for claude-dev-kit.

## Structure

```
thoughts/
├── shared/              # Team-visible artefacts (committed to git)
│   ├── research/       # Research documents (YYYY-MM-DD-*.md)
│   ├── plans/          # Implementation plans (YYYY-MM-DD-*.md)
│   └── prs/            # PR descriptions
├── personal/           # Private notes (gitignored, optional)
│   ├── tickets/
│   └── notes/
└── searchable/         # Search index (gitignored, auto-generated)
```

## Usage

Run these commands in Claude Code:

- `/research_codebase` - Research and document codebase patterns
- `/create_plan` - Create detailed implementation plans
- `/implement_plan` - Execute plans phase-by-phase
- `/validate_plan` - Validate implementation correctness

All shared artefacts use date-based naming: `YYYY-MM-DD-description.md`
