-- Zenbones for Greed: themes that tell code apart by contrast, bold and
-- italic rather than color, ported from zenbones.nvim. Each variant comes
-- dark as its name and light as NAME-light (`:theme zenbones-light`); one
-- with only one side goes by its name alone.
--
--     require("@theme").use("zenbones")
--
-- In the window, `zenbones-comment-font` sets comments in a family of its
-- own, like a handwritten one beside the code's:
--
--     require("@greed").option.set("zenbones-comment-font", "Monaspace Radon")

local greed = require("@greed")
local theme = require("@theme")
local recipe = require("@self/recipe")
local variants = require("@self/variants")

greed.option.define({
	name = "zenbones-comment-font",
	doc = "The family zenbones themes set comments in, in the window; empty for the code's",
	default = "",
})

local M = {}

--- The theme names this adds, sorted.
function M.names(): { string }
	local names = {}
	for name, variant in variants do
		local both = variant.light ~= nil and variant.dark ~= nil
		if variant.dark then
			table.insert(names, name)
		end
		if variant.light then
			table.insert(names, if both then `{name}-light` else name)
		end
	end
	table.sort(names)
	return names
end

-- Adds every variant's themes, with the options as they are now.
local function define()
	local options: recipe.Options = { comment_font = greed.option.get("zenbones-comment-font") :: string }
	for name, variant in variants do
		local both = variant.light ~= nil and variant.dark ~= nil
		local dark, light = variant.dark, variant.light
		if dark then
			theme.define(name, recipe.theme(dark.base, true, dark.overrides, options))
		end
		if light then
			local called = if both then `{name}-light` else name
			theme.define(called, recipe.theme(light.base, false, light.overrides, options))
		end
	end
end

define()

-- A new comment font shows at once in the zenbones theme in use.
greed.on("option.changed", function(event: greed.OptionChanged)
	if event.name ~= "zenbones-comment-font" then
		return
	end
	define()
	local current = theme.current()
	if table.find(M.names(), current) then
		theme.use(current)
	end
end)

return M
