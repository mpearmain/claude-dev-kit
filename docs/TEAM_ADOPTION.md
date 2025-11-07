# Team Adoption Guide

Guide for introducing the Claude Code workflow to development teams.

## Overview

Successfully adopting this workflow requires team alignment, training, and gradual integration. This guide provides a structured approach for teams of any size.

## Adoption Stages

### Stage 1: Single Developer Pilot (1-2 weeks)

**Goal**: Validate workflow on real work without team commitment.

**Steps**:
1. One developer installs workflow in their local clone
2. Use for 2-3 features end-to-end
3. Document what works and what doesn't
4. Customize templates for project needs

**Success Criteria**:
- Research documents prove valuable
- Plans reduce implementation time
- Process feels sustainable
- Clear improvement over ad-hoc approach

**Deliverables**:
- 3-5 research documents
- 2-3 implementation plans
- List of customizations needed
- Recommendation to team

### Stage 2: Small Team Trial (2-4 weeks)

**Goal**: Validate team collaboration with workflow.

**Steps**:
1. Install workflow in main repository
2. Commit `.claude/` and `thoughts/shared/` to git
3. Train 2-3 developers on workflow
4. Use for new features in parallel
5. Weekly retrospective on process

**Team Size**: 2-4 developers

**Success Criteria**:
- Team can reference each other's research
- Plans are reusable across developers
- Context management improves collaboration
- Team velocity maintained or improved

**Deliverables**:
- Shared research documents
- Cross-referenced plans
- Team-specific customizations
- Lessons learned document

### Stage 3: Full Team Rollout (1-2 months)

**Goal**: Make workflow standard practice.

**Steps**:
1. Team training session (2 hours)
2. Document team conventions
3. Integrate with existing tools (Linear, CI/CD)
4. Monitor adoption and support
5. Monthly review and optimization

**Team Size**: Entire development team

**Success Criteria**:
- All developers using workflow
- `thoughts/` directory is valuable reference
- Onboarding time reduced for new developers
- Consistent quality across implementations

**Deliverables**:
- Team workflow documentation
- Training materials
- Integration with existing processes
- Metrics on adoption and impact

## Training Plan

### Initial Training (2 hours)

**Session Outline**:

**Part 1: Context and Philosophy (20 min)**
- Why structured AI-assisted development
- The 60% context rule
- Phase-based approach
- Show before/after comparison

**Part 2: Installation and Setup (15 min)**
- Install workflow in demo project
- Walk through generated structure
- Explain `.claude/` and `thoughts/` directories
- Review customizations for your project

**Part 3: Workflow Demo (45 min)**
- Live demo: Research phase
  - Show command: `/research_codebase`
  - Demonstrate agent spawning
  - Review generated research document
- Live demo: Planning phase
  - Show command: `/create_plan`
  - Interactive planning process
  - Review generated plan
- Live demo: Implementation
  - Show command: `/implement_plan`
  - Phase-by-phase execution
  - Validation at each step
- Live demo: Supporting commands
  - `/commit` for structured commits
  - `/describe_pr` for PR descriptions

**Part 4: Hands-on Practice (30 min)**
- Pair up: one person drives, one observes
- Each pair picks a small task
- Execute research phase together
- Start planning phase
- Debrief and Q&A

**Part 5: Team Conventions (10 min)**
- Discuss team-specific customizations
- Agree on naming conventions
- Decide what goes in `thoughts/shared/`
- Set expectations for adoption

### Follow-up Support

**Week 1-2**: Daily office hours
- 30-minute sessions
- Answer questions
- Help with first tasks
- Troubleshoot issues

**Week 3-4**: Weekly check-ins
- Review examples together
- Share tips and tricks
- Refine team conventions
- Address challenges

**Month 2+**: Monthly retrospectives
- What's working well
- What needs improvement
- Share success stories
- Update documentation

## Team Conventions

### Naming Conventions

**Research Documents**:
```
Format: YYYY-MM-DD-topic.md
or: YYYY-MM-DD-TICKET-123-topic.md

Examples:
- 2025-01-15-authentication-flow.md
- 2025-01-15-ENG-456-rate-limiting.md
```

**Plans**:
```
Format: YYYY-MM-DD-feature.md
or: YYYY-MM-DD-TICKET-123-feature.md

Examples:
- 2025-01-15-oauth-implementation.md
- 2025-01-16-ENG-457-add-caching.md
```

**PRs**:
```
Format: {pr_number}_{description}.md

Examples:
- 123_oauth_implementation.md
- 456_rate_limiting_middleware.md
```

### What to Commit

**Always commit**:
- `.claude/commands/` - Customized workflow commands
- `.claude/agents/` - Customized agents
- `thoughts/shared/research/` - Team research
- `thoughts/shared/plans/` - Implementation plans
- `thoughts/shared/prs/` - PR descriptions
- `thoughts/.gitignore` - Directory configuration

**Never commit**:
- `thoughts/searchable/` - Auto-generated index
- `thoughts/personal/` - Individual notes (optional)

**`.gitignore` configuration**:
```gitignore
# In thoughts/.gitignore
searchable/
personal/
```

### Collaboration Patterns

**Pattern 1: Research Handoff**
```
Developer A researches architecture
→ Commits research document
→ Developer B reads and creates plan
→ Proceeds with implementation
```

**Pattern 2: Parallel Features**
```
Developer A and B work on related features
→ Both reference same research document
→ Plans cross-reference each other
→ Implementation coordinates at boundaries
```

**Pattern 3: Knowledge Transfer**
```
Developer A leaves project
→ Research and plans remain in repository
→ Developer B reads documents
→ Understands decisions and context
```

## Integration with Existing Tools

### Linear/Jira Integration

**Approach 1: Ticket References**
```markdown
# In research and plan files
Related Ticket: ENG-123
Linear URL: https://linear.app/team/issue/ENG-123
```

**Approach 2: Command Integration**
```bash
# Use /linear command (if configured)
> /linear ENG-123
# Fetches ticket details, creates research document
```

**Approach 3: Bidirectional Updates**
```bash
# After creating plan
> /linear update ENG-123 "Plan created: thoughts/shared/plans/2025-01-15-ENG-123-feature.md"
```

### CI/CD Integration

**Add validation to CI pipeline**:

```yaml
# .github/workflows/validate-thoughts.yml
name: Validate Thoughts

on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate Research Documents
        run: |
          # Check YAML frontmatter in research docs
          find thoughts/shared/research -name "*.md" -exec ./scripts/validate-frontmatter.sh {} \;
      - name: Check Plan References
        run: |
          # Ensure plans reference existing research
          ./scripts/check-plan-references.sh
```

**Validate PR descriptions**:
```yaml
# Require PR description from thoughts/
# or warn if missing
```

### Git Workflow Integration

**Feature Branch Workflow**:
```bash
# Create feature branch
git checkout -b feature/oauth-support

# Research phase
claude
> /research_codebase
git add thoughts/shared/research/
git commit -m "docs: research OAuth integration"

# Planning phase
> /create_plan
git add thoughts/shared/plans/
git commit -m "docs: plan OAuth implementation"

# Implementation
> /implement_plan thoughts/shared/plans/2025-01-15-oauth.md
# (makes code changes)
> /commit  # Creates implementation commits

# PR creation
> /describe_pr
# Copy generated description
git push origin feature/oauth-support
# Create PR with description
```

### Code Review Integration

**Add to PR template**:

```markdown
## Pre-Review Checklist

- [ ] Research document exists in `thoughts/shared/research/`
- [ ] Implementation plan exists in `thoughts/shared/plans/`
- [ ] All phases validated (automated + manual)
- [ ] PR description generated from `/describe_pr`

## Context

Research: [link to research doc]
Plan: [link to implementation plan]

Reviewers: Please read research and plan documents before reviewing code.
```

## Measuring Success

### Quantitative Metrics

**Development Velocity**:
- Time from ticket assignment to PR (should stabilize or decrease)
- Number of PR revisions needed (should decrease)
- Time spent in code review (should decrease with better context)

**Quality Metrics**:
- Bugs found in production (should decrease)
- Test coverage (should increase or stabilize at high level)
- Technical debt accumulation (should decrease)

**Workflow Adoption**:
- Percentage of PRs with research documents
- Percentage of PRs with implementation plans
- Number of shared research documents referenced
- Team usage of workflow commands

### Qualitative Feedback

**Developer Experience**:
- Survey: "Does the workflow improve your productivity?"
- Survey: "Are research documents valuable reference material?"
- Survey: "Does planning reduce implementation uncertainty?"

**Team Collaboration**:
- "Can you understand teammates' work more easily?"
- "Do research documents help with knowledge transfer?"
- "Is cross-referencing plans helpful?"

### Sample Survey (Monthly)

```
1. How often do you use the workflow? (1-5)
2. How valuable are research documents? (1-5)
3. How valuable are implementation plans? (1-5)
4. Does the workflow save you time overall? (1-5)
5. What's working well?
6. What needs improvement?
7. Specific suggestions?
```

## Common Challenges and Solutions

### Challenge: "Takes too long"

**Symptoms**:
- Developers skip research phase
- Plans are rushed
- "We just need to code"

**Solutions**:
- Start with complex features (where planning has obvious value)
- Show time savings: good plan = faster implementation
- Track: time spent planning vs. time spent debugging/refactoring
- Make research reusable (amortize cost across features)

### Challenge: "Not seeing the value"

**Symptoms**:
- Research documents not referenced
- Plans not followed
- Workflow feels like overhead

**Solutions**:
- Review example workflow from successful feature
- Show comparison: with workflow vs. without
- Highlight specific wins (bug prevented, refactor avoided)
- Adjust workflow to team needs (maybe full workflow only for complex features)

### Challenge: "Too prescriptive"

**Symptoms**:
- Developers want more flexibility
- Workflow feels rigid
- Customizations pile up

**Solutions**:
- Emphasize: templates are starting points
- Encourage customization for project needs
- Offer "light" mode (just research and planning, skip phases)
- Let team adapt workflow to their preferences

### Challenge: "Integration overhead"

**Symptoms**:
- Friction with existing tools
- Extra steps in git workflow
- CI/CD doesn't know about `thoughts/`

**Solutions**:
- Automate integration points (Linear sync, CI validation)
- Make `thoughts/` optional in CI (warning, not error)
- Create helper scripts for common integrations
- Document integration patterns clearly

### Challenge: "Knowledge silos"

**Symptoms**:
- Each developer has own style
- Research documents inconsistent
- Hard to find relevant documents

**Solutions**:
- Establish team conventions
- Create searchable index in `thoughts/searchable/`
- Regular "show and tell" of good examples
- Document search strategies for finding relevant research

### Challenge: "Onboarding new developers"

**Symptoms**:
- New developers overwhelmed
- Don't know how to use workflow
- Fall back to old habits

**Solutions**:
- Pair new developer with experienced one
- Assign first task with existing research/plan
- Provide "quick start" guide specific to your project
- Schedule training within first week

## Scaling Strategies

### Small Team (2-5 developers)

**Approach**: Full workflow for everything

**Benefits**:
- High collaboration
- Excellent knowledge sharing
- Thorough documentation

**Considerations**:
- May feel like overhead for tiny tasks
- Adjust: skip research/plan for very small fixes

### Medium Team (6-15 developers)

**Approach**: Full workflow for features, light mode for fixes

**Benefits**:
- Scales better
- Focus effort where it matters
- Maintains flexibility

**Workflow Tiers**:
- **Tier 1** (new features): Full research → plan → implement → validate
- **Tier 2** (enhancements): Quick research + plan, standard implement
- **Tier 3** (bug fixes): Skip research, basic plan, implement + validate

### Large Team (16+ developers)

**Approach**: Specialized roles + shared repository

**Structure**:
- Architecture team owns major research documents
- Feature teams reference and extend research
- Shared `thoughts/` directory becomes knowledge base
- Regular curation of outdated documents

**Considerations**:
- Need search/index strategy for large `thoughts/` directory
- Establish ownership model for documents
- Regular review/archival of old research

## Success Stories Template

Document successes to build momentum:

```markdown
# Success Story: OAuth Implementation

**Team**: Backend team
**Developer**: Alice
**Timeline**: Jan 10-17, 2025

## Challenge
Add OAuth support without understanding existing auth flow.

## How Workflow Helped
1. Research phase discovered undocumented JWT validation edge cases
2. Plan identified 3 phases instead of "just adding OAuth"
3. Implementation caught breaking change in phase 1 tests
4. Validation prevented deployment of incomplete feature

## Outcome
- Feature completed in 5 days (estimated 10 days without workflow)
- Zero bugs in production
- Authentication code now well-documented
- Other team members using research for related work

## Key Insight
"The research phase saved me days of debugging. I found edge cases I never would have discovered otherwise."

## Artifacts
- Research: `thoughts/shared/research/2025-01-10-authentication-flow.md`
- Plan: `thoughts/shared/plans/2025-01-12-oauth-support.md`
- PR: #234
```

Share success stories in team meetings, Slack, or documentation.

## Continuous Improvement

### Monthly Review

**Agenda**:
1. Review adoption metrics
2. Share success stories
3. Discuss challenges
4. Propose improvements to workflow
5. Update documentation

**Outputs**:
- Updated team conventions
- New customizations
- Refined training materials
- Action items for next month

### Quarterly Deep Dive

**Agenda**:
1. Analyze workflow impact on velocity and quality
2. Survey team satisfaction
3. Audit `thoughts/` directory (archive old docs)
4. Major workflow changes if needed
5. Plan for next quarter

**Outputs**:
- Workflow impact report
- Archived outdated research
- Major customization updates
- Roadmap for workflow improvements

## Resources for Team Leads

### Training Materials Checklist

- [ ] Installation guide for your project
- [ ] Customized command reference
- [ ] Worked examples from your codebase
- [ ] Video walkthrough (optional)
- [ ] FAQ based on your team's questions
- [ ] Integration guides (Linear, CI/CD, etc.)

### Support Structure

**Workflow Champion**:
- One developer becomes expert
- Answers questions
- Reviews research/plan quality
- Proposes improvements

**Office Hours**:
- Regular sessions for questions
- Screen share and help
- Build expertise across team

**Documentation**:
- Keep project-specific `.claude/README.md`
- Document team conventions
- Update based on learnings

## Getting Help

- Review examples in this repository
- Check troubleshooting in main README
- Open issue with specific challenge
- Share what you tried and what didn't work
