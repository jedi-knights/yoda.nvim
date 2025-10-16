#!/bin/bash
# Parallel test runner for maximum speed
# Runs test files in parallel using background processes

set -e

echo "Running tests in parallel..."

# Get the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Create temp directory for results
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Maximum number of parallel jobs (adjust based on your CPU cores)
MAX_JOBS=8
JOB_COUNT=0

# Function to run a single test file
run_test_file() {
    local test_file="$1"
    local result_file="$2"
    local basename_file=$(basename "$test_file")
    
    echo "Starting: $basename_file" >&2
    
    # Run test and capture results (use different timeout command for macOS)
    if nvim --headless -u tests/minimal_init_ultra.lua \
        -c "lua require('plenary.test_harness').test_directory_command('$test_file')" \
        -c "qa!" > "$result_file" 2>&1; then
        echo "✅ $basename_file" >&2
    else
        echo "❌ $basename_file" >&2
        echo "FAILED" >> "$result_file"
    fi
}

# Start all test files in parallel
pids=()
while IFS= read -r test_file; do
    # Skip known slow tests if SKIP_SLOW_TESTS is set
    if [[ "$SKIP_SLOW_TESTS" == "1" ]] && [[ "$test_file" == *"opencode_integration_spec.lua" ]]; then
        echo "⏭️  Skipping slow test: $(basename "$test_file")" >&2
        continue
    fi
    
    if [[ -f "$test_file" ]]; then
        result_file="$TEMP_DIR/$(basename "$test_file").result"
        
        # Wait if we've reached max jobs
        while [ ${#pids[@]} -ge $MAX_JOBS ]; do
            for i in "${!pids[@]}"; do
                if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                    wait "${pids[$i]}"
                    unset "pids[$i]"
                fi
            done
            pids=("${pids[@]}")  # Re-index array
            sleep 0.1
        done
        
        # Start new job
        run_test_file "$test_file" "$result_file" &
        pids+=($!)
        ((JOB_COUNT++))
    fi
done < <(find tests/unit -name "*_spec.lua")

# Wait for all jobs to complete
echo "Waiting for $JOB_COUNT test files to complete..."
for pid in "${pids[@]}"; do
    wait "$pid"
done

# Aggregate results
echo ""
echo "================================================================================"
echo "PARALLEL TEST RESULTS"
echo "================================================================================"

total_success=0
total_failed=0
total_errors=0  
file_count=0

for result_file in "$TEMP_DIR"/*.result; do
    if [[ -f "$result_file" ]]; then
        ((file_count++))
        
        if grep -q "FAILED" "$result_file"; then
            ((total_failed++))
        else
            # Strip ANSI color codes and parse plenary output
            # Look for patterns like "Success: 	29" (with tabs)
            success=$(sed 's/\[[0-9;]*m//g' "$result_file" | grep -E "Success:" | grep -oE "[0-9]+" | tail -1 || echo "0")
            failed=$(sed 's/\[[0-9;]*m//g' "$result_file" | grep -E "Failed :" | grep -oE "[0-9]+" | tail -1 || echo "0") 
            errors=$(sed 's/\[[0-9;]*m//g' "$result_file" | grep -E "Errors :" | grep -oE "[0-9]+" | tail -1 || echo "0")
            
            total_success=$((total_success + ${success:-0}))
            total_failed=$((total_failed + ${failed:-0}))
            total_errors=$((total_errors + ${errors:-0}))
        fi
    fi
done

echo "Total tests passed: $total_success"
echo "Total tests failed: $total_failed" 
echo "Total errors: $total_errors"
echo "Test files run: $file_count"
echo "================================================================================"

# Exit with error if there were failures
if [ $total_failed -gt 0 ] || [ $total_errors -gt 0 ]; then
    exit 1
fi