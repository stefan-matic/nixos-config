{
  pkgs,
  ...
}:

{
  programs.neovim = {
    enable = true;

    # vi/vim commands open neovim
    viAlias = true;
    vimAlias = true;

    # Keep nano as default editor - switch when comfortable
    defaultEditor = false;

    plugins = with pkgs.vimPlugins; [
      # === Theme (Dracula - matches Ghostty/tmux) ===
      dracula-nvim

      # === UI ===
      lualine-nvim
      bufferline-nvim
      indent-blankline-nvim
      nvim-web-devicons
      dressing-nvim
      fidget-nvim

      # === Navigation ===
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      neo-tree-nvim
      plenary-nvim
      nui-nvim
      vim-tmux-navigator
      flash-nvim

      # === Syntax ===
      (nvim-treesitter.withPlugins (
        p: with p; [
          nix
          lua
          python
          go
          javascript
          typescript
          tsx
          json
          yaml
          toml
          bash
          html
          css
          markdown
          markdown_inline
          vim
          vimdoc
          gitcommit
          diff
          dockerfile
          hcl
          terraform
          kdl
          regex
        ]
      ))
      # === LSP (nvim-lspconfig provides server config definitions for vim.lsp.config) ===
      nvim-lspconfig

      # === Completion ===
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      luasnip
      friendly-snippets

      # === Formatting ===
      conform-nvim

      # === Git ===
      gitsigns-nvim
      vim-fugitive

      # === Editing ===
      nvim-autopairs
      comment-nvim
      nvim-surround
      mini-ai

      # === Beginner helpers ===
      which-key-nvim

      # === QoL ===
      todo-comments-nvim
      trouble-nvim
    ];

    # LSP servers & formatters (installed via Nix, not Mason)
    extraPackages = with pkgs; [
      # LSP servers
      nil # Nix
      lua-language-server
      pyright
      gopls
      typescript-language-server
      bash-language-server
      yaml-language-server
      vscode-langservers-extracted # JSON, HTML, CSS
      terraform-ls

      # Formatters
      nixfmt-rfc-style
      stylua
      black
      prettierd
      shfmt

      # Telescope dependencies
      ripgrep
      fd
    ];

    extraLuaConfig = ''
      -- ============================================================
      -- Neovim Configuration
      -- Beginner-friendly setup with Dracula theme
      -- Press Space to see all available keybindings (which-key)
      -- ============================================================

      -- Leader key: Space (press it to see a menu of commands)
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- ============================================================
      -- Basic Settings
      -- ============================================================

      -- Line numbers (absolute + relative for easy jumping)
      vim.opt.number = true
      vim.opt.relativenumber = true

      -- Tabs & indentation (2 spaces, standard for Nix)
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.smartindent = true

      -- Search
      vim.opt.ignorecase = true -- Case-insensitive search...
      vim.opt.smartcase = true -- ...unless you type a capital letter
      vim.opt.hlsearch = true -- Highlight matches
      vim.opt.incsearch = true -- Show matches as you type

      -- Clear search highlighting with Escape
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

      -- Appearance
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes" -- Always show sign column (no layout shift)
      vim.opt.cursorline = true -- Highlight the line your cursor is on
      vim.opt.scrolloff = 8 -- Keep 8 lines visible above/below cursor
      vim.opt.sidescrolloff = 8
      vim.opt.wrap = false -- Don't wrap long lines (scroll instead)

      -- Clipboard: yank/paste uses system clipboard
      vim.opt.clipboard = "unnamedplus"

      -- Splits open in more natural directions
      vim.opt.splitbelow = true
      vim.opt.splitright = true

      -- Undo persists after closing file
      vim.opt.undofile = true

      -- Faster updates (for gitsigns, etc.)
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 300 -- Time for which-key to appear

      -- Better completion experience
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      -- Show invisible characters
      vim.opt.list = true
      vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

      -- Mouse support (yes, it works in the terminal!)
      vim.opt.mouse = "a"

      -- ============================================================
      -- Theme: Dracula (matches Ghostty + tmux)
      -- ============================================================
      require("dracula").setup({
        transparent_bg = true,
        italic_comment = true,
      })
      vim.cmd.colorscheme("dracula")

      -- ============================================================
      -- Plugin Setup
      -- ============================================================

      -- Statusline (bottom bar showing mode, file, git branch)
      require("lualine").setup({
        options = {
          theme = "dracula",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
      })

      -- Buffer tabs (top bar showing open files)
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "neo-tree", text = "File Explorer", text_align = "center" },
          },
        },
      })

      -- Indent guides (subtle vertical lines showing indentation)
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true },
      })

      -- Loading spinner for LSP progress
      require("fidget").setup({})

      -- Better UI for vim.ui.select and vim.ui.input
      require("dressing").setup({})

      -- ============================================================
      -- Navigation
      -- ============================================================

      -- Telescope (fuzzy finder for files, text, and more)
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")

      -- Neo-tree (file explorer sidebar)
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          filtered_items = {
            visible = true, -- Show hidden files (dimmed)
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
        window = {
          width = 35,
        },
      })

      -- Flash (quick jumping - press s then type 2 chars)
      require("flash").setup({})

      -- ============================================================
      -- Treesitter (syntax highlighting & code understanding)
      -- ============================================================
      -- Treesitter: grammars are installed by Nix, highlighting is built-in.
      -- Enable treesitter highlighting for all buffers that have a parser.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Textobjects are provided by mini.ai (configured below) which is more
      -- reliable across nvim-treesitter versions. The treesitter-textobjects
      -- plugin provides additional tree-aware motions via ]f [f ]c [c.

      -- ============================================================
      -- LSP (Language Server Protocol - IDE features)
      -- Uses native vim.lsp.config (Neovim 0.11+)
      -- ============================================================

      -- Shared capabilities (completion support)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Apply completion capabilities to all LSP servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Nix
      vim.lsp.config("nil_ls", {
        settings = {
          ["nil"] = {
            formatting = { command = { "nixfmt" } },
          },
        },
      })

      -- Lua
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- Enable all configured LSP servers
      vim.lsp.enable({
        "nil_ls",      -- Nix
        "lua_ls",      -- Lua
        "pyright",     -- Python
        "gopls",       -- Go
        "ts_ls",       -- TypeScript/JavaScript
        "bashls",      -- Bash
        "yamlls",      -- YAML
        "jsonls",      -- JSON
        "terraformls", -- Terraform
      })

      -- LSP keybindings (only active when LSP is attached to a buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end

          -- Navigation
          map("gd", require("telescope.builtin").lsp_definitions, "Go to definition")
          map("gr", require("telescope.builtin").lsp_references, "Go to references")
          map("gI", require("telescope.builtin").lsp_implementations, "Go to implementation")
          map("gy", require("telescope.builtin").lsp_type_definitions, "Go to type definition")

          -- Info
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<C-s>", vim.lsp.buf.signature_help, "Signature help")

          -- Actions (under <leader>l for "LSP")
          map("<leader>la", vim.lsp.buf.code_action, "Code action")
          map("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
          map("<leader>ls", require("telescope.builtin").lsp_document_symbols, "Document symbols")
          map("<leader>lS", require("telescope.builtin").lsp_workspace_symbols, "Workspace symbols")
        end,
      })

      -- ============================================================
      -- Completion (autocomplete as you type)
      -- ============================================================
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Load snippet collection
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(), -- Next suggestion
          ["<C-p>"] = cmp.mapping.select_prev_item(), -- Previous suggestion
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion manually
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept selected
          ["<Tab>"] = cmp.mapping(function(fallback) -- Tab cycles through suggestions
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP suggestions (highest priority)
          { name = "luasnip" }, -- Snippet suggestions
          { name = "path" }, -- File path completion
        }, {
          { name = "buffer" }, -- Words from current buffer (fallback)
        }),
      })

      -- ============================================================
      -- Formatting (auto-format on save)
      -- ============================================================
      require("conform").setup({
        formatters_by_ft = {
          nix = { "nixfmt" },
          lua = { "stylua" },
          python = { "black" },
          javascript = { "prettierd" },
          typescript = { "prettierd" },
          json = { "prettierd" },
          yaml = { "prettierd" },
          html = { "prettierd" },
          css = { "prettierd" },
          markdown = { "prettierd" },
          sh = { "shfmt" },
          bash = { "shfmt" },
        },
        format_on_save = {
          timeout_ms = 2000,
          lsp_format = "fallback",
        },
      })

      -- ============================================================
      -- Git
      -- ============================================================
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })

      -- ============================================================
      -- Editing helpers
      -- ============================================================

      -- Auto-close brackets, quotes, etc.
      require("nvim-autopairs").setup({})

      -- Comment toggling (gcc for line, gc in visual mode)
      require("Comment").setup({})

      -- Surround text objects (cs"' to change " to ', ysiw" to add " around word)
      require("nvim-surround").setup({})

      -- Better text objects (around/inside function, argument, etc.)
      require("mini.ai").setup({})

      -- ============================================================
      -- QoL plugins
      -- ============================================================

      -- Highlight TODO/FIXME/HACK comments
      require("todo-comments").setup({})

      -- Better diagnostics list
      require("trouble").setup({})

      -- ============================================================
      -- Which-Key (press Space and wait to see all commands)
      -- ============================================================
      local wk = require("which-key")
      wk.setup({
        delay = 200,
      })
      wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>l", group = "LSP" },
        { "<leader>g", group = "Git" },
        { "<leader>b", group = "Buffer" },
        { "<leader>x", group = "Trouble" },
      })

      -- ============================================================
      -- Keybindings
      -- ============================================================

      local map = vim.keymap.set

      -- Quick save/quit
      map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
      map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
      map("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit all" })

      -- File explorer
      map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

      -- Find (Telescope)
      map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
      map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Grep in project" })
      map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
      map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find help" })
      map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
      map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Find diagnostics" })

      -- Buffers (open files)
      map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
      map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
      map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })
      map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })

      -- Git
      map("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Git status (fugitive)" })
      map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
      map("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", { desc = "Blame line" })
      map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
      map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff this" })
      map("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
      map("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Previous git hunk" })

      -- Trouble (diagnostics panel)
      map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics" })
      map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics" })
      map("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "TODOs" })

      -- Flash (quick jump - press s then type where you want to go)
      map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })

      -- Better window navigation (works with tmux too)
      -- Handled by vim-tmux-navigator: Ctrl+h/j/k/l

      -- Move selected lines up/down in visual mode
      map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
      map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

      -- Keep cursor centered when scrolling
      map("n", "<C-d>", "<C-d>zz")
      map("n", "<C-u>", "<C-u>zz")

      -- Keep cursor centered when searching
      map("n", "n", "nzzzv")
      map("n", "N", "Nzzzv")

      -- Don't lose selection when indenting
      map("v", "<", "<gv")
      map("v", ">", ">gv")

      -- Format with <leader>lf (also available: format on save is automatic)
      map("n", "<leader>lf", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end, { desc = "Format buffer" })
    '';
  };
}
