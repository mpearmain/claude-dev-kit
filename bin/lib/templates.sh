#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Replace placeholders in a file
replace_placeholders() {
    local file="$1"

    # Use @ as delimiter to avoid issues with / in paths
    safe_sed "$file" \
        -e "s@{{PROJECT_NAME}}@${PROJECT_NAME}@g" \
        -e "s@{{MAIN_SRC_DIR}}@${MAIN_SRC_DIR}@g" \
        -e "s@{{TEST_COMMAND}}@${TEST_COMMAND}@g" \
        -e "s@{{LINT_COMMAND}}@${LINT_COMMAND}@g" \
        -e "s@{{BUILD_COMMAND}}@${BUILD_COMMAND}@g" \
        -e "s@{{SETUP_COMMAND}}@${SETUP_COMMAND}@g"
}

# Install templates to target directory
install_templates() {
    local target_dir="$1"
    local templates_dir="$2"
    local dry_run="${3:-false}"

    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN - No changes will be made"
        echo ""
    fi

    # Create directory structure
    info "Creating directory structure..."
    if [[ "$dry_run" != "true" ]]; then
        mkdir -p "${target_dir}/.claude/commands"
        mkdir -p "${target_dir}/.claude/agents"
        mkdir -p "${target_dir}/thoughts/shared/research"
        mkdir -p "${target_dir}/thoughts/shared/plans"
        mkdir -p "${target_dir}/thoughts/shared/prs"
        mkdir -p "${target_dir}/thoughts/searchable"
    fi
    info "  ✓ Created .claude/ and thoughts/ directories"

    # Copy and transform commands
    info "\nInstalling slash commands..."
    if [[ -d "${templates_dir}/commands" ]]; then
        local cmd_count=0
        for cmd_file in "${templates_dir}/commands/"*.md; do
            if [[ -f "$cmd_file" ]]; then
                local filename=$(basename "$cmd_file")
                if [[ "$dry_run" != "true" ]]; then
                    cp "$cmd_file" "${target_dir}/.claude/commands/$filename"
                    replace_placeholders "${target_dir}/.claude/commands/$filename"
                fi
                ((cmd_count++))
                echo "  ✓ $filename"
            fi
        done
        info "  Installed $cmd_count commands"
    else
        warn "  ⚠ No commands directory found"
    fi

    # Copy and transform agents
    info "\nInstalling agents..."
    if [[ -d "${templates_dir}/agents" ]]; then
        local agent_count=0
        for agent_file in "${templates_dir}/agents/"*.md; do
            if [[ -f "$agent_file" ]]; then
                local filename=$(basename "$agent_file")
                # Skip specialist agents - they'll be installed separately
                if [[ "$filename" == "docker-specialist.md" ]] || \
                   [[ "$filename" == "api-architect.md" ]] || \
                   [[ "$filename" == "database-specialist.md" ]] || \
                   [[ "$filename" == "security-advisor.md" ]] || \
                   [[ "$filename" == "performance-analyst.md" ]] || \
                   [[ "$filename" == "testing-strategist.md" ]] || \
                   [[ "$filename" == "specialist-template.md" ]]; then
                    continue
                fi

                if [[ "$dry_run" != "true" ]]; then
                    cp "$agent_file" "${target_dir}/.claude/agents/$filename"
                    replace_placeholders "${target_dir}/.claude/agents/$filename"
                fi
                ((agent_count++))
                echo "  ✓ $filename"
            fi
        done
        info "  Installed $agent_count core agents"
    else
        warn "  ⚠ No agents directory found"
    fi

    # Create thoughts .gitignore
    if [[ "$dry_run" != "true" ]] && [[ ! -f "${target_dir}/thoughts/.gitignore" ]]; then
        info "\nCreating thoughts/.gitignore..."
        cat > "${target_dir}/thoughts/.gitignore" << 'EOF'
# Ignore searchable index (regenerated automatically)
searchable/

# Optionally ignore personal notes (uncomment if needed)
# personal/

# Keep shared artefacts committed
!shared/
EOF
        info "  ✓ Created thoughts/.gitignore"
    fi

    # Create thoughts README
    if [[ "$dry_run" != "true" ]] && [[ ! -f "${target_dir}/thoughts/README.md" ]]; then
        info "\nCreating thoughts/README.md..."
        cat > "${target_dir}/thoughts/README.md" << EOF
# Thoughts Directory

Development artefacts from the Claude Code workflow for ${PROJECT_NAME}.

## Structure

\`\`\`
thoughts/
├── shared/              # Team-visible artefacts (committed to git)
│   ├── research/       # Research documents (YYYY-MM-DD-*.md)
│   ├── plans/          # Implementation plans (YYYY-MM-DD-*.md)
│   └── prs/            # PR descriptions
├── personal/           # Private notes (gitignored, optional)
│   ├── tickets/
│   └── notes/
└── searchable/         # Search index (gitignored, auto-generated)
\`\`\`

## Usage

Run these commands in Claude Code:

- \`/research_codebase\` - Research and document codebase patterns
- \`/create_plan\` - Create detailed implementation plans
- \`/implement_plan\` - Execute plans phase-by-phase
- \`/validate_plan\` - Validate implementation correctness

All shared artefacts use date-based naming: \`YYYY-MM-DD-description.md\`
EOF
        info "  ✓ Created thoughts/README.md"
    fi
}
