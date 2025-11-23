local M = {}

--------------------------------------------------

local orgmode = { 'nvim-orgmode/orgmode' }
orgmode.event = 'VeryLazy'
orgmode.opts = {
  org_agenda_files = '~/vault/notes/**/*',
  org_todo_keywords = { 'TODO(t)', 'PENDING', '|', 'CANCELLED', 'DONE' },
  org_todo_keyword_faces = {
    PENDING = ':foreground ' .. string.format('#%x', vim.api.nvim_get_hl(0, { name = 'WarningMsg' }).fg),
    CANCELLED = ':foreground ' .. string.format('#%x', vim.api.nvim_get_hl(0, { name = 'NonText' }).fg),
  },
  org_id_link_to_org_use_id = true,
  org_startup_indented = true,

  org_log_into_drawer = 'LOGBOOK',

  org_hide_emphasis_markers = true,
  org_ellipsis = ' [...]',
  org_highlight_latex_and_related = 'entities',

  ui = { input = { use_vim_ui = true } },
}

table.insert(M, orgmode)

--------------------------------------------------

local orgroam = { 'chipsenkbeil/org-roam.nvim' }
orgroam.dependencies = { 'nvim-orgmode/orgmode' }
orgroam.event = 'VeryLazy'
orgroam.opts = {
  directory = '~/vault/notes/',
  extensions = { dailies = { directory = '90_journal' } },
}

table.insert(M, orgroam)

--------------------------------------------------

return M
