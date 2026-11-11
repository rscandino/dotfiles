-----------------------[ Toggle Shell ]-----------------------
-- Inspired by https://github.com/justinmk/config/.config/nvim/lua/my/ctrl_s_shell.lua
-- Persistent terminal drawer with window memory as tab (default)
-- or window split if range specified.
-- Keymaps:     [range]<C-s> (Normal & Terminal modes)
--------------------------------------------------------------

vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('rscandino/ToggleShellWipeOnLeave', { clear = true }),
    desc = 'ToggleShell: Deletes :shell buffer closing nvim, prevents :mksession from saving dead buffers',
    pattern = '*',
    command = 'bwipeout! ^:shell$',
})

local PREVWID = nil

local function CheckValidShell()
    local b = vim.fn.bufnr ':shell'

    if b ~= -1 and vim.fn.bufexists(b) then
        if vim.bo[b].buftype ~= 'terminal' then
            vim.api.nvim_buf_delete(b, { force = true })
            b = -1
        end
    else
        b = -1
    end

    return b
end

local function ExitShell(prevwid)
    local term_prevwid = vim.api.nvim_get_current_win()
    local tab = vim.fn.tabpagenr()

    if vim.fn.win_gotoid(prevwid) == 0 then
        vim.cmd 'wincmd p'
    end

    if vim.fn.tabpagewinnr(tab, '$') == 1 and vim.fn.tabpagenr() ~= tab then
        vim.cmd.tabclose(tab)
    end

    return term_prevwid
end

local function FocusShell(shellbuf, cnt)
    local w = vim.fn.bufwinid(shellbuf)
    local ws = vim.fn.win_findbuf(shellbuf)

    if cnt == 0 and w > 0 then
        vim.api.nvim_set_current_win(w)
    elseif cnt == 0 and #ws > 0 then
        vim.api.nvim_set_current_win(ws[1])
    else
        vim.cmd(cnt == 0 and 'tab split' or (cnt .. 'split'))
        vim.api.nvim_set_current_buf(shellbuf)
    end
    vim.cmd 'startinsert'
end

local function CreateShell(origbuf, cnt)

    vim.cmd(cnt == 0 and 'tab split' or (cnt .. 'split'))

    vim.cmd 'terminal'
    vim.bo.scrollback = -1
    vim.cmd 'file :shell'
    vim.cmd 'startinsert'
    vim.api.nvim_buf_delete(vim.fn.bufnr '#', { force = true })
    vim.fn.setreg('#', origbuf)
end

local function ToggleShell(cnt)
    PREVWID = PREVWID or vim.api.nvim_get_current_win()
    local curbuf = vim.api.nvim_get_current_buf()
    local shellbuf = CheckValidShell()
    local shell_exists = (shellbuf ~= -1)

    if curbuf == shellbuf then
        PREVWID = ExitShell(PREVWID)
        return
    end

    local curwinid = vim.api.nvim_get_current_win()
    if shell_exists then
        FocusShell(shellbuf, cnt)
    else
        CreateShell(curbuf, cnt)
    end
    PREVWID = curwinid
    vim.bo.buflisted = false
end

vim.keymap.set({ 'n', 't' }, '<C-s>', function() ToggleShell(vim.v.count) end)
