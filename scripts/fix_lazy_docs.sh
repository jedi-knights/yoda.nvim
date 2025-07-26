#!/bin/bash

# Fix Lazy.nvim documentation generation issues
# This script cleans up problematic cache files that cause errors

echo "🔧 Fixing Lazy.nvim documentation generation issues..."

# Get Neovim state directory
NVIM_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
LAZY_STATE_DIR="$NVIM_STATE_DIR/lazy"

echo "📁 Lazy.nvim state directory: $LAZY_STATE_DIR"

# Clean up problematic directories and files
if [ -d "$LAZY_STATE_DIR/readme" ]; then
    echo "🗑️  Removing readme directory..."
    rm -rf "$LAZY_STATE_DIR/readme"
fi

if [ -f "$LAZY_STATE_DIR/lock.json" ]; then
    echo "🗑️  Removing lock file..."
    rm -f "$LAZY_STATE_DIR/lock.json"
fi

if [ -d "$LAZY_STATE_DIR/cache" ]; then
    echo "🗑️  Removing cache directory..."
    rm -rf "$LAZY_STATE_DIR/cache"
fi

# Check for plugin_dev.lua configuration
PLUGIN_DEV_CONFIG="$HOME/.config/nvim/plugin_dev.lua"
if [ -f "$PLUGIN_DEV_CONFIG" ]; then
    echo "✅ Found plugin_dev.lua configuration"
    
    # Validate local plugin paths
    echo "🔍 Checking local plugin paths..."
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        if [[ ! "$key" =~ ^[[:space:]]*-- ]] && [[ -n "$key" ]]; then
            # Extract the path (remove quotes and spaces)
            path=$(echo "$value" | sed 's/.*"\([^"]*\)".*/\1/')
            if [ -n "$path" ]; then
                expanded_path=$(eval echo "$path")
                if [ -d "$expanded_path" ]; then
                    echo "  ✅ $key: $expanded_path"
                else
                    echo "  ❌ $key: $expanded_path (not found)"
                fi
            fi
        fi
    done < "$PLUGIN_DEV_CONFIG"
else
    echo "⚠️  No plugin_dev.lua found. Create one based on plugin_dev.lua.example if needed."
fi

echo ""
echo "🎉 Lazy.nvim cache cleaned successfully!"
echo ""
echo "Next steps:"
echo "1. Restart Neovim"
echo "2. Run ':Lazy sync' to reload plugins"
echo "3. If issues persist, run ':YodaDebugLazy' for more debugging"
echo ""
echo "For more help, see the troubleshooting section in the README." 