#!/bin/bash
# Run tests and check for failures
# Usage: ./scripts/run_tests.sh [minimal_init_file]

set -e

INIT_FILE="${1:-tests/minimal_init_fast.lua}"
OUTPUT_FILE="/tmp/yoda_test_run_$$.txt"

# Run tests and capture output
nvim --headless -u "$INIT_FILE" \
  -c "lua require('plenary.test_harness').test_directory('tests/unit', {minimal_init = './$INIT_FILE'})" \
  -c "quitall!" \
  2>&1 | tee "$OUTPUT_FILE"

# Check for failures in output
if grep -q "Tests Failed" "$OUTPUT_FILE"; then
  echo "❌ Tests failed!"
  rm "$OUTPUT_FILE"
  exit 1
fi

# Count failures from summary lines
FAILED_COUNT=$(grep "^Failed :" "$OUTPUT_FILE" | awk '{sum += $NF} END {print sum+0}')
ERROR_COUNT=$(grep "^Errors :" "$OUTPUT_FILE" | awk '{sum += $NF} END {print sum+0}')

rm "$OUTPUT_FILE"

if [ "$FAILED_COUNT" -gt 0 ] || [ "$ERROR_COUNT" -gt 0 ]; then
  echo "❌ Found $FAILED_COUNT failures and $ERROR_COUNT errors"
  exit 1
fi

echo "✅ All tests passed!"
exit 0
