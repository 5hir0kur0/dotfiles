-- :PackerCompile has to be run after updating this file. This autocommand
-- should do so automatically:
vim.cmd([[
  augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require('packer').startup(function()
    -- Packer itself
    use 'wbthomason/packer.nvim'
    use 'morhetz/gruvbox'
    use 'tpope/vim-surround'
    use 'tpope/vim-repeat'
    use 'tpope/vim-unimpaired'
    use 'tpope/vim-commentary'

    use 'nvim-treesitter/nvim-treesitter-textobjects'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                -- ensure_installed = "all",
                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,
                -- Automatically install missing parsers when entering buffer
                auto_install = true,
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
                textobjects = {
                    select = {
                        enable = true,

                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,

                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@class.outer",
                        },
                    },
                },
            }
        end
    }
    -- colorize color specifications in code
    use {
        'NvChad/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup {
                css = {};
                javascript = {};
                html = {};
            }
        end
    }
    -- GitGutter replacement
    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }

    -- LSP
    use {
        'neovim/nvim-lspconfig',
        after = { 'telescope.nvim' },
        config = function()
            -- from https://github.com/neovim/nvim-lspconfig#suggested-configuration

            -- Mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            local opts = { noremap=true, silent=true }
            vim.keymap.set('n', '<space>ce', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '<space>cl', vim.diagnostic.setqflist, opts)
            vim.keymap.set('n', '[e', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']e', vim.diagnostic.goto_next, opts)
            -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)
                -- Mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local bufopts = { noremap=true, silent=true, buffer=bufnr }
                local builtin = require('telescope.builtin')
                vim.keymap.set('n', 'gD', vim.lsp.buf.references, bufopts)
                if (builtin ~= nil) then
                    vim.keymap.set('n', 'gD', builtin.lsp_references, bufopts)
                end
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                vim.keymap.set('n', '<space>cd', vim.lsp.buf.definition, bufopts)
                if (builtin ~= nil) then
                    vim.keymap.set('n', 'gd', builtin.lsp_definitions, bufopts)
                    vim.keymap.set('n', '<space>cd', builtin.lsp_definitions, bufopts)
                end
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)

                vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', '<space>ci', vim.lsp.buf.implementation, bufopts)
                if (builtin ~= nil) then
                    vim.keymap.set('n', 'gI', builtin.lsp_implementations, bufopts)
                    vim.keymap.set('n', '<space>ci', builtin.lsp_implementations, bufopts)
                end
                vim.keymap.set('n', '<space>cD', vim.lsp.buf.references, bufopts)
                vim.keymap.set('n', '<space>ck', vim.lsp.buf.hover, bufopts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set('n', '<space>cwa', vim.lsp.buf.add_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>cwr', vim.lsp.buf.remove_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>cwl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, bufopts)
                vim.keymap.set('n', '<space>ct', vim.lsp.buf.type_definition, bufopts)
                if (builtin ~= nil) then
                    vim.keymap.set('n', '<space>ct', builtin.lsp_type_definitions, bufopts)
                end
                vim.keymap.set('n', '<space>cr', vim.lsp.buf.rename, bufopts)
                vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
                vim.keymap.set('n', '<space>cf', vim.lsp.buf.formatting, bufopts)
                if (builtin ~= nil) then
                    vim.keymap.set('n', '<space>cci', builtin.lsp_incoming_calls, bufopts)
                    vim.keymap.set('n', '<space>cco', builtin.lsp_outgoing_calls, bufopts)
                end
            end

            local lspconfig = require('lspconfig')

            -- 2. (optional) Override the default configuration to be applied to all servers.
            lspconfig.util.default_config = vim.tbl_extend(
                "force",
                lspconfig.util.default_config,
                {
                    on_attach = on_attach
                }
            )
        end
    }

    use 'L3MON4D3/LuaSnip'
    use 'hrsh7th/nvim-cmp'
    use {
        'hrsh7th/cmp-nvim-lsp',
        requires = { 'hrsh7th/nvim-cmp', 'neovim/nvim-lspconfig', 'L3MON4D3/LuaSnip' },
        after = { 'nvim-cmp', 'LuaSnip', 'nvim-lspconfig' },
        config = function()
            -- from https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion

            -- Add additional capabilities supported by nvim-cmp
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

            local lspconfig = require('lspconfig')

            -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
            local servers = { 'rust_analyzer', 'pylsp', 'tsserver', 'gopls', 'hls' }
            for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup {
                    -- on_attach is set as a default value above
                    capabilities = capabilities,
                }
            end

            -- luasnip setup
            local luasnip = require 'luasnip'

            -- nvim-cmp setup
            local cmp = require 'cmp'
            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                },
            }
        end
    }

    use {
        'mfussenegger/nvim-lint',
        config = function()
            require('lint').linters_by_ft = {
                markdown = {'languagetool',},
                sh = {'shellcheck',},
                bash = {'shellcheck',},
                zsh = {'shellcheck',},
            }
            vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
                callback = function()
                    require('lint').try_lint()
                end,
            })
        end
    }

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            local opts = { noremap=true, silent=true }
            -- find files
            vim.keymap.set('n', '<space>ff', builtin.find_files, opts)
            vim.keymap.set('n', '<space>.', builtin.find_files, opts)
            -- find recent
            vim.keymap.set('n', '<space>fr', builtin.oldfiles, opts)
            -- project files
            vim.keymap.set('n', '<space>pf', builtin.git_files, opts)
            vim.keymap.set('n', '<space><space>', builtin.git_files, opts)
            -- search directory
            vim.keymap.set('n', '<space>sd', builtin.live_grep, opts)
            -- list buffers
            vim.keymap.set('n', '<space>bb', builtin.buffers, opts)
            vim.keymap.set('n', '<space>,', builtin.buffers, opts)
            -- list commands
            vim.keymap.set('n', '<space>;', builtin.commands, opts)
            -- themes
            vim.keymap.set('n', '<space>ht', builtin.colorscheme, opts)
            -- browse bindings
            vim.keymap.set('n', '<space>hbb', builtin.keymaps, opts)
            -- resume previous listing
            vim.keymap.set('n', "<space>'", builtin.resume, opts)
            -- code diagnostics
            vim.keymap.set('n', '<space>cl', builtin.diagnostics, opts)
            -- code identifiers
            vim.keymap.set('n', '<space>ci', builtin.lsp_document_symbols, opts)
            -- code jump to workspace symbol
            vim.keymap.set('n', '<space>cj', builtin.lsp_dynamic_workspace_symbols, opts)
        end
    }

    use {
        'windwp/nvim-autopairs',
        after = { 'cmp-nvim-lsp' },
        config = function()
            require('nvim-autopairs').setup {}
            -- If you want insert `(` after select function or method item
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )
        end
    }

    use {
        'nvim-lualine/lualine.nvim',
        config = function()
            require('lualine').setup {
                options = {
                    icons_enabled = false,
                    section_separators = '',
                    component_separators = '',
                }
            }
        end
    }
end)

