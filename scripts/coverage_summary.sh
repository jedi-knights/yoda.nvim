#!/bin/bash
# Parse LuaCov report and display coverage summary

REPORT_FILE="luacov.report.out"

if [ ! -f "$REPORT_FILE" ]; then
  echo "❌ Coverage report not found: $REPORT_FILE"
  exit 1
fi

# Parse the summary section
summary=$(grep -A 100 "^Summary$" "$REPORT_FILE" | tail -n +2)

# Extract overall statistics
total_files=0
covered_files=0
total_lines=0
hit_lines=0
missed_lines=0

echo "Module Coverage:"
echo "--------------------------------------------------------------------------------"

# Parse each file's coverage
while IFS= read -r line; do
  # Skip empty lines and separators
  if [[ -z "$line" || "$line" =~ ^=+ || "$line" =~ ^-+ ]]; then
    continue
  fi
  
  # Parse file coverage line (format: "filename    hits/total    percentage")
  if [[ "$line" =~ ^([^[:space:]]+)[[:space:]]+([0-9]+)/([0-9]+)[[:space:]]+([0-9.]+)% ]]; then
    file="${BASH_REMATCH[1]}"
    hits="${BASH_REMATCH[2]}"
    total="${BASH_REMATCH[3]}"
    percent="${BASH_REMATCH[4]}"
    
    # Only show yoda modules
    if [[ "$file" =~ ^lua/yoda/ ]]; then
      # Calculate coverage bar
      bar_length=40
      filled=$(echo "scale=0; $percent * $bar_length / 100" | bc)
      bar=$(printf "%${filled}s" | tr ' ' '█')
      bar+=$(printf "%$((bar_length - filled))s" | tr ' ' '░')
      
      # Color code based on coverage
      if (( $(echo "$percent >= 90" | bc -l) )); then
        color="\033[32m"  # Green
      elif (( $(echo "$percent >= 75" | bc -l) )); then
        color="\033[33m"  # Yellow
      else
        color="\033[31m"  # Red
      fi
      reset="\033[0m"
      
      printf "${color}%6.2f%%${reset} [%s] %s (%d/%d)\n" "$percent" "$bar" "$file" "$hits" "$total"
      
      total_files=$((total_files + 1))
      hit_lines=$((hit_lines + hits))
      total_lines=$((total_lines + total))
      
      if (( $(echo "$percent >= 75" | bc -l) )); then
        covered_files=$((covered_files + 1))
      fi
    fi
  fi
done < <(grep -A 1000 "^Summary$" "$REPORT_FILE")

echo "--------------------------------------------------------------------------------"

# Calculate overall percentage
if [ "$total_lines" -gt 0 ]; then
  overall=$(echo "scale=2; $hit_lines * 100 / $total_lines" | bc)
  missed_lines=$((total_lines - hit_lines))
  
  # Color code overall
  if (( $(echo "$overall >= 90" | bc -l) )); then
    color="\033[32m"  # Green
    emoji="🎉"
  elif (( $(echo "$overall >= 75" | bc -l) )); then
    color="\033[33m"  # Yellow
    emoji="⚠️"
  else
    color="\033[31m"  # Red
    emoji="❌"
  fi
  reset="\033[0m"
  
  echo ""
  printf "${emoji} ${color}Overall Coverage: %.2f%%${reset} (%d/%d lines)\n" "$overall" "$hit_lines" "$total_lines"
  echo "   Files Covered: $covered_files/$total_files (>75%)"
  echo "   Lines Hit:     $hit_lines"
  echo "   Lines Missed:  $missed_lines"
  echo ""
  
  # Show uncovered modules
  echo "Modules Below 75%:"
  while IFS= read -r line; do
    if [[ "$line" =~ ^(lua/yoda/[^[:space:]]+)[[:space:]]+([0-9]+)/([0-9]+)[[:space:]]+([0-9.]+)% ]]; then
      file="${BASH_REMATCH[1]}"
      percent="${BASH_REMATCH[4]}"
      
      if (( $(echo "$percent < 75" | bc -l) )); then
        printf "  • %s (%.2f%%)\n" "$file" "$percent"
      fi
    fi
  done < <(grep -A 1000 "^Summary$" "$REPORT_FILE")
else
  echo "⚠️  No coverage data collected"
fi

echo "--------------------------------------------------------------------------------"

