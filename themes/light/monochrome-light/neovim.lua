-- Neovim theme configuration for Monochrome Light
return {
	"mcchrish/zenbones.nvim",
	dependencies = { "rktjmp/lush.nvim" },
	lazy = false,
	priority = 1000,
	config = function()
		vim.o.background = "light"
		vim.g.zenbones_darken_comments = 45
		vim.cmd("colorscheme zenbones")
	end,
}
