return {
  -- Disable dashboard so our workspace layout opens on startup
  {
    "snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["<LeftRelease>"] = "confirm",
                },
              },
            },
          },
        },
      },
    },
  },
}
