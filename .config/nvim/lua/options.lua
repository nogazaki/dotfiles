-- Mouse mode can sometime be useful (resizing splits, for example)
vim.o.mouse = 'a'
-- Relative line number helps with jumping around
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.scrolloff = 10

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.undofile = true
vim.o.confirm = true

vim.o.list = true
vim.o.listchars = 'tab:» ,trail:·,nbsp:␣'
vim.o.signcolumn = 'yes'

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.breakindent = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.splitright = true
vim.o.splitbelow = true

vim.diagnostic.config({ virtual_lines = { current_line = true }})
