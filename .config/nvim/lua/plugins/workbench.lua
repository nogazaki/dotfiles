return {
  -- Appearance
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('catppuccin')
    end,
  },
  {
    'nvim-tree/nvim-web-devicons',
    opts = {},
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = function()
      vim.o.showmode = false
      require('lualine').setup({
        extensions = { 'nvim-tree' },
        options = {
          theme = 'auto',
          globalstatus = true,
          component_separators = { left = '·', right = '·' },
        },
      })
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Naviagation
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    keys = { '<leader>', 'g' },
    config = function()
      local wk = require('which-key')
      wk.add({ { '<leader>s', group = '[s]earch' }, { '<leader>t', group = '[t]oggle' } })
    end,
  },
  {
    'christoomey/vim-tmux-navigator',
    config = function()
      vim.keymap.set('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>', { desc = 'Move focus to the left window' })
      vim.keymap.set('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>', { desc = 'Move focus to the below window' })
      vim.keymap.set('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>', { desc = 'Move focus to the above window' })
      vim.keymap.set('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>', { desc = 'Move focus to the rigth window' })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    opts = function()
      vim.keymap.set('n', '<leader>tt', '<cmd>NvimTreeToggle<cr>', { desc = 'file [t]ree' })
      return {
        filters = { dotfiles = false },
        disable_netrw = true,
        hijack_cursor = true,
        sync_root_with_cwd = true,
        update_focused_file = { enable = true, update_root = false },
        view = { width = 30, preserve_window_proportions = true },
        renderer = {
          root_folder_label = false,
          highlight_git = true,
          indent_markers = { enable = true },
        },
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({})
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [h]elp' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[s]earch by [g]rep' })
      vim.keymap.set('n', '<leader>sf', function()
        builtin.find_files({})
      end, { desc = '[s]earch [f]iles' })
      vim.keymap.set('n', '<leader>sa', function()
        builtin.find_files({ follow = true, no_ignore = true, hidden = true })
      end, { desc = '[s]earch [a]ll files' })
      -- Clear seach highlights once done
      vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<cr>')
    end,
  },

  {
    'NeogitOrg/neogit',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'sindrets/diffview.nvim' },
      { 'nvim-telescope/telescope.nvim' },
    },
    opts = {},
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')

        local function keymap(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        keymap('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk('next')
          end
        end, { desc = 'jump to next git [c]hange' })
        keymap('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk('prev')
          end
        end, { desc = 'jump to previous git [c]hange' })
        keymap('n', '<leader>hs', gs.stage_hunk, { desc = 'git [s]tage hunk' })
        keymap('v', '<leader>hs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'git [s]tage selected hunk' })
      end,
    },
  },
}
