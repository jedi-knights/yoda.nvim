#!/bin/bash
if [ ! -f /tmp/yoda_last_snapshot.txt ]; then
  echo "No baseline snapshot found"
  exit 1
fi

BASELINE=$(cat /tmp/yoda_last_snapshot.txt)
CURRENT="/tmp/yoda_current_$$"
mkdir -p "$CURRENT"

# Create current snapshot
nvim --headless +'lua local plugins = require("lazy").plugins(); for _, p in ipairs(plugins) do print(p.name) end' +qa 2>&1 | grep -v "^$" | sort > "$CURRENT/plugins.txt"

echo "Comparing snapshots:"
echo "Baseline: $BASELINE"
echo "Current: $CURRENT"
echo ""

diff -u "$BASELINE/plugins.txt" "$CURRENT/plugins.txt" || true

rm -rf "$CURRENT"
