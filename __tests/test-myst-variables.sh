#!/usr/bin/env bash
# Test suite for myst.sh - Variables

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

# Test 1: Simple variable
test_simple_variable() {
  setup
  echo "Hello {{name}}!" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v name=World 2>&1)
  assert_contains "$output" "Hello World!" "Simple variable interpolation"
  teardown
}

# Test 2: Multiple variables
test_multiple_variables() {
  setup
  echo "{{greeting}} {{name}}!" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v greeting=Hello -v name=World 2>&1)
  assert_contains "$output" "Hello World!" "Multiple variables"
  teardown
}

# Test 3: Variable with underscore
test_variable_underscore() {
  setup
  echo "User: {{user_name}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v user_name=admin 2>&1)
  assert_contains "$output" "User: admin" "Variable with underscore"
  teardown
}

# Test 4: Variable with numbers
test_variable_numbers() {
  setup
  echo "Version: {{v123}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v v123=1.0.0 2>&1)
  assert_contains "$output" "Version: 1.0.0" "Variable with numbers"
  teardown
}

# Test 5: Missing variable stays unchanged
test_missing_variable() {
  setup
  echo "Hello {{undefined}}!" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v name=World 2>&1)
  assert_contains "$output" "{{undefined}}" "Missing variable unchanged"
  teardown
}

# Test 6: Empty variable value
test_empty_variable() {
  setup
  echo "Value: {{empty}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v empty= 2>&1)
  assert_contains "$output" "Value:" "Empty variable"
  teardown
}

# Test 7: Variable with special characters
test_special_characters() {
  setup
  echo "Message: {{msg}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v "msg=Hello @World!" 2>&1)
  assert_contains "$output" "Message: Hello @World!" "Special characters"
  teardown
}

# Test 8: Multiple occurrences
test_multiple_occurrences() {
  setup
  echo "{{name}} says {{name}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v name=Bob 2>&1)
  assert_contains "$output" "Bob says Bob" "Multiple occurrences"
  teardown
}

# Test 9: JSON variables
test_json_variables() {
  setup
  cat >vars.json <<'EOF'
{
  "title": "Test",
  "author": "John"
}
EOF
  echo "{{title}} by {{author}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -j vars.json 2>&1)
  assert_contains "$output" "Test by John" "JSON variables"
  teardown
}

# Test 10: Numeric values
test_numeric_values() {
  setup
  echo "Count: {{n}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v n=42 2>&1)
  assert_contains "$output" "Count: 42" "Numeric values"
  teardown
}

# Test 11: Variable with spaces in value
test_spaces_in_value() {
  setup
  echo "Text: {{msg}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v "msg=Hello World" 2>&1)
  assert_contains "$output" "Text: Hello World" "Spaces in value"
  teardown
}

run_tests() {
  test_simple_variable
  test_multiple_variables
  test_variable_underscore
  test_variable_numbers
  test_missing_variable
  test_empty_variable
  test_special_characters
  test_multiple_occurrences
  test_json_variables
  test_numeric_values
  test_spaces_in_value
}

export -f run_tests
