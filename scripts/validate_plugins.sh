#!/bin/bash
set -euo pipefail

echo "==================================="
echo "Plugin Configuration Validation"
echo "==================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# Test 1: Neovim starts without errors
echo -n "Test 1: Neovim startup... "
if nvim --headless +'lua vim.g.test_mode = true' +qa 2>/dev/null; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  ((ERRORS++))
fi

# Test 2: Lazy loads
echo -n "Test 2: Lazy.nvim loads... "
if nvim --headless +'lua require("lazy")' +qa 2>/dev/null; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  ((ERRORS++))
fi

# Test 3: Count plugins
echo -n "Test 3: Plugin count... "
PLUGIN_COUNT=$(nvim --headless +'lua print(#require("lazy").plugins())' +qa 2>&1 | tail -1)
if [ "$PLUGIN_COUNT" -ge 50 ]; then
  echo -e "${GREEN}PASS${NC} ($PLUGIN_COUNT plugins)"
else
  echo -e "${RED}FAIL${NC} (Expected >=50, got $PLUGIN_COUNT)"
  ((ERRORS++))
fi

# Test 4: No duplicate plugins
echo -n "Test 4: No duplicates... "
DUPES=$(nvim --headless +'lua local seen = {} local dupes = {} for _, p in ipairs(require("lazy").plugins()) do if seen[p.name] then table.insert(dupes, p.name) else seen[p.name] = true end end print(table.concat(dupes, ","))' +qa 2>&1 | tail -1)
if [ -z "$DUPES" ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (Duplicates: $DUPES)"
  ((ERRORS++))
fi

# Test 5: Lint passes
echo -n "Test 5: Lint check... "
if make lint > /dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${YELLOW}WARN${NC}"
fi

# Test 6: Tests pass
echo -n "Test 6: Test suite... "
if make test > /dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${YELLOW}WARN${NC}"
fi

echo ""
echo "==================================="
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}All critical tests passed!${NC}"
  exit 0
else
  echo -e "${RED}$ERRORS critical test(s) failed!${NC}"
  exit 1
fi
