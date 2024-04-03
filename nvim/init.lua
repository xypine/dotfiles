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
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	{ "loctvl842/monokai-pro.nvim", opts = { filter = "spectrum" } },
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
	{ "folke/neoconf.nvim" },
	"folke/neodev.nvim",
	{
		'goolord/alpha-nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require 'alpha'.setup(require 'alpha.themes.startify'.config)
		end
	},
	{ 'akinsho/bufferline.nvim',          version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },
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
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			{ 'L3MON4D3/LuaSnip' }
		},
	},
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
	}, -- commenting plugin

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
			require("guess-indent").setup {}
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

-- Show line numbers
vim.opt.number = true
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
