#!/usr/bin/env bash
# Test suite for myst.sh - Partials

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYST_SH="${SCRIPT_DIR}/../myst.sh"

# Setup before each test
setup() {
    TEST_ENV_DIR=$(create_test_env)
    cd "$TEST_ENV_DIR"
    mkdir partials
}

# Cleanup after each test
teardown() {
    cleanup_test_env
}
# Test 1: Simple partial
test_simple_partial() {
    setup
    echo "Header Content" > partials/header.myst
    cat > template.myst << 'EOF'
{{> header}}
Body
EOF
    output=$(bash "$MYST_SH" render template.myst -p partials 2>&1)
    assert_contains "$output" "Header Content" "Partial content"
    assert_contains "$output" "Body" "Body content"
    teardown
}

# Test 2: Multiple partials
test_multiple_partials() {
    setup
    echo "Header" > partials/header.myst
    echo "Footer" > partials/footer.myst
    cat > template.myst << 'EOF'
{{> header}}
Body
{{> footer}}
EOF
    output=$(bash "$MYST_SH" render template.myst -p partials 2>&1)
    assert_contains "$output" "Header" "Header partial"
    assert_contains "$output" "Body" "Body content"
    assert_contains "$output" "Footer" "Footer partial"
    teardown
}

# Test 3: Partial with variables
test_partial_with_vars() {
    setup
    echo "Hello {{name}}!" > partials/greeting.myst
    cat > template.myst << 'EOF'
{{> greeting}}
EOF
    output=$(bash "$MYST_SH" render template.myst -p partials -v name=World 2>&1)
    assert_contains "$output" "Hello World!" "Partial with variable"
    teardown
}

# Test 4: Missing partial
test_missing_partial() {
    setup
    cat > template.myst << 'EOF'
Before
{{> nonexistent}}
After
EOF
    output=$(bash "$MYST_SH" render template.myst -p partials 2>&1)
    assert_contains "$output" "Before" "Content before"
    assert_contains "$output" "After" "Content after"
    teardown
}

# Test 5: Partial with spacing
test_partial_spacing() {
    setup
    echo "Content" > partials/test.myst
    cat > template.myst << 'EOF'
{{> test}}
{{>test}}
EOF
    output=$(bash "$MYST_SH" render template.myst -p partials 2>&1)
    # Should contain Content at least once
    assert_contains "$output" "Content" "Partial renders"
    teardown
}

# Test 6: Partial with conditionals
test_partial_conditionals() {
    setup
    cat > partials/conditional.myst << 'EOF'
{{#if show}}
Visible
{{/if}}
EOF
    cat > template.myst << 'EOF'
{{> conditional}}
EOF
    output=$(bash "$MYST_SH" render template.myst -p partials -v show=true 2>&1)
    assert_contains "$output" "Visible" "Conditional in partial"
    teardown
}

# Test 7: Partial with loops
test_partial_loops() {
    setup
    cat > partials/list.myst << 'EOF'
{{#each items}}
- {{this}}
{{/each}}
EOF
    cat > template.myst << 'EOF'
{{> list}}
EOF
    output=$(bash "$MYST_SH" render template.myst -p partials -v items="A,B" 2>&1)
    assert_contains "$output" "- A" "Loop in partial A"
    assert_contains "$output" "- B" "Loop in partial B"
    teardown
}

# Test 8: Partial HTML
test_partial_html() {
    setup
    echo "<nav>Navigation</nav>" > partials/nav.myst
    cat > template.myst << 'EOF'
{{> nav}}
<main>Content</main>
EOF
    output=$(bash "$MYST_SH" render template.myst -p partials 2>&1)
    assert_contains "$output" "<nav>Navigation</nav>" "HTML partial"
    teardown
}

run_tests() {
    test_simple_partial
    test_multiple_partials
    test_partial_with_vars
    test_missing_partial
    test_partial_spacing
    test_partial_conditionals
    test_partial_loops
    test_partial_html
}

export -f run_tests
