-- Adapted from https://github.com/Hashino/minimal.nvim/blob/featureful/init.lua
-- DEPENDENCIES:
-- this configuration assumes you have the following tools installed on your
-- system:
--    `git` - for vim builtin package manager. (see `:h vim.pack`)
--    `ripgrep` - for fuzzy finding
--    clipboard tool: xclip/xsel/win32yank - for clipboard sharing between OS and neovim (see `h: clipboard-tool`)
--    a nerdfont (ensure the terminal running neovim is using it)
-- run `:checkhealth` inside neovim to see if your system is missing anything.


-- INFO: options
-- these change the default neovim behaviours using the 'vim.opt' API.
-- see `:h vim.opt` for more details.
-- run `:h '{option_name}'` to see what they do and what values they can take.
-- for example, `:h 'number'` for `vim.opt.number`.

-- set <space> as the leader key
-- must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = "  "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- enable true color support
vim.opt.termguicolors = true

-- show title in GUI
vim.opt.title = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 0

-- make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

-- enable break indent
vim.opt.breakindent = true

-- save undo history
vim.opt.undofile = true

-- case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- decrease update time
vim.opt.updatetime = 250

-- decrease mapped sequence wait time
-- displays which-key popup sooner
vim.opt.timeoutlen = 300

-- configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", }

-- preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- show which line your cursor is on
vim.opt.cursorline = true

-- set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

-- enable line wrapping
vim.opt.wrap = true

-- formatting
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.textwidth = 120
vim.opt.complete:append 'kspell'

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
  virtual_lines = {
    -- Only show virtual line diagnostics for the current cursor line
    current_line = true,
  },

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

-- KEYBINDINGS

-- clear search highlights with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TODO: Do I need this?
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>w', '<C-w>', { desc = '[W]indow commands' })

-- Some other helix-inspired mappings

vim.keymap.set('v', '<leader>y', '"+y', { desc = '[Y]ank to system clipboard' })
vim.keymap.set('n', '<leader>y', '"+yl', { desc = '[Y]ank to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = '[P]aste system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+P', { desc = '[P]aste system clipboard before' })
-- vim.keymap.set('n', '<leader>k', 'K', { desc = '[K] Docs for item' })
-- somehow, just mapping this to `gc` didn't work
vim.keymap.set({ 'n', 'v' }, '<C-c>', ':norm vgc<CR>', { desc = '<C-c> Comment selection' })
vim.keymap.set({ 'n', 'v' }, '<leader>c', ':norm vgc<CR>', { desc = '[C]omment selection' })
vim.keymap.set({ 'n', 'v', 'o' }, 'g|', '|', { desc = '[G]oto | Column' })
vim.keymap.set({ 'n', 'v', 'o' }, 'ge', 'G', { desc = '[G]oto [E]nd of File' })
vim.keymap.set({ 'n', 'v', 'o' }, 'gh', '0', { desc = '[G]oto [H] line start' })
vim.keymap.set({ 'n', 'v', 'o' }, 'gl', '$', { desc = '[G]oto [L]ine end' })
vim.keymap.set({ 'n', 'v', 'o' }, 'g.', 'gi', { desc = '[G]oto [.] last modification' })

-- INFO: Autocommands

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd({ 'VimLeave' }, {
  pattern = { '*' },
  desc = 'Reset cursor when exiting vim',
  command = 'set guicursor=a:ver100-blinkon0',
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'sh', 'man' },
  desc = 'Set keywordprg to :Man for sh and man buffers',
  command = 'setlocal keywordprg=:Man',
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'gitcommit', 'markdown', 'text' },
  desc = 'Spellcheck for git commits, markdown, and text files',
  command = 'setlocal spell spelllang=en',
})

-- Relative numbers everywhere except insert mode

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = true
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  callback = function()
    vim.opt_local.relativenumber = true
    vim.opt_local.number = true
  end,
})

-- INFO: Save view

-- Automatically save the view (cursor position, folds, etc.), except for blacklisted filetypes/buftypes
local filetype_blacklist = { gitcommit = true, man = true }
local buftype_blacklist = { terminal = true, help = true }

local function should_save_view()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype
  return not filetype_blacklist[ft] and not buftype_blacklist[bt] and vim.fn.expand '%' ~= ''
end

local group = vim.api.nvim_create_augroup('AutoSaveFolds', { clear = true })

vim.api.nvim_create_autocmd('BufWinLeave', {
  group = group,
  pattern = '*',
  callback = function()
    if should_save_view() then
      vim.cmd 'mkview'
    end
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  group = group,
  pattern = '*',
  callback = function()
    if should_save_view() then
      vim.cmd 'silent! loadview'
    end
  end,
})

-- INFO: plugins
-- we install plugins with neovim's builtin package manager: vim.pack
-- and then enable/configure them by calling their setup functions.
--
-- (see `:h vim.pack` for more details on how it works)
-- you can press `gx` on any of the plugin urls below to open them in your
-- browser and check out their documentation and functionality.
-- alternatively, you can run `:h {plugin-name}` to read their documentation.
--
-- plugins are then loaded and configured with a call to `setup` functions
-- provided by each plugin. this is not a rule of neovim but rather a convention
-- followed by the community.
-- these setup calls take a table as an agument and their expected contents can
-- vary wildly. refer to each plugin's documentation for details.

-- INFO: colorscheme
vim.pack.add({ "https://github.com/folke/tokyonight.nvim" }, { confirm = false })
vim.cmd.colorscheme("tokyonight-night")

vim.pack.add({ "https://codeberg.org/andyg/leap.nvim" }, { confirm = false })
vim.keymap.set({ 'n', 'x', 'o' }, 'gw', '<Plug>(leap)', { desc = '[G]oto [W]ord' })

-- INFO: mini.nvim
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" }, { confirm = false })
require("mini.ai").setup({
  -- Number of lines within which textobject is searched
  n_lines = 1000,

  -- How to search for object (first inside current line, then inside
  -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
  -- 'cover_or_nearest', 'next', 'previous', 'nearest'.
  search_method = 'cover_or_next',
})

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require("mini.surround").setup {
  -- Had to give up and change the bindings back to the tpope ones.
  -- (Because so many other tools like Doom, VS Code Vim, IntelliJ use them...)
  mappings = {
    add = "ys", -- Add surrounding in Normal and Visual modes
    delete = "ds", -- Delete surrounding
    find = "sf", -- Find surrounding (to the right)
    find_left = "sF", -- Find surrounding (to the left)
    highlight = "sh", -- Highlight surrounding
    replace = "cs", -- Replace surrounding
    update_n_lines = "sn", -- Update `n_lines`

    suffix_last = "l", -- Suffix to search with "prev" method
    suffix_next = "n", -- Suffix to search with "next" method
  },
}

--  Simple and easy statusline.
--  You could remove this setup call if you don't like it,
--  and try some other statusline plugin
local statusline = require 'mini.statusline'
-- set use_icons to true if you have a Nerd Font
statusline.setup { use_icons = vim.g.have_nerd_font }

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" }, { confirm = false })
require("gitsigns").setup({
  signs = {
    add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
  },

  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']g', function()
      gitsigns.nav_hunk 'next'
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[g', function()
      gitsigns.nav_hunk 'prev'
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    -- visual mode
    map('v', '<leader>=s', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>=r', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })

    -- normal mode
    map('n', '<leader>=s', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>=r', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>=S', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>=u', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
    map('n', '<leader>=R', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>=p', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>=b', gitsigns.blame_line, { desc = 'git [b]lame line' })
    map('n', '<leader>=d', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>=D', function()
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })
    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
  end,
})

-- INFO: Indentation guides
-- vim.pack.add({ "https://github.com/lukas-reineke/indent-blankline.nvim" }, { confirm = false })
-- require("ibl").setup()

-- INFO: formatting and syntax highlighting
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })

-- equivalent to :TSUpdate
require("nvim-treesitter.install").update("all")

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- check if parser exists and load it
  if not vim.treesitter.language.add(language) then return end
  -- enables syntax highlighting and other treesitter features
  vim.treesitter.start(buf, language)

  -- enables treesitter based folds
  -- for more info on folds see `:help folds`
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.wo.foldmethod = 'expr'

  -- enables treesitter based indentation
  vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

local available_parsers = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

    if vim.tbl_contains(installed_parsers, language) then
      -- enable the parser if it is installed
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
      require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
      treesitter_try_attach(buf, language)
    end
  end,
})

vim.keymap.set({ "v", "o" }, "an", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require "vim.treesitter._select".select_parent(vim.v.count1)
  else
    vim.lsp.buf.selection_range(vim.v.count1)
  end
end, { desc = "Select parent treesitter node or outer incremental lsp selections" })

vim.keymap.set({ "v", "o" }, "in", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require "vim.treesitter._select".select_child(vim.v.count1)
  else
    vim.lsp.buf.selection_range(-vim.v.count1)
  end
end, { desc = "Select child treesitter node or inner incremental lsp selections" })

-- INFO: completion engine
vim.pack.add({ "https://github.com/saghen/blink.cmp" }, { confirm = false })

require("blink.cmp").setup({
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },

  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },

  signature = { enabled = true },

  keymap = {
    preset = "enter"
    -- these are the default blink keymaps
    -- ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
    -- ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
    -- ['<C-y>'] = { 'select_and_accept', 'fallback' },
    -- ['<C-e>'] = { 'cancel', 'fallback' },
    --
    -- ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
    -- ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
    -- ['<CR>'] = { 'select_and_accept', 'fallback' },
    -- ['<Esc>'] = { 'cancel', 'hide_documentation', 'fallback' },
    --
    -- ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    --
    -- ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    -- ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
    --
    -- ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },

  fuzzy = {
    implementation = "lua",
  },
})

-- INFO: lsp server installation and configuration

-- lsp servers we want to use and their configuration
-- see `:h lspconfig-all` for available servers and their settings
local lsp_servers = {
  lua_ls = {
    -- https://luals.github.io/wiki/settings/ | `:h nvim_get_runtime_file`
    Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) }, },
  },
  rust_analyzer = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false;
      }
    }
  },
  gopls = {},
}

vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig", -- default configs for lsps

  -- NOTE: if you'd rather install the lsps through your OS package manager you
  -- can delete the next three mason-related lines and their setup calls below.
  -- see `:h lsp-quickstart` for more details.
  -- "https://github.com/mason-org/mason.nvim",                     -- package manager
  -- "https://github.com/mason-org/mason-lspconfig.nvim",           -- lspconfig bridge
  -- "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" -- auto installer
}, { confirm = false })

-- require("mason").setup()
-- require("mason-lspconfig").setup()
-- require("mason-tool-installer").setup({
--   ensure_installed = vim.tbl_keys(lsp_servers),
-- })

-- configure each lsp server on the table
-- to check what clients are attached to the current buffer, use
-- `:checkhealth vim.lsp`. to view default lsp keybindings, use `:h lsp-defaults`.
for server, config in pairs(lsp_servers) do
  vim.lsp.config(server, {
    settings = config,

    -- only create the keymaps if the server attaches successfully
    on_attach = function(client, bufnr)
      -- vim.lsp.buf.definition
      vim.keymap.set("n", "gd", require('telescope.builtin').lsp_definitions,
        { buffer = bufnr, desc = "LSP: [G]oto [D]efinition", })

      vim.keymap.set("n", "gD", vim.lsp.buf.declaration,
        { buffer = bufnr, desc = "LSP: [G]oto [D]eclaration", })

      vim.keymap.set("n", "gR", require('telescope.builtin').lsp_references,
        { buffer = bufnr, desc = "LSP: [G]oto [R]eferences", })

      vim.keymap.set("n", "gI", require('telescope.builtin').lsp_implementations,
        { buffer = bufnr, desc = "LSP: [G]oto [I]mplementations", })

      vim.keymap.set("n", "gy", require('telescope.builtin').lsp_type_definitions,
        { buffer = bufnr, desc = "LSP: [G]ode [Y] Type Def.", })

      vim.keymap.set({"n", "v"}, "=", vim.lsp.buf.format,
        { buffer = bufnr, desc = "LSP: [=] Format", })

      vim.keymap.set("n", "<leader>s", require('telescope.builtin').lsp_document_symbols,
        { buffer = bufnr, desc = "LSP: [S]ymbol Picker", })

      vim.keymap.set("n", "<leader>S", require('telescope.builtin').lsp_dynamic_workspace_symbols,
        { buffer = bufnr, desc = "LSP: [S]ymbol Picker (global)", })

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      if client and client:supports_method('textDocument/documentHighlight', bufnr) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = bufnr,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = bufnr,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method('textDocument/inlayHint', bufnr) then
        vim.keymap.set("n", "<leader>th", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }) end,
          { buffer = bufnr, desc = "LSP: [T]oggle Inlay [H]ints", })
      end
    end,
  })
  vim.lsp.enable(server)
end

-- NOTE: if all you want is lsp + completion + highlighting, you're done.
-- the rest of the lines are just quality-of-life/appearance plugins and
-- can be removed.

-- INFO: fuzzy finder
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",        -- library dependency
  "https://github.com/nvim-tree/nvim-web-devicons",  -- icons (nerd font)
  "https://github.com/nvim-telescope/telescope.nvim" -- the fuzzy finder
}, { confirm = false })

require("telescope").setup({})

local pickers = require("telescope.builtin")
local utils = require("telescope.utils")

vim.keymap.set("n", "<leader>b", pickers.buffers, { desc = "Search [B]uffers", })
vim.keymap.set('n', '<leader>?', pickers.keymaps, { desc = '[?] Search Keymaps' })
vim.keymap.set('n', '<leader>:', pickers.commands, { desc = '[:] Command Palette' })
vim.keymap.set('n', '<leader><leader>', function()
  pickers.find_files { follow = true }
end, { desc = '[ ] File Picker' })
vim.keymap.set("n", "<leader>/", pickers.live_grep, { desc = "[/] Grep Directory", })
vim.keymap.set("n", "<leader>'", pickers.resume, { desc = "['] Open Last Picker", })
vim.keymap.set('n', '<leader>F', function()
  pickers.find_files { cwd = utils.buffer_dir() }
end, { desc = '[F]file picker at buffer’s CWD' })
vim.keymap.set('n', '<leader>d', function()
  pickers.diagnostics { bufnr = 0 }
end, { desc = '[D]iagnostics (current buf)' })
vim.keymap.set('n', '<leader>D', pickers.diagnostics, { desc = '[D]iagnostics (global)' })
vim.keymap.set('n', '<leader>.', pickers.oldfiles, { desc = '[.] Search Recent Files' })
vim.keymap.set('n', '<leader>j', pickers.jumplist, { desc = '[J]umplist' })
vim.keymap.set('n', '<leader>g', pickers.git_status, { desc = '[G]it changed files' })

vim.keymap.set("n", "<leader>B", pickers.builtin, { desc = "Search [B]uiltin Pickers", })
vim.keymap.set("n", "<leader>H", pickers.help_tags, { desc = "Search [H]elp", })
vim.keymap.set("n", "<leader>M", pickers.man_pages, { desc = "Search [M]anuals", })

-- INFO: keybinding helper
vim.pack.add({ "https://github.com/folke/which-key.nvim" }, { confirm = false })

require("which-key").setup({
  -- delay between pressing a key and opening which-key (milliseconds)
  delay = 250,
  icons = { mappings = vim.g.have_nerd_font },
  win = {
    height = { min = 4, max = 40 },
  },
  spec = {
    { '<leader>=', group = '[=] Git', mode = { 'n', 'v' } },
  }
})

-- INFO: Lint
vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" }, { confirm = false })

local lint = require("lint")
lint.linters_by_ft = lint.linters_by_ft or {}
lint.linters_by_ft["markdown"] = { "vale" }
lint.linters_by_ft["text"] = { "vale" }
lint.linters_by_ft["sh"] = { "shellcheck" }
lint.linters_by_ft["rust"] = { "clippy" }

local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    -- Only run the linter in buffers that you can modify in order to
    -- avoid superfluous noise, notably within the handy LSP pop-ups that
    -- describe the hovered symbol using Markdown.
    if vim.bo.modifiable then lint.try_lint() end
  end,
})

-- INFO: NeoTree
vim.pack.add({ "https://github.com/MunifTanjim/nui.nvim", "https://github.com/nvim-neo-tree/neo-tree.nvim" }, { confirm = false })
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "[e] NeoTree", silent = true })
vim.keymap.set("n", "<leader>E", ":Neotree toggle dir=%:p:h<CR>", { desc = "[E] NeoTree (relative to buf)", silent = true })

-- INFO: utility plugins
vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/folke/todo-comments.nvim",
  "https://github.com/NMAC427/guess-indent.nvim"
}, { confirm = false })

require("nvim-autopairs").setup()

require("todo-comments").setup({
  highlight = {
    pattern = [[.*<(KEYWORDS)\s*:?]],
    keyword = "bg"
  },
  signs = false,
})

require('guess-indent').setup()

-- uncomment to enable automatic plugin updates
-- vim.pack.update()
