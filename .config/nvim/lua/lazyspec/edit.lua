local M = {}

--------------------------------------------------

local syntax = { 'nvim-treesitter/nvim-treesitter' }
syntax.event = 'VeryLazy'
syntax.build = ':TSUpdate'
syntax.main = 'nvim-treesitter.configs'
syntax.opts = { highlight = { enable = true } }

table.insert(M, syntax)

--------------------------------------------------

local format = { 'stevearc/conform.nvim' }
format.cmd = { 'ConformInfo' }
format.keys = {
  vim.custom.lazy_key('n', '<leader>f', function()
    require('conform').format({ async = true, lsp_format = 'fallback' })
  end, { desc = '[f]ormat buffer' }),
}
format.opts = {
  formatters_by_ft = {
    lua = { 'stylua' },
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    markdown = { 'prettier' },
    json = { 'prettier' },
  },
}

table.insert(M, format)

--------------------------------------------------

local autocomplete = { 'saghen/blink.cmp' }
autocomplete.version = '1.*'
autocomplete.event = 'VeryLazy'
autocomplete.fuzzy = { implementation = 'prefer_rust_with_warning' }
autocomplete.snippets = { preset = 'luasnip' }
autocomplete.signature = { enabled = true }
autocomplete.opts = {
  appearance = { nerd_font_variant = 'mono' },
  completion = { documentation = { auto_show = true, auto_show_delay_ms = 500 } },
  sources = {
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
      orgmode = { module = 'orgmode.org.autocompletion.blink', fallbacks = { 'buffer' } },
    },
  },
  cmdline = { sources = { 'cmdline' } },
}

table.insert(M, autocomplete)

--------------------------------------------------

local snippet = { 'L3MON4D3/LuaSnip' }
snippet.lazy = true
snippet.version = '2.*'
snippet.build = 'make install_jsregexp'
snippet.opts = {}

table.insert(M, snippet)

--------------------------------------------------

return M
