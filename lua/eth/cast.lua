local M = {}

--- Check if cast command is available
---@return boolean
function M.is_available()
	return vim.fn.executable(require("eth.config").get_cast_cmd()) == 1
end

--- Convert private key to Ethereum address using cast
---@param privkey string The private key (with 0x prefix)
---@return string|nil address The Ethereum address or nil on error
---@return string|nil error_msg Error message if conversion failed
function M.privkey_to_address(privkey)
	if not M.is_available() then
		return nil,
			"cast command not found. Please install Foundry: https://book.getfoundry.sh/getting-started/installation"
	end

	local cast_cmd = require("eth.config").get_cast_cmd()
	local cmd = { cast_cmd, "w", "a", privkey }

	local result = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		return nil, "cast command failed: " .. result
	end

	-- Trim whitespace
	result = result:gsub("^%s*(.-)%s*$", "%1")

	return result, nil
end

--- Get balance of an Ethereum address using cast (mainnet only)
---@param address string The Ethereum address (with 0x prefix)
---@return string|nil balance The balance string or nil on error
---@return string|nil error_msg Error message if command failed
function M.get_balance(address)
	if not M.is_available() then
		return nil,
			"cast command not found. Please install Foundry: https://book.getfoundry.sh/getting-started/installation"
	end

	local cast_cmd = require("eth.config").get_cast_cmd()
	-- Use mainnet RPC (cast will use default mainnet RPC)
	local cmd = { cast_cmd, "balance", address }

	local result = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		return nil, "cast command failed: " .. result
	end

	-- Trim whitespace
	result = result:gsub("^%s*(.-)%s*$", "%1")

	return result, nil
end

return M
