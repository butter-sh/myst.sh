#!/usr/bin/env bash
# Test suite for myst.sh - Conditionals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYST_SH="${SCRIPT_DIR}/../myst.sh"

# Setup before each test
setup() {
  TEST_ENV_DIR=$(create_test_env)
  cd "$TEST_ENV_DIR"
}

# Cleanup after each test
teardown() {
  cleanup_test_env
}

# Test 1: If with true value
test_if_true() {
  setup
  cat >template.myst <<'EOF'
{{#if show}}
Visible
{{/if}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v show=true 2>&1)
  assert_contains "$output" "Visible" "If with true"
  teardown
}

# Test 2: If with false value
test_if_false() {
  setup
  cat >template.myst <<'EOF'
{{#if show}}
Hidden
{{/if}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v show=false 2>&1)
  assert_not_contains "$output" "Hidden" "If with false"
  teardown
}

# Test 3: If with undefined variable
test_if_undefined() {
  setup
  cat >template.myst <<'EOF'
{{#if missing}}
Hidden
{{/if}}
EOF
  output=$(bash "$MYST_SH" render template.myst 2>&1)
  assert_not_contains "$output" "Hidden" "If with undefined"
  teardown
}

# Test 4: If with non-empty string
test_if_nonempty() {
  setup
  cat >template.myst <<'EOF'
{{#if name}}
Hello
{{/if}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v name=World 2>&1)
  assert_contains "$output" "Hello" "If with non-empty string"
  teardown
}

# Test 5: Unless with false
test_unless_false() {
  setup
  cat >template.myst <<'EOF'
{{#unless show}}
Visible
{{/unless}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v show=false 2>&1)
  assert_contains "$output" "Visible" "Unless with false"
  teardown
}

# Test 6: Unless with true
test_unless_true() {
  setup
  cat >template.myst <<'EOF'
{{#unless show}}
Hidden
{{/unless}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v show=true 2>&1)
  assert_not_contains "$output" "Hidden" "Unless with true"
  teardown
}

# Test 7: Unless with undefined
test_unless_undefined() {
  setup
  cat >template.myst <<'EOF'
{{#unless missing}}
Visible
{{/unless}}
EOF
  output=$(bash "$MYST_SH" render template.myst 2>&1)
  assert_contains "$output" "Visible" "Unless with undefined"
  teardown
}

# Test 8: If with zero
test_if_zero() {
  setup
  cat >template.myst <<'EOF'
{{#if count}}
Hidden
{{/if}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v count=0 2>&1)
  assert_not_contains "$output" "Hidden" "If with zero"
  teardown
}

# Test 9: If with multiline content
test_if_multiline() {
  setup
  cat >template.myst <<'EOF'
{{#if show}}
Line 1
Line 2
{{/if}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v show=true 2>&1)
  assert_contains "$output" "Line 1" "If multiline - line 1"
  assert_contains "$output" "Line 2" "If multiline - line 2"
  teardown
}

# Test 10: Variables inside if block
test_variables_in_if() {
  setup
  cat >template.myst <<'EOF'
{{#if show}}
Hello {{name}}!
{{/if}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v show=true -v name=World 2>&1)
  assert_contains "$output" "Hello World!" "Variables inside if"
  teardown
}

# Test 11: Multiple if blocks
test_multiple_ifs() {
  setup
  cat >template.myst <<'EOF'
{{#if a}}
A
{{/if}}
{{#if b}}
B
{{/if}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v a=true -v b=true 2>&1)
  assert_contains "$output" "A" "Multiple ifs - A"
  assert_contains "$output" "B" "Multiple ifs - B"
  teardown
}

# Test 12: Content before and after if
test_content_around_if() {
  setup
  cat >template.myst <<'EOF'
Before
{{#if show}}
Middle
{{/if}}
After
EOF
  output=$(bash "$MYST_SH" render template.myst -v show=true 2>&1)
  assert_contains "$output" "Before" "Content before"
  assert_contains "$output" "Middle" "Content middle"
  assert_contains "$output" "After" "Content after"
  teardown
}

run_tests() {
  test_if_true
  test_if_false
  test_if_undefined
  test_if_nonempty
  test_unless_false
  test_unless_true
  test_unless_undefined
  test_if_zero
  test_if_multiline
  test_variables_in_if
  test_multiple_ifs
  test_content_around_if
}

export -f run_tests
