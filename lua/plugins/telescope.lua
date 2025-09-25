return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      -- pickers = {}
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local telescope = require("telescope")
    -- See `:help telescope.builtin`

    -- [[ Keymaps ]]
    local function map(m, k, v, desc)
      vim.keymap.set(m, k, v, { noremap = true, silent = true, desc = desc })
    end

    telescope.load_extension("file_browser")
    ---- Files
    map('n', '<leader>ff', ':Telescope file_browser<CR>',             '[F]ile browser')
    map('n', '<leader>fw', builtin.find_files,                        '[F]iles in [W]orking directory')
    map('n', '<leader>f.', builtin.oldfiles,                          'Recent [F]iles ("." for repeat)')
    ------- Shortcut for searching your Neovim configuration files
    map('n', '<leader>fn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, '[N]eovim [F]iles')

    ---- Search
    map('n', '<leader>sh', builtin.help_tags,      '[S]earch [H]elp'              )
    map('n', '<leader>sk', builtin.keymaps,        '[S]earch [K]eymaps'           )
    map('n', '<leader>st', builtin.treesitter,     '[S]earch [T]ree-sitter symbols')
    map('n', '<leader>ss', builtin.builtin,        '[S]earch [S]elect Telescope'  )
    map('n', '<leader>sw', builtin.grep_string,    '[S]earch current [W]ord'      )
    map('n', '<leader>sg', builtin.live_grep,      '[S]earch by [G]rep'           )
    map('n', '<leader>sd', builtin.diagnostics,    '[S]earch [D]iagnostics'       )
    map('n', '<leader>sr', builtin.resume,         '[S]earch [R]esume'            )
    map('n', '<leader>sc', builtin.spell_suggest,  '[S]pell [C]heck options'      )
    map('n', '<leader><leader>', builtin.buffers,  '[ ] Find existing buffers'    )

    -- Slightly advanced example of overriding default behavior and theme
    map('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, '[/] Fuzzily search in current buffer')

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    map('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, '[S]earch [/] in Open Files')

  end,
}
