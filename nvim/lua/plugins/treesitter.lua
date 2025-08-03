
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "c", "cpp", "lua", "python", "bash"   }, -- languages you use
            indent = {
        enable = true               -- smarter indentation
      },
      incremental_selection = {
          enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<TAB>",
          node_decremental = "<BS>",
        },
      },
    }
  end
}

