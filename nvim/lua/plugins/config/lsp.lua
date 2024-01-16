-- Enable lsp_zero for easy lsp support
local lsp_zero = require('lsp-zero')
lsp_zero.configure('rust_analyzer', {
	settings = {
		['rust-analyzer'] = {
			checkOnSave = {
				command = 'clippy'
			},
		},
	},
})
lsp_zero.on_attach(function(client, bufnr)
	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	lsp_zero.default_keymaps({ buffer = bufnr })


	-- make sure you use clients with formatting capabilities
	-- otherwise you'll get a warning message
	if client.supports_method('textDocument/formatting') then
		require('lsp-format').on_attach(client)
	end
end)

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

-- Setup cmp
cmp.setup({
	mapping = cmp.mapping.preset.insert({
		-- `Enter` key to confirm completion
		['<CR>'] = cmp.mapping.confirm({ select = false }),

		-- Ctrl+Space to trigger completion menu
		['<C-Space>'] = cmp.mapping.complete(),

		-- Navigate between snippet placeholder
		['<C-f>'] = cmp_action.luasnip_jump_forward(),
		['<C-b>'] = cmp_action.luasnip_jump_backward(),

		-- Scroll up and down in the completion documentation
		['<C-u>'] = cmp.mapping.scroll_docs(-4),
		['<C-d>'] = cmp.mapping.scroll_docs(4),
	})
})

--- if you want to know more about lsp-zero and mason.nvim
--- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
require('mason').setup({})
require('mason-lspconfig').setup({
	ensure_installed = { "lua_ls", "rust_analyzer", "tsserver" },
	handlers = {
		lsp_zero.default_setup,
	},
})
