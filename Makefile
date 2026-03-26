# Makefile for Yoda.nvim

.PHONY: test test-verbose test-watch lint format benchmark benchmark-startup benchmark-buffers benchmark-files benchmark-memory benchmark-lsp benchmark-clean help

# Default target
help:
	@echo "Yoda.nvim Development Commands"
	@echo ""
	@echo "Testing:"
	@echo "  make test              - Run all tests (optimized, excludes slow tests)"
	@echo "  make test-verbose      - Run tests with detailed output (for CI)"
	@echo "  make test-watch        - Run tests in watch mode"
	@echo ""
	@echo "Code Quality:"
	@echo "  make lint              - Run linter (stylua --check)"
	@echo "  make format            - Format code (stylua)"
	@echo ""
	@echo "Performance:"
	@echo "  make benchmark         - Run all performance benchmarks"
	@echo "  make benchmark-startup - Benchmark startup time only"
	@echo "  make benchmark-buffers - Benchmark buffer switching only"
	@echo "  make benchmark-files   - Benchmark file operations only"
	@echo "  make benchmark-memory  - Benchmark memory usage only"
	@echo "  make benchmark-lsp     - Benchmark LSP operations only"
	@echo "  make benchmark-clean   - Clean up benchmark files"
	@echo ""
	@echo "Development:"
	@echo "  make clean             - Clean generated files"
	@echo "  make help              - Show this help"

# Run tests (optimized, excludes slow tests)
test:
	@echo "Running tests..."
	@./scripts/run_tests_optimized.sh tests/minimal_init_fast.lua

# Verbose test runner for CI/debugging
test-verbose:
	@echo "Running tests with detailed output..."
	@./scripts/run_tests_optimized.sh tests/minimal_init_fast.lua 2>&1 | tee /tmp/yoda_test_output.txt
	@echo ""
	@echo "================================================================================"
	@echo "AGGREGATE TEST RESULTS"
	@echo "================================================================================"
	@./scripts/test_summary.sh /tmp/yoda_test_output.txt
	@echo "================================================================================"

# Lint code with stylua
lint:
	@find lua tests -name "*.lua" -type f | xargs stylua --check

# Format code with stylua
format:
	@find lua tests -name "*.lua" -type f | xargs stylua

# Performance benchmarking
benchmark:
	@echo "Running all performance benchmarks..."
	@./scripts/benchmark_performance.sh all

benchmark-startup:
	@echo "Benchmarking startup time..."
	@./scripts/benchmark_performance.sh startup

benchmark-buffers:
	@echo "Benchmarking buffer switching..."
	@./scripts/benchmark_performance.sh buffers

benchmark-files:
	@echo "Benchmarking file operations..."
	@./scripts/benchmark_performance.sh files

benchmark-memory:
	@echo "Benchmarking memory usage..."
	@./scripts/benchmark_performance.sh memory

benchmark-lsp:
	@echo "Benchmarking LSP operations..."
	@./scripts/benchmark_performance.sh lsp

benchmark-clean:
	@echo "Cleaning benchmark files..."
	@./scripts/benchmark_performance.sh clean

# Clean generated files  
clean:
	@echo "Cleaning generated files..."
	@rm -f startup.log
	@rm -f /tmp/yoda_test_output.txt
	@echo "✅ Cleanup complete"