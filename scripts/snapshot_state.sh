#!/bin/bash
SNAPSHOT_DIR="/tmp/yoda_snapshots/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SNAPSHOT_DIR"

echo "Creating snapshot in $SNAPSHOT_DIR"

# Save plugin list
nvim --headless +'lua local plugins = require("lazy").plugins(); for _, p in ipairs(plugins) do print(p.name) end' +qa 2>&1 | grep -v "^$" | sort > "$SNAPSHOT_DIR/plugins.txt"

# Save plugin count
wc -l "$SNAPSHOT_DIR/plugins.txt" > "$SNAPSHOT_DIR/plugin_count.txt"

# Save config file checksums
find lua/plugins* -type f -name "*.lua" 2>/dev/null | xargs md5sum > "$SNAPSHOT_DIR/checksums.txt" 2>/dev/null || true

echo "Snapshot saved: $SNAPSHOT_DIR"
echo "$SNAPSHOT_DIR" > /tmp/yoda_last_snapshot.txt
