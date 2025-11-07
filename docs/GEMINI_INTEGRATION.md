# Gemini Integration Guide

Complete guide to using Gemini CLI with Claude Code workflow for enhanced validation and analysis.

## Overview

Gemini CLI integration provides **model diversity** for validation. When multiple AI models independently converge on the same finding, confidence increases exponentially.

**Core principle**: Random model errors don't align. Convergent findings across Claude + Gemini = validated signal.

## Why Gemini?

### The Problem: Single-Model Bias

When using only Claude agents:
- All findings from same model family
- Potential for systematic blind spots
- Confidence based on internal cross-checking only

### The Solution: Multi-Model Validation

Adding Gemini:
- Independent model architecture
- Different training data and biases
- Cross-model convergence = higher confidence
- Validated architectural signals, not artifacts

### Example

**Claude only**:
```
3 Claude agents find src/auth.py as bottleneck
Confidence: Medium (same model, different searches)
```

**Claude + Gemini**:
```
3 Claude agents + 1 Gemini agent find src/auth.py
Confidence: HIGH (cross-model convergence)
```

## Installation

### Prerequisites

- Node.js or Python installed
- Gemini API key (free tier available)
- Claude Code workflow already installed

### Install Gemini CLI

**Via npm**:
```bash
npm install -g @google/generative-ai-cli
```

**Via pip**:
```bash
pip install google-generativeai-cli
```

### Configure API Key

Get free API key: https://makersuite.google.com/app/apikey

```bash
gemini config set api-key YOUR_API_KEY
```

### Verify Installation

```bash
gemini --version
# Should output version number

which gemini
# Should show path to gemini executable
```

### Run Installer

The workflow installer will detect Gemini:

```bash
cd path/to/claude-dev-kit
./install.sh /path/to/your-project

# Output includes:
✓ Detected Gemini CLI (optional enhanced analysis available)
```

## Usage Patterns

### Pattern 1: Convergence Validation (Recommended)

Use Gemini to validate convergent Claude findings.

**When**: Claude agents converge on critical component
**Why**: Cross-model validation increases confidence
**Cost**: 1-2 Gemini requests per research task

**Example**:

```bash
> /research_codebase
> Where are the main performance bottlenecks?

# Claude agents work:
✓ codebase-locator found 5 suspicious files
✓ codebase-analyzer identified 2 key bottlenecks
✓ pattern-finder found anti-patterns in same 2 files

# Convergence detected on database query handler
# Spawn gemini-analyzer for validation
> Agent spawns: gemini-analyzer validate-bottleneck database_queries.py

# Gemini confirms: database N+1 queries in same file
# Confidence: HIGH (cross-model convergence)
```

**Output**:

```markdown
## High-Confidence Findings (Cross-Model Convergent)

### src/database/queries.py - Found by 4 agents (2 models)
- **codebase-locator (Claude)**: Performance hotspot search
- **codebase-analyzer (Claude)**: N+1 query detection
- **pattern-finder (Claude)**: Anti-pattern search
- **gemini-analyzer (Gemini)**: Independent validation
- **Significance**: Cross-model convergence = validated bottleneck
```

### Pattern 2: Quick Health Check

Use Gemini for fast project health assessment.

**When**: Before starting major work
**Why**: Fast feedback on obvious issues
**Cost**: 1 Gemini request

**Example**:

```bash
> /research_codebase
> Quick project health check

# Spawns gemini-analyzer quick-check
# Examines: package.json, config files, entry points
# Returns: "Project configured correctly, no blockers"
```

### Pattern 3: Pattern Search at Scale

Use Gemini for targeted pattern searches in large directories.

**When**: Searching for specific patterns across many files
**Why**: Gemini can scan large directories quickly
**Cost**: 1-2 Gemini requests depending on scope

**Example**:

```bash
> /research_codebase
> Find all deprecated API usages

# Gemini pattern-search across src/
# Returns: List of files with line numbers
# Claude agents then analyze specific files in detail
```

### Pattern 4: Feasibility Validation

Use Gemini to validate plan feasibility before implementation.

**When**: After creating implementation plan
**Why**: Independent check for conflicts/dependencies
**Cost**: 1 Gemini request

**Example**:

```bash
> /create_plan
# ... plan created ...

> /validate_feasibility thoughts/shared/plans/2025-01-15-feature.md

# Gemini analyzes proposed changes
# Checks for: conflicts, missing dependencies, architectural risks
# Returns: feasibility assessment
```

## Cost Management

### Understanding Quotas

**Free Tier (Typical)**:
- ~1500 requests per day
- Rate limited (60 requests per minute)
- Sufficient for development workflow

**Paid Tier**:
- Higher quotas
- Faster rate limits
- Only needed for heavy usage

### Strategic Usage

**Daily workflow example**:
```
Research tasks per day: 5-10
Claude agents per task: 3-5 (unlimited)
Gemini calls per task: 1-2 (counted)

Daily Gemini usage: 5-20 requests
Percentage of quota: 0.3-1.3%
```

**Conclusion**: Free tier is sufficient for daily development.

### Optimization Strategies

1. **Use Gemini selectively**
   - Validate convergent findings only
   - Skip for routine research
   - Reserve for critical decisions

2. **Batch validation**
   - Accumulate findings
   - Validate multiple in one request
   - Saves quota

3. **Target specific files**
   - Use `@specific/file.py` not `@.`
   - Reduces token usage
   - Faster response

4. **Monitor quota**
   ```bash
   # Check remaining quota (varies by CLI)
   gemini quota
   ```

## Agent Configuration

### gemini-analyzer Agent

Located: `.claude/agents/gemini-analyzer.md`

**Check Types**:

1. **initial** - Core architecture analysis
   ```bash
   # Analyzes main src directory
   # Focus: component structure, state management, API patterns
   ```

2. **pattern-search** - Find specific pattern
   ```bash
   # Search for pattern in directory
   # Returns: files with line numbers
   ```

3. **quick-check** - Health check
   ```bash
   # Minimal token usage
   # Checks: config, entry points, obvious issues
   ```

4. **validate-feasibility** - Plan validation
   ```bash
   # Check proposed changes viability
   # Focus: conflicts, dependencies
   ```

5. **custom** - Direct command
   ```bash
   # Pass-through for custom analysis
   ```

### Customization

Edit `.claude/agents/gemini-analyzer.md` to:
- Add project-specific check types
- Modify prompts for your domain
- Adjust token limits
- Add validation rules

**Example**:

```bash
# Add custom check type
case "$CHECK_TYPE" in
    # ... existing types ...

    "security-scan")
        gemini @src/ -p "Scan for security vulnerabilities: SQL injection, XSS, insecure dependencies"
        ;;
esac
```

## Troubleshooting

### Gemini Not Found

**Symptom**: `⚠️ Gemini CLI not installed`

**Solution**:
```bash
# Install via npm
npm install -g @google/generative-ai-cli

# Or via pip
pip install google-generativeai-cli

# Verify
which gemini
```

### API Key Issues

**Symptom**: `Error: API key not configured`

**Solution**:
```bash
# Get key: https://makersuite.google.com/app/apikey
gemini config set api-key YOUR_API_KEY

# Test
gemini -p "test prompt"
```

### Quota Exceeded

**Symptom**: `⚠️ Gemini quota exceeded`

**Solution**: Workflow continues with Claude-only analysis. Options:
1. Wait for quota reset (usually 24 hours)
2. Upgrade to paid tier
3. Use Claude agents only (workflow still works)

### Slow Response

**Symptom**: Gemini takes >30 seconds

**Causes**:
- Large directory scan
- Rate limiting
- Network issues

**Solutions**:
- Target specific files: `@src/specific/` not `@src/`
- Use shorter prompts
- Check network connection

### Wrong Results

**Symptom**: Gemini findings don't match Claude

**This is normal**: Different models, different perspectives.

**Action**: When models diverge:
1. Note divergence (complex problem space)
2. Investigate both perspectives
3. Use human judgment
4. Don't assume Claude is "right"

**Remember**: Divergence ≠ failure. It signals complexity.

## Best Practices

### 1. Use for Validation, Not Discovery

**Good**:
```
Claude agents discover bottleneck → Gemini validates
```

**Poor**:
```
Gemini discovers everything → Claude unused
```

**Rationale**: Claude has better tool integration for discovery. Gemini excels at independent validation.

### 2. Validate Convergent Findings Only

**Good**:
```
3 Claude agents converge on src/auth.py → Gemini validates
```

**Poor**:
```
Every single file Claude finds → Gemini validates each
```

**Rationale**: Quota preservation. Convergence already indicates importance.

### 3. Use Targeted Searches

**Good**:
```bash
gemini @src/api/ -p "Find auth issues in API layer"
```

**Poor**:
```bash
gemini @. -p "Find all issues in entire codebase"
```

**Rationale**: Token efficiency, faster response, quota preservation.

### 4. Accept Graceful Degradation

**Good**:
```
Gemini unavailable → Continue with Claude agents
```

**Poor**:
```
Gemini unavailable → Block entire workflow
```

**Rationale**: Gemini is enhancement, not requirement.

### 5. Document Cross-Model Findings

**Good**:
```markdown
### Bottleneck (Cross-Model)
- Claude: N+1 queries detected
- Gemini: Same file flagged for query inefficiency
- Confidence: HIGH
```

**Poor**:
```markdown
### Bottleneck
- Found in src/database.py
```

**Rationale**: Confidence level visible to team.

## Integration with Existing Workflow

### Research Phase

Gemini spawned automatically if available:

```bash
> /research_codebase
# ... research question ...

# Workflow spawns:
# - codebase-locator (Claude)
# - codebase-analyzer (Claude)
# - pattern-finder (Claude)
# - gemini-analyzer (Gemini) ← automatic if installed

# Convergence detected and validated
```

### Planning Phase

Use Gemini for feasibility checks:

```bash
> /create_plan
# ... plan created ...

# Optional validation:
> Spawn gemini-analyzer validate-feasibility

# Gemini checks:
# - Can changes be implemented safely?
# - Any obvious conflicts?
# - Missing dependencies?
```

### Implementation Phase

Gemini typically not used during implementation (Claude has better tool access).

### Validation Phase

Use Gemini for independent test verification:

```bash
> /validate_plan
# ... tests run ...

# Optional cross-check:
> Spawn gemini-analyzer validate-tests

# Gemini verifies:
# - Test coverage adequate?
# - Edge cases covered?
# - Test quality acceptable?
```

## Advanced Usage

### Multi-Stage Validation

For critical architectural decisions:

```bash
# Stage 1: Claude research
> /research_codebase
# → 5 Claude agents analyze architecture

# Stage 2: Gemini validation
> Spawn gemini-analyzer validate-architecture
# → Gemini independently assesses

# Stage 3: Cross-model synthesis
# → Identify convergent findings
# → Note divergent perspectives
# → Make informed decision
```

### Pattern: The God Object Detector

Replicate the article's 5-agent convergence:

```bash
# Spawn 5 orthogonal Claude agents:
# 1. Navigation analysis
# 2. State management analysis
# 3. Component coupling analysis
# 4. Data flow analysis
# 5. Type safety analysis

# Plus Gemini for 6th perspective:
# 6. gemini-analyzer architectural-scan

# If 4+ agents converge on same file:
# → God Object confirmed (cross-model validated)
```

### Custom Validation Workflows

Create project-specific validation:

```bash
# .claude/commands/security_audit.md

1. Claude agents scan for security issues
2. Gemini validates findings
3. Cross-model convergence = real vulnerability
4. Divergence = requires manual review
```

## Comparison: With vs Without Gemini

### Without Gemini (Claude Only)

**Advantages**:
- No quota management
- Faster (no cross-model wait)
- Simpler workflow

**Limitations**:
- Single model perspective
- Confidence based on internal validation only
- Potential systematic blind spots

**Best for**:
- Routine feature work
- Small codebases
- Time-critical analysis

### With Gemini (Claude + Gemini)

**Advantages**:
- Cross-model validation
- Higher confidence findings
- Independent verification
- Catches more edge cases

**Limitations**:
- Quota management required
- Slightly slower (cross-model synthesis)
- Additional configuration

**Best for**:
- Critical architectural decisions
- Large codebase audits
- High-stakes refactoring

## Conclusion

Gemini integration enhances the workflow through **model diversity**. Use strategically for validation, not discovery. The workflow remains fully functional without Gemini—it's an optional confidence multiplier for critical decisions.

**Key takeaway**: Random model errors don't align. When Claude and Gemini converge independently, trust the finding.
