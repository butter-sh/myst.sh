#!/usr/bin/env bash
# Test suite for myst.sh - Error Handling

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

# Test 1: Missing template file
test_missing_template() {
  setup
  set +e
  output=$(bash "$MYST_SH" render missing.myst 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code" "Missing template exits 1"
  assert_contains "$output" "not found" "Error message"
  teardown
}

# Test 2: Invalid JSON file
test_invalid_json() {
  setup
  echo "not json" >bad.json
  echo "Test" >template.myst
  set +e
  output=$(bash "$MYST_SH" render template.myst -j bad.json 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code" "Invalid JSON exits 1"
  teardown
}

# Test 3: Missing JSON file
test_missing_json() {
  setup
  echo "Test" >template.myst
  set +e
  output=$(bash "$MYST_SH" render template.myst -j missing.json 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code" "Missing JSON exits 1"
  assert_contains "$output" "not found" "Error message"
  teardown
}

# Test 4: Unknown option
test_unknown_option() {
  setup
  echo "Test" >template.myst
  set +e
  output=$(bash "$MYST_SH" render template.myst --badoption 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code" "Unknown option fails"
  assert_contains "$output" "Unknown option" "Error message"
  teardown
}

# Test 5: No template specified
test_no_template() {
  setup
  set +e
  output=$(bash "$MYST_SH" render 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code" "No template fails"
  assert_contains "$output" "No template" "Error message"
  teardown
}

run_tests() {
  test_missing_template
  test_invalid_json
  test_missing_json
  test_unknown_option
  test_no_template
}

export -f run_tests
