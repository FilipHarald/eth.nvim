local M = {}

local utils = require("eth.utils")
local cast = require("eth.cast")
local explorer = require("eth.explorer")

--- Print address from private key under cursor
function M.print_address()
	local hex = utils.get_hex_under_cursor()

	if not hex then
		vim.notify("No hex string found under cursor", vim.log.levels.ERROR)
		return
	end

	if not utils.is_private_key(hex) then
		vim.notify("Invalid private key format. Expected: 0x followed by 64 hexadecimal characters", vim.log.levels.ERROR)
		return
	end

	local address, err = cast.privkey_to_address(hex)
	if err then
		vim.notify(err, vim.log.levels.ERROR)
		return
	end

	vim.notify("Address: " .. address, vim.log.levels.INFO)
end

--- Go to address in block explorer (current network)
--- Converts private key to address if needed
function M.goto_address()
	local hex = utils.get_hex_under_cursor()

	if not hex then
		vim.notify("No hex string found under cursor", vim.log.levels.ERROR)
		return
	end

	local hex_type = utils.detect_type(hex)
	local address

	if hex_type == "privkey" then
		-- Could be privkey, try to convert
		if utils.is_private_key(hex) then
			local err
			address, err = cast.privkey_to_address(hex)
			if err then
				vim.notify(err, vim.log.levels.ERROR)
				return
			end
		else
			-- It's a tx hash (64 chars), not a valid input for address
			vim.notify(
				"Invalid input. Expected address (40 hex chars) or private key (64 hex chars)",
				vim.log.levels.ERROR
			)
			return
		end
	elseif hex_type == "address" then
		address = hex
	else
		vim.notify("Invalid address format. Expected: 0x followed by 40 hexadecimal characters", vim.log.levels.ERROR)
		return
	end

	explorer.open_address(address)
end

--- Go to transaction in block explorer (current network)
function M.goto_tx()
	local hex = utils.get_hex_under_cursor()

	if not hex then
		vim.notify("No hex string found under cursor", vim.log.levels.ERROR)
		return
	end

	if not utils.is_tx_hash(hex) then
		vim.notify(
			"Invalid transaction hash format. Expected: 0x followed by 64 hexadecimal characters",
			vim.log.levels.ERROR
		)
		return
	end

	explorer.open_tx(hex)
end

--- Get balance of address (mainnet only)
--- Converts private key to address if needed
function M.get_balance()
	local hex = utils.get_hex_under_cursor()

	if not hex then
		vim.notify("No hex string found under cursor", vim.log.levels.ERROR)
		return
	end

	local hex_type = utils.detect_type(hex)
	local address

	if hex_type == "privkey" then
		-- Could be privkey, try to convert
		if utils.is_private_key(hex) then
			local err
			address, err = cast.privkey_to_address(hex)
			if err then
				vim.notify(err, vim.log.levels.ERROR)
				return
			end
		else
			-- It's a tx hash (64 chars), not a valid input for balance
			vim.notify(
				"Invalid input. Expected address (40 hex chars) or private key (64 hex chars)",
				vim.log.levels.ERROR
			)
			return
		end
	elseif hex_type == "address" then
		address = hex
	else
		vim.notify("Invalid address format. Expected: 0x followed by 40 hexadecimal characters", vim.log.levels.ERROR)
		return
	end

	local balance, err = cast.get_balance(address)
	if err then
		vim.notify(err, vim.log.levels.ERROR)
		return
	end

	vim.notify("Balance: " .. balance, vim.log.levels.INFO)
end

return M
