#!/bin/bash

# Quick performance benchmark for Yoda.nvim

set -e

echo "🚀 Yoda.nvim Quick Performance Benchmark"
echo "========================================"
echo ""

# Startup time
echo "📊 Startup Time (5 iterations):"
total=0
for i in {1..5}; do
    nvim --startuptime /tmp/startup_$i.log +q
    time_ms=$(tail -n 1 /tmp/startup_$i.log | awk '{print $1}')
    echo "  Run $i: ${time_ms}ms"
    total=$(echo "$total + $time_ms" | bc -l)
done
avg=$(echo "scale=2; $total / 5" | bc -l)
echo "  Average: ${avg}ms"
echo ""

# Memory usage (basic Lua check)
echo "📊 Memory Usage:"
echo 'collectgarbage("collect"); print(string.format("  Base memory: %.2f KB", collectgarbage("count")))' > /tmp/mem_test.lua
nvim -l /tmp/mem_test.lua
echo ""

# Git info
echo "📊 Environment:"
echo "  Git commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
echo "  Neovim: $(nvim --version | head -n 1)"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Save results
results_file="benchmarks/results_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "Yoda.nvim Performance Benchmark Results"
    echo "========================================"
    echo "Date: $(date -Iseconds)"
    echo "Git commit: $(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
    echo "Neovim: $(nvim --version | head -n 1)"
    echo ""
    echo "Metrics:"
    echo "  Startup time (avg): ${avg}ms"
    echo ""
    echo "Targets:"
    echo "  Startup improvement: -15%"
    echo "  Buffer switching: -30%"
    echo "  LSP response: -20%"
} > "$results_file"

echo "✅ Results saved to: $results_file"
