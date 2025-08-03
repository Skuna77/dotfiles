vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "
vim.g.background = "light"

vim.opt.swapfile = false

vim.keymap.set("n", "<leader>tt", function()
  print("Hello from Lua!")
end, { desc = "Test keymap" })


vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { buffer = bufnr })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr })


-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.wo.number = true

vim.g.python3_host_prog = vim.fn.expand('~/.pyenv/versions/3.11.6/bin/python')

vim.keymap.set('n', '<leader>cb', ':!cmake -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build<CR>')
vim.keymap.set('n', '<leader>cr', ':!./build/<C-R>=expand("%:t:r")<CR><CR>')

-- formatting key
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file or range" })
vim.g.tex_flavor = "latex"
vim.opt.conceallevel = 1 -- Better LaTeX symbol rendering

-- PlatformIO keybindings
vim.keymap.set("n", "<leader>pb", ":!platformio run<CR>", { desc = "PIO: Build" })
vim.keymap.set("n", "<leader>pu", ":!platformio run --target upload<CR>", { desc = "PIO: Upload" })
vim.keymap.set("n", "<leader>pm", ":!platformio device monitor<CR>", { desc = "PIO: Monitor" })
vim.keymap.set("n", "<leader>pc", ":!platformio run -t clean<CR>", { desc = "PIO: Clean" })


-- Keymaps for ESP-IDF commands
vim.keymap.set("n", "<leader>eg", ":!. $HOME/esp/esp-idf/export.sh<CR>", { desc = "ESP-IDF Init" })
vim.keymap.set("n", "<leader>eb", ":!idf.py build<CR>", { desc = "ESP-IDF Build" })
vim.keymap.set("n", "<leader>ef", ":!idf.py flash<CR>", { desc = "ESP-IDF Flash" })
vim.keymap.set("n", "<leader>em", ":!idf.py monitor<CR>", { desc = "ESP-IDF Monitor" })
vim.keymap.set("n", "<leader>ec", ":!idf.py menuconfig<CR>", { desc = "ESP-IDF Menuconfig" })
vim.keymap.set("n", "<leader>esp", ":!idf.py build flash monitor<CR>", { desc = "ESP-IDF Build flash monitor" })

-- python keymap
vim.keymap.set('n', '<leader>pr', ':!python %<CR>', { desc = "Run current Python file" })
vim.keymap.set('n', '<leader>pt', ':!pytest<CR>', { desc = "Run Pytest" })

--bash run 
vim.keymap.set("n", "<leader>br", ":!bash %<CR>", { desc = "Run current Bash script" })



