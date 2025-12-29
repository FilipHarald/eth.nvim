# eth.nvim

A Neovim plugin that integrates with [Foundry's `cast`](https://book.getfoundry.sh/cast/) CLI tool for Ethereum development. Quickly convert private keys to addresses, check balances, and open block explorers directly from your editor.

## Features

- Convert private keys to Ethereum addresses
- Get address balance (mainnet)
- Open addresses and transactions in block explorers
- Session-based network switching (Mainnet, Sepolia, or custom networks)
- Smart pattern matching to find hex strings under cursor
- Auto-detects browser command based on OS

## Requirements

- Neovim >= 0.8.0
- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`cast` command must be available in PATH)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  dir = "/path/to/eth.nvim",  -- or use git URL when published
  config = function()
    require("eth").setup({
      -- Optional configuration (these are the defaults)
      networks = {
        { "Mainnet", "https://etherscan.io" },
        { "Sepolia", "https://sepolia.etherscan.io" },
      },
      browser_cmd = nil,  -- Auto-detect (xdg-open on Linux, open on macOS)
      cast_cmd = "cast",  -- Path to cast command
    })
  end,
}
```

## Usage

### Keybindings

All keybindings use the `<leader>e` prefix by default:

| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>ea` | Print Address | Convert private key under cursor to address and display |
| `<leader>egb` | Get Balance | Get and display address balance (mainnet only) |
| `<leader>eba` | Go to Address | Open address in block explorer (current network) |
| `<leader>ebt` | Go to Transaction | Open transaction in block explorer (current network) |

### Commands

- `:EthSelectNetwork` - Open a picker to select the block explorer network for the current session

### Examples

#### Convert Private Key to Address

Place your cursor on a private key and press `<leader>zca`:

```
0x0000000000000000000000000000000000000000000000000000000000000001
```

Output: `Address: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf`

#### Open Address in Block Explorer

Place your cursor on an address or private key and press `<leader>zcga`:

```
0x4838b106fce9647bdf1e7877bf73ce8b0bad5f97
```

This will open your browser to the address on the currently selected network (default: Mainnet).

If cursor is on a private key, it will first convert to an address, then open the explorer.

#### Open Transaction in Block Explorer

Place your cursor on a transaction hash and press `<leader>zcgt`:

```
0x0b18afc5253c59a459e16af0b54ceac6e3d1a5d42bc7e2beee18d2502a00a68a
```

#### Get Address Balance

Place your cursor on an address or private key and press `<leader>zcb`:

```
0x4838b106fce9647bdf1e7877bf73ce8b0bad5f97
```

Output: `Balance: 1000000000000000000` (wei)

Note: Balance check currently only works with mainnet.

#### Switch Network

Run `:EthSelectNetwork` to choose between configured networks. The selection will persist for the current Neovim session.

## Configuration

### Custom Networks

You can add custom networks or different explorers:

```lua
require("eth").setup({
  networks = {
    { "Mainnet", "https://etherscan.io" },
    { "Sepolia", "https://sepolia.etherscan.io" },
    { "Optimism", "https://optimistic.etherscan.io" },
    { "Arbitrum", "https://arbiscan.io" },
    { "Base", "https://basescan.org" },
  },
})
```

The first network in the list is the default.

### Browser Command

By default, the plugin auto-detects the browser command based on your OS:
- Linux: `xdg-open`
- macOS: `open`
- Windows: `start`

You can override this:

```lua
require("eth").setup({
  browser_cmd = "firefox",  -- or "chrome", "brave", etc.
})
```

### Cast Command Path

If `cast` is not in your PATH, you can specify the full path:

```lua
require("eth").setup({
  cast_cmd = "/path/to/cast",
})
```

### Keybindings

By default, eth.nvim sets up keybindings automatically. You can customize or disable them:

#### Disable Default Keybindings

To disable all default keybindings and set up your own:

```lua
require("eth").setup({
  keymaps = {
    enabled = false,  -- Disable all default keybindings
  },
})

-- Then set your own custom keybindings
local commands = require("eth.commands")
vim.keymap.set("n", "<leader>zea", commands.print_address, { desc = "eth: print address" })
vim.keymap.set("n", "<leader>zegb", commands.get_balance, { desc = "eth: get balance" })
vim.keymap.set("n", "<leader>zeba", commands.goto_address, { desc = "eth: goto address" })
vim.keymap.set("n", "<leader>zebt", commands.goto_tx, { desc = "eth: goto tx" })
```

#### Customize Default Keybindings

To change the default keybinding mappings:

```lua
require("eth").setup({
  keymaps = {
    mappings = {
      print_address = "<leader>zea",
      get_balance = "<leader>zegb",
      goto_address = "<leader>zeba",
      goto_tx = "<leader>zebt",
    },
  },
})
```

You can also override only specific keybindings:

```lua
require("eth").setup({
  keymaps = {
    mappings = {
      print_address = "<leader>pa",  -- Only override this one
      -- Other keybindings will use defaults
    },
  },
})
```

## How It Works

### Pattern Matching

The plugin uses smart pattern matching to find hex strings under the cursor:

1. Searches for all `0x[0-9a-fA-F]+` patterns on the current line
2. Selects the hex string closest to the cursor position
3. Falls back to Vim's `<cWORD>` if no pattern matches

### Validation

The plugin validates hex strings based on their length:
- **Private Key**: `0x` + 64 hex characters
- **Address**: `0x` + 40 hex characters  
- **Transaction Hash**: `0x` + 64 hex characters

### Type Detection

For commands that accept multiple input types (like `goto_address` and `get_balance`):
- If a 64-character hex string is detected, it assumes it's a private key and converts to an address first
- If a 40-character hex string is detected, it uses it directly as an address

## Troubleshooting

### "cast command not found"

Make sure Foundry is installed and `cast` is in your PATH:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Verify installation:
```bash
cast --version
```

### Browser doesn't open

Check your browser command configuration. You can manually set it:

```lua
require("eth").setup({
  browser_cmd = "xdg-open",  -- or your preferred command
})
```

### Balance check fails

The `cast balance` command uses the default mainnet RPC. If you're having issues:
- Check your internet connection
- Verify the address is valid
- Make sure `cast` can access mainnet RPC

## License

MIT

## Contributing

Issues and pull requests are welcome!
