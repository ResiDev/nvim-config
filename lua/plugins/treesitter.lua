-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'python',
        'zig',
        'rust',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter.configs').setup {
        -- Add these required core fields
        ensure_installed = { "lua", "vim" }, -- Languages to ensure are installed
        sync_install = false,                -- Install parsers synchronously
        auto_install = true,                 -- Automatically install missing parsers
        ignore_install = {},                 -- Parsers to ignore installing
        modules = {},                        -- Add the required modules field

        -- Your textobjects configuration
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to matching textobj
            keymaps = {
              -- You use: va to select outer, vi to select inner
              ['af'] = '@function.outer', -- Select outer part of a function
              ['if'] = '@function.inner', -- Select inner part of a function
              ['ac'] = '@class.outer',    -- Select outer part of a class
              ['ic'] = '@class.inner',    -- Select inner part of a class
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']]'] = '@function.outer',    -- Function start
              [']c'] = '@class.outer',       -- Class start
              [']l'] = '@loop.outer',        -- Loop start
              [']i'] = '@conditional.outer', -- If start
            },
            goto_next_end = {
              [']['] = '@function.outer',    -- Function end
              [']C'] = '@class.outer',       -- Class end
              [']L'] = '@loop.outer',        -- Loop end
              [']I'] = '@conditional.outer', -- If end
            },
            goto_previous_start = {
              ['[['] = '@function.outer',    -- Previous function start
              ['[c'] = '@class.outer',       -- Previous class start
              ['[l'] = '@loop.outer',        -- Previous loop start
              ['[i'] = '@conditional.outer', -- Previous if start
            },
            goto_previous_end = {
              ['[]'] = '@function.outer',    -- Previous function end
              ['[C'] = '@class.outer',       -- Previous class end
              ['[L'] = '@loop.outer',        -- Previous loop end
              ['[I'] = '@conditional.outer', -- Previous if end
            },
          },
        },
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesitter-context').setup {
        enable = true,       -- Can also be toggled with :TSContextEnable, :TSContextDisable, :TSContextToggle commands
        multiwindow = false, -- If true, shows context in all Neovim windows
        max_lines = 5,
        multiline_threshold = 1,
        trim_scope = 'inner',
        mode = 'cursor',
        line_numbers = true,
      }
    end,
  },


}
