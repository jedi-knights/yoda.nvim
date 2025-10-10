#!/bin/bash
# Parse test output and show aggregate results

if [ ! -f "$1" ]; then
    echo "Usage: $0 <test_output_file>"
    exit 1
fi

# Strip ANSI color codes from file
stripped_file="/tmp/yoda_test_stripped.txt"
sed 's/\x1b\[[0-9;]*m//g' "$1" > "$stripped_file"

# Extract numbers from Success/Failed/Errors lines
success_sum=0
failed_sum=0
errors_sum=0

while IFS= read -r line; do
    # Extract the number (last field with digits)
    num=$(echo "$line" | grep -oE '[0-9]+' | tail -1)
    if [ -n "$num" ]; then
        success_sum=$((success_sum + num))
    fi
done < <(grep "^Success:" "$stripped_file" | grep -v "||")

while IFS= read -r line; do
    num=$(echo "$line" | grep -oE '[0-9]+' | tail -1)
    if [ -n "$num" ]; then
        failed_sum=$((failed_sum + num))
    fi
done < <(grep "^Failed :" "$stripped_file")

while IFS= read -r line; do
    num=$(echo "$line" | grep -oE '[0-9]+' | tail -1)
    if [ -n "$num" ]; then
        errors_sum=$((errors_sum + num))
    fi
done < <(grep "^Errors :" "$stripped_file")

test_files=$(grep -c "^Testing:" "$stripped_file")

echo "Total tests passed: $success_sum"
echo "Total tests failed: $failed_sum"
echo "Total errors: $errors_sum"
echo "Test files run: $test_files"

# Exit with error if there were failures
if [ $failed_sum -gt 0 ] || [ $errors_sum -gt 0 ]; then
    exit 1
fi

