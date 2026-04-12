# Makefile for Yoda.nvim

# Path to the neospec binary. Override with: make test NEOSPEC=/path/to/neospec
NEOSPEC ?= neospec

.PHONY: test test-verbose test-watch lint format benchmark benchmark-startup benchmark-buffers benchmark-files benchmark-memory benchmark-lsp benchmark-clean install help

# Default target
help:
	@echo "Yoda.nvim Development Commands"
	@echo ""
	@echo "Testing:"
	@echo "  make test              - Run all tests with coverage (neospec)"
	@echo "  make test-verbose      - Run tests with detailed diagnostic output"
	@echo "  make test-watch        - Run tests in watch mode (not yet implemented)"
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
	@echo "  make install           - Install dev dependencies (latest neospec)"
	@echo "  make clean             - Clean generated files"
	@echo "  make help              - Show this help"

# Install development dependencies (always fetches the latest neospec)
install:
	@echo "Installing neospec (latest)..."
	@go install github.com/jedi-knights/neospec/cmd/neospec@latest
	@echo "Done. Run 'make test' to verify."

# Run tests with coverage (reads neospec.toml for all settings)
test:
	@command -v $(NEOSPEC) >/dev/null 2>&1 || { \
		echo "Error: neospec not found in PATH."; \
		echo "Install: go install github.com/jedi-knights/neospec/cmd/neospec@latest"; \
		exit 1; \
	}
	@$(NEOSPEC) run

# Verbose test runner for CI/debugging
test-verbose:
	@command -v $(NEOSPEC) >/dev/null 2>&1 || { \
		echo "Error: neospec not found in PATH."; \
		echo "Install: go install github.com/jedi-knights/neospec/cmd/neospec@latest"; \
		exit 1; \
	}
	@$(NEOSPEC) run --verbose

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
	@rm -rf coverage/
	@echo "Done."