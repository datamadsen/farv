-- Neovim theme configuration for tokyonight-night
return {
	"folke/tokyonight.nvim",
	opts = {
		day_brightness = 0.1,
		dim_inactive = true,
		on_highlights = function(hl, c)
			local x = "#FFDC00"
			hl.FlashLabel = {
				bg = c.yellow,
				fg = c.black,
				bold = true,
			}
		end,
	},
	config = function()
		vim.cmd("set background=dark")
		vim.cmd("colorscheme tokyonight-night")
	end,
}

