vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  pattern = '*.tex',
  command = 'set filetype=tex'
})
