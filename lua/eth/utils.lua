local M = {}

--- Check if a string is a valid private key (0x + 64 hex chars)
---@param str string
---@return boolean
function M.is_private_key(str)
	if not str then
		return false
	end
	if not str:match("^0x[0-9a-fA-F]+$") then
		return false
	end
	return #str == 66 -- 0x + 64 hex chars
end

--- Check if a string is a valid Ethereum address (0x + 40 hex chars)
---@param str string
---@return boolean
function M.is_address(str)
	if not str then
		return false
	end
	if not str:match("^0x[0-9a-fA-F]+$") then
		return false
	end
	return #str == 42 -- 0x + 40 hex chars
end

--- Check if a string is a valid transaction hash (0x + 64 hex chars)
---@param str string
---@return boolean
function M.is_tx_hash(str)
	if not str then
		return false
	end
	if not str:match("^0x[0-9a-fA-F]+$") then
		return false
	end
	return #str == 66 -- 0x + 64 hex chars
end

--- Detect the type of hex string
---@param str string
---@return "privkey"|"address"|"txhash"|nil
function M.detect_type(str)
	if not str then
		return nil
	end

	-- Check length after 0x prefix
	if not str:match("^0x") then
		return nil
	end

	local hex_part = str:sub(3)
	if not hex_part:match("^[0-9a-fA-F]+$") then
		return nil
	end

	local len = #hex_part
	if len == 64 then
		-- Could be either privkey or txhash, but we'll call it privkey for conversion purposes
		-- Commands will handle the distinction
		return "privkey"
	elseif len == 40 then
		return "address"
	end

	return nil
end

--- Get hex string under cursor using pattern matching
--- Finds the hex string closest to cursor position
---@return string|nil
function M.get_hex_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Convert to 1-indexed

	-- Find all hex strings in the line
	local matches = {}
	local pattern = "0x[0-9a-fA-F]+"

	local start_pos = 1
	while true do
		local match_start, match_end = line:find(pattern, start_pos)
		if not match_start then
			break
		end

		local hex_str = line:sub(match_start, match_end)
		table.insert(matches, {
			str = hex_str,
			start_pos = match_start,
			end_pos = match_end,
		})

		start_pos = match_end + 1
	end

	-- Find the match closest to cursor
	if #matches == 0 then
		-- Fallback to <cWORD>
		local word = vim.fn.expand("<cWORD>")
		if word and word:match("^0x[0-9a-fA-F]+") then
			return word
		end
		return nil
	end

	-- Find closest match
	local closest = nil
	local min_distance = math.huge

	for _, match in ipairs(matches) do
		-- Check if cursor is within the match
		if col >= match.start_pos and col <= match.end_pos then
			return match.str
		end

		-- Calculate distance to match
		local distance
		if col < match.start_pos then
			distance = match.start_pos - col
		else
			distance = col - match.end_pos
		end

		if distance < min_distance then
			min_distance = distance
			closest = match
		end
	end

	return closest and closest.str or nil
end

return M
