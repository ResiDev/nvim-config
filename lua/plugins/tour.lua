return {
  {
    'ResiDev/nvim-tour',
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
      'TourFollow',
      'TourQuickfix',
      'TourOpen',
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
