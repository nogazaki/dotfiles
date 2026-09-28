local o = vim.opt

-- Mouse mode can sometime be useful (resizing splits, for example)
o.mouse = 'a'
-- Relative line number helps with jumping around
o.number = true
o.relativenumber = true
o.cursorline = true
o.scrolloff = 10
o.wrap = false

o.updatetime = 250
o.timeoutlen = 300

o.undofile = true
o.confirm = true

o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.signcolumn = 'yes'

o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.breakindent = true

o.ignorecase = true
o.smartcase = true

o.splitright = true
o.splitbelow = true

o.foldenable = true
o.foldlevel = 5
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.lsp.foldexpr()'
o.fillchars = { eob = ' ', fold = '-', foldopen = '', foldsep = ' ', foldclose = '', foldinner = ' ' }

o.foldtext = ''
o.foldcolumn = '1'
o.statuscolumn = '%s%l %C '

o.winborder = 'rounded'

-- vim.highlight.priorities.semantic_tokens = 75
-- vim.highlight.priorities.treesitter = 125
