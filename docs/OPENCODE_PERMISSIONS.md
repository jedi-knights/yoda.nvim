# OpenCode Permissions Guide

OpenCode requires explicit permission to run bash commands. This guide explains how to configure permissions to avoid constant prompts in plan mode.

## Quick Fix

Run the included script to update your permissions:

```bash
./update-opencode-permissions.sh
```

This will:
- Backup your current config
- Add comprehensive tool permissions
- Allow ~100+ common development tools

## Manual Configuration

Edit `~/.config/opencode/opencode.json` and add tools to the `permission.bash` section:

```json
{
  "permission": {
    "bash": {
      "python": "allow",
      "git": "allow",
      "make": "allow",
      "npm": "allow",
      "nvim": "allow"
    }
  }
}
```

## Common Tools to Allow

### Essential Development Tools
```json
"python": "allow",
"python3": "allow",
"node": "allow",
"npm": "allow",
"git": "allow",
"make": "allow",
"nvim": "allow",
"lua": "allow"
```

### File Operations
```json
"cat": "allow",
"ls": "allow",
"cd": "allow",
"mkdir": "allow",
"rm": "allow",
"mv": "allow",
"cp": "allow",
"touch": "allow"
```

### Text Processing
```json
"grep": "allow",
"rg": "allow",
"sed": "allow",
"awk": "allow",
"jq": "allow",
"wc": "allow",
"head": "allow",
"tail": "allow"
```

### Build Tools
```json
"make": "allow",
"cmake": "allow",
"cargo": "allow",
"go": "allow",
"gcc": "allow",
"clang": "allow"
```

## Permission Options

| Value | Description |
|-------|-------------|
| `"allow"` | Always allow without prompting |
| `"deny"` | Always deny without prompting |
| (omitted) | Prompt user each time |

## Troubleshooting

### Still Getting Prompts

1. Check your config is valid JSON:
   ```bash
   jq . ~/.config/opencode/opencode.json
   ```

2. Verify permissions are loaded:
   ```bash
   cat ~/.config/opencode/opencode.json | jq '.permission.bash'
   ```

3. Restart OpenCode completely (not just window)

### Permission Denied Errors

The command might not be in your permission list. Add it:

```json
"command_name": "allow"
```

### Want to Review Before Allowing

Instead of `"allow"`, omit the entry to get prompted:

```json
{
  "permission": {
    "bash": {
      "safe_command": "allow",
      // risky_command will prompt
    }
  }
}
```

## Security Considerations

### Safe to Allow

- Read-only commands: `cat`, `ls`, `head`, `tail`, `grep`
- Version control: `git` (with care)
- Package managers: `npm`, `pip`, `cargo` (for development)
- Build tools: `make`, `cmake`
- Text editors: `nvim`, `vim`

### Be Careful With

- `rm` - Can delete files
- `chmod` - Can change permissions
- `sudo` - Elevated privileges (never allow)
- `curl`/`wget` - Can download arbitrary content
- Shell operators: `>`, `>>`, `|`, `;`

### Never Allow

- `sudo` - Root access
- `dd` - Can destroy data
- `mkfs` - Formats disks
- `fdisk` - Disk partitioning
- `reboot`/`shutdown` - System control

## Advanced Configuration

### Allow Specific Patterns

You can't use wildcards in permissions, but you can allow base commands:

```json
{
  "bash": {
    "python": "allow",
    // This allows: python, python3, python3.11, etc.
    // But you must explicitly list each variant you use
    "python3": "allow"
  }
}
```

### Environment-Specific Configs

Create separate configs for different projects:

```bash
# Work project
cp ~/.config/opencode/opencode.json ~/work-project/.opencode.json

# Personal project with more permissive settings
cp ~/.config/opencode/opencode.json ~/personal-project/.opencode.json
```

OpenCode will use project-specific config if it exists.

## Backup and Restore

### Backup Current Config

```bash
cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.backup
```

### Restore Backup

```bash
cp ~/.config/opencode/opencode.json.backup ~/.config/opencode/opencode.json
```

### Version Control Your Config

```bash
cd ~/.config/opencode
git init
git add opencode.json
git commit -m "feat: add opencode permissions config"
```

## Example Configs

### Minimal (Manual Approval)

```json
{
  "permission": {
    "bash": {
      "cat": "allow",
      "ls": "allow",
      "grep": "allow"
    }
  }
}
```

### Development (Most Common)

```json
{
  "permission": {
    "bash": {
      "python": "allow",
      "python3": "allow",
      "node": "allow",
      "npm": "allow",
      "git": "allow",
      "make": "allow",
      "nvim": "allow",
      "cat": "allow",
      "ls": "allow",
      "grep": "allow",
      "rg": "allow",
      "find": "allow",
      "sed": "allow",
      "awk": "allow"
    }
  }
}
```

### Comprehensive (Trust OpenCode)

Use the included script:
```bash
./update-opencode-permissions.sh
```

This allows ~100+ common development tools.

## See Also

- [OpenCode Documentation](https://opencode.ai/docs)
- [Security Best Practices](https://opencode.ai/docs/security)
- Main project documentation: [OPENCODE.md](OPENCODE.md)
