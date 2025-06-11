## 🚀 ChatGPT Integration

Yoda.nvim comes with powerful ChatGPT integration out of the box, allowing you to interact with OpenAI’s GPT directly from Neovim for tasks like code explanation, optimization, translation, and more.

### ✅ Prerequisites

1. **OpenAI Account:**
   You need an OpenAI account and an API key. You can get your API key here:
   👉 [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys)

2. **Environment Variable:**
   Set your `OPENAI_API_KEY` in your shell environment:

   **For bash/zsh:**

   ```sh
   export OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

   **For fish:**

   ```fish
   set -x OPENAI_API_KEY sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

   **For Windows (PowerShell):**

   ```powershell
   $env:OPENAI_API_KEY = "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   ```

   > 🔑 **Note:** Make sure this is available in your terminal session **before launching Neovim.**

---

### 🗘️ Keymaps

| Keymap       | Description                   |
| ------------ | ----------------------------- |
| `<leader>cc` | Open ChatGPT chat window      |
| `<leader>ce` | Edit with instructions        |
| `<leader>cg` | Grammar correction            |
| `<leader>ct` | Translate                     |
| `<leader>ck` | Extract keywords              |
| `<leader>cd` | Generate docstring            |
| `<leader>ca` | Add tests                     |
| `<leader>co` | Optimize code                 |
| `<leader>cs` | Summarize code                |
| `<leader>cf` | Fix bugs                      |
| `<leader>cx` | Explain code                  |
| `<leader>cr` | Roxygen edit (for R language) |
| `<leader>cl` | Code readability analysis     |

---

### ⚙️ Usage Tips

* Most commands run in **Normal mode**.
* For actions like grammar correction or code optimization, place your cursor in the relevant file **and press the mapped key.**
* The `:ChatGPT` window provides a full chat experience where you can freely ask questions and get detailed answers.

---

### 🛡️ Troubleshooting

* If ChatGPT doesn’t open or shows an error like `No API key found`, double-check that your `OPENAI_API_KEY` is set correctly **in the same terminal session** where you start Neovim.
* Check your internet connection—ChatGPT requires an active connection to OpenAI’s servers.

