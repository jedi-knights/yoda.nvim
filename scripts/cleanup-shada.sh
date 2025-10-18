#!/bin/bash

# Cleanup stale ShaDa temporary files
# These can accumulate when Neovim doesn't exit cleanly

SHADA_DIR="$HOME/.local/state/nvim/shada"

if [ -d "$SHADA_DIR" ]; then
    echo "Cleaning up ShaDa temporary files..."
    
    # Count all temp files (including recent ones that may be stuck)
    ALL_TEMPS=$(find "$SHADA_DIR" -name "*.tmp.*" 2>/dev/null | wc -l)
    
    if [ "$ALL_TEMPS" -gt 0 ]; then
        echo "Found $ALL_TEMPS temporary files"
        
        # List the files we're about to remove for transparency
        echo "Removing files:"
        find "$SHADA_DIR" -name "*.tmp.*" 2>/dev/null | head -10
        if [ "$ALL_TEMPS" -gt 10 ]; then
            echo "... and $(($ALL_TEMPS - 10)) more"
        fi
        
        # Remove ALL temp files (not just old ones)
        # This is safe because these are temporary files by definition
        find "$SHADA_DIR" -name "*.tmp.*" -delete 2>/dev/null
        echo "Cleanup completed - removed $ALL_TEMPS temporary files"
    else
        echo "No temporary files found"
    fi
    
    # Also clean up any backup ShaDa files that might be causing issues
    BACKUP_FILES=$(find "$SHADA_DIR" -name "*.bak" 2>/dev/null | wc -l)
    if [ "$BACKUP_FILES" -gt 0 ]; then
        echo "Found $BACKUP_FILES backup ShaDa files, removing..."
        find "$SHADA_DIR" -name "*.bak" -delete 2>/dev/null
        echo "Backup files removed"
    fi
else
    echo "ShaDa directory not found: $SHADA_DIR"
fi