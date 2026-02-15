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
o.fillchars = { eob = ' ', fold = '-', foldopen = '', foldsep = ' ', foldclose = '' }

o.foldtext = 'v:lua.vim.custom.foldtext()'
o.statuscolumn = '%!v:lua.vim.custom.foldcolumn()'

--------------------------------------------------

local ffi = require('ffi')
ffi.cdef([[
    typedef struct {} Error;
    typedef struct {} win_T;
    typedef struct { int start; int level; int llevel; int lines; } foldinfo_T;

    win_T* find_window_by_handle(int win, Error* err);
    foldinfo_T fold_info(win_T* win, int lnum);
]])

--------------------------------------------------

vim.custom.foldtext = function()
  local bufnr = vim.api.nvim_get_current_buf()

  local function parse_line(linenr)
    local line = vim.api.nvim_buf_get_lines(bufnr, linenr - 1, linenr, false)[1]
    if not line then
      return {}
    end

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok then
      return { { line } }
    end

    local highlights = {}
    local lang = parser:lang()
    local query = vim.treesitter.query.get(lang, 'highlights')
    local tree = parser:parse({ linenr - 1, linenr })[1]

    for id, node, metadata in query:iter_captures(tree:root(), 0, linenr - 1, linenr) do
      local hl = query.captures[id]
      local _, s_pos, _, e_pos = node:range()
      local priority = tonumber(metadata.priority or vim.highlight.priorities.treesitter)

      for i = s_pos + 1, e_pos do
        if not highlights[i] or highlights[i][2] <= priority then
          highlights[i] = { '@' .. hl, priority }
        end
      end
    end

    local res = {}
    for i = 1, #line do
      table.insert(res, { line:sub(i, i), (highlights[i] or {})[1] })
    end

    return res
  end

  local result = parse_line(vim.v.foldstart)

  local count = vim.v.foldend - vim.v.foldstart
  local noun = (count > 1) and ' lines' or ' line'

  table.insert(result, { ' [...]', 'MsgSeparator' })
  table.insert(result, { ' +' .. count .. noun .. ' ', 'Comment' })

  return result
end

--------------------------------------------------

vim.custom.foldcolumn = function()
  local function get_fold(lnum)
    local fcs = vim.opt.fillchars:get()

    local ffi_error = ffi.new('Error')
    local win = ffi.C.find_window_by_handle(vim.g.statusline_winid, ffi_error)
    local fold = ffi.C.fold_info(win, lnum)

    if fold.level == 0 then
      return ' '
    end

    if lnum ~= fold.start then
      return fcs.foldsep
    end

    return fold.lines == 0 and fcs.foldopen or fcs.foldclose
  end

  local fold_symbol = vim.v.virtnum == 0 and get_fold(vim.v.lnum) or ''
  return '%s%l ' .. fold_symbol .. ' '
end
