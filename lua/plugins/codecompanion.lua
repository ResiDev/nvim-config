return {
  {
    "olimorris/codecompanion.nvim",
    config = true,
    vim.keymap.set('n', '<leader>C', "<cmd>CodeCompanionActions<cr>", { desc = 'Code Companion Actions' }),
    vim.keymap.set('v', '<c-c>', ":CodeCompanion", { desc = 'code companion actions' }),
    vim.keymap.set('n', '<leader>c', "<cmd>CodeCompanionChat Toggle<cr>", { desc = 'code companion chat' }),
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "replace"
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = "replace",
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "gemini",
          keymaps = {
            send = {
              modes = { n = "<C-s>", i = "<C-s>" },
            },
            next_chat = {
              modes = { n = "<C-n>", i = "<C-n>" },
            },
            previous_chat = {
              modes = { n = "<C-p>", i = "<C-p>" },
            }
          }
        },
        inline = {
          adapter = "gemini",
        },
      },
    },
  },
}
