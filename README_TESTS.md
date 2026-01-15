# Z.sh Test Suite

This directory contains unit tests for the z.sh script, specifically for the ranking selection feature.

## Running Tests

To run all tests:

```bash
./test_ranking_selection.sh
```

The test script will:
1. Create a temporary test environment
2. Run 12 comprehensive tests
3. Display pass/fail status for each test
4. Clean up after itself
5. Exit with code 0 if all tests pass, 1 if any fail

## Test Coverage

The test suite covers the following scenarios:

### Ranking Display Tests
- **Test 1**: Verify `-l` displays rankings with selection prompt
- **Test 2**: Verify `-l -e` displays scores (original behavior)
- **Test 11**: Verify prompt shows correct number of matches

### Selection Tests
- **Test 3**: Select rank 1 (highest score) and verify cd
- **Test 4**: Select rank 2 (second highest score) and verify cd
- **Test 8**: Verify normal `z` without `-l` works without prompt

### Input Validation Tests
- **Test 5**: Reject non-numeric input (e.g., "abc")
- **Test 6**: Reject out of range input (e.g., "99")
- **Test 7**: Reject zero input
- **Test 10**: Reject empty input
- **Test 12**: Reject negative numbers (e.g., "-1")

### Sorting Tests
- **Test 9**: Verify rankings are sorted by score (descending, 1=highest)

## Requirements

- Bash shell
- Write access to /tmp directory
- z.sh file in the same directory as the test script

## Test Output

Successful test run example:
```
═══════════════════════════════════════════════════════════
  Z.sh Ranking Selection Feature - Unit Tests
═══════════════════════════════════════════════════════════

Test 1: z -l displays rankings (not scores)
─────────────────────────────────────
✓ PASS: Rankings displayed with selection prompt

...

═══════════════════════════════════════════════════════════
  Test Summary
═══════════════════════════════════════════════════════════
Total tests run: 12
Passed: 12
Failed: 0

All tests passed!
```

## Adding New Tests

To add a new test:

1. Create a test function following the naming convention `test_<description>`
2. Use `run_test "Test description"` to start the test
3. Use `pass "message"` or `fail "name" "expected" "got"` to report results
4. Call your test function in the `main()` function
5. Remember to handle cleanup in your test if needed

Example:
```bash
test_my_new_feature() {
    run_test "My new feature works correctly"

    local result
    result=$(_z -l test 2>&1)

    if echo "$result" | grep -q "expected output"; then
        pass "Feature works as expected"
    else
        fail "Feature test" "expected output" "$result"
    fi
}
```

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```bash
# Exit code 0 = all tests passed
# Exit code 1 = one or more tests failed
./test_ranking_selection.sh
```

## Troubleshooting

If tests fail:

1. Check that z.sh is in the same directory as the test script
2. Ensure you have write permissions to /tmp
3. Verify no other z.sh instance is interfering with test environment
4. Run with bash -x for debug output: `bash -x test_ranking_selection.sh`

## License

Same as z.sh (WTFPL)
