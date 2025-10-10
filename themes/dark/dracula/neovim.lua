-- Neovim theme configuration for Dracula
return {
	"Mofiqul/dracula.nvim",
	opts = {
		colors = {
			bg = "#282a36",
			fg = "#f8f8f2",
			selection = "#44475a",
			comment = "#6272a4",
			red = "#ff5555",
			orange = "#ffb86c",
			yellow = "#f1fa8c",
			green = "#50fa7b",
			purple = "#bd93f9",
			cyan = "#8be9fd",
			pink = "#ff79c6",
			bright_red = "#ff6e6e",
			bright_green = "#69ff94",
			bright_yellow = "#ffffa5",
			bright_blue = "#d6acff",
			bright_magenta = "#ff92df",
			bright_cyan = "#a4ffff",
			bright_white = "#ffffff",
			menu = "#21222c",
			visual = "#3e4452",
			gutter_fg = "#4b5263",
			nontext = "#3b4048",
		},
		show_end_of_buffer = true,
		transparent_bg = false,
		lualine_bg_color = "#44475a",
		italic_comment = true,
	},
	config = function(_, opts)
		require("dracula").setup(opts)
		vim.cmd("colorscheme dracula")
	end,
}
