-- Neovim theme configuration for Everforest Light
return {
	"sainnhe/everforest",
	config = function()
		vim.g.everforest_background = "medium"
		vim.cmd("set background=light")
		vim.cmd("colorscheme everforest")
	end,
}
