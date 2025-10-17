#!/bin/bash

# Cleanup stale ShaDa temporary files
# These can accumulate when Neovim doesn't exit cleanly

SHADA_DIR="$HOME/.local/state/nvim/shada"

if [ -d "$SHADA_DIR" ]; then
    echo "Cleaning up stale ShaDa temporary files..."
    
    # Find temp files older than 1 day
    OLD_TEMPS=$(find "$SHADA_DIR" -name "*.tmp.*" -mtime +1 2>/dev/null | wc -l)
    
    if [ "$OLD_TEMPS" -gt 0 ]; then
        echo "Found $OLD_TEMPS stale temporary files"
        find "$SHADA_DIR" -name "*.tmp.*" -mtime +1 -delete 2>/dev/null
        echo "Cleanup completed"
    else
        echo "No stale temporary files found"
    fi
else
    echo "ShaDa directory not found: $SHADA_DIR"
fi