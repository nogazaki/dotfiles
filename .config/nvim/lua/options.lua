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

    local lang = parser:lang()
    local query = vim.treesitter.query.get(lang, 'highlights')
    local tree = parser:parse({ linenr - 1, linenr })[1]

    local highlights = {}

    -- This works on the assumption that
    -- - The start positions of sections are in ascending order
    -- - For one section, if multiple captures with the same priority exist, the one that comes first in the iterator is prioritized
    for id, node, metadata in query:iter_captures(tree:root(), 0, linenr - 1, linenr) do
      local hl = query.captures[id]
      local _, s_pos, _, e_pos = node:range()
      local priority = tonumber(metadata.priority or vim.highlight.priorities.treesitter)

      local entry = { hl = '@' .. hl, hl_seen = {}, priority = priority, s_pos = s_pos, e_pos = e_pos }

      if (#highlights == 0) or (highlights[#highlights].e_pos <= entry.s_pos) then
        -- This is either the first section, or a completely new section (doesn't overlap with previous sections)
        table.insert(highlights, entry)
      elseif highlights[#highlights].priority <= entry.priority then
        -- The current section overlap with the previous section
        local old_entry = table.remove(highlights, #highlights)
        if entry.s_pos > old_entry.s_pos then
          table.insert(highlights, vim.tbl_extend('force', old_entry, { e_pos = entry.s_pos }))
        end

        entry.hl_seen = old_entry.hl_seen
        if entry.hl_seen[entry.hl] then
          entry.hl = old_entry.hl
        else
          entry.hl_seen[entry.hl] = true
        end
        table.insert(highlights, entry)

        if old_entry.e_pos > entry.e_pos then
          table.insert(highlights, vim.tbl_extend('force', old_entry, { s_pos = entry.e_pos }))
        end
      end
    end

    local res = {}
    local line_pos = 0
    for _, entry in ipairs(highlights) do
      -- Some characters may be ignored by treesitter
      if entry.s_pos > line_pos then
        table.insert(res, { line:sub(line_pos + 1, entry.s_pos), 'Folded' })
      end
      table.insert(res, { line:sub(entry.s_pos + 1, entry.e_pos), entry.hl .. '.' .. lang })
      line_pos = entry.e_pos
    end

    return res
  end

  local content = parse_line(vim.v.foldstart)

  local count = vim.v.foldend - vim.v.foldstart
  local noun = (count > 1) and ' lines' or ' line'

  table.insert(content, { ' [...]', 'MsgSeparator' })
  table.insert(content, { ' +' .. count .. noun .. ' ', 'Comment' })

  return content
end

--------------------------------------------------

vim.custom.foldcolumn = function()
  local function get_fold(lnum)
    local fcs = vim.opt.fillchars:get()
    local win_id = vim.api.nvim_get_current_win()

    local ffi_error = ffi.new('Error')
    local win = ffi.C.find_window_by_handle(win_id, ffi_error)
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
