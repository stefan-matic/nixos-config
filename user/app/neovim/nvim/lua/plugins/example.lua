-- Add your custom plugin specs here
-- https://lazyvim.github.io/plugins
return {
  -- Disable dashboard so our workspace layout opens on startup
  {
    "snacks.nvim",
    opts = {
      dashboard = { enabled = false },
    },
  },
}
