# Makefile for Yoda.nvim

.PHONY: test test-watch test-unit test-integration lint format help

# Default target
help:
	@echo "Yoda.nvim Development Commands"
	@echo ""
	@echo "  make test              - Run all tests (optimized)"
	@echo "  make test-verbose      - Run tests with detailed output (for CI)"
	@echo "  make test-watch        - Run tests in watch mode" 
	@echo "  make test-unit         - Run unit tests only"
	@echo "  make test-integration  - Run integration tests only"
	@echo "  make lint              - Run linter (stylua --check)"
	@echo "  make format            - Format code (stylua)"
	@echo "  make help              - Show this help"

# Run all tests (optimized for speed)
test:
	@echo "Running all tests..."
	@nvim --headless -u tests/minimal_init_fast.lua -c "luafile tests/run_all_fast.lua"

# Verbose test runner for CI/debugging  
test-verbose:
	@echo "Running tests with detailed output..."
	@nvim --headless -u tests/minimal_init.lua -c "luafile tests/run_all.lua" 2>&1 | tee /tmp/yoda_test_output.txt
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