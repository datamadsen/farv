-- Neovim theme configuration for Zenbones Light
return {
	"mcchrish/zenbones.nvim",
	dependencies = { "rktjmp/lush.nvim" },
	config = function()
		vim.cmd("set background=light")
		vim.cmd("colorscheme zenbones")
	end,
}
