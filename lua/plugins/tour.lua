return {
  {
    -- The local checkout, on the `diagrams` branch; back to 'ResiDev/nvim-tour'
    -- once that is pushed.
    dir = vim.fn.stdpath 'config' .. '/tour.nvim',
    name = 'nvim-tour',
    cmd = {
      'Tour',
      'TourNext',
      'TourPrev',
      'TourStageNext',
      'TourStagePrev',
      'TourGoto',
      'TourHere',
      'TourList',
      'TourStop',
      'TourCheck',
      'TourPreview',
      'TourFollow',
      'TourQuickfix',
      'TourOpen',
      'TourMap',
      'TourPreview',
      'TourDiff',
      'TourChanges',
    },
    -- setup() is optional; drop `opts` entirely to take the defaults.
    opts = {
      mappings = {
        stage_next = '<leader>tj', -- default J shadows join
        stage_prev = '<leader>tk', -- default K shadows LSP hover
      },
    },
  },
}
