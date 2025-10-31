#!/bin/bash

# scripts/benchmark_performance.sh
# Performance benchmarking script for Yoda.nvim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BENCHMARK_DIR="$PROJECT_ROOT/benchmarks"
RESULTS_FILE="$BENCHMARK_DIR/results_$(date +%Y%m%d_%H%M%S).json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create benchmarks directory
mkdir -p "$BENCHMARK_DIR"
mkdir -p "$BENCHMARK_DIR/temp"

echo -e "${BLUE}🚀 Yoda.nvim Performance Benchmark${NC}"
echo "Results will be saved to: $RESULTS_FILE"
echo ""

# ============================================================================
# Helper Functions
# ============================================================================

log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARN:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1"
}

# Create test files for benchmarking
create_test_files() {
    log "Creating test files..."
    
    # Small files (1KB each)
    for i in {1..10}; do
        head -c 1024 /dev/urandom > "$BENCHMARK_DIR/temp/small_${i}.txt"
    done
    
    # Medium files (100KB each)  
    for i in {1..5}; do
        head -c 102400 /dev/urandom > "$BENCHMARK_DIR/temp/medium_${i}.txt"
    done
    
    # Large file (1MB)
    head -c 1048576 /dev/urandom > "$BENCHMARK_DIR/temp/large.txt"
    
    # Code files with syntax highlighting
    cat > "$BENCHMARK_DIR/temp/test.lua" << 'EOF'
-- Test Lua file for syntax highlighting benchmark
local M = {}

function M.test_function()
    for i = 1, 100 do
        local result = math.random() * i
        if result > 50 then
            print("Result: " .. result)
        end
    end
end

return M
EOF

    cat > "$BENCHMARK_DIR/temp/test.py" << 'EOF'
# Test Python file for LSP benchmark
import sys
import os
from typing import List, Dict, Optional

class TestClass:
    def __init__(self, name: str):
        self.name = name
        self.items: List[str] = []
    
    def add_item(self, item: str) -> None:
        """Add an item to the collection."""
        self.items.append(item)
    
    def get_items(self) -> List[str]:
        """Return all items."""
        return self.items.copy()

def main():
    test = TestClass("example")
    for i in range(100):
        test.add_item(f"item_{i}")
    print(f"Added {len(test.get_items())} items")

if __name__ == "__main__":
    main()
EOF
}

# Cleanup test files
cleanup_test_files() {
    log "Cleaning up test files..."
    rm -rf "$BENCHMARK_DIR/temp"
}

# Benchmark startup time
benchmark_startup() {
    log "Benchmarking startup time..."
    
    local total_time=0
    local iterations=5
    
    for i in $(seq 1 $iterations); do
        local startup_log="$BENCHMARK_DIR/temp/startup_${i}.log"
        nvim --startuptime "$startup_log" +q 2>/dev/null
        
        # Extract total startup time (last line)
        local time_ms=$(tail -n 1 "$startup_log" | awk '{print $1}')
        total_time=$(echo "$total_time + $time_ms" | bc -l)
        
        # Small delay between iterations
        sleep 0.5
    done
    
    local avg_time=$(echo "scale=2; $total_time / $iterations" | bc -l)
    echo "$avg_time"
}

# Benchmark buffer switching
benchmark_buffer_switching() {
    log "Benchmarking buffer switching..."
    
    local test_script="$BENCHMARK_DIR/temp/buffer_test.vim"
    
    cat > "$test_script" << 'EOF'
let start_time = reltime()
for i in range(20)
    execute 'edit ' . expand('~') . '/buffer_test_' . i . '.txt'
    call append(0, 'Test content ' . i)
    write
endfor
let elapsed = reltimestr(reltime(start_time))
echo elapsed
qall!
EOF
    
    # Run the test and capture timing
    local result=$(nvim -u NONE -c "source $test_script" 2>/dev/null | tail -n 1)
    
    # Convert to milliseconds and return
    local time_ms=$(echo "$result * 1000" | bc -l)
    echo "$time_ms"
}

# Benchmark file operations
benchmark_file_operations() {
    log "Benchmarking file operations..."
    
    local test_script="$BENCHMARK_DIR/temp/file_test.vim"
    
    cat > "$test_script" << EOF
let start_time = reltime()
edit $BENCHMARK_DIR/temp/small_1.txt
edit $BENCHMARK_DIR/temp/small_2.txt  
edit $BENCHMARK_DIR/temp/medium_1.txt
edit $BENCHMARK_DIR/temp/large.txt
edit $BENCHMARK_DIR/temp/test.lua
edit $BENCHMARK_DIR/temp/test.py
let elapsed = reltimestr(reltime(start_time))
echo elapsed
qall!
EOF
    
    local result=$(nvim -c "source $test_script" 2>/dev/null | tail -n 1)
    local time_ms=$(echo "$result * 1000" | bc -l)
    echo "$time_ms"
}

# Benchmark memory usage
benchmark_memory() {
    log "Benchmarking memory usage..."
    
    local memory_script="$BENCHMARK_DIR/temp/memory_test.lua" 
    
    cat > "$memory_script" << 'EOF'
-- Load some plugins and measure memory
collectgarbage("collect")  -- Force garbage collection
local before = collectgarbage("count")

-- Simulate some plugin loading
for i = 1, 100 do
    local t = {}
    for j = 1, 100 do
        t[j] = "test_string_" .. j
    end
end

collectgarbage("collect")
local after = collectgarbage("count")

print(string.format("%.2f", after))
EOF
    
    local memory_kb=$(nvim -l "$memory_script" 2>/dev/null)
    echo "$memory_kb"
}

# Run LSP benchmark (if Python LSP is available)
benchmark_lsp() {
    log "Benchmarking LSP operations..."
    
    # Check if basedpyright is available
    if ! command -v basedpyright-langserver &> /dev/null; then
        warn "basedpyright-langserver not found, skipping LSP benchmark"
        echo "0"
        return
    fi
    
    local lsp_script="$BENCHMARK_DIR/temp/lsp_test.lua"
    
    cat > "$lsp_script" << EOF
-- Simple LSP timing test
local start_time = vim.loop.hrtime()

-- Open Python file to trigger LSP
vim.cmd('edit $BENCHMARK_DIR/temp/test.py')

-- Wait a bit for LSP to initialize
vim.wait(2000, function() return false end)

-- Simulate some LSP operations
vim.lsp.buf.hover()

local elapsed_ms = (vim.loop.hrtime() - start_time) / 1000000
print(string.format("%.2f", elapsed_ms))
vim.cmd('qall!')
EOF
    
    local result=$(timeout 10s nvim -l "$lsp_script" 2>/dev/null || echo "0")
    echo "$result"
}

# ============================================================================
# Main Benchmark Execution
# ============================================================================

run_benchmarks() {
    log "Starting performance benchmarks..."
    
    # Create test environment
    create_test_files
    
    # Run benchmarks
    log "Running startup benchmark..."
    local startup_time=$(benchmark_startup)
    
    log "Running buffer switching benchmark..."  
    local buffer_time=$(benchmark_buffer_switching)
    
    log "Running file operations benchmark..."
    local file_time=$(benchmark_file_operations)
    
    log "Running memory benchmark..."
    local memory_usage=$(benchmark_memory)
    
    log "Running LSP benchmark..."
    local lsp_time=$(benchmark_lsp)
    
    # Generate results JSON
    cat > "$RESULTS_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "neovim_version": "$(nvim --version | head -n 1)",
  "system": "$(uname -s)",
  "benchmarks": {
    "startup_time_ms": $startup_time,
    "buffer_switching_ms": $buffer_time,
    "file_operations_ms": $file_time, 
    "memory_usage_kb": $memory_usage,
    "lsp_response_ms": $lsp_time
  },
  "targets": {
    "startup_improvement_percent": 15,
    "buffer_improvement_percent": 30,
    "file_improvement_percent": 20,
    "memory_improvement_percent": 10,
    "lsp_improvement_percent": 25
  }
}
EOF
    
    # Cleanup
    cleanup_test_files
    
    # Display results
    echo ""
    echo -e "${GREEN}📊 Benchmark Results${NC}"
    echo "================================"
    printf "%-25s %10.2f ms\n" "Startup Time:" "$startup_time"
    printf "%-25s %10.2f ms\n" "Buffer Switching:" "$buffer_time" 
    printf "%-25s %10.2f ms\n" "File Operations:" "$file_time"
    printf "%-25s %10.2f KB\n" "Memory Usage:" "$memory_usage"
    printf "%-25s %10.2f ms\n" "LSP Response:" "$lsp_time"
    echo ""
    echo "Results saved to: $RESULTS_FILE"
}

# ============================================================================
# Script Execution
# ============================================================================

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v nvim &> /dev/null; then
        missing_deps+=("neovim")
    fi
    
    if ! command -v bc &> /dev/null; then
        missing_deps+=("bc")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Parse command line arguments
case "${1:-}" in
    "startup")
        create_test_files
        benchmark_startup
        cleanup_test_files
        ;;
    "buffers")
        create_test_files  
        benchmark_buffer_switching
        cleanup_test_files
        ;;
    "files")
        create_test_files
        benchmark_file_operations
        cleanup_test_files
        ;;
    "memory")
        benchmark_memory
        ;;
    "lsp")
        create_test_files
        benchmark_lsp
        cleanup_test_files
        ;;
    "clean")
        log "Cleaning up benchmark files..."
        rm -rf "$BENCHMARK_DIR/temp"
        rm -f "$BENCHMARK_DIR"/results_*.json
        log "Cleanup complete"
        ;;
    "compare")
        if [ -z "${2:-}" ]; then
            error "Usage: $0 compare <results_file1> [results_file2]"
            exit 1
        fi
        # Future enhancement: Compare two result files
        warn "Comparison feature not yet implemented"
        ;;
    "" | "all")
        check_dependencies
        run_benchmarks
        ;;
    *)
        echo "Usage: $0 [startup|buffers|files|memory|lsp|clean|compare|all]"
        echo ""
        echo "Commands:"
        echo "  startup   - Benchmark startup time only"
        echo "  buffers   - Benchmark buffer switching only"  
        echo "  files     - Benchmark file operations only"
        echo "  memory    - Benchmark memory usage only"
        echo "  lsp       - Benchmark LSP operations only"
        echo "  clean     - Clean up benchmark files"
        echo "  compare   - Compare two benchmark results"
        echo "  all       - Run all benchmarks (default)"
        exit 1
        ;;
esac