-- Neovim theme configuration for Kanagawa Lotus
return {
	"rebelot/kanagawa.nvim",
	config = function()
		require("kanagawa").setup({
			background = {
				light = "lotus",
			},
		})
		vim.cmd("set background=light")
		vim.cmd("colorscheme kanagawa")
	end,
}
