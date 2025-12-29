local M = {}

--- Open an Ethereum address in block explorer
---@param address string The Ethereum address
function M.open_address(address)
	local network = require("eth.config").get_current_network()
	local url = network[2] .. "/address/" .. address

	M.open_url(url)
end

--- Open a transaction in block explorer
---@param tx_hash string The transaction hash
function M.open_tx(tx_hash)
	local network = require("eth.config").get_current_network()
	local url = network[2] .. "/tx/" .. tx_hash

	M.open_url(url)
end

--- Open a URL in the browser
---@param url string The URL to open
function M.open_url(url)
	local browser_cmd = require("eth.config").get_browser_cmd()

	local result = vim.fn.jobstart({ browser_cmd, url }, {
		detach = true,
		on_exit = function(_, exit_code)
			if exit_code ~= 0 then
				vim.notify("Failed to open browser", vim.log.levels.ERROR)
			end
		end,
	})

	if result <= 0 then
		vim.notify("Failed to open browser", vim.log.levels.ERROR)
	end
end

return M
