-- Neovim theme configuration for Kanagawa
return {
	"rebelot/kanagawa.nvim",
	opts = {
		compile = false,
		undercurl = true,
		commentStyle = { italic = true },
		functionStyle = {},
		keywordStyle = { italic = true },
		statementStyle = { bold = true },
		typeStyle = {},
		transparent = false,
		dimInactive = true,
		terminalColors = true,
		colors = {
			theme = {
				all = {
					ui = {
						bg_gutter = "none"
					}
				}
			}
		},
	},
	config = function(_, opts)
		require("kanagawa").setup(opts)
		vim.cmd("set background=dark")
		vim.cmd("colorscheme kanagawa")
	end,
}
