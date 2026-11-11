-----------------------[ Keymaps ]-----------------------

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { noremap = true, desc = "<Esc> to clear search highlights" })
vim.keymap.set('t', '<Esc>', '<C-\\><C-N>', { noremap = true, desc = "<Esc> to exit terminal mode" })
vim.keymap.set('t', '<C-[>', '<C-\\><C-N>', { noremap = true, desc = "<C-[> to exit terminal mode" })
vim.keymap.set('x', '<', '<gv', { noremap = true, silent = true, desc = 'Move block selection left, remain visual' })
vim.keymap.set('x', '>', '>gv', { noremap = true, silent = true, desc = 'Move block selection right, remain visual' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true, desc = 'Scroll down, centered' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { silent = true, desc = 'Scroll up, centered' })
vim.keymap.set('n', 'n', 'nzzzv', { silent = true, desc = 'Next search result, centered' })
vim.keymap.set('n', 'N', 'Nzzzv', { silent = true, desc = 'Prev search result, centered' })
vim.keymap.set('n', '<C-o>', '<C-o>zz', { silent = true, desc = 'Jump back, centered' })
vim.keymap.set('n', '<C-i>', '<C-i>zz', { silent = true, desc = 'Jump forward, centered' })
vim.keymap.set('n', 'gl', '$', { silent = true, desc = '$ remap' })
vim.keymap.set('n', 'gh', '^', { silent = true, desc = '^ remap' })
vim.keymap.set('c', 'dm', 'delmarks ', { desc = 'Delete marks, :delmarks shortcut' })
vim.keymap.set('n', 'ZB', '<cmd>%bd|e#|bd#<CR>', { desc = 'Close other Buffers' })
vim.keymap.set('x', '<leader>y', [["+y]], { noremap = true, silent = true, desc = 'Yank to system clipboard' })
vim.keymap.set({'n', 'x'}, '<leader>p', [["+p]], { noremap = true, silent = true, desc = 'Paste from system clipboard' })
vim.keymap.set('x', "<leader>r", [["hy:%s/<C-r>h//g<left><left>]], { desc = "Replace selection in buffer" })
vim.keymap.set('n', "<leader>s", ":.s/, */,\\r/g<CR>:nohlsearch<CR>", { desc = "Split comma-list onto lines" })
vim.keymap.set('x', "<leader>s", "<Esc>:'<,'>s/\\%V, */,\\r/g<CR>:nohlsearch<CR>", { desc = "Split comma-list inside block selection" })
vim.keymap.set("n", "<leader>x", ':! chmod +x % <CR>', { desc = "Make current file executable" })
vim.keymap.set("n", "<leader>t", ':vsplit term://', { desc = "Terminal: Launch command vertical" })
vim.keymap.set("n", "<leader>T", ':split term://', { desc = "Launch command in Horizontal terminal" })
vim.keymap.set("n", "<leader>f", ":find ", { desc = "Find function shortcut" })
vim.keymap.set("n", "<leader>b", ":b ", { desc = "Buffers list shortcut" })

vim.keymap.set("n", "<leader>g", function()
    vim.ui.input({ prompt = ":silent grep! " }, function(pattern)
        if pattern then
            vim.cmd("silent grep! " .. vim.fn.fnameescape(pattern))
        end
    end)
end, { silent = true, desc = "Silent grep to QuickFixList" })

vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.setqflist()
    vim.cmd("copen")
end, { silent = true, desc = "Send diagnostics to QuickFixList" })

vim.keymap.set("n", "<leader>q", function()
    if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end, {desc = "Toggle QuickFixList"})
