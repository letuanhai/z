#!/bin/bash

# Unit tests for z.sh ranking selection feature
# Tests the -l option with interactive ranking selection

# Don't exit on errors - we want to run all tests and report results
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Setup test environment
setup() {
    export TEST_DIR="/tmp/z_test_$$"
    export TEST_Z_DATA="$TEST_DIR/z_data"
    export _Z_DATA="$TEST_Z_DATA"

    mkdir -p "$TEST_DIR"

    # Create test directories
    mkdir -p "$TEST_DIR/projects/frontend"
    mkdir -p "$TEST_DIR/projects/backend"
    mkdir -p "$TEST_DIR/documents/work"
    mkdir -p "$TEST_DIR/downloads"
    mkdir -p "$TEST_DIR/music"
    mkdir -p "$TEST_DIR/videos"

    # Source z.sh
    source "$(dirname "$0")/z.sh"

    # Populate z datafile with test data
    # Format: path|rank|time
    _z --add "$TEST_DIR/projects/frontend"
    _z --add "$TEST_DIR/projects/frontend"
    _z --add "$TEST_DIR/projects/frontend"
    _z --add "$TEST_DIR/projects/backend"
    _z --add "$TEST_DIR/projects/backend"
    _z --add "$TEST_DIR/documents/work"
    _z --add "$TEST_DIR/downloads"
    _z --add "$TEST_DIR/music"
}

# Cleanup test environment
cleanup() {
    rm -rf "$TEST_DIR"
    unset _Z_DATA TEST_DIR TEST_Z_DATA
}

# Test helper functions
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    echo -e "  ${YELLOW}Expected:${NC} $2"
    echo -e "  ${YELLOW}Got:${NC} $3"
    ((TESTS_FAILED++))
}

run_test() {
    ((TESTS_RUN++))
    echo ""
    echo "Test $TESTS_RUN: $1"
    echo "─────────────────────────────────────"
}

# Test 1: -l displays rankings with prompt
test_list_with_rankings() {
    run_test "z -l displays rankings (not scores)"

    local output
    output=$(echo "" | _z -l proj 2>&1 || true)

    if echo "$output" | grep -q "1)" && \
       echo "$output" | grep -q "Select a directory"; then
        pass "Rankings displayed with selection prompt"
    else
        fail "Rankings display" "Rankings with prompt" "$output"
    fi
}

# Test 2: -l -e displays scores (original behavior)
test_list_with_echo_shows_scores() {
    run_test "z -l -e displays scores (original behavior)"

    local output
    output=$(_z -l -e proj 2>&1)

    if echo "$output" | grep -E "^[0-9]+\s+" && \
       ! echo "$output" | grep -q "Select a directory"; then
        pass "Scores displayed without prompt"
    else
        fail "Score display" "Numeric scores without prompt" "$output"
    fi
}

# Test 3: Select rank 1 (highest score)
test_select_rank_1() {
    run_test "Selecting rank 1 changes to highest scored directory"

    # Get the expected directory (highest score)
    local expected
    expected=$(_z -l -e proj 2>&1 | tail -1 | awk '{print $2}')

    local result
    result=$(cd "$TEST_DIR" && _z -l proj <<< "1" 2>/dev/null && pwd)

    if [ "$result" = "$expected" ]; then
        pass "Successfully changed to rank 1 directory"
    else
        fail "Rank 1 selection" "$expected" "$result"
    fi
}

# Test 4: Select rank 2
test_select_rank_2() {
    run_test "Selecting rank 2 changes to second highest scored directory"

    # Get the expected directory (second highest score)
    local expected
    expected=$(_z -l -e proj 2>&1 | tail -2 | head -1 | awk '{print $2}')

    local result
    result=$(cd "$TEST_DIR" && _z -l proj <<< "2" 2>/dev/null && pwd)

    if [ "$result" = "$expected" ]; then
        pass "Successfully changed to rank 2 directory"
    else
        fail "Rank 2 selection" "$expected" "$result"
    fi
}

# Test 5: Invalid input (non-numeric)
test_invalid_input_nonnumeric() {
    run_test "Non-numeric input is rejected"

    local output
    output=$(cd "$TEST_DIR" && _z -l proj <<< "abc" 2>&1 || true)

    if echo "$output" | grep -q "Invalid selection"; then
        pass "Non-numeric input rejected with error message"
    else
        fail "Invalid input handling" "Invalid selection message" "$output"
    fi
}

# Test 6: Out of range input
test_invalid_input_out_of_range() {
    run_test "Out of range input is rejected"

    local output
    output=$(cd "$TEST_DIR" && _z -l proj <<< "99" 2>&1 || true)

    if echo "$output" | grep -q "Invalid selection"; then
        pass "Out of range input rejected with error message"
    else
        fail "Out of range handling" "Invalid selection message" "$output"
    fi
}

# Test 7: Zero input is rejected
test_invalid_input_zero() {
    run_test "Zero input is rejected"

    local output
    output=$(cd "$TEST_DIR" && _z -l proj <<< "0" 2>&1 || true)

    if echo "$output" | grep -q "Invalid selection"; then
        pass "Zero input rejected with error message"
    else
        fail "Zero input handling" "Invalid selection message" "$output"
    fi
}

# Test 8: Normal z without -l still works
test_normal_z_without_list() {
    run_test "Normal z without -l works (no prompt)"

    local expected
    expected=$(_z -l -e proj 2>&1 | tail -1 | awk '{print $2}')

    local result
    result=$(cd "$TEST_DIR" && _z proj 2>/dev/null && pwd)

    if [ "$result" = "$expected" ] && \
       ! _z proj 2>&1 | grep -q "Select a directory"; then
        pass "Normal z changes to directory without prompt"
    else
        fail "Normal z behavior" "$expected (no prompt)" "$result"
    fi
}

# Test 9: Rankings are sorted by score (descending)
test_rankings_sorted_descending() {
    run_test "Rankings are sorted by score (1=highest)"

    # Get scores with -l -e
    local scores_output
    scores_output=$(_z -l -e proj 2>&1)

    # Get first directory from scores (should be highest)
    local highest_score_dir
    highest_score_dir=$(echo "$scores_output" | tail -1 | awk '{print $2}')

    # Get first directory from rankings
    local rank1_output
    rank1_output=$(_z -l proj 2>&1 <<< "" || true)
    local rank1_dir
    rank1_dir=$(echo "$rank1_output" | grep "^1)" | sed 's/^1) //')

    if [ "$highest_score_dir" = "$rank1_dir" ]; then
        pass "Rank 1 corresponds to highest score"
    else
        fail "Ranking order" "Rank 1 = $highest_score_dir" "Rank 1 = $rank1_dir"
    fi
}

# Test 10: Empty input handling
test_empty_input() {
    run_test "Empty input is rejected"

    local output
    output=$(cd "$TEST_DIR" && _z -l proj <<< "" 2>&1 || true)

    if echo "$output" | grep -q "Invalid selection"; then
        pass "Empty input rejected with error message"
    else
        fail "Empty input handling" "Invalid selection message" "$output"
    fi
}

# Test 11: Multiple matches display correct count
test_multiple_matches_count() {
    run_test "Prompt shows correct number of matches"

    local output
    output=$(_z -l proj 2>&1 <<< "" || true)

    # Count number of ranking lines
    local count
    count=$(echo "$output" | grep -c "^[0-9]\+)" || true)

    if [ "$count" -gt 0 ] && echo "$output" | grep -q "Select a directory (1-$count)"; then
        pass "Prompt shows correct count: $count matches"
    else
        fail "Match count" "Prompt with 1-$count" "$output"
    fi
}

# Test 12: Negative number input
test_invalid_input_negative() {
    run_test "Negative number input is rejected"

    local output
    output=$(cd "$TEST_DIR" && _z -l proj <<< "-1" 2>&1 || true)

    if echo "$output" | grep -q "Invalid selection"; then
        pass "Negative input rejected with error message"
    else
        fail "Negative input handling" "Invalid selection message" "$output"
    fi
}

# Main test execution
main() {
    echo "═══════════════════════════════════════════════════════════"
    echo "  Z.sh Ranking Selection Feature - Unit Tests"
    echo "═══════════════════════════════════════════════════════════"

    setup

    # Run all tests
    test_list_with_rankings
    test_list_with_echo_shows_scores
    test_select_rank_1
    test_select_rank_2
    test_invalid_input_nonnumeric
    test_invalid_input_out_of_range
    test_invalid_input_zero
    test_normal_z_without_list
    test_rankings_sorted_descending
    test_empty_input
    test_multiple_matches_count
    test_invalid_input_negative

    cleanup

    # Print summary
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Test Summary"
    echo "═══════════════════════════════════════════════════════════"
    echo "Total tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"

    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $TESTS_FAILED${NC}"
        echo ""
        echo "Some tests failed. Please review the output above."
        exit 1
    else
        echo -e "${RED}Failed: 0${NC}"
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main
fi
