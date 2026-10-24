local test = require("@greed/test")
local greed = require("@greed")
local theme = require("@theme")
local zenbones = require("@zenbones")
local hsluv = require("../hsluv")

test("HSLuv turns colors to #rrggbb and back", function()
	assert(hsluv.hex({ h = 0, s = 0, l = 50 }) == "#777777", hsluv.hex({ h = 0, s = 0, l = 50 }))
	assert(hsluv.hex({ h = 0, s = 0, l = 100 }) == "#ffffff")
	assert(hsluv.hex({ h = 0, s = 0, l = 0 }) == "#000000")
	for _, color in { "#2e3440", "#bf616a", "#a3be8c", "#e7eee8", "#0f111b" } do
		assert(hsluv.hex(hsluv.of(color)) == color, `{color} came back as {hsluv.hex(hsluv.of(color))}`)
	end
	local red = hsluv.of("#ff0000")
	assert(math.abs(red.h - 12.177) < 0.01 and math.abs(red.s - 100) < 0.01, `{red.h} {red.s}`)
end)

test("each variant is a dark theme by its name and a light one, unless it has only one", function()
	local names = theme.list()
	for _, name in { "zenbones", "zenbones-light", "zenwritten-light", "nordbones", "vimbones", "kanagawabones" } do
		assert(table.find(names, name), `{name} is missing`)
	end
	assert(not table.find(names, "nordbones-light"), "nordbones is dark only")
	assert(not table.find(names, "vimbones-light"), "vimbones is light only, as vimbones")
	assert(#zenbones.names() == 19, tostring(#zenbones.names()))
end)

test("code stands apart by bold and italic, which a terminal shows too", function()
	theme.use("zenbones")
	local keyword, str, comment = greed.theme.get("keyword"), greed.theme.get("string"), greed.theme.get("comment")
	assert(keyword and keyword.bold, "keywords are bold")
	assert(str and str.italic, "strings are italic")
	assert(comment and comment.italic, "comments are italic")
	local fn = greed.theme.get("function")
	assert(fn and not fn.bold and not fn.italic, "functions are plain")
	-- Zenwritten's text has no hue at all.
	theme.use("zenwritten")
	local text = greed.theme.get("ui.text")
	local r, g, b = string.match(text and text.fg or "", "^#(%x%x)(%x%x)(%x%x)$")
	assert(r and r == g and g == b, text and text.fg)
	-- Nordbones colors its keywords instead of making them bold.
	theme.use("nordbones")
	keyword = greed.theme.get("keyword")
	assert(keyword and not keyword.bold and keyword.fg == "#81a1c1", keyword and keyword.fg)
	theme.use("default")
end)

test("comments go in a family of their own in the window, and stay italic in a terminal", function()
	theme.use("zenbones-light")
	greed.option.set("zenbones-comment-font", "Monaspace Radon")
	local comment = greed.theme.get("comment")
	assert(comment and comment.italic, "still italic")
	local gui = comment and comment.gui
	assert(gui and gui.font == "Monaspace Radon", "in the window")
	greed.option.set("zenbones-comment-font", "")
	comment = greed.theme.get("comment")
	assert(comment and (comment.gui == nil or comment.gui.font == nil), "and back to the code's")
	theme.use("default")
end)
