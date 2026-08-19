# Makefile for Yoda.nvim

# Neovim binary. Override with: make test NVIM_BIN=/path/to/nvim
# NOTE: We intentionally avoid `NVIM` here because that name collides with the
# `$NVIM` env var Neovim exports when a terminal buffer runs a child shell —
# it holds the msgpack-RPC socket path, not the binary.
NVIM_BIN ?= nvim

# Directory containing plenary-driven spec files
SPEC_DIR   ?= tests/yoda
SPEC_INIT  ?= tests/minimal_init.lua

.PHONY: test test-file lint format benchmark benchmark-startup benchmark-buffers benchmark-files benchmark-memory benchmark-lsp benchmark-clean clean help

# Default target
help:
	@echo "Yoda.nvim Development Commands"
	@echo ""
	@echo "Testing (plenary-based):"
	@echo "  make test              - Run all specs under $(SPEC_DIR)"
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

# Run every spec under $(SPEC_DIR) using plenary.busted.
# Plenary auto-discovers *_spec.lua files. minimal_init is passed so each spec
# subprocess boots with the same isolated environment.
test:
	@command -v $(NVIM_BIN) >/dev/null 2>&1 || { \
		echo "Error: $(NVIM_BIN) not found in PATH."; \
		echo "Install Neovim (>= 0.10.1) or set NVIM_BIN=/path/to/nvim"; \
		exit 1; \
	}
	@$(NVIM_BIN) --headless --noplugin -u $(SPEC_INIT) \
		-c "PlenaryBustedDirectory $(SPEC_DIR) { minimal_init = '$(SPEC_INIT)' }"

# Run a single spec file, e.g. `make test-file FILE=tests/yoda/environment_spec.lua`
test-file:
	@[ -n "$(FILE)" ] || { echo "Usage: make test-file FILE=tests/yoda/<spec>_spec.lua"; exit 1; }
	@$(NVIM_BIN) --headless --noplugin -u $(SPEC_INIT) \
		-c "PlenaryBustedFile $(FILE)"

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
