local M = {}
-- credit goes out to: https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua

M.center = function(str)
	local width = vim.api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(" ", shift) .. str
end

M.set_header = function(buf, header)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)

	local underline = ""
	for _ = 1, vim.fn.len(header) do
		underline = "-" .. underline
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		M.center(header),
		M.center(underline),
		M.center(""),
	})

	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

M.set_content = function(buf, top_offset, content)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	vim.api.nvim_buf_set_lines(buf, top_offset, -1, false, content)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

M.open_window = function()
	-- get dimensions
	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	-- calculate our floating window size
	local win_height = math.ceil(height * 0.5 - 4)
	local win_width = math.ceil(width * 0.5)

	-- and its starting position
	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local border_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1,
	}

	local border_lines = { "╔" .. string.rep("═", win_width) .. "╗" }
	local middle_line = "║" .. string.rep(" ", win_width) .. "║"
	for i = 1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, "╚" .. string.rep("═", win_width) .. "╝")

	local buf = vim.api.nvim_create_buf(false, true) -- create new emtpy buffer

	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- set some options
	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	-- set bufer's (border_buf) lines from first line (0) to last (-1)
	-- ignoring out-of-bounds error (false) with lines (border_lines)
	local border_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
	local border_win = vim.api.nvim_open_win(border_buf, true, border_opts)
	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

	return buf, win
end

M.set_mappings = function(buf)
	local mappings = {
		["<cr>"] = "open_host()",
		j = "move_cursor(-1)",
		h = "move_cursor(-1)",
		k = "move_cursor(1)",
		l = "move_cursor(1)",
		q = "close_window()",
	}

	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, "n", k, ':lua require"sshfs".' .. v .. "<cr>", {
			nowait = true,
			noremap = true,
			silent = true,
		})
	end
end

return M
