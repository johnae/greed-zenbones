-- The zenbones family, as zenbones.nvim has it: each variant's colors on a
-- light and a dark background, and the groups it colors its own way.

local recipe = require("./recipe")

local hsluv, hex = recipe.hsluv, recipe.hex
local li, da, de, sa = recipe.li, recipe.da, recipe.de, recipe.sa

--- A variant on one background: its colors and its changes to the recipe.
export type Side = { base: recipe.Base, overrides: recipe.Overrides? }

--- A variant: what it's like, and its light and dark sides, either of
--- which it may not have.
export type Variant = { doc: string, light: Side?, dark: Side? }

local nord = {
	nord0 = hex("#2e3440"),
	nord6 = hex("#eceff4"),
	nord7 = hex("#8fbcbb"),
	nord8 = hex("#88c0d0"),
	nord9 = hex("#81a1c1"),
	nord10 = hex("#5e81ac"),
	nord11 = hex("#bf616a"),
	nord12 = hex("#d08770"),
	nord14 = hex("#a3be8c"),
	nord15 = hex("#b48ead"),
}

local vim = hsluv(131.8, 92, 51)

local rose_light: recipe.Base = {
	bg = hsluv(57.9, 49.8, 96.5),
	fg = hsluv(14.5, 32, 34),
	rose = hsluv(355.6, 38.5, 51.9),
	leaf = hsluv(228.3, 84.5, 41.5),
	wood = hsluv(45.4, 90.6, 70.8),
	water = hsluv(208.6, 65.3, 57.7),
	blossom = hsluv(283.8, 30.2, 54.8),
	sky = hsluv(208.6, 65.3, 57.7),
	text = hsluv(270.1, 22.9, 36.8),
}
local rose_dark: recipe.Base = {
	bg = hsluv(271.2, 20.2, 8.5),
	fg = hsluv(14.8, 23, 86),
	rose = hsluv(357.2, 75.7, 62.6),
	leaf = hsluv(227.7, 81.8, 45.8),
	wood = hsluv(53.2, 78.8, 81.3),
	water = hsluv(206.7, 42.9, 80),
	blossom = hsluv(283.1, 67.3, 73),
	sky = hsluv(206.7, 42.9, 80),
	text = hsluv(269.4, 56, 89.2),
}

local forest_light: recipe.Base = {
	bg = hsluv(72, 52, 96),
	fg = hsluv(226.3, 24.8, 38),
	rose = hsluv(12.7, 90.9, 59),
	leaf = hsluv(96.6, 99.9, 62.6),
	wood = hsluv(53.5, 100, 70.1),
	water = hsluv(236.1, 86.1, 58.1),
	blossom = hsluv(327.8, 67, 61.1),
	sky = hsluv(151.6, 87.3, 61.5),
}
local forest_dark: recipe.Base = {
	bg = hsluv(232.6, 27, 20.7),
	fg = hsluv(67.1, 26.4, 88),
	rose = hsluv(11.3, 67.5, 64.4),
	leaf = hsluv(105.4, 50.2, 74.5),
	wood = hsluv(62.2, 55.8, 77.6),
	water = hsluv(179.5, 51, 71.8),
	blossom = hsluv(339.1, 46.7, 69.8),
	sky = hsluv(136.1, 45.8, 72.6),
}

local tokyo_light: recipe.Base = {
	bg = hex("#d5d6db"),
	fg = hex("#343b58"),
	rose = hex("#8c4351"),
	leaf = hex("#33635c"),
	wood = hex("#8f5e15"),
	water = hex("#34548a"),
	blossom = hex("#5a4a78"),
	sky = hex("#166775"),
}
local tokyo_dark: recipe.Base = {
	bg = hex("#1a1b26"),
	fg = hex("#c0caf5"),
	rose = hex("#f7768e"),
	leaf = hex("#73daca"),
	wood = hex("#e0af68"),
	water = hex("#7aa2f7"),
	blossom = hex("#bb9af7"),
	sky = hex("#2ac3de"),
}
local function tokyo(p: { [string]: any }): recipe.Overrides
	return {
		Statement = { fg = p.blossom, bold = true },
		Keyword = { fg = p.blossom, italic = true },
		Number = { fg = p.sky },
		PreProc = { fg = p.blossom },
		Special = { fg = p.water },
	}
end

local seoul_light: recipe.Base = {
	bg = hex("#e1e1e1"),
	fg = da(hex("#616161"), 12),
	rose = da(hex("#e17899"), 12),
	leaf = da(hex("#719872"), 12),
	wood = da(hex("#e19972"), 12),
	water = da(hex("#0099bd"), 12),
	blossom = da(hex("#9a7599"), 12),
	sky = da(hex("#009799"), 12),
	orange = da(hex("#9a7200"), 12),
}
local seoul_dark: recipe.Base = {
	bg = hex("#4b4b4b"),
	fg = li(hex("#d9d9d9"), 10),
	rose = li(hex("#e17899"), 12),
	leaf = hex("#98bc99"),
	wood = hex("#ffde99"),
	water = hex("#98bede"),
	blossom = li(hex("#999abd"), 10),
	sky = hex("#6fbcbd"),
	orange = hex("#e19972"),
}

local M: { [string]: Variant } = {
	zenbones = {
		doc = "Contrast, not color: the original",
		light = { base = { bg = hsluv(39, 12, 94), fg = hsluv(230, 30, 22) } },
		dark = { base = { bg = hsluv(39, 12, 9), fg = hsluv(230, 10, 76) } },
	},
	zenwritten = {
		doc = "Zenbones with no hue in the text and background",
		light = { base = { bg = hsluv(0, 0, 94), fg = hsluv(0, 0, 22) } },
		dark = { base = { bg = hsluv(0, 0, 9), fg = hsluv(0, 0, 76) } },
	},
	neobones = {
		doc = "Inspired by neovim.io",
		light = {
			base = {
				bg = hex("#e7eee8"),
				fg = hex("#202e18"),
				leaf = li(sa(hsluv(112, 72, 42), 24), 8),
			},
		},
		dark = {
			base = {
				bg = hex("#0f191f"),
				fg = hex("#c7d6d0"),
				leaf = hex("#8fff6d"),
				water = hex("#8190d4"),
			},
		},
	},
	vimbones = {
		doc = "Inspired by vim.org",
		light = {
			base = { bg = hsluv(85.9, 27, 94), fg = hsluv(0, 0, 22) },
			overrides = {
				Number = { fg = da(de(vim, 20), 26), italic = true },
				Statement = { fg = da(vim, 24), bold = true },
				PreProc = { fg = da(de(vim, 31), 24) },
			},
		},
	},
	rosebones = {
		doc = "Inspired by Rosé Pine",
		light = {
			base = rose_light,
			overrides = {
				Statement = { fg = rose_light.leaf },
				Special = { fg = rose_light.water },
				Type = { fg = rose_light.text },
			},
		},
		dark = {
			base = rose_dark,
			overrides = {
				Statement = { fg = rose_dark.leaf },
				Special = { fg = rose_dark.water },
				Type = { fg = rose_dark.text },
			},
		},
	},
	forestbones = {
		doc = "Inspired by Everforest",
		light = {
			base = forest_light,
			overrides = {
				Statement = { fg = forest_light.leaf, bold = true },
				PreProc = { fg = forest_light.sky },
				Type = { fg = forest_light.water },
			},
		},
		dark = {
			base = forest_dark,
			overrides = {
				Statement = { fg = forest_dark.leaf, bold = true },
				PreProc = { fg = forest_dark.sky },
				Type = { fg = forest_dark.water },
			},
		},
	},
	nordbones = {
		doc = "Inspired by Nord",
		dark = {
			base = {
				bg = nord.nord0,
				fg = nord.nord6,
				rose = nord.nord11,
				leaf = nord.nord14,
				wood = nord.nord12,
				water = nord.nord7,
				blossom = nord.nord15,
				sky = nord.nord8,
			},
			overrides = {
				Number = { fg = nord.nord7, italic = true },
				Identifier = { fg = nord.nord6 },
				Function = { fg = nord.nord8 },
				Statement = { fg = nord.nord9 },
				Type = { fg = nord.nord10 },
			},
		},
	},
	tokyobones = {
		doc = "Inspired by Tokyo Night",
		light = { base = tokyo_light, overrides = tokyo(tokyo_light) },
		dark = { base = tokyo_dark, overrides = tokyo(tokyo_dark) },
	},
	seoulbones = {
		doc = "Inspired by Seoul256",
		light = {
			base = seoul_light,
			overrides = {
				Comment = { fg = seoul_light.leaf, keep = true },
				Statement = { fg = seoul_light.water, keep = true },
				Keyword = { fg = de(seoul_light.rose, 25), bold = true },
				PreProc = { fg = de(seoul_light.rose, 40) },
				Identifier = { fg = seoul_light.fg },
				Function = { fg = da(de(hex("#727100"), 12), 5) },
				Special = { fg = da(de(seoul_light.blossom, 30), 10) },
				Number = { fg = seoul_light.orange, keep = true },
				String = { fg = da(de(seoul_light.water, 40), 8), keep = true },
			},
		},
		dark = {
			base = seoul_dark,
			overrides = {
				Comment = { fg = hex("#719872"), keep = true },
				Statement = { fg = seoul_dark.water, keep = true },
				Keyword = { fg = de(seoul_dark.rose, 12), bold = true },
				PreProc = { fg = de(seoul_dark.rose, 25) },
				Identifier = { fg = seoul_dark.fg },
				Function = { fg = de(hex("#dfdebd"), 12) },
				Special = { fg = li(seoul_dark.blossom, 26) },
				Number = { fg = de(seoul_dark.wood, 30), keep = true },
				String = { fg = li(de(seoul_dark.water, 20), 10), keep = true },
			},
		},
	},
	duckbones = {
		doc = "Inspired by Spaceduck",
		dark = {
			base = {
				bg = hex("#0f111b"),
				fg = hex("#ecf0c1"),
				rose = hex("#e33400"),
				leaf = hex("#5ccc96"),
				wood = hex("#e39400"),
				water = hex("#00a3cc"),
				blossom = hex("#7a5ccc"),
				sky = hex("#00a3cc"),
			},
			overrides = {
				Statement = { fg = hex("#7a5ccc"), keep = true },
				Special = { fg = hex("#5ccc96") },
				PreProc = { fg = hex("#00a3cc") },
			},
		},
	},
	zenburned = {
		doc = "Inspired by Zenburn",
		dark = {
			base = {
				bg = hex("#3f3f3f"),
				fg = li(de(hex("#efdcbc"), 14), 20),
				rose = hex("#e37170"),
			},
			overrides = {
				Statement = { fg = hex("#dca3a3"), keep = true },
				Special = { fg = hex("#efef8f") },
				PreProc = { fg = hex("#ffcfaf") },
			},
		},
	},
	kanagawabones = {
		doc = "Inspired by Kanagawa",
		dark = {
			base = {
				bg = hex("#1f1f28"),
				fg = hex("#dcd7ba"),
				leaf = hex("#98bb6c"),
				water = hex("#7fb4ca"),
				rose = hex("#e46876"),
				wood = hex("#e6c384"),
				blossom = hex("#957fb8"),
				sky = hex("#7fb4ca"),
			},
		},
	},
}

return M
