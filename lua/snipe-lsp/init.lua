--- retrieve LSP document symbols
local function get_document_symbols()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	local symbols = vim.lsp.buf_request_sync(0, 'textDocument/documentSymbol', params, 1000)
	if not symbols or vim.tbl_isempty(symbols) then
		vim.notify('No symbols found', vim.log.levels.INFO)
		return {}
	end
	local items = {}
	for _, result in pairs(symbols) do
		for _, symbol in ipairs(result.result or {}) do
			table.insert(items, {
				name = symbol.name,
				kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown',
				range = symbol.range
			})
		end
	end
	return items
end

--- get the position of a given symbol
--- @param symbol table
--- @param buf number
--- @return table
local function get_symbol_pos(symbol, buf)
	local range = symbol.range
	local line_count = vim.api.nvim_buf_line_count(buf)
	local start_line = math.min(range.start.line + 1, line_count)
	local line_length = #vim.api.nvim_buf_get_lines(buf, start_line - 1, start_line, false)
	    [1] or 0
	local start_char = math.min(range.start.character, line_length)
	return { start_line, start_char }
end

---icons used within our display format
local kind_icons = {
	Function = "󰊕",
	Method = "󰡱",
	Struct = "󰙅",
	Class = "󰌗",
	Variable = "󰀫",
	Interface = "",
	Module = "",
}

---format a symbol for display within the menu window
---@param symbol any
---@return string
local function format_symbol_for_display(symbol)
	return string.format('%s %s', kind_icons[symbol.kind] or "-", symbol.name)
end

local Menu = require('snipe.menu')

--- add an escape keymap to the menu
--- @param menu table snipe menu instance
--- @return nil
local function add_close_keymap(menu)
	menu:add_new_buffer_callback(function(m)
		vim.keymap.set("n", "<esc>", function()
			m:close()
		end, { nowait = true, buffer = m.buf })
	end)
end

---open the symbols menu and navigate to the selected symbol
local function open_symbols_menu()
	local symbols = get_document_symbols()
	if vim.tbl_isempty(symbols) then return end

	local main_buf = vim.api.nvim_get_current_buf()
	local main_win = vim.api.nvim_get_current_win()

	local menu = Menu:new { position = "cursor", open_win_override = { title = "LSP Document Symbols" } }
	add_close_keymap(menu)

	menu:open(symbols, function(m, i)
		local pos = get_symbol_pos(symbols[i], main_buf)
		vim.api.nvim_win_set_cursor(main_win, { pos[1], pos[2] })
		m:close()
	end, format_symbol_for_display)
end

---open the symbols menu and navigate to the selected symbol in a new split/vsplit
---@param split string split or vsplit
---@return function
local function open_symbols_menu_for_split(split)
	return function()
		local symbols = get_document_symbols()
		if vim.tbl_isempty(symbols) then return end

		local main_buf = vim.api.nvim_get_current_buf()
		local menu = Menu:new { position = "cursor", open_win_override = { title = "LSP Document Symbols -> Split" } }
		add_close_keymap(menu)

		menu:open(symbols, function(m, i)
			m:close() -- quite important to close the menu before opening a split

			vim.cmd(split)
			local new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, main_buf)
			-- Get the position of the symbol
			local pos = get_symbol_pos(symbols[i], main_buf)

			-- Set the cursor in the new window
			vim.api.nvim_win_set_cursor(new_win, { pos[1], pos[2] })
			vim.api.nvim_set_current_win(new_win)
		end, format_symbol_for_display)
	end
end

return {

	--- Setup the plugin
	--- @param config table
	--- @return nil
	setup = function(config)
		-- merge config with default keymap
		config = vim.tbl_deep_extend('force', {
			keymap = {
				open_symbols_menu = '<leader>ds',
				open_symbols_menu_for_split = '<leader>sds',
				open_symbols_menu_for_vsplit = '<leader>vds',
			},
		}, config or {})

		-- Keymap to open the symbols menu and navigate
		 vim.keymap.set('n', config.keymap.open_symbols_menu, open_symbols_menu, { desc = 'Navigate LSP Symbols' })
		 vim.keymap.set('n', config.keymap.open_symbols_menu_for_split, open_symbols_menu_for_split("split"),
			{ desc = 'Navigate LSP Symbols and open in a split pane' })
		 vim.keymap.set('n', config.keymap.open_symbols_menu_for_vsplit, open_symbols_menu_for_split("vsplit"),
			{ desc = 'Navigate LSP Symbols and open in a vertical split pane' })

		-- register the commands
		vim.api.nvim_create_user_command('SnipeLspSymbols', open_symbols_menu, { nargs = 0 })
		vim.api.nvim_create_user_command('SnipeLspSymbolsSplit', open_symbols_menu_for_split("split"), { nargs = 0 })
		vim.api.nvim_create_user_command('SnipeLspSymbolsVSplit', open_symbols_menu_for_split("vsplit"),
			{ nargs = 0 })
	end
}
