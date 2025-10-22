#!/usr/bin/env bash

# demo.sh - Comprehensive demonstration of myst.sh features
# This script showcases all the capabilities of the myst templating engine

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYST="${SCRIPT_DIR}/../myst.sh"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    myst.sh Templating Engine Demo     ${NC}"
echo -e "${CYAN}========================================${NC}"
echo

# Check if myst.sh exists
if [[ ! -f "$MYST" ]]; then
  echo -e "${YELLOW}Error: myst.sh not found at $MYST${NC}"
  exit 1
fi

chmod +x "$MYST"

#=============================================================================
# Demo 1: Simple Variable Interpolation
#=============================================================================

echo -e "${GREEN}[Demo 1]${NC} Simple Variable Interpolation"
echo "-------------------------------------------"
echo -e "${BLUE}Template:${NC} templates/simple.myst"
echo -e "${BLUE}Command:${NC} myst.sh render simple.myst -v name=Alice -v premium=true -v theme=dark"
echo
"$MYST" render "${SCRIPT_DIR}/templates/simple.myst" \
  -v name=Alice \
  -v premium=true \
  -v theme=dark
echo
echo

#=============================================================================
# Demo 2: Loops
#=============================================================================

echo -e "${GREEN}[Demo 2]${NC} Loop Structures"
echo "-------------------------------------------"
echo -e "${BLUE}Template:${NC} templates/list.myst"
echo -e "${BLUE}Command:${NC} myst.sh render list.myst -v items='Apples,Bananas,Oranges' -v count=3"
echo
"$MYST" render "${SCRIPT_DIR}/templates/list.myst" \
  -v items="Apples,Bananas,Oranges,Grapes" \
  -v count=4
echo
echo

#=============================================================================
# Demo 3: JSON Data Input
#=============================================================================

echo -e "${GREEN}[Demo 3]${NC} JSON Data Input"
echo "-------------------------------------------"
echo -e "${BLUE}Data file:${NC} data.json"
echo -e "${BLUE}Template:${NC} templates/simple.myst"
echo -e "${BLUE}Command:${NC} myst.sh render simple.myst -j data.json"
echo
"$MYST" render "${SCRIPT_DIR}/templates/simple.myst" \
  -j "${SCRIPT_DIR}/data.json"
echo
echo

#=============================================================================
# Demo 4: YAML Data Input (if yq is available)
#=============================================================================

if command -v yq >/dev/null 2>&1; then
  echo -e "${GREEN}[Demo 4]${NC} YAML Data Input"
  echo "-------------------------------------------"
  echo -e "${BLUE}Data file:${NC} config.yml"
  echo -e "${BLUE}Template:${NC} templates/simple.myst"
  echo -e "${BLUE}Command:${NC} myst.sh render simple.myst -y config.yml"
  echo
  "$MYST" render "${SCRIPT_DIR}/templates/simple.myst" \
    -y "${SCRIPT_DIR}/config.yml"
  echo
  echo
else
  echo -e "${YELLOW}[Demo 4]${NC} YAML Data Input - SKIPPED (yq not installed)"
  echo
fi

#=============================================================================
# Demo 5: Partials
#=============================================================================

echo -e "${GREEN}[Demo 5]${NC} Template Partials"
echo "-------------------------------------------"
echo -e "${BLUE}Template:${NC} templates/with-partials.myst"
echo -e "${BLUE}Partials:${NC} partials/_header.myst, partials/_footer.myst, partials/_nav.myst"
echo -e "${BLUE}Command:${NC} myst.sh render with-partials.myst -p partials -j data.json"
echo
"$MYST" render "${SCRIPT_DIR}/templates/with-partials.myst" \
  -p "${SCRIPT_DIR}/partials" \
  -j "${SCRIPT_DIR}/data.json"
echo
echo

#=============================================================================
# Demo 6: Template Inheritance
#=============================================================================

echo -e "${GREEN}[Demo 6]${NC} Template Inheritance"
echo "-------------------------------------------"
echo -e "${BLUE}Layout:${NC} templates/layout.myst"
echo -e "${BLUE}Child:${NC} templates/page.myst"
echo -e "${BLUE}Command:${NC} myst.sh render page.myst -l layout.myst -j data.json"
echo
"$MYST" render "${SCRIPT_DIR}/templates/page.myst" \
  -l "${SCRIPT_DIR}/templates/layout.myst" \
  -j "${SCRIPT_DIR}/data.json"
echo
echo

#=============================================================================
# Demo 7: Environment Variables
#=============================================================================

echo -e "${GREEN}[Demo 7]${NC} Environment Variables"
echo "-------------------------------------------"
echo -e "${BLUE}Setting:${NC} export MYST_name=Bob MYST_premium=false MYST_theme=light"
echo -e "${BLUE}Template:${NC} templates/simple.myst"
echo -e "${BLUE}Command:${NC} myst.sh render simple.myst -e"
echo
export MYST_name=Bob
export MYST_premium=false
export MYST_theme=light
"$MYST" render "${SCRIPT_DIR}/templates/simple.myst" -e
unset MYST_name MYST_premium MYST_theme
echo
echo

#=============================================================================
# Demo 8: Stdin Template
#=============================================================================

echo -e "${GREEN}[Demo 8]${NC} Template from Stdin"
echo "-------------------------------------------"
echo -e "${BLUE}Command:${NC} echo 'Hello {{name}}, welcome to {{app}}!' | myst.sh render --stdin -v name=Charlie -v app=myst.sh"
echo
echo 'Hello {{name}}, welcome to {{app}}!' | "$MYST" render --stdin -v name=Charlie -v app="myst.sh"
echo
echo

#=============================================================================
# Demo 9: Combined Data Sources
#=============================================================================

echo -e "${GREEN}[Demo 9]${NC} Combined Data Sources"
echo "-------------------------------------------"
echo -e "${BLUE}Description:${NC} Combining JSON, environment, and CLI variables"
echo -e "${BLUE}Command:${NC} Multiple sources with override precedence"
echo
export MYST_theme=override_theme
"$MYST" render "${SCRIPT_DIR}/templates/simple.myst" \
  -j "${SCRIPT_DIR}/data.json" \
  -e \
  -v name="Override Name" \
  -v premium=false
unset MYST_theme
echo
echo

#=============================================================================
# Demo 10: Output to File
#=============================================================================

echo -e "${GREEN}[Demo 10]${NC} Output to File"
echo "-------------------------------------------"
echo -e "${BLUE}Command:${NC} myst.sh render page.myst -l layout.myst -j data.json -o output.html"
echo

OUTPUT_FILE="${SCRIPT_DIR}/../output.html"
"$MYST" render "${SCRIPT_DIR}/templates/page.myst" \
  -l "${SCRIPT_DIR}/templates/layout.myst" \
  -j "${SCRIPT_DIR}/data.json" \
  -o "$OUTPUT_FILE"

if [[ -f "$OUTPUT_FILE" ]]; then
  echo -e "${GREEN}✓${NC} File created successfully: $OUTPUT_FILE"
  echo -e "${BLUE}Preview (first 10 lines):${NC}"
  head -10 "$OUTPUT_FILE"
  echo "..."
else
  echo -e "${YELLOW}✗${NC} File creation failed"
fi
echo
echo

#=============================================================================
# Demo 11: Embedding myst as a library
#=============================================================================

echo -e "${GREEN}[Demo 11]${NC} Embedding myst.sh as a Library"
echo "-------------------------------------------"
echo -e "${BLUE}Description:${NC} Using myst functions in a script"
echo

# Source myst.sh to use it as a library
source "$MYST"

# Set variables programmatically
myst_set_var "app_name" "MyApp"
myst_set_var "version" "1.0.0"
myst_set_var "status" "active"

# Create a simple template
template='Application: {{app_name}}
Version: {{version}}
Status: {{#if status}}✓ Active{{/if}}'

# Render it
result=$(myst_render "$template")

echo -e "${BLUE}Rendered output:${NC}"
echo "$result"
echo
echo

#=============================================================================
# Summary
#=============================================================================

echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✓ Demo Complete!${NC}"
echo -e "${CYAN}========================================${NC}"
echo
echo "You've seen all major features of myst.sh:"
echo "  • Variable interpolation"
echo "  • Conditionals (if/unless)"
echo "  • Loops (each)"
echo "  • Partials"
echo "  • Template inheritance"
echo "  • JSON/YAML input"
echo "  • Environment variables"
echo "  • Stdin input/output"
echo "  • Multiple data sources"
echo "  • Library embedding"
echo
echo "For more information, see:"
echo "  • README.md"
echo "  • DSL_DOCUMENTATION.md"
echo "  • ./myst.sh --help"
echo
