-- telescope
require("telescope").setup({
	pickers = {
		find_files = {
			hidden = true,
		},
		file_browser = {
			hidden = true,
		},
	},
})

-- nice default keymaps
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Find in files" })
vim.keymap.set('n', '<leader>fl', builtin.buffers, { desc = "Find buffers" })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Find help" })

-- file browser
require("telescope").load_extension("file_browser")
vim.api.nvim_set_keymap(
	"n",
	"<space>fb",
	":Telescope file_browser<CR>",
	{ noremap = true, desc = "File browser" }
)
-- open file_browser with the path of the current buffer
vim.api.nvim_set_keymap(
	"n",
	"<space>fb",
	":Telescope file_browser path=%:p:h select_buffer=true<CR>",
	{ noremap = true }
)

-- refactoring
require("telescope").load_extension("refactoring")
vim.keymap.set(
	{ "n", "x" },
	"<leader>rr",
	function() require('telescope').extensions.refactoring.refactors() end,
	{ desc = "Refactor" }
)
