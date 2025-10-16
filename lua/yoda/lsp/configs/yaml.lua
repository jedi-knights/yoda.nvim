-- lua/yoda/lsp/configs/yaml.lua
-- YAML and Helm language server configurations

local config_builder = require("yoda.lsp.services.config_builder")

local M = {}

--- Create yamlls configuration
--- @param builder LSPConfigBuilder
--- @return table
function M.create_yaml_config(builder)
  return builder
    :with_filetypes({ "yaml" })
    :with_settings({
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://json.schemastore.org/ansible-stable-2.9.json"] = "/ansible/**/*.yml",
          ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml",
          ["https://json.schemastore.org/kustomization.json"] = "kustomization.yaml",
          ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "/*openapi*.{yml,yaml}",
        },
        validate = true,
        completion = true,
        hover = true,
        format = {
          enable = true,
          singleQuote = false,
          bracketSpacing = true,
        },
        customTags = {
          "!reference sequence",
          "!encrypted/pkcs1-oaep scalar",
          "!vault scalar",
        },
      },
    })
    :with_root_dir(config_builder.create_root_dir_function({ ".git", "pyproject.toml", "setup.py" }))
    :build()
end

--- Create helm_ls configuration
--- @param builder LSPConfigBuilder
--- @return table
function M.create_helm_config(builder)
  return builder
    :with_filetypes({ "helm" })
    :with_settings({
      ["helm-ls"] = {
        yamlls = {
          enabled = false,
        },
      },
    })
    :with_root_dir(config_builder.create_root_dir_function({ "Chart.yaml", "Chart.yml" }))
    :build()
end

return M
