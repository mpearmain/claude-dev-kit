#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/templates.sh"

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
    local templates_dir="$2"
    shift 2
    local selected_agents=("$@")

    # Copy base configuration file
    cp "$templates_dir/.claude-specialists.yml" "$target_dir/.claude/"

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

# Install selected specialist agents
install_specialist_agents() {
    local target_dir="$1"
    local templates_dir="$2"
    shift 2
    local selected_agents=("$@")

    if [[ ${#selected_agents[@]} -eq 0 ]]; then
        return
    fi

    info "\nInstalling selected specialist agents..."
    for agent in "${selected_agents[@]}"; do
        if [[ -f "$templates_dir/agents/${agent}.md" ]]; then
            cp "$templates_dir/agents/${agent}.md" "${target_dir}/.claude/agents/"
            replace_placeholders "${target_dir}/.claude/agents/${agent}.md"
            echo "  ✓ ${agent}"
        fi
    done

    # Setup configuration for selected agents
    if [[ ${#selected_agents[@]} -gt 0 ]]; then
        setup_specialist_config "$target_dir" "$templates_dir" "${selected_agents[@]}"
    fi
}
