# 🚀 Warp Terminal Icon Setup Guide

This guide will help you configure Warp terminal to properly display icons in your Yoda.nvim distribution.

## 🔍 **The Problem**

Snacks explorer and other file managers need **Nerd Font** icons to display file type icons properly. If you see squares (□) or missing characters instead of icons, your terminal font doesn't support these special characters.

## ✅ **Quick Fix Steps**

### **1. Install a Nerd Font**

**Option A: Install via Homebrew (Recommended)**
```bash
# Install JetBrains Mono Nerd Font (popular choice)
brew install --cask font-jetbrains-mono-nerd-font

# Or install FiraCode Nerd Font
brew install --cask font-fira-code-nerd-font

# Or install Hack Nerd Font
brew install --cask font-hack-nerd-font
```

**Option B: Manual Installation**
1. Go to [Nerd Fonts website](https://www.nerdfonts.com/)
2. Download your preferred font (JetBrains Mono, FiraCode, or Hack recommended)
3. Install the `.ttf` or `.otf` files by double-clicking them

### **2. Configure Warp Terminal**

**Method 1: Via Warp Settings**
1. Open Warp Terminal
2. Press `Cmd + ,` to open settings
3. Go to **Appearance** → **Text**
4. Change the font to your installed Nerd Font:
   - `JetBrainsMono Nerd Font`
   - `FiraCode Nerd Font` 
   - `Hack Nerd Font`
   - Or any other Nerd Font you installed

**Method 2: Via Configuration File**
Edit `~/.warp/settings.json`:
```json
{
  "appearance": {
    "font": {
      "name": "JetBrainsMono Nerd Font",
      "size": 14
    }
  }
}
```

### **3. Restart Warp Terminal**

Close and reopen Warp for the font changes to take effect.

## 🧪 **Test Icon Display**

After configuring the font, test if icons work:

1. **Open Neovim in Warp:**
   ```bash
   nvim
   ```

2. **Run Icon Diagnostics:**
   ```vim
   :IconDiagnostics
   ```

3. **Test Snacks Explorer:**
   ```vim
   :lua Snacks.explorer.open()
   ```

You should now see proper file icons! 🎉

## 🔧 **Alternative Solutions**

### **If Icons Still Don't Work:**

**Option 1: Disable Icons**
Add to your Snacks configuration:
```lua
explorer = {
  enabled = true,
  replace_netrw = true,
  show_hidden = true,
  icons = {
    enabled = false, -- Disable icons completely
  },
}
```

**Option 2: Use Text-Based Icons**
```lua
explorer = {
  enabled = true,
  replace_netrw = true,
  show_hidden = true,
  icons = {
    enabled = true,
    default_file = "📄",
    default_folder = "📁",
    default_folder_open = "📂",
  },
}
```

## 🎨 **Recommended Nerd Fonts**

| Font | Style | Best For |
|------|-------|----------|
| **JetBrains Mono** | Clean, modern | Programming, general use |
| **FiraCode** | Ligature support | Code with symbols |
| **Hack** | Clear, readable | Long coding sessions |
| **Meslo** | Classic | Terminal work |
| **Source Code Pro** | Adobe design | Professional look |

## 🔍 **Troubleshooting**

### **Icons Show as Squares (□)**
- Font doesn't support Nerd Font icons
- Install and configure a proper Nerd Font

### **Icons Show Incorrectly**
- Font version might be outdated
- Download latest version from [Nerd Fonts](https://www.nerdfonts.com/)

### **Warp Doesn't Show Font Options**
- Restart Warp after installing fonts
- Check font is properly installed in Font Book (macOS)

### **Still No Icons in Neovim**
- Run `:IconDiagnostics` for detailed troubleshooting
- Check `:checkhealth` for any terminal issues

## ✅ **Success Indicators**

You'll know it's working when you see:
- ✅ File type icons in Snacks explorer
- ✅ Folder icons (📁/📂) 
- ✅ Language-specific icons (🐍 for Python, ⚡ for JavaScript, etc.)
- ✅ Git status icons in file explorer

---

Once configured properly, your Yoda.nvim distribution will have beautiful file icons throughout the interface! 🚀
