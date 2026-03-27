-- Neovim theme configuration for Tokyo Night Day
return {
	"folke/tokyonight.nvim",
	opts = {
		day_brightness = 0.1,
		dim_inactive = true,
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)
		vim.cmd("set background=light")
		vim.cmd("colorscheme tokyonight-day")
	end,
}
