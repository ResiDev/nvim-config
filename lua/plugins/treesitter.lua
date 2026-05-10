-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      local query = vim.treesitter.query

      query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
        local capture_id = pred[2]
        local node = match[capture_id]

        if type(node) == 'table' then
          node = node[1]
        end

        if not node or type(node.range) ~= 'function' then
          return
        end

        local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
        if not ok or not text or text == '' then
          return
        end

        local lang = text:match('^%s*([^%s{,]+)')
        if not lang or lang == '' then
          return
        end

        metadata['injection.language'] = vim.treesitter.language.get_lang(lang:lower()) or lang:lower()
      end, { force = true })
    end,
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
        'javascript',
        'typescript',
        'tsx',
        'zig',
        'rust',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']]'] = '@function.outer',
            [']c'] = '@class.outer',
            [']l'] = '@loop.outer',
            [']i'] = '@conditional.outer',
          },
          goto_next_end = {
            [']['] = '@function.outer',
            [']C'] = '@class.outer',
            [']L'] = '@loop.outer',
            [']I'] = '@conditional.outer',
          },
          goto_previous_start = {
            ['[['] = '@function.outer',
            ['[c'] = '@class.outer',
            ['[l'] = '@loop.outer',
            ['[i'] = '@conditional.outer',
          },
          goto_previous_end = {
            ['[]'] = '@function.outer',
            ['[C'] = '@class.outer',
            ['[L'] = '@loop.outer',
            ['[I'] = '@conditional.outer',
          },
        },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
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
