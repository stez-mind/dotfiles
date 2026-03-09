-- Dependencies:
--   macOS:  brew install neovim fzf ripgrep
--   Linux:  sudo apt install neovim fzf ripgrep
--   Both:   install a Nerd Font (e.g. Hack Nerd Font) for file icons

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys (must be set before lazy)
-- mapleader stays as default backslash
vim.g.maplocalleader = ","

-- Disable netrw (required for nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--------------------------------------------------------------------------------
-- General settings
--------------------------------------------------------------------------------

vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.visualbell = true
vim.opt.smartindent = true
vim.opt.wildignore = { "*.swp", "*.bak", "*.pyc", "*.class" }
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.hlsearch = true
vim.opt.equalalways = false
vim.opt.background = "dark"
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 2
vim.opt.foldenable = false

-- Jump to last cursor position when opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line = mark[1]
    if line > 1 and line <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Fix window height on new splits
vim.api.nvim_create_autocmd("WinNew", {
  callback = function()
    vim.wo.winfixheight = true
  end,
})

-- Highlight trailing whitespace (works with Tree-sitter)
local function set_whitespace_hl()
  vim.api.nvim_set_hl(0, "ExtraWhitespace", { ctermbg = "darkgreen", bg = "darkgreen" })
end
set_whitespace_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_whitespace_hl })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  pattern = "*",
  callback = function()
    vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
  end,
})

--------------------------------------------------------------------------------
-- Key mappings
--------------------------------------------------------------------------------

-- Clipboard operations
vim.keymap.set("v", "<C-Insert>", '"*y')
vim.keymap.set("", "<S-Insert>", '"*p')

-- CTRL-Y is Redo
vim.keymap.set("n", "<C-Y>", "<C-R>")
vim.keymap.set("i", "<C-Y>", "<C-O><C-R>")

-- CTRL-A is Select all
vim.keymap.set("n", "<C-A>", "gggH<C-O>G")
vim.keymap.set("i", "<C-A>", "<C-O>gg<C-O>gH<C-O>G")
vim.keymap.set("c", "<C-A>", "<C-C>gggH<C-O>G")
vim.keymap.set("o", "<C-A>", "<C-C>gggH<C-O>G")
vim.keymap.set("s", "<C-A>", "<C-C>gggH<C-O>G")
vim.keymap.set("x", "<C-A>", "<C-C>ggVG")

-- Scroll other window
vim.keymap.set("n", "<A-j>", "<C-W>w<C-D><C-W>w")
vim.keymap.set("n", "<A-k>", "<C-W>w<C-U><C-W>w")

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, "<Plug>AirlineSelectTab" .. i, { desc = "Buffer " .. i })
end

--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------

require("lazy").setup({
  -- File explorer (replaces NERDTree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 24 },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
    end,
  },

  -- Fuzzy finder
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup({
        winopts = { start_in_normal = true },
      })
      vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>")
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>")
      vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>")
      vim.keymap.set("n", "<leader>b", "<cmd>FzfLua buffers<cr>")
      vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>")
      vim.keymap.set("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>")
      vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua git_commits<cr>")
      vim.keymap.set("n", "<leader>fw", "<cmd>FzfLua grep_cword<cr>")
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "pyright" },
        automatic_installation = true,
      })
      vim.lsp.config("clangd", {})
      vim.lsp.config("pyright", {})
      vim.lsp.enable({ "clangd", "pyright" })

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
      vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<cr>", { desc = "References" })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
      vim.keymap.set("n", "<leader>fi", "<cmd>FzfLua lsp_incoming_calls<cr>", { desc = "Incoming calls" })
      vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua lsp_outgoing_calls<cr>", { desc = "Outgoing calls" })
      -- Replaces a.vim: switch between source/header via clangd
      vim.keymap.set("n", "<leader>a", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch source/header" })
    end,
  },

  -- Appearance
  {
    "vim-airline/vim-airline",
    config = function()
      vim.g["airline#extensions#tabline#enabled"] = 1
      vim.g["airline#extensions#tabline#formatter"] = "unique_tail"
      vim.g["airline#extensions#tabline#buffer_idx_mode"] = 1
    end,
  },
  { "ericbn/vim-solarized" },

  -- Utilities
  { "mbbill/undotree" },
  { "vimwiki/vimwiki" },
  { "vim-scripts/DoxygenToolkit.vim" },

  -- Other languages
  { "sbl/scvim", ft = "sclang" },
  { "gmoe/vim-faust", ft = "faust" },
  { "gryf/kickass-syntax-vim" },

  -- Treesitter (better syntax highlighting + incremental selection)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "python", "bash", "json", "markdown", "asm", "bitbake", "csv", "lua" },
      highlight = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          node_decremental = "<BS>",
          scope_incremental = false,
        },
      },
    },
  },

  -- Autocompletion
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "accept", "fallback" },
      },
      completion = {
        list = { max_items = 5 },
      },
      fuzzy = {
        frecency = { enabled = false },
        proximity = { enabled = false },
        sorts = { "score", "sort_text" },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
        min_keyword_length = function()
          local ft = vim.bo.filetype
          local plain_types = { text = true, markdown = true, gitcommit = true, help = true }
          if plain_types[ft] or ft == "" then
            return 4
          end
          return 3
        end,
      },
    },
  },

  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Better diagnostics list
  {
    "folke/trouble.nvim",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
    },
  },

  -- CSV column coloring
  {
    "cameron-wags/rainbow_csv.nvim",
    ft = { "csv", "tsv" },
    opts = {},
  },
})

-- Colorscheme (after plugins are loaded)
vim.cmd.colorscheme("solarized")

-- Linux kernel coding style paths
vim.g.linuxsty_patterns = { "/linux/", "/kernel/" }
