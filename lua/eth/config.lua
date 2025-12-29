local M = {}

-- Default configuration
local defaults = {
	networks = {
		{ "Mainnet", "https://etherscan.io" },
		{ "Sepolia", "https://sepolia.etherscan.io" },
	},
	browser_cmd = nil, -- Auto-detect
	cast_cmd = "cast",
	
	-- Keybinding configuration
	keymaps = {
		enabled = true, -- Set to false to disable all default keybindings
		mappings = {
			print_address = "<leader>ea",
			get_balance = "<leader>egb",
			goto_address = "<leader>eba",
			goto_tx = "<leader>ebt",
		},
	},
}

-- Current configuration (merged with user config)
local config = vim.deepcopy(defaults)

-- Current network index (session-based)
local current_network_index = 1

--- Setup configuration with user options
---@param opts table|nil User configuration options
function M.setup(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("force", defaults, opts)
end

--- Get list of networks
---@return table List of {name, url} tuples
function M.get_networks()
	return config.networks
end

--- Get current network
---@return table {name, url} tuple
function M.get_current_network()
	return config.networks[current_network_index]
end

--- Set current network by index
---@param index number Network index (1-based)
function M.set_current_network(index)
	if index >= 1 and index <= #config.networks then
		current_network_index = index
	end
end

--- Get browser command (auto-detect if not configured)
---@return string Browser command
function M.get_browser_cmd()
	if config.browser_cmd then
		return config.browser_cmd
	end

	-- Auto-detect browser command
	if vim.fn.has("mac") == 1 then
		return "open"
	elseif vim.fn.has("unix") == 1 then
		return "xdg-open"
	elseif vim.fn.has("win32") == 1 then
		return "start"
	end

	return "xdg-open" -- fallback
end

--- Get cast command path
---@return string Cast command
function M.get_cast_cmd()
	return config.cast_cmd
end

--- Get keymaps configuration
---@return table Keymaps configuration
function M.get_keymaps()
	return config.keymaps
end

--- Get current options
---@return table Current configuration options
function M.get_options()
	return config
end

-- Expose options directly for convenience
M.options = config

--- Show network selection picker
function M.select_network()
	local networks = M.get_networks()
	local items = {}

	for i, net in ipairs(networks) do
		local prefix = ""
		if i == current_network_index then
			prefix = "* "
		end
		table.insert(items, string.format("%s%d. %s (%s)", prefix, i, net[1], net[2]))
	end

	vim.ui.select(items, {
		prompt = "Select Block Explorer Network:",
	}, function(choice, idx)
		if idx then
			M.set_current_network(idx)
			vim.notify("Network set to: " .. networks[idx][1], vim.log.levels.INFO)
		end
	end)
end

return M
