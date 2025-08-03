return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        cpp = { "clang_format" },
        c = { "clang_format" },
        h = { "clang_format" },
        python = {"black"},
        tex = { "latexindent" },
      },
  formatters = {
  black = {
    command = vim.fn.exepath("black") or "black", -- Use available black
    args = { "-q", "-" },
  },
},
       latexindent = {
         command = "latexindent",
         args = { "-" },
       },
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 500,
      },
    })
  end,
}

