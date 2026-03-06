-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- VSCode-like layout: file tree left, editor top-right, terminal bottom-right
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only open the layout when starting without file arguments
    if vim.fn.argc() == 0 then
      -- Open neo-tree on the left
      vim.cmd("Neotree show")
      -- Open a horizontal terminal at the bottom
      vim.cmd("botright split | terminal")
      vim.cmd("resize 15")
      -- Move cursor back to the editor pane (top-right)
      vim.cmd("wincmd k")
    end
  end,
})
