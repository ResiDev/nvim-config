-- ~/.config/nvim/lua/plugins/treesitter.lua
--
-- nvim-treesitter `main` branch: a full rewrite of the old `master` API.
-- There is no `nvim-treesitter.configs`, no `ensure_installed`, and no
-- `highlight`/`indent`/`textobjects` modules any more -- the plugin only
-- installs parsers and ships queries, and we wire up Neovim's built-in
-- treesitter features ourselves.

-- The `tree-sitter` CLI lives in ~/.local/bin, which is not on PATH in this
-- WSL home (there is no ~/.profile to add it), so nvim cannot find it when
-- launched from a normal shell. The rewrite shells out to `tree-sitter build`
-- for every parser, so put it on PATH ourselves.
local local_bin = vim.fs.normalize '~/.local/bin'
if not vim.list_contains(vim.split(vim.env.PATH, ':'), local_bin) then
  vim.env.PATH = local_bin .. ':' .. vim.env.PATH
end

-- Replaces the old `ensure_installed`.
local ensure_installed = {
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
}

-- Replaces `highlight.additional_vim_regex_highlighting`: `vim.treesitter.start()`
-- clears 'syntax', so put it back for these filetypes.
local extra_regex_highlight = { ruby = true }

-- Replaces `indent.disable`.
local no_ts_indent = { ruby = true }

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- the rewrite does not support lazy-loading
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'
      local ts_config = require 'nvim-treesitter.config'

      ts.setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      local function installed()
        local set = {}
        for _, lang in ipairs(ts_config.get_installed 'parsers') do
          set[lang] = true
        end
        return set
      end

      -- Parsers can only be built if the CLI is present; without this guard
      -- every startup retries and floods the screen with build errors.
      local can_install = vim.fn.executable 'tree-sitter' == 1
      if not can_install then
        vim.notify(
          'nvim-treesitter: `tree-sitter` CLI not found on PATH -- parser installation disabled',
          vim.log.levels.WARN
        )
      end

      -- `ensure_installed`: install whatever is missing (async, no-op if present).
      if can_install then
        local have = installed()
        local missing = vim.tbl_filter(function(lang)
          return not have[lang]
        end, ensure_installed)
        if #missing > 0 then
          ts.install(missing, { summary = true })
        end
      end

      -- `highlight` + `indent`: turn them on per buffer.
      local function enable(buf, ft, lang)
        if not vim.api.nvim_buf_is_valid(buf) then
          return false
        end
        if not pcall(vim.treesitter.start, buf, lang) then
          return false
        end
        if extra_regex_highlight[ft] then
          vim.bo[buf].syntax = 'on'
        end
        if not no_ts_indent[ft] then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        return true
      end

      -- `auto_install`: pull a parser on first sight of its filetype, once.
      local installing = {}
      local function auto_install(buf, ft, lang)
        if not can_install or installing[lang] or not vim.tbl_contains(ts_config.get_available(), lang) then
          return
        end
        installing[lang] = true
        ts.install(lang):await(function()
          installing[lang] = nil
          vim.schedule(function()
            enable(buf, ft, lang)
          end)
        end)
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-enable', { clear = true }),
        callback = function(args)
          local ft = args.match
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if not enable(args.buf, ft, lang) then
            auto_install(args.buf, ft, lang)
          end
        end,
      })

      -- Custom injection directive for fenced code blocks whose info string
      -- carries more than the language (```ts {1,3} title="x").
      vim.treesitter.query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
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

        local lang = text:match '^%s*([^%s{,]+)'
        if not lang or lang == '' then
          return
        end

        metadata['injection.language'] = vim.treesitter.language.get_lang(lang:lower()) or lang:lower()
      end, { force = true })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'

      -- select
      for lhs, query in pairs {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      } do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end, { desc = 'Select ' .. query })
      end

      -- move
      local moves = {
        [move.goto_next_start] = {
          [']]'] = '@function.outer',
          [']c'] = '@class.outer',
          [']l'] = '@loop.outer',
          [']i'] = '@conditional.outer',
        },
        [move.goto_next_end] = {
          ['][']  = '@function.outer',
          [']C'] = '@class.outer',
          [']L'] = '@loop.outer',
          [']I'] = '@conditional.outer',
        },
        [move.goto_previous_start] = {
          ['[['] = '@function.outer',
          ['[c'] = '@class.outer',
          ['[l'] = '@loop.outer',
          ['[i'] = '@conditional.outer',
        },
        [move.goto_previous_end] = {
          ['[]']  = '@function.outer',
          ['[C'] = '@class.outer',
          ['[L'] = '@loop.outer',
          ['[I'] = '@conditional.outer',
        },
      }
      for fn, maps in pairs(moves) do
        for lhs, query in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            fn(query, 'textobjects')
          end, { desc = 'Move to ' .. query })
        end
      end
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
