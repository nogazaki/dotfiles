local M = {}

--------------------------------------------------

local syntax = { 'nvim-treesitter/nvim-treesitter' }
syntax.event = 'VeryLazy'
syntax.build = ':TSUpdate'
syntax.opts = { highlight = { enable = true } }
syntax.config = function()
  require('nvim-treesitter').install()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function() pcall(vim.treesitter.start) end,
  })
end

table.insert(M, syntax)
vim.g.c_syntax_for_h = true

--------------------------------------------------

local format = { 'stevearc/conform.nvim' }
format.cmd = { 'ConformInfo' }
format.keys = {
  vim.custom.lazy_key(
    '',
    '<leader>f',
    function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
    { desc = '[f]ormat buffer' }
  ),
}
format.opts = {
  formatters_by_ft = {
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    css = { 'prettier' },
    html = { 'prettier' },
    json = { 'prettier' },
    lua = { 'stylua' },
    markdown = { 'prettier' },
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
