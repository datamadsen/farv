-- Neovim theme configuration for osaka-jade
return {
	"ribru17/bamboo.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("bamboo").setup({})
		require("bamboo").load()
	end,
}
