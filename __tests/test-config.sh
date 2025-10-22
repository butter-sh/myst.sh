#!/usr/bin/env bash
# Test configuration for myst.sh test suite
# This file is sourced by test files to set common configuration

export TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test directory structure
export MYST_SH_ROOT="$PWD"

# Test behavior flags
export MYST_TEST_MODE=1
export MYST_SKIP_YQ_CHECK=0 # Set to 1 to skip yq availability check in tests
export MYST_SKIP_JQ_CHECK=0 # Set to 1 to skip jq availability check in tests

# Color output in tests (set to 0 to disable)
export MYST_TEST_COLORS=1
