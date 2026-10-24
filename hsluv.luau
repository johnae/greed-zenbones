-- HSLuv: hue, saturation and lightness as people see them, which zenbones
-- picks its colors in. Ported from the reference implementation at
-- hsluv.org (MIT), only what turning colors to and from `#rrggbb` needs.

--- A color as HSLuv: hue in degrees, saturation and lightness out of 100.
export type Hsluv = { h: number, s: number, l: number }

local M = {}

local m = {
	{ 3.240969941904521, -1.537383177570093, -0.498610760293 },
	{ -0.96924363628087, 1.87596750150772, 0.041555057407175 },
	{ 0.055630079696993, -0.20397695888897, 1.056971514242878 },
}
local minv = {
	{ 0.41239079926595, 0.35758433938387, 0.18048078840183 },
	{ 0.21263900587151, 0.71516867876775, 0.072192315360733 },
	{ 0.019330818715591, 0.11919477979462, 0.95053215224966 },
}
local ref_u = 0.19783000664283
local ref_v = 0.46831999493879
local kappa = 903.2962962
local epsilon = 0.0088564516

-- The edges of what sRGB can show at lightness `l`, as lines.
local function bounds(l: number): { { slope: number, intercept: number } }
	local out = {}
	local sub1 = ((l + 16) ^ 3) / 1560896
	local sub2 = if sub1 > epsilon then sub1 else l / kappa
	for c = 1, 3 do
		local m1, m2, m3 = m[c][1], m[c][2], m[c][3]
		for t = 0, 1 do
			local top1 = (284517 * m1 - 94839 * m3) * sub2
			local top2 = (838422 * m3 + 769860 * m2 + 731718 * m1) * l * sub2 - 769860 * t * l
			local bottom = (632260 * m3 - 126452 * m2) * sub2 + 126452 * t
			table.insert(out, { slope = top1 / bottom, intercept = top2 / bottom })
		end
	end
	return out
end

-- The most chroma sRGB has at lightness `l` and hue `h`.
local function max_chroma(l: number, h: number): number
	local radians = math.rad(h)
	local most = math.huge
	for _, line in bounds(l) do
		local length = line.intercept / (math.sin(radians) - line.slope * math.cos(radians))
		if length >= 0 then
			most = math.min(most, length)
		end
	end
	return most
end

local function from_linear(c: number): number
	return if c <= 0.0031308 then 12.92 * c else 1.055 * c ^ (1 / 2.4) - 0.055
end

local function to_linear(c: number): number
	return if c > 0.04045 then ((c + 0.055) / 1.055) ^ 2.4 else c / 12.92
end

--- `#rrggbb` for `color`.
function M.hex(color: Hsluv): string
	local h, s, l = color.h, math.clamp(color.s, 0, 100), math.clamp(color.l, 0, 100)
	local c = if l > 99.9999999 or l < 0.00000001 then 0 else max_chroma(l, h) / 100 * s
	local u, v = c * math.cos(math.rad(h)), c * math.sin(math.rad(h))
	local x, y, z = 0, 0, 0
	if l > 0 then
		local var_u, var_v = u / (13 * l) + ref_u, v / (13 * l) + ref_v
		y = if l <= 8 then l / kappa else ((l + 16) / 116) ^ 3
		x = -(9 * y * var_u) / ((var_u - 4) * var_v - var_u * var_v)
		z = (9 * y - 15 * var_v * y - var_v * x) / (3 * var_v)
	end
	local out = {}
	for i = 1, 3 do
		local linear = m[i][1] * x + m[i][2] * y + m[i][3] * z
		local channel = math.clamp(from_linear(linear), 0, 1)
		out[i] = string.format("%02x", math.floor(channel * 255 + 0.5))
	end
	return "#" .. table.concat(out)
end

--- The color `#rrggbb` as HSLuv.
function M.of(hex: string): Hsluv
	local r, g, b = string.match(hex, "^#(%x%x)(%x%x)(%x%x)$")
	assert(r and g and b, `{hex} isn't a #rrggbb color`)
	local rgb = {
		to_linear((tonumber(r, 16) :: number) / 255),
		to_linear((tonumber(g, 16) :: number) / 255),
		to_linear((tonumber(b, 16) :: number) / 255),
	}
	local xyz = {}
	for i = 1, 3 do
		xyz[i] = minv[i][1] * rgb[1] + minv[i][2] * rgb[2] + minv[i][3] * rgb[3]
	end
	local x, y, z = xyz[1], xyz[2], xyz[3]
	local l = if y <= epsilon then y * kappa else 116 * y ^ (1 / 3) - 16
	if l < 0.00000001 then
		return { h = 0, s = 0, l = 0 }
	end
	local divider = x + 15 * y + 3 * z
	local u = 13 * l * (4 * x / divider - ref_u)
	local v = 13 * l * (9 * y / divider - ref_v)
	local c = math.sqrt(u * u + v * v)
	local h = if c < 0.00000001 then 0 else math.deg(math.atan2(v, u)) % 360
	if l > 99.9999999 then
		return { h = h, s = 0, l = 100 }
	end
	return { h = h, s = c / max_chroma(l, h) * 100, l = l }
end

return M
