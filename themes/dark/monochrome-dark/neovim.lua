-- Neovim theme configuration for Monochrome Dark
return {
	"Lokaltog/vim-monotone",
	lazy = false,
	priority = 1000,
	config = function()
		vim.cmd("set background=dark")
		vim.cmd("colorscheme monotone")
	end,
}
