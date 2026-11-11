-----------------------[ Autocommands ]-----------------------

local file_search_patterns = {}
for _, pat in ipairs({ '^find?', '^bu?f?f?e?r?', '^e', '^edit' }) do
    table.insert(file_search_patterns, { space = pat .. '%s', eol = pat .. '$' })
end

vim.api.nvim_create_autocmd('CmdlineChanged', {
    group = vim.api.nvim_create_augroup('rscandino/AutoCompleteCommand', { clear = true }),
    desc = 'Enable command line auto complete for ~file search commands',
    callback = function()
        if vim.fn.getcmdtype() ~= ':' then
            return
        end
        local cmd = vim.fn.getcmdline()
        for _, p in ipairs(file_search_patterns) do
            if cmd:match(p.space) or cmd:match(p.eol) then
                vim.fn.wildtrigger()
                return
            end
        end
    end
})

vim.api.nvim_create_autocmd('VimResized', {
    group = vim.api.nvim_create_augroup('rscandino/AutoResizeSplit', { clear = true }),
    desc = 'Auto resize splits when window is modified',
    command = 'wincmd ='
})

vim.api.nvim_create_autocmd({ "BufHidden", "FocusLost", "WinLeave", "CursorHold" }, {
    group = vim.api.nvim_create_augroup('rscandino/AutoWriteFile', { clear = true }),
    desc = 'Auto writes file',
    callback = function()
        if not vim.bo.modified or vim.bo.buftype ~= "" or vim.bo.readonly then
            return
        end
        local path = vim.fn.expand("%:p")
        if vim.fn.filereadable(path) == 1 then
            vim.cmd("silent lockmarks update ++p")
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('rscandino/CloseWithQ', { clear = true }),
    desc = 'Close various window types with <q>',
    pattern = {
        'git',
        'help',
        'man',
        'qf',
        'lf',
    },
    callback = function(args)
        if args.match ~= 'help' or not vim.bo[args.buf].modifiable then
            vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = args.buf })
        end
    end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('rscandino/HighlightText', { clear = true }),
    desc = 'Highlight when yanking text',
    callback = function()
        vim.hl.on_yank { higroup = 'Visual', timeout = 300 }
    end,
})

-- vim.api.nvim_create_autocmd("BufReadPost", {
--     group = vim.api.nvim_create_augroup('rscandino/OpenLastPosition', { clear = true }),
--     desc = 'Move cursor to last modified position of buffer',
--     pattern = "*",
--     callback = function()
--         local mark = vim.api.nvim_buf_get_mark(0, '"')
--         local lcount = vim.api.nvim_buf_line_count(0)
--         if mark[1] > 0 and mark[1] <= lcount then
--             pcall(vim.api.nvim_win_set_cursor, 0, mark)
--         end
--     end,
-- })

vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('rscandino/RemoveEndingEmptyLines', { clear = true }),
    desc = 'Remove end of file empty lines',
    pattern = '*',
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local last_line = vim.api.nvim_buf_line_count(bufnr)
        while last_line > 1 and vim.trim(vim.api.nvim_buf_get_lines(bufnr, last_line - 1, last_line, false)[1]) == '' do
            vim.api.nvim_buf_set_lines(bufnr, last_line - 1, last_line, false, {})
            last_line = last_line - 1
        end
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('rscandino/RemoveWhitespaces', { clear = true }),
    desc = 'Remove end of line whitespaces on writing',
    pattern = "*",
    command = [[%s/\s\+$//e]],
})


vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
    group = vim.api.nvim_create_augroup('rscandino/ToggleLineNumbersOn', { clear = true }),
    desc = 'Toggle line numbers: show relative in active window',
    callback = function()
        local win = vim.wo[0]

        if win.number and not win.relativenumber then
            local in_insert_mode = vim.api.nvim_get_mode().mode:match('^i') ~= nil

            if not in_insert_mode then
                win.relativenumber = true
            end
        end
    end,
})

local skip_redraw_cmdtypes = { ['@'] = true, ['-'] = true }
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
    group = vim.api.nvim_create_augroup('rscandino/ToggleLineNumbersOff', { clear = true }),
    desc = 'Toggle line numbers: show absolute in inactive window/insert/cmdline',
    callback = function(args)
        local win = vim.wo[0]

        if win.number and win.relativenumber then
            win.relativenumber = false
        end

        if args.event == 'CmdlineEnter' and not skip_redraw_cmdtypes[vim.v.event.cmdtype] then
            vim.cmd.redraw()
        end
    end,
})

-- vim.api.nvim_create_autocmd("FileType", {
--     group = vim.api.nvim_create_augroup('rscandino/VerticalHelp', { clear = true }),
--     desc = 'Open help/man page vertically',
--     pattern = {
--         "help",
--         "man",
--     },
--     command = "wincmd L",
-- })
