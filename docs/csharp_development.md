# C# / .NET Development in Yoda.nvim

> A comprehensive guide to C# and .NET development in Yoda.nvim with Roslyn LSP, netcoredbg debugging, neotest-dotnet testing, and csharpier formatting.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [LSP Features](#lsp-features)
4. [Debugging](#debugging)
5. [Testing](#testing)
6. [Linting & Formatting](#linting--formatting)
7. [Solution & Project Management](#solution--project-management)
8. [NuGet Package Management](#nuget-package-management)
9. [Code Navigation](#code-navigation)
10. [Keymap Reference](#keymap-reference)
11. [Framework Support](#framework-support)
12. [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Install C# Tools

Run the setup command to install all required tools:

```vim
:YodaCSharpSetup
```

This installs:
- `csharp-ls` - Roslyn LSP server (official Microsoft)
- `netcoredbg` - .NET debugger
- `csharpier` - C# formatter

After installation completes, restart Neovim.

### 2. Open a .NET Project

```bash
cd your-dotnet-project
nvim Program.cs
```

csharp-ls will automatically activate and provide:
- ✅ IntelliSense completions
- ✅ Type checking
- ✅ Code actions
- ✅ Inlay hints
- ✅ Inline diagnostics
- ✅ Roslyn analyzers

### 3. Essential Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>cr` | dotnet run |
| `<leader>cb` | dotnet build |
| `<leader>ct` | Run nearest test |
| `<leader>cd` | Start debugger |
| `<leader>ch` | Toggle inlay hints |
| `<leader>co` | Toggle outline |

---

## Installation

### Automatic Setup

```vim
:YodaCSharpSetup
```

This command installs all necessary tools via Mason.

### Manual Setup

If you prefer manual installation:

#### 1. Install csharp-ls (Roslyn LSP)

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to csharp-ls, press 'i' to install
```

**Via dotnet tool:**
```bash
dotnet tool install -g csharp-ls
```

#### 2. Install netcoredbg (Debugger)

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to netcoredbg, press 'i' to install
```

**Manual download**:
- [netcoredbg releases](https://github.com/Samsung/netcoredbg/releases)

#### 3. Install csharpier (Formatter)

**Via Mason (Recommended):**
```vim
:Mason
# Navigate to csharpier, press 'i' to install
```

**Via dotnet tool:**
```bash
dotnet tool install -g csharpier
```

#### 4. Install .NET SDK

```bash
# macOS (via Homebrew)
brew install dotnet

# Or download from Microsoft
# https://dotnet.microsoft.com/download
```

#### 5. Restart Neovim

After installation, restart Neovim to activate the tools.

### Verify Installation

Open a C# file and check:
```vim
:LspInfo        " Should show csharp_ls attached
:Mason          " Should show csharp-ls, netcoredbg, csharpier installed
:YodaDotnetVersion  " Check .NET SDK version
```

---

## LSP Features

Yoda.nvim uses `csharp-ls` (Roslyn LSP) for C# support.

### Why Roslyn LSP?

- 🚀 **Official Microsoft** LSP implementation
- ⚡ **Fast** performance
- 🎯 **Complete** C# language support
- 🔧 **Roslyn analyzers** built-in
- ✅ **.NET Core, .NET 5+** support

### Code Completion (IntelliSense)

Automatic as you type. Powered by Roslyn.

Features:
- Method/property completions
- Using statements
- Type hints
- XML documentation
- Code snippets
- Extension methods

### Inlay Hints

Roslyn shows type information inline:

```csharp
// Without inlay hints:
var numbers = new[] { 1, 2, 3 };

// With inlay hints enabled:
var numbers: int[] = new[] { 1, 2, 3 };
```

**Toggle inlay hints**:
```vim
<leader>ch      " Toggle inlay hints on/off
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
- Add using statement
- Generate constructor
- Implement interface
- Extract method
- Inline variable
- Convert to expression body
- Add null check

### Diagnostics & Analyzers

Roslyn analyzers run automatically:
- **Style analyzers** (naming conventions, formatting)
- **Code quality** (unused variables, dead code)
- **Performance** (boxing, allocations)
- **Security** (SQL injection, XSS)

View diagnostics:
```vim
<leader>ce      " Open diagnostics in Trouble
<leader>fD      " Find diagnostics with Telescope
```

---

## Debugging

Yoda.nvim uses `netcoredbg` for .NET debugging via `nvim-dap`.

### Why netcoredbg?

- 🎯 **Best .NET debugger** for Linux/macOS
- 🔧 **Cross-platform** (Windows, Linux, macOS)
- 📦 **Multi-framework** (.NET Core, .NET 5+)
- ⚡ **Fast** and lightweight

### Setup Debugging

1. Ensure netcoredbg is installed (`:Mason`)
2. Build your project (`dotnet build`)
3. Open a C# file
4. Set breakpoints
5. Start debugging

### Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>cd` | Start debugger |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / Start debug |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dq` | Terminate debug session |
| `<leader>du` | Toggle DAP UI |

### Debugging Workflow

1. **Build project**: `<leader>cb` or `:!dotnet build`
2. **Set breakpoint**: Place cursor on line, press `<leader>db`
3. **Start debugger**: Press `<leader>cd`
4. **Select DLL**: Enter path to your compiled DLL
   - Usually: `bin/Debug/net8.0/YourProject.dll`
5. **Control execution**:
   - `<leader>dc` - Continue
   - `<leader>do` - Step over
   - `<leader>di` - Step into
6. **Inspect variables**: Check DAP UI panels
7. **Stop**: `<leader>dq`

### Debug Configurations

netcoredbg provides configurations for:
- **Launch** - Start your application
- **Attach** - Attach to running process

### Example Debug Session

```csharp
public class Program
{
    static void Main(string[] args)
    {
        var result = Calculate(5, 3);  // Set breakpoint here
        Console.WriteLine(result);
    }
    
    static int Calculate(int a, int b)
    {
        return a + b;  // Step into here
    }
}
```

1. Set breakpoint on `var result = ...`
2. Press `<leader>cd`
3. Enter DLL path
4. Debugger stops at breakpoint
5. Press `<leader>di` to step into `Calculate`
6. Inspect `a` and `b` in DAP UI

---

## Testing

Yoda.nvim uses `neotest-dotnet` for running .NET tests.

### Supported Test Frameworks

- ✅ **xUnit** (recommended)
- ✅ **NUnit**
- ✅ **MSTest**

### Run Tests

| Keymap | Action |
|--------|--------|
| `<leader>ct` | Run nearest test |
| `<leader>cT` | Run all tests in file |
| `<leader>cC` | Run test suite |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Toggle test output |

### Test Workflow

#### xUnit Example

1. **Write a test**:
```csharp
using Xunit;

public class CalculatorTests
{
    [Fact]
    public void Add_TwoNumbers_ReturnsSum()
    {
        var result = Calculator.Add(2, 2);
        Assert.Equal(4, result);
    }
}
```

2. **Run test**: Place cursor in test method, press `<leader>ct`

3. **View results**: 
   - Inline icons show pass/fail
   - `<leader>ts` - Open summary panel
   - `<leader>to` - See detailed output

#### NUnit Example

```csharp
using NUnit.Framework;

[TestFixture]
public class CalculatorTests
{
    [Test]
    public void Add_TwoNumbers_ReturnsSum()
    {
        var result = Calculator.Add(2, 2);
        Assert.AreEqual(4, result);
    }
}
```

### Debug Tests

To debug a failing test:
1. Set breakpoint in test
2. Press `<leader>cd`
3. Use standard debug keymaps

### Test Coverage

Use coverlet for code coverage:

```bash
dotnet test /p:CollectCoverage=true
```

View coverage in Neovim with nvim-coverage plugin.

---

## Linting & Formatting

### Formatting with csharpier

Yoda.nvim uses `csharpier` for C# formatting.

**Why csharpier?**
- ⚡ **Fast** - Written in C#
- 🎯 **Opinionated** - Like rustfmt, minimal config
- ✅ **Official** - Recommended by C# community
- 🔧 **Consistent** - No style debates

**Auto-format on save**: Enabled by default

**Manual format**:
```vim
<leader>f       " Format buffer
```

**Configuration**: Uses `.csharpierrc` if present:

```json
{
  "printWidth": 100,
  "useTabs": false,
  "tabWidth": 4
}
```

### Linting with Roslyn Analyzers

Roslyn analyzers run automatically via csharp-ls LSP.

**Built-in analyzers**:
- **IDE** analyzers (code style)
- **CA** analyzers (code analysis)
- **Performance** analyzers
- **Security** analyzers

**View diagnostics**:
```vim
<leader>ce      " Open diagnostics in Trouble
```

**Configure analyzers** in `.editorconfig`:

```ini
[*.cs]

# Naming conventions
dotnet_naming_rule.interfaces_should_be_prefixed_with_i.severity = warning

# Code style
csharp_prefer_braces = true:warning
csharp_using_directive_placement = outside_namespace:warning

# Code quality
dotnet_code_quality_unused_parameters = all:warning
```

---

## Solution & Project Management

### Solution Files (.sln)

Roslyn automatically detects solution files:

```
MyProject/
├── MyProject.sln          # Solution file
├── MyProject/
│   ├── MyProject.csproj   # Project file
│   └── Program.cs
└── MyProject.Tests/
    ├── MyProject.Tests.csproj
    └── ProgramTests.cs
```

Open any `.cs` file, and Roslyn loads the entire solution.

### Multi-Project Support

Work with multiple projects:

```csharp
// MyProject/Program.cs
using MyLibrary;  // References MyLibrary project

public class Program { }
```

LSP understands project references automatically.

### Create New Project

```vim
<leader>cn      " dotnet new
:YodaDotnetNew  " Alternative command
```

Common templates:
- `console` - Console application
- `classlib` - Class library
- `web` - ASP.NET Core web app
- `webapi` - ASP.NET Core Web API
- `mvc` - ASP.NET Core MVC
- `razor` - Razor Pages
- `blazor` - Blazor app

Example:
```bash
dotnet new console -n MyApp
dotnet new webapi -n MyApi
dotnet new classlib -n MyLibrary
```

---

## NuGet Package Management

### Add NuGet Package

```vim
<leader>cN      " Add NuGet package
```

Enter package name when prompted:
```
Package name: Newtonsoft.Json
```

Runs: `dotnet add package Newtonsoft.Json`

### Check Outdated Packages

```vim
:YodaNuGetOutdated
```

Shows all packages that need updates:
```
Project `MyProject` has the following updates to its packages
   [netX.X]:
   Top-level Package      Requested   Resolved   Latest
   > Newtonsoft.Json      12.0.3      12.0.3     13.0.3
```

### Restore Packages

```vim
<leader>cR      " dotnet restore
```

Restores all NuGet packages from `.csproj` files.

### Manual NuGet Commands

```bash
# Search for package
dotnet package search Newtonsoft

# Add specific version
dotnet add package Newtonsoft.Json --version 13.0.3

# Remove package
dotnet remove package Newtonsoft.Json
```

---

## Code Navigation

### Outline View (Aerial)

View code structure with `aerial.nvim`.

**Toggle outline**:
```vim
<leader>co      " Toggle outline sidebar
```

Shows:
- Namespaces
- Classes
- Interfaces
- Methods
- Properties
- Fields
- Events

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
<leader>fS      " Find symbols across solution
```

### File Navigation

**Find files** (Snacks picker):
```vim
<leader>ff      " Find files
<leader>fg      " Grep in files
<leader>fr      " Recent files
```

---

## Keymap Reference

### C#-Specific Keymaps

All C# keymaps use the `<leader>c` prefix.

#### Build & Run

| Keymap | Action | Command |
|--------|--------|---------|
| `<leader>cr` | Run application | `dotnet run` |
| `<leader>cb` | Build project | `dotnet build` |
| `<leader>cB` | Clean and build | `dotnet clean && dotnet build` |
| `<leader>cR` | Restore packages | `dotnet restore` |

#### Testing

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>ct` | Run nearest test | Neotest |
| `<leader>cT` | Run file tests | Neotest |
| `<leader>cC` | Run test suite | Neotest |

#### Debugging

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>cd` | Start debugger | netcoredbg |
| `<leader>db` | Toggle breakpoint | DAP |
| `<leader>dc` | Continue | DAP |

#### Code Quality

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>ch` | Toggle inlay hints | LSP |
| `<leader>ce` | Open diagnostics | Trouble |

#### Navigation

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>co` | Toggle outline | Aerial |
| `<leader>fR` | Find symbols | Telescope |

#### Project Management

| Keymap | Action | Command |
|--------|--------|---------|
| `<leader>cn` | Create new project | `dotnet new` |
| `<leader>cN` | Add NuGet package | `dotnet add package` |

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

## Framework Support

### .NET Core / .NET 5+

**Full support** for modern .NET:

```csharp
// Minimal API (.NET 6+)
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello World!");
app.Run();
```

Features:
- C# 10+ features
- Nullable reference types
- Record types
- Pattern matching
- Init-only properties

### ASP.NET Core

**Web development** with ASP.NET:

```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    [HttpGet]
    public ActionResult<IEnumerable<User>> Get()
    {
        return Ok(users);
    }
}
```

**Debugging**:
1. Start app: `dotnet run`
2. Attach debugger: `<leader>cd`, select "Attach"
3. Set breakpoints in controllers

### Entity Framework Core

**ORM support**:

```csharp
public class AppDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
}

// IntelliSense works for LINQ queries
var users = await context.Users
    .Where(u => u.Age > 18)
    .ToListAsync();
```

### Blazor

**Full Blazor support** (Server & WebAssembly):

```razor
@page "/counter"

<h1>Counter</h1>
<p>Current count: @currentCount</p>
<button @onclick="IncrementCount">Click me</button>

@code {
    private int currentCount = 0;
    
    void IncrementCount()
    {
        currentCount++;
    }
}
```

### Unity

**Game development** with Unity:

- C# scripting support
- MonoBehaviour completions
- Unity API IntelliSense

**Note**: Unity requires specific Roslyn version.

---

## Troubleshooting

### csharp-ls not starting

**Check installation**:
```vim
:Mason          " Verify csharp-ls is installed
:LspInfo        " Check if attached to buffer
```

**Reinstall**:
```vim
:MasonUninstall csharp-ls
:MasonInstall csharp-ls
```

**Restart LSP**:
```vim
:LspRestart
```

**Check for errors**:
```vim
:LspLog         " View LSP logs
```

### Solution not detected

**Check solution file**:
```bash
ls *.sln        " Should exist in root
```

**Create if missing**:
```bash
dotnet new sln
dotnet sln add MyProject/MyProject.csproj
```

**Restart LSP** after creating solution:
```vim
:LspRestart
```

### Debugger not working

**Check netcoredbg installation**:
```vim
:Mason          " Verify netcoredbg installed
```

**Build first**:
```bash
dotnet build
```

**Check DLL path**: Ensure DLL exists in build output:
```bash
ls bin/Debug/net8.0/*.dll
```

**Common paths**:
- .NET 8: `bin/Debug/net8.0/YourProject.dll`
- .NET 6: `bin/Debug/net6.0/YourProject.dll`

### Tests not detected

**Check test framework**:
```bash
dotnet list package | grep -i test
```

Should show:
- `xunit` or
- `NUnit` or
- `MSTest.TestFramework`

**Check test file naming**:
- Files: `*Tests.cs` or `*Test.cs`
- Classes: `public class XxxTests`
- Methods: `[Fact]`, `[Test]`, `[TestMethod]`

**Restart neotest**:
```vim
:Neotest run.run()
```

### Inlay hints not showing

**Enable inlay hints**:
```vim
<leader>ch      " Toggle inlay hints
```

**Check LSP capability**:
```vim
:lua print(vim.lsp.inlay_hint.is_enabled())
```

### Package restore fails

**Check .NET SDK**:
```vim
:YodaDotnetVersion
```

**Restore manually**:
```bash
dotnet restore
```

**Check NuGet sources**:
```bash
dotnet nuget list source
```

---

## Best Practices

### 1. Use Nullable Reference Types

Enable in `.csproj`:

```xml
<PropertyGroup>
  <Nullable>enable</Nullable>
</PropertyGroup>
```

```csharp
string? name = null;  // Nullable
string email = "";     // Non-nullable
```

### 2. Follow .NET Naming Conventions

- PascalCase: Classes, methods, properties
- camelCase: Local variables, parameters
- _camelCase: Private fields
- UPPER_CASE: Constants

```csharp
public class UserService  // PascalCase
{
    private readonly ILogger _logger;  // _camelCase
    
    public async Task<User> GetUserAsync(int userId)  // PascalCase
    {
        var user = await FindUser(userId);  // camelCase
        return user;
    }
}
```

### 3. Use Code Actions

Press `<leader>ca` frequently to:
- Add using statements
- Implement interfaces
- Generate constructors
- Extract methods

### 4. Test-Driven Development

Write tests first, use `<leader>ct` to run them as you code.

### 5. Keep Packages Updated

```vim
:YodaNuGetOutdated    " Check weekly
```

### 6. Use Inlay Hints for Complex Code

```vim
<leader>ch      " Enable when working with LINQ, generics
```

### 7. Format on Save

Keep format-on-save enabled for consistent code style.

---

## Advanced Configuration

### Custom Roslyn Settings

Edit `lua/yoda/lsp.lua`:

```lua
vim.lsp.config.csharp_ls = {
  settings = {
    csharp = {
      inlayHints = {
        enableInlayHintsForParameters = false,  -- Disable if too noisy
        enableInlayHintsForTypes = true,
      },
    },
  },
}
```

### EditorConfig

Create `.editorconfig` for style rules:

```ini
root = true

[*.cs]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

# C# specific
csharp_new_line_before_open_brace = all
csharp_space_after_cast = false
csharp_preserve_single_line_blocks = true
```

### Custom csharpier Config

Create `.csharpierrc.json`:

```json
{
  "printWidth": 120,
  "useTabs": false,
  "tabWidth": 4,
  "endOfLine": "lf"
}
```

### xUnit Configuration

No configuration file needed, but you can add in `.csproj`:

```xml
<ItemGroup>
  <PackageReference Include="xunit" Version="2.6.1" />
  <PackageReference Include="xunit.runner.visualstudio" Version="2.5.3" />
</ItemGroup>
```

---

## Common Patterns

### Async/Await Debugging

Set breakpoints in async methods:

```csharp
public async Task<User> GetUserAsync(int id)
{
    var user = await _repository.FindAsync(id);  // Breakpoint here
    return user;
}
```

Debug normally with `<leader>cd`.

### LINQ Debugging

Debug complex LINQ queries:

```csharp
var results = users
    .Where(u => u.Age > 18)      // Breakpoint here
    .Select(u => u.Name)          // Or here
    .OrderBy(n => n)
    .ToList();
```

Use `<leader>di` to step into each LINQ method.

### Dependency Injection

ASP.NET Core DI debugging:

```csharp
public class UserController : ControllerBase
{
    private readonly IUserService _userService;
    
    public UserController(IUserService userService)  // Breakpoint here
    {
        _userService = userService;
    }
}
```

---

## .NET CLI Integration

### Common Commands

| Command | Description |
|---------|-------------|
| `dotnet run` | Run application |
| `dotnet build` | Build project |
| `dotnet test` | Run tests |
| `dotnet clean` | Clean build artifacts |
| `dotnet restore` | Restore NuGet packages |
| `dotnet watch` | Watch mode (auto-rebuild) |

### Project Templates

| Template | Description |
|----------|-------------|
| `console` | Console application |
| `classlib` | Class library |
| `web` | ASP.NET Core web app |
| `webapi` | REST API |
| `mvc` | MVC application |
| `blazor` | Blazor app |
| `xunit` | xUnit test project |

---

## Resources

### Official Documentation

- [.NET Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [C# Guide](https://docs.microsoft.com/en-us/dotnet/csharp/)
- [ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/)

### Tools

- [Roslyn](https://github.com/dotnet/roslyn)
- [csharpier](https://csharpier.com/)
- [netcoredbg](https://github.com/Samsung/netcoredbg)

### Plugin Documentation

- [roslyn.nvim](https://github.com/jmederosalvarado/roslyn.nvim)
- [neotest-dotnet](https://github.com/Issafalcon/neotest-dotnet)

### Yoda.nvim Docs

- [LSP Guide](overview/LSP.md)
- [Debugging Guide](overview/DEBUGGING.md)
- [Keymaps Reference](KEYMAPS.md)
- [Troubleshooting](TROUBLESHOOTING.md)

---

## Comparison: All Four Languages

| Feature | Rust 🦀 | Python 🐍 | JavaScript 🟨 | C# ⚡ |
|---------|---------|-----------|---------------|-------|
| **LSP** | rust-tools | basedpyright | ts_ls | csharp-ls |
| **Inlay Hints** | ✅ | ❌ | ✅ TypeScript | ✅ |
| **DAP** | codelldb | debugpy | vscode-js-debug | netcoredbg |
| **Testing** | neotest-rust | neotest-python | neotest-jest/vitest | neotest-dotnet |
| **Linting** | Clippy | ruff+mypy | Biome | Roslyn |
| **Formatting** | rustfmt | ruff/black | Biome/Prettier | csharpier |
| **Keymaps** | `<leader>r*` | `<leader>p*` | `<leader>j*` | `<leader>c*` |
| **Setup** | `:YodaRustSetup` | `:YodaPythonSetup` | `:YodaJavaScriptSetup` | `:YodaCSharpSetup` |
| **Pkg Mgmt** | crates.nvim | ❌ | package-info.nvim | Built-in commands |

### C# Unique Features

- ✨ **Solution management** (multi-project)
- 🔧 **Roslyn analyzers** (code quality)
- 📦 **NuGet integration** (built-in commands)
- 🎮 **Unity support** (game development)
- 🌐 **ASP.NET** (web development)
- 📱 **MAUI** (cross-platform mobile/desktop)
- ⚡ **Blazor** (WebAssembly)

---

## Feedback

Found an issue or have a suggestion? 

- [Open an issue](https://github.com/jedi-knights/yoda.nvim/issues)
- [Start a discussion](https://github.com/jedi-knights/yoda.nvim/discussions)

---

> *"Do. Or do not. There is no try."* — Yoda

Happy C# coding! ⚡

