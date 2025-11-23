local M = {}

--------------------------------------------------

local theme = { 'catppuccin/nvim' }
theme.name = 'catppuccin'
theme.priority = 1000
theme.config = function()
  local opts = {
    transparent_background = true,
    float = { transparent = true, solid = true },
    integrations = {
      diffview = true,
      gitsigns = { enabled = true, transparent = true },
      neogit = true,
      snacks = true,
      which_key = true,
    },
  }

  require('catppuccin').setup(opts)
  vim.cmd.colorscheme('catppuccin')
end

table.insert(M, theme)

--------------------------------------------------

local icons = { 'nvim-tree/nvim-web-devicons' }
icons.opts = {}

table.insert(M, icons)

--------------------------------------------------

local line = { 'nvim-lualine/lualine.nvim' }
line.dependencies = { 'nvim-tree/nvim-web-devicons' }
line.event = 'UIEnter'
line.config = function()
  vim.o.showmode = false

  local opts = {
    options = {
      theme = 'catppuccin',
      component_separators = { left = '·', right = '·' },
      disabled_filetypes = { 'snacks_dashboard' },
      always_show_tabline = false,
    },

    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { 'filename', path = 1, shorting_target = 0 } },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {},
      lualine_c = { { 'filename', path = 1, shorting_target = 0 }, '%L lines', 'diff' },
      lualine_x = { 'diagnostics', 'lsp_status', 'location', 'filetype' },
      lualine_y = {},
      lualine_z = { 'progress' },
    },
    tabline = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {
        {
          'tabs',
          tabs_color = { active = 'lualine_a_normal', inactive = 'lualine_b_normal' },
          separator = { left = '', right = '' },
        },
      },
    },

    extensions = { 'fzf', 'lazy', 'nvim-dap-ui' },
  }

  require('lualine').setup(opts)
end

table.insert(M, line)

--------------------------------------------------

return M
