---
date: 2025-11-10T16:34:41+04:00
researcher: mpearmain
git_commit: f8c4c7484899481fe26256f2a8ac2d8103ba976a
branch: main
repository: claude-dev-kit
topic: "Analysis of dendroh-ai project agents and commands for base toolkit enhancement"
tags: [ research, codebase, agents, commands, enhancement, dendroh ]
status: complete
last_updated: 2025-11-10
last_updated_by: mpearmain
---

# Research: Dendroh Project Enhancement Analysis for Claude Dev Kit

**Date**: 2025-11-10T16:34:41+04:00
**Researcher**: mpearmain
**Git Commit**: f8c4c7484899481fe26256f2a8ac2d8103ba976a
**Branch**: main
**Repository**: claude-dev-kit

## Research Question

Assess the ./claude/* agents and commands in dendroh-frontend and dendroh-backend projects to identify parts that would
improve the claude-dev-kit base commands and agents.

## Summary

The dendroh projects have evolved the base claude-dev-kit with domain-specific agents and enhanced workflows that
demonstrate patterns worth incorporating into the base toolkit. Key innovations include specialist architectural
consultation agents, pre-commit validation workflows, and differentiated approaches for frontend vs backend development.

## High-Value Additions for Base Toolkit

### 1. Domain-Specific Specialist Agents (Backend)

The dendroh-backend introduces four specialist agents that operate as architectural consultants during the planning
phase:

#### **Docker Specialist** (`/Users/mpearmain/dendroh-ai/dendroh-backend/.claude/agents/docker-specialist.md`)

- **Purpose**: Container infrastructure planning consultant
- **Auto-triggers**: On Dockerfile or docker-compose file changes
- **Value**: Enforces production-grade practices (multi-stage builds, security hardening, layer optimisation)
- **Token budget**: 1,000-2,000 tokens with Opus model

#### **FastAPI Architect** (`/Users/mpearmain/dendroh-ai/dendroh-backend/.claude/agents/fastapi-architect.md`)

- **Purpose**: API design and endpoint architecture consultant
- **Auto-triggers**: On `packages/*/routers/*.py` changes
- **Value**: Ensures consistent API patterns, Pydantic validation, dependency injection
- **References**: Project-specific CLAUDE.md standards

#### **MongoDB Specialist** (`/Users/mpearmain/dendroh-ai/dendroh-backend/.claude/agents/mongodb-specialist.md`)

- **Purpose**: Database schema and query optimisation consultant
- **Auto-triggers**: On `*_mongo*.py` file patterns
- **Value**: Schema design, aggregation pipeline optimisation, CosmosDB compatibility
- **Innovation**: Tracks Request Unit (RU) consumption for cloud cost optimisation

#### **Jupyter Specialist** (`/Users/mpearmain/dendroh-ai/dendroh-backend/.claude/agents/jupyter-specialist.md`)

- **Purpose**: Notebook workflow and data pipeline architecture
- **No auto-triggers**: Manual invocation only
- **Value**: Notebook organisation, reproducibility, backend integration patterns

**Integration Pattern**: All specialists integrate into Step 3 of `/create_plan` command with automatic detection rules.

### 2. Pre-Commit Validation Workflow (Backend)

#### **COMMIT_CHECKLIST.md** (`/Users/mpearmain/dendroh-ai/dendroh-backend/.claude/COMMIT_CHECKLIST.md`)

A mandatory 9-step pre-commit workflow that prevents incomplete commits:

```bash
1. Run pre-commit BEFORE staging
2. Check git status and git diff
3. Stage ALL changes (including hook modifications)
4. Verify staging complete
5. Run pre-commit again (verification)
6. Commit
7. Verify working tree clean
8. Run full test suite
9. Push only if all pass
```

**Key Innovation**: Handles the common problem where pre-commit hooks modify files after staging, ensuring complete
commits.

### 3. Enhanced Command Patterns

#### **Frontend commit.md** Improvements

- Detailed conventional commit format with project-specific scopes
- Explicit scope enumeration: `auth`, `workspace`, `canvas`, `problem`, `project`, etc.
- Concrete examples for each commit type

#### **Frontend implement_plan.md** Quality Standards

- Staff engineer code quality requirements
- Comprehensive JSDoc documentation standards
- Dead code removal patterns (unused imports, commented code)
- Semantic token enforcement from `tailwind.config.ts`

#### **Backend create_plan.md** Architectural Consultation

- Auto-detection rules for specialist invocation
- Domain-specific consultation before plan creation
- Technology stack awareness (FastAPI, MongoDB, Docker)

## Comparison with Current Base Toolkit

### Current claude-dev-kit Assets

- **7 base agents**: codebase-analyzer, codebase-locator, codebase-pattern-finder, thoughts-analyzer, thoughts-locator,
  web-search-researcher, gemini-analyzer
- **10 base commands**: research_codebase, create_plan, implement_plan, validate_plan, commit, describe_pr, linear,
  local_review, debug, founder_mode
- **Template system**: Enables easy customisation through templates/

### Gaps Addressed by Dendroh Projects

1. **No domain-specific agents** in base toolkit
    - Dendroh adds: Docker, FastAPI, MongoDB, Jupyter specialists

2. **No pre-commit validation workflow**
    - Dendroh adds: 9-step checklist with hook modification handling

3. **Generic commit format**
    - Dendroh adds: Project-specific scope definitions and examples

4. **No architectural consultation phase**
    - Dendroh adds: Automatic specialist invocation based on file patterns

5. **No code quality enforcement**
    - Dendroh frontend adds: JSDoc requirements, dead code removal standards

## Recommended Base Toolkit Enhancements

### Priority 1: Add Specialist Agent Framework

Create a framework for domain-specific agents with:

- Auto-trigger patterns based on file changes
- Token budget constraints (1,000-2,000)
- Reference to external standards files
- Planning-only scope (no implementation)

**Template location**: `templates/agents/specialist-template.md`

### Priority 2: Pre-Commit Validation System

Add optional pre-commit workflow:

- Create `templates/COMMIT_CHECKLIST.md`
- Integrate into `commit.md` command with opt-in flag
- Handle hook modification re-staging problem

### Priority 3: Enhanced Code Quality Standards

Extract frontend quality patterns:

- Create `templates/CODE_QUALITY_STANDARDS.md`
- JSDoc documentation templates
- python documentation templates
- Dead code detection patterns
- Integrate into `implement_plan.md`

### Priority 4: Scope-Based Commit Convention

- Create `templates/COMMIT_SCOPES.md`
- Allow projects to define custom scopes
- Reference in `commit.md` command

### Priority 5: Architectural Consultation Phase

Enhance `create_plan.md` with:

- Optional Step 3: Architectural Consultation
- Configuration for specialist auto-detection rules
- Integration points for custom specialists

## Implementation Strategy

### Phase 1: Framework Development

1. Create specialist agent template with YAML frontmatter for triggers
2. Develop auto-detection registry system
3. Add configuration hooks in create_plan.md

### Phase 2: Workflow Enhancement

1. Port COMMIT_CHECKLIST.md to templates/
2. Add pre-commit validation flags to commit.md
3. Create CODE_QUALITY_STANDARDS.md template

### Phase 3: Customisation Support

1. Document specialist agent creation process
2. Create example specialists for common stacks
3. Add scope configuration system

## Architectural Considerations

### Modularity vs Integration

- Specialists should be optional add-ons, not core requirements
- Use feature flags or configuration files for activation
- Maintain backward compatibility with existing workflows

### Token Efficiency

- Specialist token budgets (1,000-2,000) prevent context bloat
- Planning-only scope reduces implementation overhead
- Reference external standards rather than embedding

### Team Adoption

- Pre-commit workflow should be team-configurable
- Code quality standards should allow per-project customisation
- Specialist triggers should be directory-aware

## Code References

- Specialist agents: `/Users/mpearmain/dendroh-ai/dendroh-backend/.claude/agents/`
- Enhanced commands: `/Users/mpearmain/dendroh-ai/dendroh-{frontend,backend}/.claude/commands/`
- COMMIT_CHECKLIST: `/Users/mpearmain/dendroh-ai/dendroh-backend/.claude/COMMIT_CHECKLIST.md`
- Current base toolkit: `/Users/mpearmain/gitpackages/claude-dev-kit/templates/`

## Historical Context

The dendroh projects demonstrate natural evolution of the base toolkit for production environments. The frontend
emphasises code quality and documentation, while the backend prioritises architectural validation and git safety. Both
approaches offer valuable patterns for generalisation.

## Related Research

- Team adoption patterns in `/Users/mpearmain/gitpackages/claude-dev-kit/docs/TEAM_ADOPTION.md`
- Customisation guide in `/Users/mpearmain/gitpackages/claude-dev-kit/docs/CUSTOMISATION.md`

## Open Questions

1. Should specialist agents be bundled with the base toolkit or maintained as separate packages?
2. How should project-specific standards (CLAUDE.md) be integrated without creating dependencies?
3. Should the pre-commit workflow be mandatory or optional in the base toolkit?