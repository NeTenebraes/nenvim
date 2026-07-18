-- =========================================================
-- pack.lua
-- Centralized plugin installation, update, and loading.
-- =========================================================

local pack_path = vim.fn.stdpath("config") .. "/pack/plugins"

local plugins = {
{ url = "https://github.com/sphamba/smear-cursor.nvim", dest = "start/smear-cursor.nvim" },

  -- treesitter
  { url = "https://github.com/nvim-treesitter/nvim-treesitter", dest = "start/nvim-treesitter" },
  { url = "https://github.com/windwp/nvim-ts-autotag", dest = "start/nvim-ts-autotag" }, 
  { url = "https://github.com/nvim-treesitter/nvim-treesitter-context", dest = "start/nvim-treesitter-context" },
  { url = "https://github.com/hiphish/rainbow-delimiters.nvim", dest = "start/rainbow-delimiters.nvim" }, 

  { url = "https://github.com/folke/flash.nvim", dest = "start/flash.nvim" },

  -- UI
  { url = "https://github.com/nvim-tree/nvim-web-devicons", dest = "start/nvim-web-devicons" }, -- 󰀫 ¡Añade esta línea aquí!
  { url = "https://github.com/lewis6991/gitsigns.nvim", dest = "start/gitsigns.nvim" },
  { url = "https://github.com/MunifTanjim/nui.nvim", dest = "start/nui.nvim" },
  { url = "https://github.com/MeanderingProgrammer/render-markdown.nvim", dest = "start/render-markdown.nvim" },
  { url = "https://github.com/nvim-lualine/lualine.nvim", dest = "start/lualine.nvim" },
  { url = "https://github.com/akinsho/bufferline.nvim", dest = "start/bufferline.nvim" },
  { url = "https://github.com/folke/noice.nvim", dest = "start/noice.nvim" },
  { url = "https://github.com/uga-rosa/ccc.nvim", dest = "start/ccc.nvim" },
  { url = "https://github.com/gorbit99/codewindow.nvim", dest = "start/codewindow.nvim" },

  --echeva github multi cursor nvim Multi
  { url = "https://github.com/echasnovski/mini.nvim", dest = "start/mini.nvim" }, 
  { url = "https://github.com/folke/snacks.nvim", dest = "start/snacks.nvim" },

  -- LSP / Tools
  { url = "https://github.com/hrsh7th/cmp-nvim-lsp", dest = "start/cmp-nvim-lsp" },
  { url = "https://github.com/neovim/nvim-lspconfig", dest = "start/nvim-lspconfig" },
  { url = "https://github.com/williamboman/mason.nvim", dest = "start/mason.nvim" },
  { url = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", dest = "start/mason-tool-installer.nvim" },
  { url = "https://github.com/stevearc/conform.nvim", dest = "start/conform.nvim" },
  { url = "https://github.com/mfussenegger/nvim-lint", dest = "start/nvim-lint" },


  -- Completion & Snippets (Lista unificada y optimizada)
  { url = "https://github.com/hrsh7th/nvim-cmp", dest = "start/nvim-cmp" },

  { url = "https://github.com/hrsh7th/cmp-buffer", dest = "start/cmp-buffer" },
  { url = "https://github.com/hrsh7th/cmp-path", dest = "start/cmp-path" },
  { url = "https://github.com/saadparwaiz1/cmp_luasnip", dest = "start/cmp_luasnip" },
  { url = "https://github.com/rafamadriz/friendly-snippets", dest = "start/friendly-snippets" },
  { url = "https://github.com/L3MON4D3/LuaSnip", dest = "start/LuaSnip" },
  { url = "https://github.com/mg979/vim-visual-multi", dest = "start/vim-visual-multi" },

  -- Debug
  { url = "https://github.com/mfussenegger/nvim-dap", dest = "start/nvim-dap" },
  { url = "https://github.com/rcarriga/nvim-dap-ui", dest = "start/nvim-dap-ui" },
  { url = "https://github.com/jay-babu/mason-nvim-dap.nvim", dest = "start/mason-nvim-dap.nvim" },
  { url = "https://github.com/mxsdev/nvim-dap-vscode-js", dest = "start/nvim-dap-vscode-js" },
  { url = "https://github.com/nvim-neotest/nvim-nio", dest = "start/nvim-nio" },
}

-- [BOOTSTRAP ONLY] Clones missing plugins on startup
for _, plugin in ipairs(plugins) do
  local path = pack_path .. "/" .. plugin.dest
  if vim.fn.empty(vim.fn.glob(path)) == 1 then
    vim.fn.system({ "git", "clone", "--depth=1", "--filter=blob:none", plugin.url, path })
  end
end

-- =========================================================
-- MODULE EXPORTS (For init.lua commands)
-- =========================================================
local M = {}

M.update = function()
  local updated_plugins = {}
  local installed_plugins = {}
  local total_plugins = #plugins
  local completed = 0

  local function check_completion()
    completed = completed + 1
    if completed == total_plugins then
      vim.schedule(function()
        if #installed_plugins > 0 then
          vim.notify("🚀 Installed: " .. table.concat(installed_plugins, ", "), vim.log.levels.INFO)
        end
        if #updated_plugins > 0 then
          vim.notify("🔄 Updated: " .. table.concat(updated_plugins, ", "), vim.log.levels.INFO)
        else
          vim.notify("✨ Up to date. No updates found.", vim.log.levels.INFO)
        end
      end)
    end
  end

  for _, plugin in ipairs(plugins) do
    local path = pack_path .. "/" .. plugin.dest
    local name = plugin.dest:gsub("start/", "")
    
    if vim.fn.empty(vim.fn.glob(path)) == 1 then
      vim.system({ "git", "clone", "--depth=1", "--filter=blob:none", plugin.url, path }, {}, function(obj)
        if obj.code == 0 then table.insert(installed_plugins, name) end
        check_completion()
      end)
    else
      vim.system({ "git", "-C", path, "pull", "--ff-only", "--rebase=false" }, {}, function(obj)
        if obj.code == 0 and obj.stdout then
          if not obj.stdout:find("Already up to date") and not obj.stdout:find("Ya está al día") then
            table.insert(updated_plugins, name)
          end
        end
        check_completion()
      end)
    end
  end
end

-- =========================================================
-- MODULE INITIALIZATION
-- =========================================================
pcall(require, "plugins.treesitter")
pcall(require, "plugins.mini")
pcall(require, "plugins.snacks")
pcall(require, "plugins.flash")
pcall(require, "plugins.live-server")

pcall(require, "plugins.lsp.lsp")
pcall(require, "plugins.lsp.lint")
pcall(require, "plugins.lsp.format")
pcall(require, "plugins.lsp.dap")

pcall(require, "plugins.CMP.luasnip")
pcall(require, "plugins.CMP.cmp")

pcall(require, "plugins.UI.gitsigns")
pcall(require, "plugins.UI.lualine")
pcall(require, "plugins.UI.bufferline")
pcall(require, "plugins.UI.render-markdown")
pcall(require, "plugins.UI.noice")
pcall(require, "plugins.UI.ccc")
pcall(require, "plugins.UI.devicons")
pcall(require, "plugins.UI.rainbow")
pcall(require, "plugins.UI.smear_cursor")

pcall(require, "plugins.multi_cursor")


return M
