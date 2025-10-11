# Makefile for Yoda.nvim

.PHONY: test test-watch test-unit test-integration coverage coverage-report lint format clean help

# Default target
help:
	@echo "Yoda.nvim Development Commands"
	@echo ""
	@echo "  make test              - Run all tests"
	@echo "  make test-watch        - Run tests in watch mode"
	@echo "  make test-unit         - Run unit tests only"
	@echo "  make test-integration  - Run integration tests only"
	@echo "  make coverage          - Run tests with coverage collection"
	@echo "  make coverage-report   - Generate and display coverage report"
	@echo "  make lint              - Run linter (stylua --check)"
	@echo "  make format            - Format code (stylua)"
	@echo "  make clean             - Remove coverage files"
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

# Run tests with coverage
coverage:
	@echo "Running tests with coverage..."
	@rm -f luacov.*.out
	@eval $$(luarocks path); nvim --headless -u tests/minimal_init.lua -c "luafile tests/run_all.lua" 2>&1 | tee /tmp/yoda_test_output.txt
	@echo ""
	@echo "================================================================================"
	@echo "AGGREGATE TEST RESULTS"
	@echo "================================================================================"
	@./scripts/test_summary.sh /tmp/yoda_test_output.txt
	@echo "================================================================================"
	@if [ -f luacov.stats.out ]; then \
		echo ""; \
		echo "✅ Coverage data collected: luacov.stats.out"; \
		echo "Run 'make coverage-report' to generate report"; \
	fi

# Generate coverage report
coverage-report:
	@if [ ! -f luacov.stats.out ]; then \
		echo "❌ No coverage data found. Run 'make coverage' first."; \
		exit 1; \
	fi
	@echo "Generating coverage report..."
	@luacov
	@if [ -f luacov.report.out ]; then \
		echo ""; \
		echo "================================================================================"; \
		echo "COVERAGE REPORT"; \
		echo "================================================================================"; \
		./scripts/coverage_summary.sh; \
		echo ""; \
		echo "Full report: luacov.report.out"; \
	fi

# Clean coverage files
clean:
	@echo "Cleaning coverage files..."
	@rm -f luacov.*.out
	@echo "✅ Coverage files removed"

