Zenbones for [Greed](https://greed.rs): themes that tell code apart by
contrast, bold and italic instead of a rainbow of colors. A port of
[zenbones.nvim](https://github.com/zenbones-theme/zenbones.nvim), with its
colors and its recipe.

Keywords are bold, strings and comments italic, types and punctuation a
shade lighter or darker than the text. Since that's mostly bold and italic,
it looks the same in a terminal as in Greed's window.

## Install

In your `init.luau`:

```luau
require("@git-plugins").use("https://github.com/johnae/greed-zenbones")
require("@theme").use("zenbones")
```

Greed fetches it in the background the first time, pins it in
`plugins.lock` next to your config, and `:plugins-update` moves it on.
`:theme` lists the variants to try.

## The variants

Each comes dark as its name and light as `NAME-light`, like
`zenbones-light`. Those with only one side go by the name alone.

| Theme | |
|---|---|
| `zenbones` | The original |
| `zenwritten` | No hue at all in the text and background |
| `neobones` | Inspired by neovim.io |
| `vimbones` | Inspired by vim.org, light only |
| `rosebones` | Inspired by Rosé Pine |
| `forestbones` | Inspired by Everforest |
| `nordbones` | Inspired by Nord, dark only |
| `tokyobones` | Inspired by Tokyo Night |
| `seoulbones` | Inspired by Seoul256 |
| `duckbones` | Inspired by Spaceduck, dark only |
| `zenburned` | Inspired by Zenburn, dark only |
| `kanagawabones` | Inspired by Kanagawa, dark only |

## Comments in another font

In Greed's window, comments can go in a family of their own. Families made
to share a grid work best, like Monaspace's: a handwritten Radon beside
Neon for the code.

```luau
require("@greed").option.set("zenbones-comment-font", "Monaspace Radon")
require("@greed").option.set("gui-font", "Monaspace Neon")
```

The terminal keeps comments italic, as always.

## Working on it

`greed test .` runs the tests. Colors are worked out in HSLuv, as zenbones
does (`hsluv.luau`); `recipe.luau` turns a variant's few colors into a
theme, and `variants.luau` has each variant.

MIT, like zenbones. Thanks to Michael Chris Lopez for zenbones itself.
