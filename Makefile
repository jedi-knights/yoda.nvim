# Makefile for Yoda.nvim

# Test runner. neospec downloads and caches its own pinned Neovim, so no
# system Neovim is required for `make test`.
NEOSPEC     ?= neospec
# Keep in step with .github/workflows/ci.yml — the suite is verified against
# the minimum supported Neovim, not whatever is installed locally.
NVIM_VERSION ?= v0.11.0

SPEC_DIR    ?= tests/yoda
SPEC_INIT   ?= tests/minimal_init.lua
SPEC_GLOB   ?= $(SPEC_DIR)/**/*_spec.lua

.PHONY: test test-file test-coverage require-neospec lint format benchmark benchmark-startup benchmark-buffers benchmark-files benchmark-memory benchmark-lsp benchmark-clean clean help

# Default target
help:
	@echo "Yoda.nvim Development Commands"
	@echo ""
	@echo "Testing (neospec):"
	@echo "  make test              - Run all specs under $(SPEC_DIR)"
	@echo "  make test-coverage     - Run all specs and emit coverage reports"
	@echo "  make test-file FILE=x  - Run a single spec file"
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

# Run every spec under $(SPEC_DIR) with neospec's embedded harness.
test: require-neospec
	@$(NEOSPEC) run --init-file=$(SPEC_INIT) --pattern='$(SPEC_GLOB)' \
		--neovim-version=$(NVIM_VERSION) --format=console

# Run a single spec file, e.g. `make test-file FILE=tests/yoda/environment_spec.lua`
test-file: require-neospec
	@[ -n "$(FILE)" ] || { echo "Usage: make test-file FILE=tests/yoda/<spec>_spec.lua"; exit 1; }
	@$(NEOSPEC) run --init-file=$(SPEC_INIT) --pattern='$(FILE)' \
		--neovim-version=$(NVIM_VERSION) --format=console

# Run the suite and emit coverage reports. Used by the Badge workflow; the
# test execution is identical to `make test`, so the badge measures exactly
# what CI verifies rather than a second, drifting runner configuration.
# --coverage-include is a substring match, so it must be narrow enough to
# exclude Neovim's own runtime. `lua/` is NOT enough: runtime paths contain
# `runtime/lua/vim/...`, which leaks vim/F.lua and friends into the report as
# relative paths genhtml then fails to resolve.
# --coverage-source makes files that no test loads count against the total.
# Without it the report only contains modules some spec happened to require,
# which silently flatters the percentage: untested code is exactly the code
# most likely never to be loaded. Requires neospec >= v0.6.0.
test-coverage: require-neospec
	@$(NEOSPEC) run --init-file=$(SPEC_INIT) --pattern='$(SPEC_GLOB)' \
		--neovim-version=$(NVIM_VERSION) --coverage-include=lua/yoda \
		--coverage-source='lua/**/*.lua' \
		--format=console --format=lcov --coverage-dir=coverage

# Fail with an actionable message rather than a cryptic "command not found".
# This is the one out-of-band install the suite needs; neospec fetches its own
# Neovim, so it is the only prerequisite.
require-neospec:
	@command -v $(NEOSPEC) >/dev/null 2>&1 || { \
		echo "Error: $(NEOSPEC) not found in PATH."; \
		echo ""; \
		echo "  brew install jedi-knights/tap/neospec"; \
		echo ""; \
		echo "or set NEOSPEC=/path/to/neospec"; \
		exit 1; \
	}

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
