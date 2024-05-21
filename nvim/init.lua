local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Install lazy.nvim if it isn't installed already
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
--
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

local enable_ai = function()
	local current_dir = vim.fn.getcwd()
	local home_dir = os.getenv("HOME") or os.getenv("USERPROFILE")
	local code_path = home_dir .. "/code"

	-- if git repo is filed under ~/code/_private, do not allow AI
	local private_path = code_path .. "/_private"
	local is_code_private = string.find(current_dir, private_path) == 1

	if is_code_private then
		return false
	else
		return true
	end
end

require("lazy").setup({
	{
		"f4z3r/gruvbox-material.nvim",
		name = "gruvbox-material",
		lazy = false,
		priority = 1000,
		opts = {
			italics = true,
			contrast = "hard",
			comments = {
				italics = true,
			},
			background = {
				transparent = false,
			},
		}
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', "f4z3r/gruvbox-material.nvim" }
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	},
	"folke/neoconf.nvim",
	"folke/neodev.nvim",
	{
		'goolord/alpha-nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require 'alpha'.setup(require 'alpha.themes.startify'.config)
		end
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	},
	{
		'akinsho/bufferline.nvim',
		version = "*",
		dependencies = 'nvim-tree/nvim-web-devicons'
	},
	{ 'williamboman/mason.nvim' },
	{ 'williamboman/mason-lspconfig.nvim' },
	-- LSP Support
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		lazy = true,
		config = false,
	},
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			{ 'hrsh7th/cmp-nvim-lsp' },
		}
	},
	{ "lukas-reineke/lsp-format.nvim" },
	-- Autocompletion
	{ -- Autocompletion
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				'L3MON4D3/LuaSnip',
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
						return
					end
					return 'make install_jsregexp'
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					-- {
					--   'rafamadriz/friendly-snippets',
					--   config = function()
					--     require('luasnip.loaders.from_vscode').lazy_load()
					--   end,
					-- },
				},
			},
			'saadparwaiz1/cmp_luasnip',

			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path',
		},
		config = function()
			-- See `:help cmp`
			local cmp = require 'cmp'
			local luasnip = require 'luasnip'
			luasnip.config.setup {}

			cmp.setup {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = 'menu,menuone,noinsert' },

				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert {
					-- Select the [n]ext item
					['<C-n>'] = cmp.mapping.select_next_item(),
					-- Select the [p]revious item
					['<C-p>'] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					['<C-y>'] = cmp.mapping.confirm { select = true },

					-- Manually trigger a completion from nvim-cmp.
					--  Generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					['<C-Space>'] = cmp.mapping.complete {},

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					-- ['<C-l>'] = cmp.mapping(function()
					-- 	if luasnip.expand_or_locally_jumpable() then
					-- 		luasnip.expand_or_jump()
					-- 	end
					-- end, { 'i', 's' }),
					-- ['<C-h>'] = cmp.mapping(function()
					-- 	if luasnip.locally_jumpable(-1) then
					-- 		luasnip.jump(-1)
					-- 	end
					-- end, { 'i', 's' }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				},
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'path' },
				},
			}
		end,
	},
	-- Highlights the current chunk of text
	{
		'shellRaining/hlchunk.nvim',
		event = { "UIEnter" },
		config = function()
			require("hlchunk").setup({})
		end,
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
	},
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- empty for now
			})
		end
	},
	-- AI
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				panel = {
					enabled = true,
					auto_refresh = true,
				},
				suggestion = {
					enabled = true,
					auto_trigger = true,
					--	accept = false, -- disable built-in keymapping
				},
			})

			-- hide copilot suggestions when cmp menu is open
			-- to prevent odd behavior/garbled up suggestions
			local cmp_status_ok, cmp = pcall(require, "cmp")
			if cmp_status_ok then
				cmp.event:on("menu_opened", function()
					vim.b.copilot_suggestion_hidden = true
				end)

				cmp.event:on("menu_closed", function()
					vim.b.copilot_suggestion_hidden = false
				end)
			end

			-- disable copilot if we are in a private project
			if not enable_ai() then
				vim.cmd("Copilot disable")
			end
		end,
	},
	{ "testaustime/testaustime.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	-- treesitter configuration
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		config = function()
			require("plugins.config.treesitter")
		end,
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring", -- allow comments in mixed content files like jsx, html and svelte
			"windwp/nvim-ts-autotag", -- autoclose html tags
		},
	},
	-- commenting
	{
		"terrortylor/nvim-comment",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugins.config.comment")
		end,
	},
	-- Bar at the top showing location
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
			"f4z3r/gruvbox-material.nvim"
		},
		opts = {
			show_basename = false, -- don't show filename as it is already shown in the bufferline
		},
	},
	-- auto closing
	{
		"windwp/nvim-autopairs",
		event = { "InsertEnter" },
		config = function()
			require("plugins.config.autopairs")
		end,
	}, -- autoclose parens, brackets, quotes, etc...

	-- git integration
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugins.config.gitsigns")
		end,
	}, -- show line modifications on left hand side

	{
		"sindrets/diffview.nvim",
		config = function()
			require("plugins.config.diffview")
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
	}, -- diffview (diffing and merging git commits)
	{ "norcalli/nvim-colorizer.lua" },
	{
		"f-person/git-blame.nvim",
	}, -- git blame
	{
		"lvimuser/lsp-inlayhints.nvim"
	},
	{
		"natecraddock/workspaces.nvim"
	}, -- Workspace management
	{
		"sitiom/nvim-numbertoggle"
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	}, -- Nice "problems" panel
	{
		"aznhe21/actions-preview.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			vim.keymap.set({ "v", "n" }, "gf", require("actions-preview").code_actions)
		end,

	},
	{
		"natecraddock/sessions.nvim"
	},
	{
		"nanotee/sqls.nvim"
	},
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim"
		},
		config = function()
			require("refactoring").setup()
		end,
	},
	{
		"t-troebst/perfanno.nvim",
		config = function()
			require("perfanno").setup()
		end,
	}, -- Flamegraph results in editor
	{
		'stevearc/oil.nvim',
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("plugins.config.oil")
		end,
	}, -- fs as a buffer
	{
		"j-hui/fidget.nvim",
	}, -- Notifications and LSP progress
	{
		"google/executor.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		config = function()
			require("executor").setup({})
		end,
	}, -- Execute commands in the background
	{
		"NMAC427/guess-indent.nvim",
		config = function()
			require("guess-indent").setup({
				auto_cmd = true,
			})
		end
	}, -- Automatically guess indent settings
	{
		"xiyaowong/transparent.nvim",
	}, -- Quick toggle for background transparency
	{
		'tamton-aquib/duck.nvim',
		config = function()
			vim.keymap.set('n', '<leader>dd', function() require("duck").hatch() end, {
				desc = "Hatch a duck"
			})
			vim.keymap.set('n', '<leader>dk', function() require("duck").cook() end, {
				desc = "Cook a duck"
			})
			vim.keymap.set('n', '<leader>da', function() require("duck").cook_all() end, {
				desc = "Cook all ducks"
			})
		end
	}, -- Fun nonsense
})


vim.opt.termguicolors = true
vim.g.have_nerd_font = true
-- Show line numbers
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.keymap.set("i", "<C-h>", "<Left>", { noremap = true })
vim.keymap.set("i", "<C-j>", "<Down>", { noremap = true })
vim.keymap.set("i", "<C-k>", "<Up>", { noremap = true })
vim.keymap.set("i", "<C-l>", "<Right>", { noremap = true })

-- Highlight search results, clear search results on <Esc>
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("ee-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end
})
-- Quickfix bindings
-- vim.keymap.set("n", "<leader>qn", "<cmd>cnext<CR>", { desc = "Next quickfix" })
-- vim.keymap.set("n", "<leader>qN", "<cmd>cprev<CR>", { desc = "Previous quickfix" })

-- Load more complex configuration
require('colorscheme')
require("plugins.config.lualine")
require("plugins.config.telescope")
require("plugins.config.lsp")
require("plugins.config.testaustime")

-- Copilot
require("copilot").setup()

require("colorizer").setup()
require("gitblame")

require("workspaces").setup()
require("sessions").setup()
require("transparent").setup()
local bufferline = require("bufferline")
bufferline.setup({
	options = {
		separator_style = "slope",
	}
})

-- Fidget
local fidget = require("fidget").setup()

-- Trouble keymaps
vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = "Toggle Trouble" })
vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end,
	{ desc = "Toggle Workspace Trouble" })
vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end,
	{ desc = "Toggle Document Trouble" })
vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end,
	{ desc = "Toggle Quickfix Trouble" })
vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end,
	{ desc = "Toggle Loclist Trouble" })
vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end,
	{ desc = "Toggle LSP References Trouble" })

-- Executor keymaps
vim.api.nvim_set_keymap("n", "<leader>er", ":ExecutorRun<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>ev", ":ExecutorToggleDetail<CR>", {})
