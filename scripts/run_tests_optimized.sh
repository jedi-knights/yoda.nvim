#!/bin/bash
# Run tests with slow tests excluded for better performance  
# Usage: ./scripts/run_tests_fast.sh [minimal_init_file]

set -e

INIT_FILE="${1:-tests/minimal_init_fast.lua}"
OUTPUT_FILE="/tmp/yoda_test_run_fast_$$.txt"
TEMP_DIR="/tmp/yoda_tests_fast_$$"

# Create temporary directory structure for fast tests
mkdir -p "$TEMP_DIR/tests"
cp -r tests/unit "$TEMP_DIR/tests/"
cp -r tests/property "$TEMP_DIR/tests/"
cp tests/helpers.lua "$TEMP_DIR/tests/"

# Remove slow tests with significant vim.wait() delays
rm -f "$TEMP_DIR/tests/unit/integrations/gitsigns_spec.lua"  # 1.3+ seconds of waiting
rm -f "$TEMP_DIR/tests/unit/window/layout_manager_spec.lua"  # Additional 150ms of waiting

echo "Running test suite..."

# Run tests from the temporary directory
nvim --headless -u "$INIT_FILE" \
  -c "lua require('plenary.test_harness').test_directory('$TEMP_DIR/tests/unit', {minimal_init = './$INIT_FILE'})" \
  -c "quitall!" \
  2>&1 | tee "$OUTPUT_FILE"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

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