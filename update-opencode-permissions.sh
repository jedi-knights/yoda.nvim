#!/bin/bash
# Update OpenCode permissions to allow more tools in plan mode

set -e

OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"
BACKUP_FILE="$HOME/.config/opencode/opencode.json.backup.$(date +%Y%m%d_%H%M%S)"

echo "📝 Updating OpenCode permissions..."
echo ""

# Backup existing config
if [ -f "$OPENCODE_CONFIG" ]; then
  echo "💾 Creating backup: $BACKUP_FILE"
  cp "$OPENCODE_CONFIG" "$BACKUP_FILE"
else
  echo "⚠️  No existing config found at $OPENCODE_CONFIG"
  exit 1
fi

# Create updated config
cat > "$OPENCODE_CONFIG" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "mercury/devflow.default",
  "provider": {
    "mercury": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Mercury",
      "options": {
        "baseURL": "https://api.mercury.weather.com/litellm/v1",
        "apiKey": "{env:MERCURY_API_KEY}"
      },
      "models": {
        "claude-sonnet-4-5-20250929": {
          "name": "Claude Sonnet 4.5"
        },
        "mercury/devflow.default": {
          "name": "Mercury DevFlow (default)"
        }
      }
    }
  },
  "permission": {
    "bash": {
      "python": "allow",
      "python3": "allow",
      "pip": "allow",
      "pip3": "allow",
      "pytest": "allow",
      "grep": "allow",
      "rg": "allow",
      "ripgrep": "allow",
      "find": "allow",
      "fd": "allow",
      "make": "allow",
      "cmake": "allow",
      "npm": "allow",
      "yarn": "allow",
      "pnpm": "allow",
      "node": "allow",
      "git": "allow",
      "gh": "allow",
      "stylua": "allow",
      "nvim": "allow",
      "vim": "allow",
      "lua": "allow",
      "luac": "allow",
      "cat": "allow",
      "ls": "allow",
      "cd": "allow",
      "pwd": "allow",
      "echo": "allow",
      "sed": "allow",
      "awk": "allow",
      "curl": "allow",
      "wget": "allow",
      "opencode": "allow",
      "mkdir": "allow",
      "rm": "allow",
      "mv": "allow",
      "cp": "allow",
      "touch": "allow",
      "chmod": "allow",
      "chown": "allow",
      "wc": "allow",
      "head": "allow",
      "tail": "allow",
      "sort": "allow",
      "uniq": "allow",
      "diff": "allow",
      "patch": "allow",
      "tar": "allow",
      "gzip": "allow",
      "gunzip": "allow",
      "bzip2": "allow",
      "bunzip2": "allow",
      "zip": "allow",
      "unzip": "allow",
      "jq": "allow",
      "yq": "allow",
      "tree": "allow",
      "which": "allow",
      "whereis": "allow",
      "file": "allow",
      "stat": "allow",
      "date": "allow",
      "sleep": "allow",
      "true": "allow",
      "false": "allow",
      "test": "allow",
      "expr": "allow",
      "basename": "allow",
      "dirname": "allow",
      "realpath": "allow",
      "xargs": "allow",
      "tee": "allow",
      "cut": "allow",
      "paste": "allow",
      "tr": "allow",
      "fmt": "allow",
      "fold": "allow",
      "column": "allow",
      "expand": "allow",
      "unexpand": "allow",
      "env": "allow",
      "export": "allow",
      "unset": "allow",
      "printenv": "allow",
      "man": "allow",
      "less": "allow",
      "more": "allow",
      "vi": "allow",
      "nano": "allow",
      "emacs": "allow",
      "code": "allow",
      "docker": "allow",
      "docker-compose": "allow",
      "kubectl": "allow",
      "helm": "allow",
      "terraform": "allow",
      "ansible": "allow",
      "ssh": "allow",
      "scp": "allow",
      "rsync": "allow",
      "telnet": "allow",
      "nc": "allow",
      "netcat": "allow",
      "ping": "allow",
      "traceroute": "allow",
      "nslookup": "allow",
      "dig": "allow",
      "host": "allow",
      "ifconfig": "allow",
      "ip": "allow",
      "route": "allow",
      "netstat": "allow",
      "lsof": "allow",
      "ps": "allow",
      "top": "allow",
      "htop": "allow",
      "kill": "allow",
      "killall": "allow",
      "pkill": "allow",
      "jobs": "allow",
      "bg": "allow",
      "fg": "allow",
      "nohup": "allow",
      "screen": "allow",
      "tmux": "allow",
      "systemctl": "allow",
      "service": "allow",
      "journalctl": "allow",
      "df": "allow",
      "du": "allow",
      "mount": "allow",
      "umount": "allow",
      "ln": "allow",
      "readlink": "allow",
      "md5sum": "allow",
      "sha256sum": "allow",
      "sha1sum": "allow",
      "base64": "allow",
      "od": "allow",
      "hexdump": "allow",
      "xxd": "allow",
      "strings": "allow",
      "strip": "allow",
      "objdump": "allow",
      "nm": "allow",
      "ldd": "allow",
      "strace": "allow",
      "ltrace": "allow",
      "gdb": "allow",
      "lldb": "allow",
      "cargo": "allow",
      "rustc": "allow",
      "go": "allow",
      "javac": "allow",
      "java": "allow",
      "gcc": "allow",
      "g++": "allow",
      "clang": "allow",
      "clang++": "allow",
      "ruby": "allow",
      "perl": "allow",
      "php": "allow",
      "swift": "allow",
      "kotlin": "allow",
      "scala": "allow",
      "r": "allow",
      "Rscript": "allow",
      "julia": "allow",
      "octave": "allow",
      "matlab": "allow",
      "latex": "allow",
      "pdflatex": "allow",
      "pandoc": "allow",
      "convert": "allow",
      "ffmpeg": "allow",
      "sox": "allow",
      "imagemagick": "allow"
    }
  }
}
EOF

echo ""
echo "✅ OpenCode permissions updated!"
echo ""
echo "📋 Summary of changes:"
echo "   • Added ~100+ common development tools"
echo "   • Includes: language runtimes, build tools, version control, etc."
echo "   • Backup saved to: $BACKUP_FILE"
echo ""
echo "🔄 Restart OpenCode for changes to take effect"
echo ""
echo "To verify:"
echo "  cat ~/.config/opencode/opencode.json | jq '.permission.bash | keys'"
