local M = {}

--- Setup eth.nvim plugin
---@param opts table|nil User configuration options
function M.setup(opts)
  -- Setup configuration
  require("eth.config").setup(opts)
  
  local config = require("eth.config")
  local commands = require("eth.commands")

  -- Set up keybindings only if enabled
  local keymaps = config.get_keymaps()
  if keymaps.enabled then
    local mappings = keymaps.mappings
    
    vim.keymap.set("n", mappings.print_address, commands.print_address, 
      { desc = "eth: print address from privkey" })
    vim.keymap.set("n", mappings.get_balance, commands.get_balance, 
      { desc = "eth: get address balance" })
    vim.keymap.set("n", mappings.goto_address, commands.goto_address, 
      { desc = "eth: browse address in explorer" })
    vim.keymap.set("n", mappings.goto_tx, commands.goto_tx, 
      { desc = "eth: browse tx in explorer" })
  end

  -- User commands
  vim.api.nvim_create_user_command("EthSelectNetwork", require("eth.config").select_network, {})
end

return M
