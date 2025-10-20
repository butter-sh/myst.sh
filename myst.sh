#!/usr/bin/env bash
# myst.sh  
# Version: 1.0.2 - Large content handling + whitespace in conditionals

set -euo pipefail

VERSION="1.0.2"

# Global state
declare -A MYST_VARS=()
declare -A MYST_PARTIALS=()
TEMP_DIR=""

#=============================================================================
# Core Functions
#=============================================================================

die() {
    echo "[ERROR] $*" >&2
    cleanup_temp
    exit 1
}

cleanup_temp() {
    [[ -n "${TEMP_DIR:-}" ]] && [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
}

trap cleanup_temp EXIT

#=============================================================================
# Variable Management
#=============================================================================

myst_set_var() {
    MYST_VARS["$1"]="$2"
}

myst_load_json() {
    [[ ! -f "$1" ]] && die "JSON file not found: $1"
    
    if ! jq empty "$1" 2>/dev/null; then
        die "Invalid JSON in $1"
    fi
    
    [[ -z "$TEMP_DIR" ]] && TEMP_DIR=$(mktemp -d)
    
    local keys=($(jq -r 'keys[]' "$1"))
    for key in "${keys[@]}"; do
        local value=$(jq -r ".[\"$key\"]" "$1")
        MYST_VARS["$key"]="$value"
    done
}

myst_load_env() {
    local prefix="${1:-MYST_}"
    while IFS='=' read -r key value; do
        if [[ "$key" =~ ^${prefix}(.+)$ ]]; then
            MYST_VARS["${BASH_REMATCH[1]}"]="$value"
        fi
    done < <(env)
}

#=============================================================================
# Rendering
#=============================================================================

html_escape() {
    local text="$1"
    text="${text//&/&amp;}"
    text="${text//</&lt;}"
    text="${text//>/&gt;}"
    text="${text//\"/&quot;}"
    text="${text//\'/&#39;}"
    printf '%s' "$text"
}

safe_replace() {
    local placeholder="$1"
    local content_file="$2"
    local replacement_file="$3"
    local output_file="$4"
    
    perl -e '
        use strict;
        use warnings;
        
        my $placeholder = $ARGV[0];
        my $repl_file = $ARGV[1];
        my $content_file = $ARGV[2];
        
        open(my $rfh, "<", $repl_file) or die "Cannot open $repl_file: $!";
        local $/;
        my $replacement = <$rfh>;
        close($rfh);
        
        open(my $cfh, "<", $content_file) or die "Cannot open $content_file: $!";
        my $content = <$cfh>;
        close($cfh);
        
        my $quoted = quotemeta($placeholder);
        $content =~ s/$quoted/$replacement/g;
        
        print $content;
    ' "$placeholder" "$replacement_file" "$content_file" > "$output_file"
}

myst_render_vars() {
    local content="$1"
    [[ -z "$TEMP_DIR" ]] && TEMP_DIR=$(mktemp -d)
    
    for key in "${!MYST_VARS[@]}"; do
        local value="${MYST_VARS[$key]}"
        local placeholder_triple="{{{${key}}}}"
        local placeholder_amp="{{&${key}}}"
        
        if [[ "$content" == *"$placeholder_triple"* ]]; then
            local content_file="${TEMP_DIR}/content_$$_${RANDOM}"
            local repl_file="${TEMP_DIR}/repl_$$_${RANDOM}"
            local output_file="${TEMP_DIR}/output_$$_${RANDOM}"
            
            printf '%s' "$content" > "$content_file"
            printf '%s' "$value" > "$repl_file"
            
            safe_replace "$placeholder_triple" "$content_file" "$repl_file" "$output_file"
            content=$(cat "$output_file")
            
            rm -f "$content_file" "$repl_file" "$output_file"
        fi
        
        if [[ "$content" == *"$placeholder_amp"* ]]; then
            local content_file="${TEMP_DIR}/content_$$_${RANDOM}"
            local repl_file="${TEMP_DIR}/repl_$$_${RANDOM}"
            local output_file="${TEMP_DIR}/output_$$_${RANDOM}"
            
            printf '%s' "$content" > "$content_file"
            printf '%s' "$value" > "$repl_file"
            
            safe_replace "$placeholder_amp" "$content_file" "$repl_file" "$output_file"
            content=$(cat "$output_file")
            
            rm -f "$content_file" "$repl_file" "$output_file"
        fi
    done
    
    for key in "${!MYST_VARS[@]}"; do
        local value="${MYST_VARS[$key]}"
        local escaped_value=$(html_escape "$value")
        local placeholder="{{${key}}}"
        
        if [[ "$content" == *"$placeholder"* ]]; then
            local content_file="${TEMP_DIR}/content_$$_${RANDOM}"
            local repl_file="${TEMP_DIR}/repl_$$_${RANDOM}"
            local output_file="${TEMP_DIR}/output_$$_${RANDOM}"
            
            printf '%s' "$content" > "$content_file"
            printf '%s' "$escaped_value" > "$repl_file"
            
            safe_replace "$placeholder" "$content_file" "$repl_file" "$output_file"
            content=$(cat "$output_file")
            
            rm -f "$content_file" "$repl_file" "$output_file"
        fi
    done
    
    printf '%s' "$content"
}

myst_render_conditionals() {
    local content="$1"
    
    [[ ! "$content" =~ \{\{#(if|unless) ]] && printf '%s' "$content" && return
    
    local output="" state="normal" var_name="" block="" is_unless=false
    
    while IFS= read -r line; do
        if [[ "$state" == "normal" ]]; then
            if [[ "$line" =~ ^[[:space:]]*\{\{#if[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\}[[:space:]]*$ ]]; then
                var_name="${BASH_REMATCH[1]}"
                block=""
                is_unless=false
                state="in_block"
            elif [[ "$line" =~ ^[[:space:]]*\{\{#unless[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\}[[:space:]]*$ ]]; then
                var_name="${BASH_REMATCH[1]}"
                block=""
                is_unless=true
                state="in_block"
            else
                output+="$line"$'\n'
            fi
        elif [[ "$state" == "in_block" ]]; then
            if [[ "$line" =~ ^[[:space:]]*\{\{/(if|unless)\}\}[[:space:]]*$ ]]; then
                local value="${MYST_VARS[$var_name]:-}"
                local render=false
                
                if [[ "$is_unless" == true ]]; then
                    [[ -z "$value" || "$value" == "false" || "$value" == "0" ]] && render=true
                else
                    [[ -n "$value" && "$value" != "false" && "$value" != "0" ]] && render=true
                fi
                
                [[ "$render" == true ]] && output+="$block"
                state="normal"
            else
                block+="$line"$'\n'
            fi
        fi
    done <<< "$content"
    
    printf '%s' "${output%$'\n'}"
}

myst_render_loops() {
    local content="$1"
    
    [[ ! "$content" =~ \{\{#each ]] && printf '%s' "$content" && return
    
    local output="" state="normal" var_name="" block=""
    
    while IFS= read -r line; do
        if [[ "$state" == "normal" ]]; then
            if [[ "$line" =~ ^\{\{#each[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\}$ ]]; then
                var_name="${BASH_REMATCH[1]}"
                block=""
                state="in_loop"
            else
                output+="$line"$'\n'
            fi
        elif [[ "$state" == "in_loop" ]]; then
            if [[ "$line" =~ ^\{\{/each\}\}$ ]]; then
                local array_value="${MYST_VARS[$var_name]:-}"
                
                if [[ -n "$array_value" ]]; then
                    IFS=',' read -ra items <<< "$array_value"
                    for item in "${items[@]}"; do
                        item="${item#"${item%%[![:space:]]*}"}"
                        item="${item%"${item##*[![:space:]]}"}"
                        local rendered="$block"
                        rendered="${rendered//\{\{this\}\}/$item}"
                        rendered="${rendered//\{\{.\}\}/$item}"
                        output+="$rendered"
                    done
                fi
                state="normal"
            else
                block+="$line"$'\n'
            fi
        fi
    done <<< "$content"
    
    printf '%s' "${output%$'\n'}"
}

myst_render_partials() {
    local content="$1"
    
    [[ ! "$content" =~ \{\{\> ]] && printf '%s' "$content" && return
    
    [[ -z "$TEMP_DIR" ]] && TEMP_DIR=$(mktemp -d)
    local max_iter=100 iter=0
    
    while [[ "$content" =~ \{\{\>[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)\}\} ]] && (( iter < max_iter )); do
        local name="${BASH_REMATCH[1]}"
        local partial="${MYST_PARTIALS[$name]:-}"
        
        for placeholder in "{{> $name}}" "{{>$name}}"; do
            if [[ "$content" == *"$placeholder"* ]]; then
                local content_file="${TEMP_DIR}/content_$$_${RANDOM}"
                local repl_file="${TEMP_DIR}/repl_$$_${RANDOM}"
                local output_file="${TEMP_DIR}/output_$$_${RANDOM}"
                
                printf '%s' "$content" > "$content_file"
                printf '%s' "$partial" > "$repl_file"
                
                safe_replace "$placeholder" "$content_file" "$repl_file" "$output_file"
                content=$(cat "$output_file")
                
                rm -f "$content_file" "$repl_file" "$output_file"
            fi
        done
        (( iter++ ))
    done
    
    printf '%s' "$content"
}

myst_render() {
    local content="$1"
    content=$(myst_render_partials "$content")
    content=$(myst_render_loops "$content")
    content=$(myst_render_conditionals "$content")
    content=$(myst_render_vars "$content")
    printf '%s' "$content"
}

myst_load_template() {
    [[ ! -f "$1" ]] && die "Template not found: $1"
    cat "$1"
}

myst_load_partials_dir() {
    [[ ! -d "$1" ]] && return 0
    while IFS= read -r -d '' file; do
        local name=$(basename "$file" .myst)
        MYST_PARTIALS["$name"]=$(cat "$file")
    done < <(find "$1" -name "*.myst" -type f -print0 2>/dev/null)
}

show_help() {
    cat << 'EOF'
myst.sh - Minimal templating engine

USAGE:
    myst.sh [OPTIONS] <template>

OPTIONS:
    -v, --var KEY=VALUE     Set variable
    -j, --json FILE         Load JSON
    -e, --env [PREFIX]      Load env vars (default: MYST_)
    -p, --partials DIR      Partials directory
    -o, --output FILE       Output file
    --stdin                 Read from stdin
    -h, --help              Show help
    -V, --version           Show version
EOF
}

show_version() {
    echo "myst.sh version $VERSION"
}

main() {
    local template_file="" output_file="" use_stdin=false partials_dir=""
    
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help; exit 0 ;;
            -V|--version) show_version; exit 0 ;;
            --stdin) use_stdin=true; shift ;;
            -v|--var)
                if [[ "$2" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
                    myst_set_var "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
                fi
                shift 2
                ;;
            -j|--json) myst_load_json "$2"; shift 2 ;;
            -e|--env)
                if [[ -n "${2:-}" ]] && [[ "$2" != -* ]]; then
                    myst_load_env "$2"; shift 2
                else
                    myst_load_env "MYST_"; shift
                fi
                ;;
            -p|--partials) partials_dir="$2"; shift 2 ;;
            -o|--output) output_file="$2"; shift 2 ;;
            -t|--template) template_file="$2"; shift 2 ;;
            render) shift ;;
            -*) die "Unknown option: $1" ;;
            *)
                if [[ -z "$template_file" ]]; then
                    template_file="$1"
                fi
                shift
                ;;
        esac
    done
    
    [[ -n "$partials_dir" ]] && myst_load_partials_dir "$partials_dir"
    
    local content=""
    if [[ "$use_stdin" == true ]]; then
        content=$(cat)
    elif [[ -n "$template_file" ]]; then
        content=$(myst_load_template "$template_file")
    else
        die "No template specified"
    fi
    
    local result=$(myst_render "$content")
    
    if [[ -n "$output_file" ]]; then
        printf '%s' "$result" > "$output_file"
    else
        printf '%s' "$result"
    fi
}

main "$@"
