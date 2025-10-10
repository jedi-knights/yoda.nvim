# 🚀 Installation Guide

This guide will help you install and set up Yoda.nvim quickly and easily.

## Prerequisites

- **Neovim 0.10.1+**
- **Git**
- **ripgrep** (for fuzzy finding)

### Install Prerequisites

#### macOS (Homebrew)
```bash
# Install Neovim
brew install neovim

# Install ripgrep
brew install ripgrep
```

#### Ubuntu/Debian
```bash
# Install Neovim
sudo apt update
sudo apt install neovim

# Install ripgrep
sudo apt install ripgrep
```

#### Arch Linux
```bash
# Install Neovim
sudo pacman -S neovim

# Install ripgrep
sudo pacman -S ripgrep
```

## Quick Installation

### Method 1: Git Clone (Recommended)
```bash
# Clone the repository
git clone https://github.com/jedi-knights/yoda ~/.config/nvim

# Start Neovim
nvim
```

### Method 2: Shallow Clone (Faster)
```bash
# Shallow clone for faster download
git clone --depth=1 https://github.com/jedi-knights/yoda ~/.config/nvim

# Start Neovim
nvim
```

### Method 3: Manual Installation
```bash
# Create Neovim config directory
mkdir -p ~/.config/nvim

# Download and extract
curl -L https://github.com/jedi-knights/yoda/archive/main.tar.gz | tar -xz
mv yoda-main/* ~/.config/nvim/
rm -rf yoda-main
```

## First Launch

The first launch will automatically bootstrap all plugins via `lazy.nvim`. This may take a few minutes depending on your internet connection.

### What Happens on First Launch
1. **Plugin Installation**: Lazy.nvim downloads and installs all required plugins
2. **Language Servers**: Mason installs LSP servers for common languages
3. **Dashboard**: Alpha dashboard appears with welcome screen
4. **Configuration**: All settings are applied automatically

## Shell Aliases (Optional)

Add these to your `~/.zshrc` or `~/.bashrc` for convenience:

```bash
alias vi=nvim
alias vim=nvim
```

## Verification

After installation, verify everything is working:

```bash
# Check Neovim version
nvim --version

# Should show 0.10.1 or higher
```

## Next Steps

- **[Getting Started Guide](GETTING_STARTED.md)** - Learn the basics
- **[Keymaps Reference](KEYMAPS.md)** - Essential shortcuts
- **[AI Setup Guide](AI_SETUP.md)** - Configure AI features
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions

## Uninstallation

To remove Yoda.nvim:

```bash
# Remove the configuration directory
rm -rf ~/.config/nvim

# Optional: Remove Lazy.nvim data
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
```

---

**Need help?** Check our [Troubleshooting Guide](TROUBLESHOOTING.md) or [open an issue](https://github.com/jedi-knights/yoda.nvim/issues).
