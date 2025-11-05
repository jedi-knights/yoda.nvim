# Makefile for Yoda.nvim

.PHONY: test test-watch test-unit test-integration test-property lint format benchmark benchmark-startup benchmark-buffers benchmark-files benchmark-memory benchmark-lsp benchmark-clean help

# Default target
help:
	@echo "Yoda.nvim Development Commands"
	@echo ""
	@echo "Testing:"
	@echo "  make test              - Run all tests (optimized)"
	@echo "  make test-verbose      - Run tests with detailed output (for CI)"
	@echo "  make test-watch        - Run tests in watch mode" 
	@echo "  make test-unit         - Run unit tests only"
	@echo "  make test-integration  - Run integration tests only"
	@echo "  make test-property     - Run property-based tests (advanced)"
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
	@echo "  make install-hooks     - Install git pre-commit hooks"
	@echo "  make clean             - Clean generated files"
	@echo "  make help              - Show this help"

# Run all tests (optimized for speed)
test:
	@echo "Running all tests..."
	@./scripts/run_tests.sh tests/minimal_init_fast.lua

# Verbose test runner for CI/debugging  
test-verbose:
	@echo "Running tests with detailed output..."
	@nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/unit', {minimal_init = './tests/minimal_init.lua'})" -c "quitall!" 2>&1 | tee /tmp/yoda_test_output.txt
	@echo ""
	@echo "================================================================================"
	@echo "AGGREGATE TEST RESULTS"
	@echo "================================================================================"
	@./scripts/test_summary.sh /tmp/yoda_test_output.txt
	@echo "================================================================================"

# Watch mode (requires snacks.nvim in Neovim session)
test-watch:
	@echo "Run ':lua require(\"yoda.plenary\").watch_tests()' in Neovim"

# Run only unit tests
test-unit:
	@nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/unit')" -c "quitall!"

# Run only integration tests
test-integration:
	nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/integration')" -c "quitall!"

# Run property-based tests (advanced)
test-property:
	@echo "Running property-based tests (200+ runs per test)..."
	@echo "This will take longer than unit tests..."
	@nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/property')" -c "quitall!"

# Lint code with stylua (excluding files with goto labels)
lint:
	@find lua tests -name "*.lua" ! -name "yaml_parser.lua" ! -name "config_loader.lua" -type f | xargs stylua --check

# Format code with stylua (excluding files with goto labels)  
format:
	@find lua tests -name "*.lua" ! -name "yaml_parser.lua" ! -name "config_loader.lua" -type f | xargs stylua

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

# Install git hooks
install-hooks:
	@echo "Installing git hooks..."
	@cp scripts/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✅ Pre-commit hook installed"

# Clean generated files  
clean:
	@echo "Cleaning generated files..."
	@rm -f startup.log
	@rm -rf benchmarks/temp/
	@rm -f /tmp/yoda_test_output.txt
	@echo "✅ Cleanup complete"