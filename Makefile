# Makefile for Yoda.nvim

.PHONY: test test-watch test-unit test-integration lint format help

# Default target
help:
	@echo "Yoda.nvim Development Commands"
	@echo ""
	@echo "  make test              - Run all tests"
	@echo "  make test-fast         - Run tests (optimized for development)"
	@echo "  make test-ultra        - Run tests in parallel (maximum speed)"
	@echo "  make test-dev          - Run tests in parallel (skip slow tests)"
	@echo "  make test-watch        - Run tests in watch mode"
	@echo "  make test-unit         - Run unit tests only"
	@echo "  make test-integration  - Run integration tests only"
	@echo "  make lint              - Run linter (stylua --check)"
	@echo "  make format            - Format code (stylua)"
	@echo "  make help              - Show this help"

# Run all tests
test:
	@echo "Running all tests..."
	@nvim --headless -u tests/minimal_init.lua -c "luafile tests/run_all.lua" 2>&1 | tee /tmp/yoda_test_output.txt
	@echo ""
	@echo "================================================================================"
	@echo "AGGREGATE TEST RESULTS"
	@echo "================================================================================"
	@./scripts/test_summary.sh /tmp/yoda_test_output.txt
	@echo "================================================================================"

# Fast test runner for development (optimized for speed)
test-fast:
	@echo "Running tests (fast mode)..."
	@nvim --headless -u tests/minimal_init_fast.lua -c "luafile tests/run_all_fast.lua"

# Ultra-fast parallel test runner (maximum speed)
test-ultra:
	@echo "Running tests in parallel (ultra-fast mode)..."
	@./tests/run_parallel.sh

# Ultra-fast parallel test runner (skip slow tests for development)
test-dev:
	@echo "Running tests in parallel (development mode - skipping slow tests)..."
	@SKIP_SLOW_TESTS=1 ./tests/run_parallel.sh

# Ultra-fast single-session test runner
test-ultra-single:
	@echo "Running tests in single session (experimental)..."
	@nvim --headless -u tests/minimal_init_ultra.lua -c "luafile tests/run_all_ultra.lua"

# Watch mode (requires snacks.nvim in Neovim session)
test-watch:
	@echo "Run ':lua require(\"yoda.plenary\").watch_tests()' in Neovim"

# Run only unit tests
test-unit:
	nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/unit')" -c "quitall!"

# Run only integration tests
test-integration:
	nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/integration')" -c "quitall!"

# Lint code with stylua (excluding files with goto labels)
lint:
	@find lua tests -name "*.lua" ! -name "yaml_parser.lua" ! -name "config_loader.lua" -type f | xargs stylua --check

# Format code with stylua (excluding files with goto labels)  
format:
	@find lua tests -name "*.lua" ! -name "yaml_parser.lua" ! -name "config_loader.lua" -type f | xargs stylua