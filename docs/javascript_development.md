# JavaScript/TypeScript/Node.js Development in Yoda.nvim

> A comprehensive guide to JavaScript, TypeScript, and Node.js development in Yoda.nvim with ts_ls LSP, vscode-js-debug debugging, Jest/Vitest testing, and Biome linting/formatting.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [LSP Features](#lsp-features)
4. [Debugging](#debugging)
5. [Testing](#testing)
6. [Linting & Formatting](#linting--formatting)
7. [TypeScript](#typescript)
8. [Package.json Management](#packagejson-management)
9. [Node.js REPL](#nodejs-repl)
10. [Code Navigation](#code-navigation)
11. [Console.log Helpers](#consolelog-helpers)
12. [Framework Support](#framework-support)
13. [Keymap Reference](#keymap-reference)
14. [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Install JavaScript Tools

Run the setup command to install all required tools:

```vim
:YodaJavaScriptSetup
```

This installs:
- `typescript-language-server` (ts_ls) - LSP server
- `js-debug-adapter` - Debug adapter for Node.js
- `biome` - Ultra-fast linter and formatter

After installation completes, restart Neovim.

### 2. Open a JavaScript/TypeScript Project

```bash
cd your-js-project
nvim src/index.ts
```

ts_ls will automatically activate and provide:
- ✅ Code completion
- ✅ Type checking (TypeScript)
- ✅ Auto-imports
- ✅ Inlay hints
- ✅ Inline diagnostics
- ✅ Refactoring actions

### 3. Essential Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>jr` | Run Node.js file |
| `<leader>jn` | Open Node REPL |
| `<leader>jt` | Run nearest test |
| `<leader>jd` | Start debugger |
| `<leader>jh` | Toggle inlay hints |
| `<leader>jo` | Toggle outline |

---

## Installation

### Automatic Setup

```vim
:YodaJavaScriptSetup
```

This command installs all necessary tools via Mason.

### Manual Setup

If you prefer manual installation:

#### 1. Install TypeScript Language Server

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to typescript-language-server, press 'i' to install
```

**Via npm:**
```bash
npm install -g typescript typescript-language-server
```

#### 2. Install js-debug-adapter (Debugger)

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to js-debug-adapter, press 'i' to install
```

This installs the VSCode JavaScript debugger adapter.

#### 3. Install Biome (Linter/Formatter)

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to biome, press 'i' to install
```

**Via npm:**
```bash
npm install -g @biomejs/biome
```

#### 4. Restart Neovim

After installation, restart Neovim to activate the tools.

### Verify Installation

Open a JavaScript/TypeScript file and check:
```vim
:LspInfo        " Should show ts_ls attached
:Mason          " Should show typescript-language-server, js-debug-adapter, biome installed
```

---

## LSP Features

Yoda.nvim uses `ts_ls` (TypeScript Language Server) for JavaScript and TypeScript support.

### Code Completion

Automatic as you type. Powered by ts_ls and Neovim's built-in LSP.

Features:
- Function/method completions
- Module imports
- Type hints (TypeScript)
- JSDoc snippets
- Framework-specific completions (React, Vue, etc.)

### Inlay Hints

TypeScript LSP shows type information inline:

```typescript
// Without inlay hints:
const numbers = [1, 2, 3].map(n => n * 2);

// With inlay hints enabled:
const numbers: number[] = [1, 2, 3].map((n: number): number => n * 2);
```

**Toggle inlay hints**:
```vim
<leader>jh      " Toggle inlay hints on/off
```

### Auto-Imports

ts_ls automatically suggests and adds imports:

```typescript
// Type: useState
// ts_ls suggests: import { useState } from 'react'
```

Press `<CR>` to accept the auto-import.

### Organize Imports

Clean up your imports:

```vim
<leader>jI      " Organize imports (remove unused, sort)
```

### Go to Definition

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |

### Code Actions

| Keymap | Action |
|--------|--------|
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |

Available code actions:
- Add missing imports
- Convert to arrow function
- Extract to function
- Extract to constant
- Infer function return type
- Add JSDoc comment

---

## Debugging

Yoda.nvim uses `vscode-js-debug` for JavaScript/Node.js debugging via `nvim-dap`.

### Why vscode-js-debug?

- 🎯 **Best-in-class** Node.js debugger
- 🌐 **Chrome DevTools** protocol
- 📦 **Multi-runtime** (Node.js, Chrome, Edge)
- 🗺️ **Source maps** support (TypeScript, webpack)
- ⚛️ **Framework support** (React, Vue, etc.)

### Setup Debugging

1. Ensure js-debug-adapter is installed (`:Mason`)
2. Open a JavaScript/TypeScript file
3. Set breakpoints
4. Start debugging

### Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>jd` | Start debugger |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / Start debug |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dq` | Terminate debug session |
| `<leader>du` | Toggle DAP UI |

### Debugging Workflow

1. **Set breakpoint**: Place cursor on line, press `<leader>db`
2. **Start debugger**: Press `<leader>jd`
3. **Select configuration**:
   - Launch file (debug current file)
   - Attach (attach to running process)
   - Debug Jest Tests
   - Launch Chrome (for web apps)
4. **Control execution**:
   - `<leader>dc` - Continue
   - `<leader>do` - Step over
   - `<leader>di` - Step into
5. **Inspect variables**: Check DAP UI panels
6. **Stop**: `<leader>dq`

### Debug Configurations

#### Node.js Debugging

**Launch current file**:
- Automatically runs current file with Node.js
- Sets up debugging session

**Attach to process**:
- Select running Node.js process
- Attach debugger to it

#### Jest/Vitest Debugging

**Debug Jest tests**:
- Runs Jest with `--runInBand` (sequential)
- Stops at breakpoints in tests

**Debug single test**:
1. Set breakpoint in test
2. Press `<leader>jd`
3. Select "Debug Jest Tests"

#### Chrome/Browser Debugging

**Debug web app**:
- Launches Chrome on `http://localhost:3000`
- Debugs frontend JavaScript
- Works with React, Vue, etc.

**Setup**:
1. Start your dev server: `npm run dev`
2. Update URL in config if needed
3. Press `<leader>jd`, select "Launch Chrome"

---

## Testing

Yoda.nvim supports **Jest** and **Vitest** via neotest.

### Test Frameworks

**Jest** (Traditional):
- Most widely used
- Great React support
- Extensive ecosystem

**Vitest** (Modern):
- 10x faster than Jest
- Built for Vite
- ESM first
- Better TypeScript support

**Both can coexist!** Neotest auto-detects which to use.

### Run Tests

| Keymap | Action |
|--------|--------|
| `<leader>jt` | Run nearest test |
| `<leader>jT` | Run all tests in file |
| `<leader>jC` | Run test suite |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Toggle test output |

### Test Workflow

#### Jest Example

1. **Write a test**:
```javascript
describe('Math functions', () => {
  test('addition works', () => {
    expect(2 + 2).toBe(4);
  });
});
```

2. **Run test**: Place cursor in test, press `<leader>jt`

3. **View results**: 
   - Inline icons show pass/fail
   - `<leader>ts` - Open summary panel
   - `<leader>to` - See detailed output

#### Vitest Example

1. **Write a test**:
```typescript
import { describe, it, expect } from 'vitest'

describe('Math functions', () => {
  it('addition works', () => {
    expect(2 + 2).toBe(4)
  })
})
```

2. **Run test**: Press `<leader>jt`

### Debug Tests

To debug a failing test:
1. Set breakpoint in test
2. Press `<leader>jd`, select "Debug Jest Tests"
3. Use standard debug keymaps

### Watch Mode

For continuous testing:
```vim
:Neotest watch      " Enable watch mode
```

Tests rerun automatically on file changes.

---

## Linting & Formatting

Yoda.nvim uses **Biome** for ultra-fast linting and formatting.

### Why Biome?

- ⚡ **10-100x faster** than ESLint + Prettier
- 🎯 **All-in-one** tool (lint + format)
- 🔧 **Compatible** with Prettier formatting
- 🦀 **Written in Rust**, extremely fast
- 📦 **Zero config** for most projects

### Formatting

**Auto-format on save**: Enabled by default

**Manual format**:
```vim
<leader>f       " Format buffer
```

**Formatters tried in order**:
1. Biome (fast, modern)
2. Prettier (fallback)
3. LSP formatter (final fallback)

### Linting

Biome runs automatically:
- On buffer enter
- On save
- On leaving insert mode

**View diagnostics**:
```vim
<leader>je      " Open diagnostics in Trouble
<leader>fD      " Find diagnostics with Telescope
```

### Configuration

#### Biome Configuration

Create `biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/1.0.0/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "lineWidth": 100
  }
}
```

#### Alternative: ESLint + Prettier

If you prefer traditional tools, update configs:

**For formatting** (edit `lua/plugins.lua`):
```lua
javascript = { "prettier" },
typescript = { "prettier" },
```

**For linting** (edit `lua/plugins.lua`):
```lua
javascript = { "eslint_d" },
typescript = { "eslint_d" },
```

Then install:
```vim
:MasonInstall eslint_d prettier
```

---

## TypeScript

### Type Checking

ts_ls provides real-time type checking as you type.

**Type checking features**:
- Type inference
- Interface checking
- Generic types
- Union/intersection types
- Type guards

### Example

```typescript
interface User {
  name: string;
  age: number;
}

function greet(user: User): string {
  return `Hello, ${user.name}`;
}

greet({ name: "Yoda", age: 900 }); // ✅ OK
greet({ name: "Luke" });           // ❌ Error: Missing 'age'
```

### tsconfig.json

TypeScript behavior is controlled by `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  }
}
```

### Strict Mode

Enable strict type checking in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

This enables:
- `strictNullChecks`
- `strictFunctionTypes`
- `strictBindCallApply`
- `noImplicitAny`
- `noImplicitThis`

---

## Package.json Management

`package-info.nvim` provides smart package.json editing.

### Features in package.json

When editing `package.json`, you get:
- Version information inline
- Latest version display
- Update actions
- Outdated package highlighting

### Keymaps (in package.json only)

| Keymap | Action |
|--------|--------|
| `<leader>js` | Show package info (versions, changelog) |
| `<leader>ju` | Update package to latest |
| `<leader>jd` | Delete package |
| `<leader>ji` | Install new package |
| `<leader>jv` | Change package version |

### Example Workflow

1. Open `package.json`
2. Place cursor on a dependency:
```json
{
  "dependencies": {
    "react": "^18.0.0"
           ^ cursor here
  }
}
```
3. Press `<leader>js` to see:
   - Current version: 18.0.0
   - Latest version: 18.3.1
   - Changelog link
   - Update action

4. Press `<leader>ju` to update to latest

### Check Outdated Packages

```vim
:YodaNpmOutdated    " Run npm outdated
```

Shows all packages that need updates.

---

## Node.js REPL

### Interactive Node.js Shell

Open an interactive Node.js REPL:

```vim
<leader>jn      " Open Node.js REPL in floating terminal
```

### Features

- ✅ **Floating terminal** - Doesn't split your layout
- ✅ **Persistent** - Toggle on/off with same keymap
- ✅ **Full REPL** - All Node.js functionality
- ✅ **Module imports** - Require/import modules

### REPL Workflow

```vim
<leader>jn      " Open REPL

# In REPL:
> const fs = require('fs');
> fs.readdirSync('.').filter(f => f.endsWith('.js'))
[ 'index.js', 'utils.js' ]

> .exit        # Or press <leader>jn to close
```

### REPL Commands

- `.help` - Show available commands
- `.break` - Exit multi-line input
- `.clear` - Clear REPL context
- `.exit` - Exit REPL
- `.save filename` - Save session to file
- `.load filename` - Load file into session

---

## Code Navigation

### Outline View (Aerial)

View code structure with `aerial.nvim`.

**Toggle outline**:
```vim
<leader>jo      " Toggle outline sidebar
```

Shows:
- Functions
- Classes
- Methods
- Interfaces (TypeScript)
- Types (TypeScript)
- Constants
- Imports

**Navigate**:
- Press `Enter` on symbol to jump
- `q` to close

### Symbol Search

**Document symbols**:
```vim
<leader>fR      " Find symbols in current file
```

**Workspace symbols**:
```vim
<leader>fS      " Find symbols across project
```

### File Navigation

**Find files** (Snacks picker):
```vim
<leader>ff      " Find files
<leader>fg      " Grep in files
<leader>fr      " Recent files
```

**Git files** (Telescope):
```vim
<leader>fG      " Find Git files
```

---

## Console.log Helpers

Quick utilities for debugging with console.log.

### Insert console.log

```vim
<leader>jl      " Insert console.log for word under cursor
```

Example:
```javascript
const userName = "Yoda";
//    ^ cursor here, press <leader>jl

// Automatically inserts:
console.log("userName:", userName);
```

### Remove All console.logs

Clean up debugging statements:

```vim
<leader>jL      " Remove all console.log statements from file
```

**Before**:
```javascript
function calculate(a, b) {
  console.log("a:", a);
  const result = a + b;
  console.log("result:", result);
  return result;
}
```

**After** (press `<leader>jL`):
```javascript
function calculate(a, b) {
  const result = a + b;
  return result;
}
```

---

## Framework Support

### React

**File types**: `.jsx`, `.tsx`

**Features**:
- JSX/TSX syntax highlighting
- Component completions
- Hook completions
- Prop type checking (TypeScript)

**Example**:
```typescript
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  //                         ^ Auto-complete shows: useState<number>(0)
  
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

### Vue

**File types**: `.vue`

**Note**: For optimal Vue support, consider adding `volar` LSP:
```vim
:MasonInstall vue-language-server
```

### Next.js / Nuxt

Works out of the box with ts_ls. Features:
- API route completions
- Dynamic imports
- Environment variables

### Build Tools

**Vite**:
- Works with Vitest testing
- Fast HMR
- ESM-first

**Webpack/esbuild**:
- Supported via source maps
- Debug bundled code

---

## Keymap Reference

### JavaScript-Specific Keymaps

All JavaScript keymaps use the `<leader>j` prefix.

#### Execution

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>jr` | Run Node.js file | Native |
| `<leader>jn` | Open Node.js REPL | Snacks terminal |

#### Testing

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>jt` | Run nearest test | Neotest |
| `<leader>jT` | Run file tests | Neotest |
| `<leader>jC` | Run test suite | Neotest |

#### Debugging

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>jd` | Start debugger | vscode-js-debug |
| `<leader>db` | Toggle breakpoint | DAP |
| `<leader>dc` | Continue | DAP |

#### Code Quality

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>jh` | Toggle inlay hints | LSP |
| `<leader>jI` | Organize imports | LSP |
| `<leader>je` | Open diagnostics | Trouble |

#### Navigation

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>jo` | Toggle outline | Aerial |
| `<leader>fR` | Find symbols | Telescope |

#### Utilities

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>jl` | Insert console.log | Native |
| `<leader>jL` | Remove console.logs | Native |

#### Package.json (in package.json only)

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>js` | Show package info | package-info.nvim |
| `<leader>ju` | Update package | package-info.nvim |
| `<leader>jd` | Delete package | package-info.nvim |
| `<leader>ji` | Install package | package-info.nvim |
| `<leader>jv` | Change version | package-info.nvim |

### General LSP Keymaps

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format buffer |

---

## Troubleshooting

### ts_ls not starting

**Check installation**:
```vim
:Mason          " Verify typescript-language-server is installed
:LspInfo        " Check if attached to buffer
```

**Reinstall**:
```vim
:MasonUninstall typescript-language-server
:MasonInstall typescript-language-server
```

**Restart LSP**:
```vim
:LspRestart
```

**Check for errors**:
```vim
:LspLog         " View LSP logs
```

### Module resolution errors

**Check tsconfig.json**:
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

**Restart LSP** after updating tsconfig:
```vim
:LspRestart
```

### Debugger not working

**Check js-debug-adapter installation**:
```vim
:Mason          " Verify js-debug-adapter installed
```

**Check DAP configuration**:
```vim
:lua print(vim.inspect(require("dap").configurations.typescript))
```

**Common issues**:

1. **Program not found**: Update `program` in debug config
2. **Port in use**: Change dev server port
3. **Source maps**: Ensure `sourceMap: true` in tsconfig

**Restart Neovim** after installing js-debug-adapter.

### Tests not detected

**Check test file naming**:

**Jest**:
- Files: `*.test.js`, `*.spec.js`, `__tests__/*.js`
- Functions: `test()`, `it()`

**Vitest**:
- Files: `*.test.ts`, `*.spec.ts`
- Functions: `test()`, `it()`, `describe()`

**Check test runner installation**:
```bash
npm list jest
# or
npm list vitest
```

**Restart neotest**:
```vim
:Neotest run.run()
```

### Biome not linting

**Check biome installation**:
```vim
:Mason          " Verify biome installed
```

**Or install via npm**:
```bash
npm install -g @biomejs/biome
```

**Check nvim-lint**:
```vim
:lua print(vim.inspect(require("lint").linters_by_ft.javascript))
```

### Inlay hints not showing

**Enable inlay hints**:
```vim
<leader>jh      " Toggle inlay hints
```

**Check LSP capability**:
```vim
:lua print(vim.lsp.inlay_hint.is_enabled())
```

**TypeScript only**: Inlay hints work for TypeScript, limited for plain JavaScript.

---

## Best Practices

### 1. Use TypeScript

TypeScript provides better IDE support:

```typescript
// Instead of:
function add(a, b) {
  return a + b;
}

// Use:
function add(a: number, b: number): number {
  return a + b;
}
```

### 2. Organize Imports Regularly

Keep imports clean:
```vim
<leader>jI      " Organize imports (remove unused, sort)
```

### 3. Use Inlay Hints for Learning

When learning new APIs:
```vim
<leader>jh      " Enable inlay hints to see types
```

Disable them once you're familiar with the code.

### 4. Debug with Breakpoints

Instead of console.log everywhere:
```vim
<leader>db      " Set breakpoint
<leader>jd      " Start debugger
```

### 5. Test-Driven Development

Write tests first, use `<leader>jt` to run them as you code.

### 6. Use Biome for Speed

Biome is much faster than ESLint + Prettier:
- Instant linting
- Instant formatting
- Better DX

### 7. Keep Dependencies Updated

Regularly check package.json:
```vim
:YodaNpmOutdated    " Check for updates
```

---

## Advanced Configuration

### Custom TypeScript Settings

Edit `lua/yoda/lsp.lua`:

```lua
vim.lsp.config.ts_ls = {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals", -- "none", "literals", "all"
      },
      preferences = {
        quoteStyle = "single",  -- Use single quotes
        importModuleSpecifier = "relative",  -- Relative imports
      },
    },
  },
}
```

### Disable Inlay Hints by Default

```lua
-- In TypeScript settings
inlayHints = {
  includeInlayParameterNameHints = "none",
}
```

Toggle them on when needed with `<leader>jh`.

### Custom Biome Rules

Create `biome.json`:

```json
{
  "linter": {
    "rules": {
      "suspicious": {
        "noDebugger": "error",
        "noConsoleLog": "warn"
      },
      "style": {
        "noNegationElse": "off"
      }
    }
  }
}
```

### Jest Configuration

Create `jest.config.js`:

```javascript
module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.js'],
  collectCoverageFrom: ['src/**/*.js'],
  coverageDirectory: 'coverage',
};
```

### Vitest Configuration

Create `vitest.config.ts`:

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
  },
})
```

---

## Node.js Version Management

### Check Node Version

```vim
:YodaNodeVersion    " Show current Node.js version
```

### Using nvm

If you use nvm, Yoda respects `.nvmrc`:

```bash
# Create .nvmrc
echo "18.17.0" > .nvmrc

# Use correct version
nvm use
```

### Multiple Node Versions

For projects requiring different Node versions:

```bash
# In project A (.nvmrc: v18)
nvm use
nvim

# In project B (.nvmrc: v20)
nvm use
nvim
```

ts_ls will use the active Node version.

---

## Build Tool Integration

### Vite

Works seamlessly with Vitest:

```vim
<leader>jt      " Run Vitest tests
```

**Dev server**:
```bash
npm run dev     # Start Vite dev server
<leader>jd      # Debug in Chrome (http://localhost:5173)
```

### Webpack

**Debug bundled code**:
- Ensure source maps enabled
- Set breakpoints in source files
- Debug works through source maps

### npm Scripts

Run any npm script:

```vim
:!npm run build
:!npm run lint
:!npm run test
```

Or create custom keymaps for common scripts.

---

## Comparison with Other Editors

### vs VSCode

| Feature | Yoda.nvim | VSCode |
|---------|-----------|--------|
| LSP | ts_ls | ts_ls (same!) |
| Debugger | vscode-js-debug | vscode-js-debug (same!) |
| Speed | ⚡⚡⚡ Fast | ⚡⚡ Moderate |
| Memory | Low | High |
| Testing | ✅ neotest | ✅ Jest Runner |
| Linting | ✅ Biome | ✅ ESLint |
| Customization | ✅✅✅ Unlimited | ✅✅ Extensions |

**Advantages**:
- **Faster**: Lighter weight, quicker startup
- **Keyboard-driven**: No mouse needed
- **Terminal-based**: Works over SSH
- **Unified**: Same editor for Rust, Python, Go, etc.

---

## Resources

### Official Documentation

- [TypeScript Docs](https://www.typescriptlang.org/docs/)
- [Node.js Docs](https://nodejs.org/docs/)
- [MDN JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [Biome Docs](https://biomejs.dev/)

### Testing Frameworks

- [Jest](https://jestjs.io/)
- [Vitest](https://vitest.dev/)

### Plugin Documentation

- [nvim-dap-vscode-js](https://github.com/mxsdev/nvim-dap-vscode-js)
- [neotest-jest](https://github.com/nvim-neotest/neotest-jest)
- [neotest-vitest](https://github.com/marilari88/neotest-vitest)
- [package-info.nvim](https://github.com/vuki656/package-info.nvim)

### Yoda.nvim Docs

- [LSP Guide](overview/LSP.md)
- [Debugging Guide](overview/DEBUGGING.md)
- [Keymaps Reference](KEYMAPS.md)
- [Troubleshooting](TROUBLESHOOTING.md)

---

## Comparison: All Three Languages

| Feature | Rust 🦀 | Python 🐍 | JavaScript 🟨 |
|---------|---------|-----------|---------------|
| **LSP** | rust-tools | basedpyright | ts_ls (enhanced) |
| **Inlay Hints** | ✅ | ❌ | ✅ TypeScript |
| **DAP** | codelldb | debugpy | vscode-js-debug |
| **Testing** | neotest-rust | neotest-python | neotest-jest/vitest |
| **Linting** | Clippy | ruff + mypy | Biome |
| **Formatting** | rustfmt | ruff/black | Biome/Prettier |
| **Keymaps** | `<leader>r*` | `<leader>p*` | `<leader>j*` |
| **Setup** | `:YodaRustSetup` | `:YodaPythonSetup` | `:YodaJavaScriptSetup` |
| **Pkg Mgmt** | crates.nvim | None | package-info.nvim |

### JavaScript Unique Features

- ✨ **Multiple test frameworks** (Jest, Vitest, Mocha)
- 🌐 **Browser debugging** (Chrome DevTools)
- ⚛️ **Framework support** (React, Vue, Svelte)
- 📦 **Package.json tooling** (inline version info)
- 🖥️ **Multi-runtime** (Node, Deno, Bun)
- 🔧 **Console.log helpers** (insert/remove)

---

## Tips & Tricks

### 1. Use TypeScript Strict Mode

Enable in `tsconfig.json`:
```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

Catches more errors at compile time.

### 2. Leverage Code Actions

Press `<leader>ca` frequently:
- Add missing imports
- Convert to arrow function
- Extract to function
- Add type annotations

### 3. Debug Tests Directly

Instead of console.log in tests:
```vim
<leader>db      " Set breakpoint in test
<leader>jd      " Debug test
```

### 4. Keep package.json Updated

```vim
:YodaNpmOutdated    " Check weekly
```

### 5. Use REPL for Experiments

Quick experiments:
```vim
<leader>jn
> [1,2,3].map(x => x * 2)
[ 2, 4, 6 ]
```

### 6. Clean Console.logs Before Committing

```vim
<leader>jL      " Remove all console.logs
```

### 7. Use Outline for Large Files

In large components:
```vim
<leader>jo      " Open outline to navigate
```

---

## Common Patterns

### Async/Await Debugging

Set breakpoints in async functions:

```typescript
async function fetchData() {
  const response = await fetch('/api/data');  // Set breakpoint here
  const data = await response.json();         // And here
  return data;
}
```

Debug normally with `<leader>jd`.

### React Component Debugging

Debug React components:

```typescript
function MyComponent({ prop }: Props) {
  const [state, setState] = useState(0);  // Breakpoint here
  
  useEffect(() => {
    console.log("Mounted");  // Or here
  }, []);
  
  return <div>{state}</div>;
}
```

Use Chrome debugging config for browser rendering.

### Testing Patterns

**Unit test**:
```typescript
import { add } from './math';

test('adds numbers', () => {
  expect(add(2, 2)).toBe(4);
});
```

**Component test** (React):
```typescript
import { render, screen } from '@testing-library/react';
import { MyComponent } from './MyComponent';

test('renders component', () => {
  render(<MyComponent />);
  expect(screen.getByText('Hello')).toBeInTheDocument();
});
```

---

## Graceful Degradation

Yoda.nvim works gracefully when tools are missing.

### Missing ts_ls

If ts_ls is not installed:
- Basic Vim editing works
- No LSP features
- Install via `:YodaJavaScriptSetup`

### Missing js-debug-adapter

If debugger not installed:
- `<leader>jd` shows error message
- Basic editing still works
- Install via `:YodaJavaScriptSetup`

### Missing Biome

If Biome not installed:
- Falls back to Prettier
- Then falls back to LSP formatting
- Install via `:MasonInstall biome`

### Missing Test Framework

If Jest/Vitest not in project:
- Test keymaps show helpful errors
- Can still run tests via `:!npm test`

---

## Feedback

Found an issue or have a suggestion? 

- [Open an issue](https://github.com/jedi-knights/yoda.nvim/issues)
- [Start a discussion](https://github.com/jedi-knights/yoda.nvim/discussions)

---

> *"Much to learn, you still have."* — Yoda

Happy JavaScript coding! 🟨

