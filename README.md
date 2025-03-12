# snipe-lsp 

snipe-lsp adds some lsp support to ["leath-dub/snipe.nvim"](https://github.com/leath-dub/snipe.nvim) by providing a way to navigate through symbols in the current buffer.

![output](https://github.com/user-attachments/assets/16e110f8-b2b8-4c9f-aa3b-79292835b23e)

## Features

- Navigate through symbols in the current buffer quickly using mnemonics.
- Open the symbols menu in the current buffer or split/vsplit the window for the result.
- Customizable keymaps for opening the symbols menu.

## Installation

Use your favorite plugin manager. For example, with here is how you can install the plugin using lazy

```lua
{
	"kungfusheep/snipe-lsp.nvim",
	event = "VeryLazy",
	dependencies = "leath-dub/snipe.nvim",
	opts = {},
},
```


## Configuration

You can configure snipe-lsp by passing a table to the setup function. Here is an example of the default configuration:

```lua
{
    keymap = {
        open_symbols_menu = '<leader>ds',
        open_symbols_menu_for_split = '<leader>sds',
        open_symbols_menu_for_vsplit = '<leader>vds',
    },
}
```

 ## Usage

You can use the default keymaps provided. The plugin provides three commands:

- `:SnipeLspSymbols` — Open the symbols menu
- `:SnipeLspSymbolsSplit` — Open the symbols menu and split the window for the result.
- `:SnipeLspSymbolsVSplit` — Open the symbols menu and vsplit the window for the result.

## Contributing

If you would like to contribute to the project, please feel free to open a pull request or an issue. 

## License

This project is licensed under the MIT [license](LICENSE).
