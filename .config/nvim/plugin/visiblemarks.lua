-----------------------[ Marks ]-----------------------
-- Renders visual sign-column indicators for active
-- marks on current buffer (`a-z`, `A-Z`).
-------------------------------------------------------

local ns = vim.api.nvim_create_namespace 'rscandino/Marks'

local function decor_mark(bufnr, mark)
    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, mark.pos[2] - 1, 0, {
        sign_text = "`" .. mark.mark:sub(2),
        sign_hl_group = 'Statusline',
    })
end

local function refresh_marks_for_buf(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end

    local current_file = vim.api.nvim_buf_get_name(bufnr)
    if current_file == '' then return end

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local globals = vim.fn.getmarklist()
    for i = 1, #globals do
        local mark = globals[i]
        if mark.mark:match '^.[a-zA-Z]$' and mark.file then
            if current_file == vim.fn.fnamemodify(mark.file, ':p:a') then
                decor_mark(bufnr, mark)
            end
        end
    end

    local locals = vim.fn.getmarklist(bufnr)
    for i = 1, #locals do
        local mark = locals[i]
        if mark.mark:match '^.[a-zA-Z]$' then
            decor_mark(bufnr, mark)
        end
    end
end

local seen = {}
vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, bufnr)
        if seen[bufnr] then return end
        seen[bufnr] = true
        refresh_marks_for_buf(bufnr)
    end,
})

vim.api.nvim_create_autocmd('BufWipeout', {
    group = vim.api.nvim_create_augroup('rscandino/MarksCleanup', { clear = true }),
    callback = function(args) seen[args.buf] = nil end,
})

vim.api.nvim_create_autocmd('MarkSet', {
    group = vim.api.nvim_create_augroup('rscandino/MarksOnSet', { clear = true }),
    pattern = '*',
    callback = function(ev)
        vim.schedule(function()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                seen[bufnr] = nil
            end
            refresh_marks_for_buf(vim.api.nvim_get_current_buf())
        end)
    end,
})
