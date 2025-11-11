#!/usr/bin/env bash
set -euo pipefail

# Claude Code Workflow Installer
# Installs slash commands and agents into target project with smart defaults

VERSION="1.0.0"

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Script directory (where templates live)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

# Global variables for detected/configured values
PROJECT_NAME=""
MAIN_SRC_DIR=""
TEST_COMMAND=""
LINT_COMMAND=""
BUILD_COMMAND=""
SETUP_COMMAND=""

error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}$1${NC}"
}

header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS] [TARGET_DIR]

Installs Claude Code workflow templates into a target project.

Arguments:
  TARGET_DIR    Path to target project (default: current directory)

Options:
  -h, --help    Show this help message
  -v, --version Show version
  --dry-run     Show what would be installed without making changes
  --force       Overwrite existing .claude directory without prompting

Examples:
  $0                          # Install in current directory
  $0 ../my-project            # Install in specific project
  $0 --force .                # Force reinstall in current directory
EOF
    exit 0
}

# Detect project type and suggest defaults
detect_project_context() {
    local target_dir="$1"

    info "Detecting project context..."

    # Detect project name from directory or git
    if [[ -d "$target_dir/.git" ]]; then
        PROJECT_NAME=$(basename "$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null || echo "$target_dir")")
    else
        PROJECT_NAME=$(basename "$target_dir")
    fi

    # Python detection
    if [[ -f "$target_dir/pyproject.toml" ]]; then
        info "  ✓ Detected Python project"
        MAIN_SRC_DIR="src"

        if [[ -f "$target_dir/uv.lock" ]]; then
            info "  ✓ Detected uv package manager"
            TEST_COMMAND="uv run pytest"
            LINT_COMMAND="uv run ruff check"
            BUILD_COMMAND="uv build"
            SETUP_COMMAND="uv sync"
        elif [[ -f "$target_dir/poetry.lock" ]]; then
            info "  ✓ Detected Poetry package manager"
            TEST_COMMAND="poetry run pytest"
            LINT_COMMAND="poetry run ruff check"
            BUILD_COMMAND="poetry build"
            SETUP_COMMAND="poetry install"
        else
            TEST_COMMAND="pytest"
            LINT_COMMAND="ruff check"
            BUILD_COMMAND="python -m build"
            SETUP_COMMAND="pip install -e ."
        fi
        return
    fi

    # Node.js detection
    if [[ -f "$target_dir/package.json" ]]; then
        info "  ✓ Detected Node.js project"
        MAIN_SRC_DIR="src"

        if [[ -f "$target_dir/pnpm-lock.yaml" ]]; then
            info "  ✓ Detected pnpm package manager"
            TEST_COMMAND="pnpm test"
            LINT_COMMAND="pnpm run lint"
            BUILD_COMMAND="pnpm run build"
            SETUP_COMMAND="pnpm install"
        elif [[ -f "$target_dir/yarn.lock" ]]; then
            info "  ✓ Detected Yarn package manager"
            TEST_COMMAND="yarn test"
            LINT_COMMAND="yarn lint"
            BUILD_COMMAND="yarn build"
            SETUP_COMMAND="yarn install"
        else
            TEST_COMMAND="npm test"
            LINT_COMMAND="npm run lint"
            BUILD_COMMAND="npm run build"
            SETUP_COMMAND="npm install"
        fi
        return
    fi

    # Go detection
    if [[ -f "$target_dir/go.mod" ]]; then
        info "  ✓ Detected Go project"
        MAIN_SRC_DIR="."
        TEST_COMMAND="go test ./..."
        LINT_COMMAND="golangci-lint run"
        BUILD_COMMAND="go build ./..."
        SETUP_COMMAND="go mod download"
        return
    fi

    # Rust detection
    if [[ -f "$target_dir/Cargo.toml" ]]; then
        info "  ✓ Detected Rust project"
        MAIN_SRC_DIR="src"
        TEST_COMMAND="cargo test"
        LINT_COMMAND="cargo clippy"
        BUILD_COMMAND="cargo build"
        SETUP_COMMAND="cargo fetch"
        return
    fi

    # Terraform detection
    if [[ -f "$target_dir/main.tf" ]] || [[ -d "$target_dir/modules" ]]; then
        info "  ✓ Detected Terraform project"
        MAIN_SRC_DIR="modules"
        TEST_COMMAND="terraform validate"
        LINT_COMMAND="tflint"
        BUILD_COMMAND="terraform plan"
        SETUP_COMMAND="terraform init"
        return
    fi

    # Defaults if nothing detected
    warn "  ⚠ Could not detect project type - using generic defaults"
    MAIN_SRC_DIR="src"
    TEST_COMMAND="make test"
    LINT_COMMAND="make lint"
    BUILD_COMMAND="make build"
    SETUP_COMMAND="make install"
}

# Check for optional tools
check_optional_tools() {
    # Check for Gemini CLI (optional enhanced analysis)
    if command -v gemini &> /dev/null; then
        info "  ✓ Detected Gemini CLI (optional enhanced analysis available)"
    fi
}

# Optional Agent Selection Menu
show_agent_menu() {
    echo -e "\n${BLUE}═══ Optional Workflow Agents ═══${NC}\n"
    echo "Select additional agents to enhance your workflow:"
    echo ""
    echo "  ${GREEN}[1]${NC} Docker Specialist    - Container optimization & best practices"
    echo "  ${GREEN}[2]${NC} API Architect       - REST/GraphQL API design patterns"
    echo "  ${GREEN}[3]${NC} Database Specialist - Schema design & query optimization"
    echo "  ${GREEN}[4]${NC} Security Advisor    - Security best practices & vulnerability prevention"
    echo "  ${GREEN}[5]${NC} Performance Analyst - Performance optimization & profiling"
    echo "  ${GREEN}[6]${NC} Testing Strategist  - Test architecture & coverage strategies"
    echo ""
    echo "  ${GREEN}[a]${NC} Install all agents"
    echo "  ${GREEN}[n]${NC} Skip optional agents"
    echo ""
    echo -e "${YELLOW}You can add more agents later by copying from templates/agents/${NC}"
    echo ""
    read -p "Enter choices (e.g., 1,3,5 or 'a' for all): " agent_choices

    local selected_agents=()

    if [[ "$agent_choices" == "a" ]]; then
        selected_agents=("docker-specialist" "api-architect" "database-specialist"
                        "security-advisor" "performance-analyst" "testing-strategist")
    elif [[ "$agent_choices" != "n" ]]; then
        IFS=',' read -ra choices <<< "$agent_choices"
        for choice in "${choices[@]}"; do
            case ${choice// /} in
                1) selected_agents+=("docker-specialist") ;;
                2) selected_agents+=("api-architect") ;;
                3) selected_agents+=("database-specialist") ;;
                4) selected_agents+=("security-advisor") ;;
                5) selected_agents+=("performance-analyst") ;;
                6) selected_agents+=("testing-strategist") ;;
            esac
        done
    fi

    # Return selected agents array
    echo "${selected_agents[@]}"
}

# Setup specialist configuration based on selections
setup_specialist_config() {
    local target_dir="$1"
    shift
    local selected_agents=("$@")

    # Copy base configuration file
    cp "$TEMPLATES_DIR/.claude-specialists.yml" "$target_dir/.claude/"

    # Create a temporary file for modifications
    local temp_file="${target_dir}/.claude/.claude-specialists.yml.tmp"
    local config_file="${target_dir}/.claude/.claude-specialists.yml"

    # Enable selected specialists in the configuration using simple bash
    for agent in "${selected_agents[@]}"; do
        local specialist_key=""
        case $agent in
            docker-specialist)
                specialist_key="docker"
                ;;
            api-architect)
                specialist_key="api"
                ;;
            database-specialist)
                specialist_key="database"
                ;;
            security-advisor)
                specialist_key="security"
                ;;
            performance-analyst)
                specialist_key="performance"
                ;;
            testing-strategist)
                specialist_key="testing"
                ;;
        esac

        if [[ -n "$specialist_key" ]]; then
            # Read the file and update the enabled flag for this specialist
            awk -v key="$specialist_key" '
                /^[[:space:]]*'"$specialist_key"':/ { found=1 }
                found && /enabled:/ {
                    sub(/false/, "true");
                    found=0
                }
                { print }
            ' "$config_file" > "$temp_file"
            mv "$temp_file" "$config_file"
        fi
    done

    info "  ✓ Specialist configuration created"
}

# Pre-commit detection and setup
setup_precommit() {
    local target_dir="$1"

    if [[ -f "$target_dir/.pre-commit-config.yaml" ]]; then
        echo -e "\n${BLUE}Pre-commit hooks detected${NC}"
        echo -e "${GREEN}Enable commit validation workflow? (y/n)${NC}"
        read -r ENABLE_PRECOMMIT

        if [[ "$ENABLE_PRECOMMIT" == "y" ]]; then
            # Copy checklist
            cp "$TEMPLATES_DIR/COMMIT_CHECKLIST.md" "$target_dir/.claude/"

            # Customize based on language
            local PRECOMMIT_CMD="pre-commit run --all-files"
            local VERIFY_CMDS=""
            local MAIN_LANGUAGE=""

            # Detect main language
            if [[ -f "$target_dir/pyproject.toml" ]] || [[ -f "$target_dir/setup.py" ]]; then
                MAIN_LANGUAGE="python"
            elif [[ -f "$target_dir/package.json" ]]; then
                MAIN_LANGUAGE="javascript"
            elif [[ -f "$target_dir/go.mod" ]]; then
                MAIN_LANGUAGE="go"
            fi

            case $MAIN_LANGUAGE in
                python)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="# Type checking\n$TEST_COMMAND\n$LINT_COMMAND"

                    # Enable Python hooks in pre-commit config if not exists
                    if [[ ! -f "$target_dir/.pre-commit-config.yaml" ]]; then
                        cp "$TEMPLATES_DIR/.pre-commit-config.yaml" "$target_dir/"
                        # Uncomment Python hooks
                        sed -i.bak 's/# - repo:.*ruff/- repo:/' "$target_dir/.pre-commit-config.yaml"
                        sed -i.bak 's/#   /  /' "$target_dir/.pre-commit-config.yaml"
                        rm -f "$target_dir/.pre-commit-config.yaml.bak"
                    fi
                    ;;
                javascript)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="$TEST_COMMAND\n$LINT_COMMAND\n$BUILD_COMMAND"

                    # Enable JS hooks
                    if [[ ! -f "$target_dir/.pre-commit-config.yaml" ]]; then
                        cp "$TEMPLATES_DIR/.pre-commit-config.yaml" "$target_dir/"
                        # Uncomment JS hooks
                        sed -i.bak 's/# - repo:.*prettier/- repo:/' "$target_dir/.pre-commit-config.yaml"
                        sed -i.bak 's/#   /  /' "$target_dir/.pre-commit-config.yaml"
                        rm -f "$target_dir/.pre-commit-config.yaml.bak"
                    fi
                    ;;
                go)
                    PRECOMMIT_CMD="pre-commit run --all-files"
                    VERIFY_CMDS="$TEST_COMMAND\n$LINT_COMMAND\n$BUILD_COMMAND"
                    ;;
                *)
                    VERIFY_CMDS="$TEST_COMMAND\n$LINT_COMMAND"
                    ;;
            esac

            # Replace placeholders in checklist
            sed -i.bak "s|{{PRE_COMMIT_COMMAND}}|$PRECOMMIT_CMD|g" "$target_dir/.claude/COMMIT_CHECKLIST.md"
            sed -i.bak "s|{{VERIFICATION_COMMANDS}}|$VERIFY_CMDS|g" "$target_dir/.claude/COMMIT_CHECKLIST.md"
            rm -f "$target_dir/.claude/COMMIT_CHECKLIST.md.bak"

            info "  ✓ Commit validation workflow enabled"
            warn "Remember to run 'pre-commit install' to set up hooks"
        fi
    else
        echo -e "\n${YELLOW}No pre-commit configuration found. Skipping validation setup.${NC}"
        echo -e "${YELLOW}To enable later, create .pre-commit-config.yaml and re-run installer${NC}"
    fi
}

# Code quality standards setup
setup_quality_standards() {
    local target_dir="$1"

    info "\nSetting up code quality standards..."

    # Copy standards template
    cp "$TEMPLATES_DIR/CODE_QUALITY_STANDARDS.md" "$target_dir/.claude/"

    # Customize based on language
    local MIN_COVERAGE="80"
    local MAIN_LANGUAGE=""

    # Detect main language
    if [[ -f "$target_dir/pyproject.toml" ]] || [[ -f "$target_dir/setup.py" ]]; then
        MAIN_LANGUAGE="python"
    elif [[ -f "$target_dir/package.json" ]]; then
        # Check if TypeScript
        if [[ -f "$target_dir/tsconfig.json" ]]; then
            MAIN_LANGUAGE="typescript"
        else
            MAIN_LANGUAGE="javascript"
        fi
    elif [[ -f "$target_dir/go.mod" ]]; then
        MAIN_LANGUAGE="go"
    elif [[ -f "$target_dir/Cargo.toml" ]]; then
        MAIN_LANGUAGE="rust"
    else
        MAIN_LANGUAGE="generic"
    fi

    case $MAIN_LANGUAGE in
        python)
            sed -i.bak 's/{{MAIN_LANGUAGE}}/Python/g' "$target_dir/.claude/CODE_QUALITY_STANDARDS.md"
            # Remove JS-specific sections (everything between ### JavaScript/TypeScript and ### Python)
            awk '/### JavaScript\/TypeScript/{flag=1} /### Python/{flag=0; print; next} !flag' \
                "$target_dir/.claude/CODE_QUALITY_STANDARDS.md" > "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.tmp"
            mv "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.tmp" "$target_dir/.claude/CODE_QUALITY_STANDARDS.md"
            ;;
        javascript|typescript)
            sed -i.bak "s/{{MAIN_LANGUAGE}}/$MAIN_LANGUAGE/g" "$target_dir/.claude/CODE_QUALITY_STANDARDS.md"
            # Remove Python-specific sections (everything between ### Python and ## Dead Code Removal)
            awk '/### Python/{flag=1} /## Dead Code Removal/{flag=0; print; next} !flag' \
                "$target_dir/.claude/CODE_QUALITY_STANDARDS.md" > "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.tmp"
            mv "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.tmp" "$target_dir/.claude/CODE_QUALITY_STANDARDS.md"
            ;;
        *)
            sed -i.bak "s/{{MAIN_LANGUAGE}}/$MAIN_LANGUAGE/g" "$target_dir/.claude/CODE_QUALITY_STANDARDS.md"
            ;;
    esac

    sed -i.bak "s/{{MIN_COVERAGE}}/$MIN_COVERAGE/g" "$target_dir/.claude/CODE_QUALITY_STANDARDS.md"
    rm -f "$target_dir/.claude/CODE_QUALITY_STANDARDS.md.bak"

    info "  ✓ Code quality standards configured for $MAIN_LANGUAGE"
}

# Commitlint setup
setup_commitlint() {
    local target_dir="$1"

    info "\nSetting up commit conventions..."

    # Copy templates
    cp "$TEMPLATES_DIR/COMMIT_SCOPES.yml" "$target_dir/.claude/"
    cp "$TEMPLATES_DIR/.commitlintrc.yml" "$target_dir/"

    # Detect project type and suggest scopes
    local DETECTED_SCOPES=""

    # Check for common directories/files to suggest scopes
    [[ -d "$target_dir/api" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - api\n"
    [[ -d "$target_dir/auth" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - auth\n"
    [[ -d "$target_dir/components" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - components\n"
    [[ -d "$target_dir/pages" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - pages\n"
    [[ -d "$target_dir/models" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - models\n"
    [[ -d "$target_dir/routes" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - routes\n"
    [[ -d "$target_dir/services" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - services\n"
    [[ -d "$target_dir/utils" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - utils\n"
    [[ -f "$target_dir/Dockerfile" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - docker\n"
    [[ -d "$target_dir/k8s" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - k8s\n"
    [[ -d "$target_dir/terraform" ]] && DETECTED_SCOPES="$DETECTED_SCOPES  - terraform\n"

    if [[ -n "$DETECTED_SCOPES" ]]; then
        info "Detected project scopes:"
        echo -e "$DETECTED_SCOPES"

        # Add to COMMIT_SCOPES.yml after "# Features" comment
        # Using awk to insert after the Features line
        awk -v scopes="$DETECTED_SCOPES" '
            /# Features/ {
                print
                printf "%s", scopes
                next
            }
            { print }
        ' "$target_dir/.claude/COMMIT_SCOPES.yml" > "$target_dir/.claude/COMMIT_SCOPES.yml.tmp"
        mv "$target_dir/.claude/COMMIT_SCOPES.yml.tmp" "$target_dir/.claude/COMMIT_SCOPES.yml"
    fi

    # Check if package.json exists for npm setup
    if [[ -f "$target_dir/package.json" ]]; then
        warn "To complete commitlint setup:"
        warn "1. Install commitlint:"
        warn "   npm install --save-dev @commitlint/cli @commitlint/config-conventional"
        warn "2. Add to package.json scripts:"
        warn '   "commitlint": "commitlint --edit"'
        warn "3. Configure git hook:"
        warn "   npx husky add .husky/commit-msg 'npx commitlint --edit \$1'"
    fi

    # For Python projects
    if [[ -f "$target_dir/pyproject.toml" ]]; then
        warn "To complete commitlint setup:"
        warn "1. Install commitizen:"
        warn "   pip install commitizen"
        warn "2. Add to pyproject.toml:"
        warn "   [tool.commitizen]"
        warn "   name = 'cz_conventional_commits'"
        warn "3. Use 'cz commit' for interactive commits"
    fi

    info "  ✓ Commit conventions configured"
    warn "Remember to customize scopes in .claude/COMMIT_SCOPES.yml"
}

# Prompt user for values with defaults
prompt_for_values() {
    local interactive="${1:-true}"

    if [[ "$interactive" != "true" ]]; then
        info "Using auto-detected values (non-interactive mode)"
        return
    fi

    header "Configuration"

    echo -e "${BLUE}Press Enter to accept detected defaults, or type custom values:${NC}\n"

    read -p "Project name [$PROJECT_NAME]: " input
    PROJECT_NAME="${input:-$PROJECT_NAME}"

    read -p "Main source directory [$MAIN_SRC_DIR]: " input
    MAIN_SRC_DIR="${input:-$MAIN_SRC_DIR}"

    read -p "Test command [$TEST_COMMAND]: " input
    TEST_COMMAND="${input:-$TEST_COMMAND}"

    read -p "Lint command [$LINT_COMMAND]: " input
    LINT_COMMAND="${input:-$LINT_COMMAND}"

    read -p "Build command [$BUILD_COMMAND]: " input
    BUILD_COMMAND="${input:-$BUILD_COMMAND}"

    read -p "Setup/install command [$SETUP_COMMAND]: " input
    SETUP_COMMAND="${input:-$SETUP_COMMAND}"

    echo ""
}

# Replace placeholders in a file
replace_placeholders() {
    local file="$1"

    # Use @ as delimiter to avoid issues with / in paths
    sed -i.bak \
        -e "s@{{PROJECT_NAME}}@${PROJECT_NAME}@g" \
        -e "s@{{MAIN_SRC_DIR}}@${MAIN_SRC_DIR}@g" \
        -e "s@{{TEST_COMMAND}}@${TEST_COMMAND}@g" \
        -e "s@{{LINT_COMMAND}}@${LINT_COMMAND}@g" \
        -e "s@{{BUILD_COMMAND}}@${BUILD_COMMAND}@g" \
        -e "s@{{SETUP_COMMAND}}@${SETUP_COMMAND}@g" \
        "$file"

    # Remove backup file
    rm -f "${file}.bak"
}

# Install templates to target directory
install_templates() {
    local target_dir="$1"
    local dry_run="${2:-false}"

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
    if [[ -d "${TEMPLATES_DIR}/commands" ]]; then
        local cmd_count=0
        for cmd_file in "${TEMPLATES_DIR}/commands/"*.md; do
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
    if [[ -d "${TEMPLATES_DIR}/agents" ]]; then
        local agent_count=0
        for agent_file in "${TEMPLATES_DIR}/agents/"*.md; do
            if [[ -f "$agent_file" ]]; then
                local filename=$(basename "$agent_file")
                if [[ "$dry_run" != "true" ]]; then
                    cp "$agent_file" "${target_dir}/.claude/agents/$filename"
                    replace_placeholders "${target_dir}/.claude/agents/$filename"
                fi
                ((agent_count++))
                echo "  ✓ $filename"
            fi
        done
        info "  Installed $agent_count agents"
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

# Print installation summary
print_summary() {
    local target_dir="$1"

    header "Installation Complete!"

    info "Project: ${PROJECT_NAME}"
    info "Location: ${target_dir}"
    echo ""
    info "Configuration:"
    echo "  Source directory: ${MAIN_SRC_DIR}"
    echo "  Test command:     ${TEST_COMMAND}"
    echo "  Lint command:     ${LINT_COMMAND}"
    echo "  Build command:    ${BUILD_COMMAND}"
    echo "  Setup command:    ${SETUP_COMMAND}"
    echo ""

    header "Available Commands"
    info "Core workflow:"
    echo "  /research_codebase  - Research and document codebase patterns"
    echo "  /create_plan        - Create detailed implementation plans"
    echo "  /implement_plan     - Execute plans phase-by-phase"
    echo "  /validate_plan      - Validate implementation correctness"
    echo ""
    info "Supporting commands:"
    echo "  /commit             - Create structured git commits"
    echo "  /describe_pr        - Generate PR descriptions"
    echo "  /linear             - Interact with Linear issues"
    echo "  /local_review       - Review code changes"
    echo "  /debug              - Debug issues systematically"
    echo "  /founder_mode       - High-level strategic mode"
    echo ""

    header "Next Steps"
    warn "1. Review installed commands: .claude/commands/*.md"
    warn "2. Customize any commands for your specific needs"
    warn "3. Create thoughts/personal/ directory for private notes (optional)"
    warn "4. Start using: cd ${target_dir} && claude"
    echo ""
}

# Main installation flow
main() {
    local target_dir="."
    local dry_run=false
    local force=false
    local interactive=true

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -v|--version)
                echo "Claude Code Workflow Installer v${VERSION}"
                exit 0
                ;;
            --dry-run)
                dry_run=true
                interactive=false  # Dry-run implies non-interactive
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            --non-interactive)
                interactive=false
                shift
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done

    # Resolve target directory
    if [[ ! -d "$target_dir" ]]; then
        error "Target directory does not exist: $target_dir"
    fi
    target_dir="$(cd "$target_dir" && pwd)"

    # Verify templates directory exists
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        error "Templates directory not found: ${TEMPLATES_DIR}"
    fi

    # Check if .claude already exists
    if [[ -d "${target_dir}/.claude" ]] && [[ "$force" != "true" ]]; then
        warn "Directory ${target_dir}/.claude already exists."
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Installation cancelled."
            exit 0
        fi
    fi

    header "Claude Code Workflow Installer v${VERSION}"

    # Detect project context
    detect_project_context "$target_dir"

    # Check for optional tools
    check_optional_tools

    # Prompt for values
    prompt_for_values "$interactive"

    # Show agent menu if interactive and save selected agents
    local selected_specialist_agents=""
    if [[ "$interactive" == "true" ]] && [[ "$dry_run" != "true" ]]; then
        selected_specialist_agents=$(show_agent_menu)
    fi

    # Install templates
    install_templates "$target_dir" "$dry_run"

    # Install selected specialist agents
    if [[ -n "$selected_specialist_agents" ]] && [[ "$dry_run" != "true" ]]; then
        info "\nInstalling selected specialist agents..."
        for agent in $selected_specialist_agents; do
            if [[ -f "$TEMPLATES_DIR/agents/${agent}.md" ]]; then
                cp "$TEMPLATES_DIR/agents/${agent}.md" "${target_dir}/.claude/agents/"
                replace_placeholders "${target_dir}/.claude/agents/${agent}.md"
                echo "  ✓ ${agent}"
            fi
        done

        # Setup configuration for selected agents
        if [[ -n "$selected_specialist_agents" ]]; then
            setup_specialist_config "$target_dir" $selected_specialist_agents
        fi
    fi

    # Setup pre-commit if detected
    if [[ "$interactive" == "true" ]] && [[ "$dry_run" != "true" ]]; then
        setup_precommit "$target_dir"
    fi

    # Setup code quality standards
    if [[ "$dry_run" != "true" ]]; then
        setup_quality_standards "$target_dir"
    fi

    # Setup commit conventions
    if [[ "$dry_run" != "true" ]]; then
        setup_commitlint "$target_dir"
    fi

    # Print summary
    if [[ "$dry_run" != "true" ]]; then
        print_summary "$target_dir"
    else
        info "\nDry run complete. Run without --dry-run to install."
    fi
}

main "$@"
