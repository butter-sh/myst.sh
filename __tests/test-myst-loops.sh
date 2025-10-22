#!/usr/bin/env bash
# Test suite for myst.sh - Loops

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

# Test 1: Simple loop
test_simple_loop() {
  setup
  cat >template.myst <<'EOF'
{{#each items}}
- {{this}}
{{/each}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v items="A,B,C" 2>&1)
  assert_contains "$output" "- A" "Loop item A"
  assert_contains "$output" "- B" "Loop item B"
  assert_contains "$output" "- C" "Loop item C"
  teardown
}

# Test 2: Loop with dot syntax
test_loop_dot_syntax() {
  setup
  cat >template.myst <<'EOF'
{{#each items}}
* {{.}}
{{/each}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v items="X,Y,Z" 2>&1)
  assert_contains "$output" "* X" "Dot syntax X"
  assert_contains "$output" "* Y" "Dot syntax Y"
  assert_contains "$output" "* Z" "Dot syntax Z"
  teardown
}

# Test 3: Loop with single item
test_single_item() {
  setup
  cat >template.myst <<'EOF'
{{#each items}}
Item: {{this}}
{{/each}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v items="Single" 2>&1)
  assert_contains "$output" "Item: Single" "Single item"
  teardown
}

# Test 4: Loop with empty array
test_empty_array() {
  setup
  cat >template.myst <<'EOF'
Start
{{#each items}}
- {{this}}
{{/each}}
End
EOF
  output=$(bash "$MYST_SH" render template.myst -v items="" 2>&1)
  assert_contains "$output" "Start" "Empty loop start"
  assert_contains "$output" "End" "Empty loop end"
  assert_not_contains "$output" "- " "No items rendered"
  teardown
}

# Test 5: Loop with spaces in items
test_spaces_in_items() {
  setup
  cat >template.myst <<'EOF'
{{#each items}}
{{this}}
{{/each}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v items="first item, second item" 2>&1)
  assert_contains "$output" "first item" "First item with space"
  assert_contains "$output" "second item" "Second item with space"
  teardown
}

# Test 6: Loop with numbers
test_numeric_items() {
  setup
  cat >template.myst <<'EOF'
{{#each nums}}
Number: {{this}}
{{/each}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v nums="1,2,3" 2>&1)
  assert_contains "$output" "Number: 1" "Number 1"
  assert_contains "$output" "Number: 2" "Number 2"
  assert_contains "$output" "Number: 3" "Number 3"
  teardown
}

# Test 7: Loop with HTML
test_loop_html() {
  setup
  cat >template.myst <<'EOF'
<ul>
{{#each items}}
<li>{{this}}</li>
{{/each}}
</ul>
EOF
  output=$(bash "$MYST_SH" render template.myst -v items="A,B" 2>&1)
  assert_contains "$output" "<li>A</li>" "HTML list item A"
  assert_contains "$output" "<li>B</li>" "HTML list item B"
  teardown
}

# Test 8: Multiple loops
test_multiple_loops() {
  setup
  cat >template.myst <<'EOF'
{{#each list1}}
{{this}}
{{/each}}
{{#each list2}}
{{this}}
{{/each}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v list1="A,B" -v list2="X,Y" 2>&1)
  assert_contains "$output" "A" "First loop A"
  assert_contains "$output" "B" "First loop B"
  assert_contains "$output" "X" "Second loop X"
  assert_contains "$output" "Y" "Second loop Y"
  teardown
}

# Test 9: Loop with external variable
test_loop_external_var() {
  setup
  cat >template.myst <<'EOF'
Prefix: {{prefix}}
{{#each items}}
{{this}}
{{/each}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v prefix=TEST -v items="A,B" 2>&1)
  assert_contains "$output" "Prefix: TEST" "External variable"
  assert_contains "$output" "A" "Loop item A"
  assert_contains "$output" "B" "Loop item B"
  teardown
}

# Test 10: Loop with special characters
test_special_chars_in_loop() {
  setup
  cat >template.myst <<'EOF'
{{#each items}}
- {{this}}
{{/each}}
EOF
  output=$(bash "$MYST_SH" render template.myst -v items="@user,#tag" 2>&1)
  assert_contains "$output" "- @user" "Special char @"
  assert_contains "$output" "- #tag" "Special char #"
  teardown
}

run_tests() {
  test_simple_loop
  test_loop_dot_syntax
  test_single_item
  test_empty_array
  test_spaces_in_items
  test_numeric_items
  test_loop_html
  test_multiple_loops
  test_loop_external_var
  test_special_chars_in_loop
}

export -f run_tests
