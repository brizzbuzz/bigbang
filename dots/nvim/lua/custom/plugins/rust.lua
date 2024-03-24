return {
	{
		"mrcjkb/rustaceanvim",
		version = "^4", -- Recommended
		ft = { "rust" },
	},
	{
		"saecki/crates.nvim",
		-- To lazy load only when entering Cargo.toml
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup()
		end,
	},
}
