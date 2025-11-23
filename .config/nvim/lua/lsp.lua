local lsps = {
  lua = {
    filetypes = { 'lua' },
    cmd = { 'lua-language-server' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', '.git' },
    settings = { Lua = { runtime = { version = 'LuaJIT' } } },
  },
  c_cpp = {
    filetypes = { 'c', 'cpp' },
    cmd = { 'clangd' },
  },
}

for name, config in pairs(lsps) do
  vim.lsp.config[name] = config
  vim.lsp.enable(name)
end

vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = '[D]eclaration' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = '[d]efinition' })
vim.keymap.set('n', '<leader>th', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'inlay [h]ints' })
vim.keymap.set({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename, { desc = 'rename' })
