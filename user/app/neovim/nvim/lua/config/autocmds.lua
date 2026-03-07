-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- VSCode-like layout: explorer left, editor top, terminal bottom
-- This file loads on VeryLazy (after all plugins are ready), so we can run directly.
if vim.fn.argc() == 0 then
  vim.schedule(function()
    local ok, err = pcall(function()
      -- Open the file explorer sidebar (same as <leader>e)
      Snacks.explorer({ cwd = LazyVim.root() })
      -- Open a terminal at the bottom (same as <c-/>)
      Snacks.terminal(nil, { cwd = LazyVim.root() })
      -- Move cursor to the editor pane
      vim.cmd("wincmd k")
    end)
    if not ok then
      vim.notify("Startup layout error: " .. tostring(err), vim.log.levels.WARN)
    end
  end)
end
