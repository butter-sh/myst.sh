#!/usr/bin/env bash
# Test suite for myst.sh - CLI Interface

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

# Test 1: Help command
test_help() {
  setup
  output=$(bash "$MYST_SH" --help 2>&1)
  assert_contains "$output" "USAGE" "Help shows usage"
  assert_contains "$output" "OPTIONS" "Help shows options"
  teardown
}

# Test 2: Version command
test_version() {
  setup
  output=$(bash "$MYST_SH" --version 2>&1)
  assert_contains "$output" "version" "Version command"
  teardown
}

# Test 3: No arguments shows help
test_no_args() {
  setup
  output=$(bash "$MYST_SH" 2>&1)
  assert_contains "$output" "USAGE" "No args shows help"
  teardown
}

# Test 4: Missing template file error
test_missing_template() {
  setup
  set +e
  output=$(bash "$MYST_SH" render nonexistent.myst 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code" "Missing template fails"
  assert_contains "$output" "not found" "Error message"
  teardown
}

# Test 5: Render with -t flag
test_render_with_t_flag() {
  setup
  echo "Hello {{name}}!" >test.myst
  output=$(bash "$MYST_SH" render -t test.myst -v name=World 2>&1)
  assert_contains "$output" "Hello World!" "Render with -t"
  teardown
}

# Test 6: Render with positional argument
test_render_positional() {
  setup
  echo "Hello {{name}}!" >test.myst
  output=$(bash "$MYST_SH" render test.myst -v name=World 2>&1)
  assert_contains "$output" "Hello World!" "Render positional"
  teardown
}

# Test 7: Render shorthand (without 'render' command)
test_render_shorthand() {
  setup
  echo "Hello {{name}}!" >test.myst
  output=$(bash "$MYST_SH" test.myst -v name=World 2>&1)
  assert_contains "$output" "Hello World!" "Render shorthand"
  teardown
}

# Test 8: Stdin template
test_stdin_template() {
  setup
  output=$(echo "Hello {{name}}!" | bash "$MYST_SH" render --stdin -v name=World 2>&1)
  assert_contains "$output" "Hello World!" "Stdin template"
  teardown
}

# Test 9: Output to file
test_output_file() {
  setup
  echo "Test" >template.myst
  bash "$MYST_SH" render template.myst -o output.txt 2>&1
  assert_file_exists "output.txt" "Output file created"
  content=$(cat output.txt)
  assert_contains "$content" "Test" "Output file content"
  teardown
}

# Test 10: Unknown option error
test_unknown_option() {
  setup
  echo "Test" >template.myst
  set +e
  output=$(bash "$MYST_SH" render template.myst --unknown 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code" "Unknown option fails"
  assert_contains "$output" "Unknown option" "Error message"
  teardown
}

# Test 11: Variable via -v flag
test_var_flag() {
  setup
  echo "{{x}}" >template.myst
  output=$(bash "$MYST_SH" render template.myst -v x=42 2>&1)
  assert_contains "$output" "42" "Variable via -v"
  teardown
}

run_tests() {
  test_help
  test_version
  test_no_args
  test_missing_template
  test_render_with_t_flag
  test_render_positional
  test_render_shorthand
  test_stdin_template
  test_output_file
  test_unknown_option
  test_var_flag
}

export -f run_tests
