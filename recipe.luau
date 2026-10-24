-- How zenbones makes a whole theme from a few colors: the text and the
-- background, and six hues it uses sparingly. Syntax stands apart by how
-- light it is and by bold and italic rather than by color, so it reads the
-- same in any terminal. Ported from zenbones.nvim's specs (MIT, Michael
-- Chris Lopez): the numbers are its own.

local hsluv = require("./hsluv")

type Hsluv = hsluv.Hsluv

--- A variant's colors by name: `bg` and `fg`, which it must have, any of
--- the hues (rose, leaf, wood, water, blossom, sky) it changes, and any it
--- adds for its own groups.
export type Base = { [string]: Hsluv }

--- A highlight group as zenbones has them: its color, and bold or italic.
--- With `keep`, it starts from the group as the recipe made it.
export type Group = { fg: Hsluv?, bold: boolean?, italic: boolean?, keep: boolean? }

--- The changes a variant makes to the recipe's groups.
export type Overrides = { [string]: Group }

--- What to change from zenbones' defaults: comments in another font in
--- the window.
export type Options = { comment_font: string? }

local M = {}

-- Lush's steps, each a new color: relative, a share of the way to the end,
-- or absolute.
local function step(c: Hsluv, s: number?, l: number?): Hsluv
	return { h = c.h, s = math.clamp(s or c.s, 0, 100), l = math.clamp(l or c.l, 0, 100) }
end
local function li(c: Hsluv, n: number): Hsluv
	return step(c, nil, c.l + (100 - c.l) * n / 100)
end
local function da(c: Hsluv, n: number): Hsluv
	return step(c, nil, c.l - c.l * n / 100)
end
local function sa(c: Hsluv, n: number): Hsluv
	return step(c, c.s + (100 - c.s) * n / 100)
end
local function de(c: Hsluv, n: number): Hsluv
	return step(c, c.s - c.s * n / 100)
end

M.li, M.da, M.sa, M.de = li, da, sa, de

--- `h`, `s`, `l`, as a color.
function M.hsluv(h: number, s: number, l: number): Hsluv
	return { h = h, s = s, l = l }
end

--- The color `#rrggbb`.
M.hex = hsluv.of

-- The hues zenbones falls back on, light and dark.
local DEFAULTS: { [string]: { [string]: Hsluv } } = {
	light = {
		leaf = M.hsluv(112, 72, 42),
		water = M.hsluv(236, 84, 40),
		rose = M.hsluv(4, 70, 40),
		wood = M.hsluv(26, 80, 40),
		blossom = M.hsluv(318, 42, 42),
		sky = M.hsluv(204, 80, 53),
	},
	dark = {
		rose = M.hsluv(6, 62, 60),
		leaf = M.hsluv(111, 47, 61),
		wood = M.hsluv(32, 47, 58),
		water = M.hsluv(236, 64, 61),
		blossom = M.hsluv(318, 32, 58),
		sky = M.hsluv(204, 61, 64),
	},
}

-- One way or the other from the background: lighter on a dark one.
local function away(dark: boolean, c: Hsluv, n: number): Hsluv
	return if dark then li(c, n) else da(c, n)
end

--- The groups for `base` on a light or `dark` background, with what a
--- variant `overrides`, and the colors the rest of a theme needs.
function M.groups(base: Base, dark: boolean, overrides: Overrides?): ({ [string]: Group }, { [string]: Hsluv })
	local defaults = DEFAULTS[if dark then "dark" else "light"]
	local p: { [string]: Hsluv } = table.clone(defaults)
	for name, color in base do
		p[name] = color
	end
	local bg, fg = p.bg, p.fg
	assert(bg and fg, "a zenbones variant needs bg and fg")
	local function fgn(n: number): Hsluv
		local by = ({ 10, 14, 20, 24, 30, 42 })[n]
		local light = ({ 11, 15, 22, 25, 31, 42 })[n]
		return if dark then da(fg, by) else li(fg, light)
	end
	local c = {
		bg = bg,
		fg = fg,
		comment = if dark then de(li(bg, 38), 24) else de(da(bg, 38), 28),
		gutter = away(dark, bg, if dark then 35 else 33),
		float = away(dark, bg, if dark then 10 else 8),
		menu = away(dark, bg, if dark then 22 else 20),
		status = away(dark, bg, 12),
		border = away(dark, bg, if dark then 46 else 50),
		nontext = away(dark, bg, if dark then 30 else 25),
		selection = if dark then step(de(fg, 18), nil, bg.l + 18) else step(fg, nil, bg.l - 8),
		search = step(p.blossom, nil, bg.l + (if dark then 24 else -15)),
		type = if dark then li(bg, 58) else da(sa(bg, 20), 60),
		delimiter = away(dark, bg, if dark then 47 else 42),
		rose = p.rose,
		leaf = p.leaf,
		wood = p.wood,
		water = p.water,
		blossom = p.blossom,
		sky = p.sky,
	}
	local groups: { [string]: Group } = {
		Comment = { fg = c.comment, italic = true },
		Constant = { fg = fgn(4), italic = true },
		String = { fg = fgn(4), italic = true },
		Number = { fg = fgn(4) },
		Boolean = { fg = fg, italic = true },
		Identifier = { fg = fgn(2) },
		Function = { fg = fg },
		Statement = { fg = fg, bold = true },
		Type = { fg = c.type },
		Special = { fg = fgn(3), bold = true },
		Delimiter = { fg = c.delimiter },
		Title = { fg = fg, bold = true },
	}
	local changes = overrides or {}
	for name, group in changes do
		local from: Group = if group.keep then groups[name] or {} else {}
		groups[name] = {
			fg = group.fg or from.fg,
			bold = if group.bold ~= nil then group.bold else from.bold,
			italic = if group.italic ~= nil then group.italic else from.italic,
		}
	end
	-- These follow Statement, as changed, unless a variant sets them.
	for _, name in { "Keyword", "PreProc" } do
		if changes[name] == nil then
			groups[name] = groups.Statement
		end
	end
	return groups, c
end

-- A group as a style.
local function style(group: Group): { [string]: any }
	return {
		fg = if group.fg then hsluv.hex(group.fg) else nil,
		bold = group.bold or nil,
		italic = group.italic or nil,
	}
end

--- The theme for `base` on a light or `dark` background, with a variant's
--- `overrides`: a palette for Greed's own parts and styles for the syntax,
--- as `require("@theme").define` takes them.
function M.theme(base: Base, dark: boolean, overrides: Overrides?, options: Options?): { palette: any, styles: any }
	local g, c = M.groups(base, dark, overrides)
	local hex = hsluv.hex
	local palette = {
		bg = hex(c.bg),
		bg_alt = hex(c.float),
		bg_high = hex(c.menu),
		selection = hex(c.selection),
		fg = hex(c.fg),
		comment = hex(c.comment),
		gutter = hex(c.gutter),
		red = hex(c.rose),
		orange = hex(c.wood),
		yellow = hex(c.wood),
		green = hex(c.leaf),
		cyan = hex(c.sky),
		blue = hex(c.water),
		purple = hex(c.blossom),
		accent = hex(c.water),
	}
	local comment = style(g.Comment)
	local font = options and options.comment_font
	if font and font ~= "" then
		comment.gui = { font = font }
	end
	local styles: { [string]: any } = {
		comment = comment,
		keyword = style(g.Keyword),
		operator = style(g.Statement),
		label = style(g.Statement),
		tag = style(g.Statement),
		attribute = style(g.PreProc),
		["function"] = style(g.Function),
		["function.macro"] = style(g.PreProc),
		["function.builtin"] = style(g.Special),
		constructor = style(g.Special),
		string = style(g.String),
		["string.special"] = style(g.Special),
		["string.regexp"] = style(g.Constant),
		constant = style(g.Constant),
		["constant.numeric"] = style(g.Number),
		["constant.builtin.boolean"] = style(g.Boolean),
		["constant.character.escape"] = style(g.Special),
		namespace = style(g.Constant),
		type = style(g.Type),
		variable = style(g.Identifier),
		["variable.builtin"] = style(g.Constant),
		punctuation = style(g.Delimiter),
		special = style(g.Special),
		["markup.heading"] = style(g.Title),
		["markup.link"] = style(g.Constant),
		["markup.link.url"] = style(g.Constant),
		["markup.link.text"] = style(g.Special),
		["markup.link.label"] = style(g.Special),
		["markup.quote"] = { fg = hex(g.Constant.fg :: Hsluv) },
		["markup.raw"] = style(g.Constant),
		["markdown.heading"] = style(g.Title),
		["markdown.heading.1"] = style(g.Title),
		["markdown.heading.2"] = style(g.Title),
		["markdown.link"] = { fg = hex(g.Constant.fg :: Hsluv), underline = true },
		["markdown.code"] = { fg = hex(g.Constant.fg :: Hsluv), bg = hex(c.float), gui = { font = "mono" } },
		["ui.search.match"] = { bg = hex(c.search), fg = hex(c.fg) },
		["ui.statusline"] = { bg = hex(c.status), fg = hex(c.fg) },
		["ui.statusline.mode"] = { bg = hex(c.fg), fg = hex(c.bg), bold = true },
		["ui.statusline.tab"] = { bg = hex(c.menu), fg = hex(c.fg) },
		["ui.tabline.active"] = { bg = hex(c.menu), fg = hex(c.fg), bold = true },
		["ui.float.border"] = { bg = hex(c.float), fg = hex(c.border) },
		["ui.indent.guide"] = { fg = hex(c.nontext) },
		["ui.ruler"] = { fg = hex(c.nontext) },
	}
	return { palette = palette, styles = styles }
end

return M
