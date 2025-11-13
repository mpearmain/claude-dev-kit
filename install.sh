#!/usr/bin/env bash
set -euo pipefail

# Claude Code Workflow Installer
# Installs slash commands and agents into target project with smart defaults

VERSION="2.0.0"

# Script directory (where templates live)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"
LIB_DIR="${SCRIPT_DIR}/bin/lib"

# Load library modules
source "${LIB_DIR}/common.sh"
source "${LIB_DIR}/detect.sh"
source "${LIB_DIR}/templates.sh"
source "${LIB_DIR}/specialists.sh"
source "${LIB_DIR}/precommit.sh"
source "${LIB_DIR}/quality.sh"
source "${LIB_DIR}/commitlint.sh"

# Global variables for detected/configured values
PROJECT_NAME=""
MAIN_SRC_DIR=""
TEST_COMMAND=""
LINT_COMMAND=""
BUILD_COMMAND=""
SETUP_COMMAND=""
MIN_COVERAGE="80"  # Default coverage threshold

usage() {
    cat << EOF
Usage: $0 [OPTIONS] [TARGET_DIR]

Installs Claude Code workflow templates into a target project.

Arguments:
  TARGET_DIR    Path to target project (default: current directory)

Options:
  -h, --help         Show this help message
  -v, --version      Show version
  --dry-run          Show what would be installed without making changes
  --force            Overwrite existing .claude directory without prompting
  --non-interactive  Skip all prompts and use auto-detected values

Examples:
  $0                          # Install in current directory
  $0 ../my-project            # Install in specific project
  $0 --force .                # Force reinstall in current directory
  $0 --non-interactive .      # Install with auto-detected defaults
EOF
    exit 0
}

# Prompt user for values with defaults
prompt_for_values() {
    local interactive="${1:-true}"

    if [[ "$interactive" != "true" ]]; then
        info "Using auto-detected values (non-interactive mode)"
        echo ""
        info "Configuration:"
        echo "  Project name:     ${PROJECT_NAME}"
        echo "  Source directory: ${MAIN_SRC_DIR}"
        echo "  Test command:     ${TEST_COMMAND}"
        echo "  Lint command:     ${LINT_COMMAND}"
        echo "  Build command:    ${BUILD_COMMAND}"
        echo "  Setup command:    ${SETUP_COMMAND}"
        echo "  Min coverage:     ${MIN_COVERAGE}%"
        echo ""
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

    read -p "Minimum coverage threshold % [$MIN_COVERAGE]: " input
    MIN_COVERAGE="${input:-$MIN_COVERAGE}"

    echo ""
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
    echo "  Min coverage:     ${MIN_COVERAGE}%"
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
    install_templates "$target_dir" "$TEMPLATES_DIR" "$dry_run"

    # Install selected specialist agents
    if [[ -n "$selected_specialist_agents" ]] && [[ "$dry_run" != "true" ]]; then
        install_specialist_agents "$target_dir" "$TEMPLATES_DIR" $selected_specialist_agents
    fi

    # Setup pre-commit if detected
    if [[ "$interactive" == "true" ]] && [[ "$dry_run" != "true" ]]; then
        setup_precommit "$target_dir" "$TEMPLATES_DIR"
    fi

    # Setup code quality standards
    if [[ "$dry_run" != "true" ]]; then
        setup_quality_standards "$target_dir" "$TEMPLATES_DIR" "$MIN_COVERAGE"
    fi

    # Setup commit conventions
    if [[ "$dry_run" != "true" ]]; then
        setup_commitlint "$target_dir" "$TEMPLATES_DIR"
    fi

    # Print summary
    if [[ "$dry_run" != "true" ]]; then
        print_summary "$target_dir"
    else
        info "\nConfiguration that would be used:"
        echo "  Project name:     ${PROJECT_NAME}"
        echo "  Source directory: ${MAIN_SRC_DIR}"
        echo "  Test command:     ${TEST_COMMAND}"
        echo "  Lint command:     ${LINT_COMMAND}"
        echo "  Build command:    ${BUILD_COMMAND}"
        echo "  Setup command:    ${SETUP_COMMAND}"
        echo "  Min coverage:     ${MIN_COVERAGE}%"
        echo ""
        info "Dry run complete. Run without --dry-run to install."
    fi
}

main "$@"
