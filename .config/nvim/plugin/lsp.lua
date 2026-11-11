-----------------------[ LSP ]-----------------------

local function UseIcons()
    local is_utf8 = (vim.opt.encoding:get() == "utf-8")
    local term = os.getenv("TERM")
    local is_dumb = (term == "dumb" or term == nil)
    return is_utf8 and not is_dumb
end

local icons = {}
local active = UseIcons()

icons.error = active and " " or "E"
icons.warning = active and " " or "W"
icons.hint = active and "⚑" or "H"
icons.info = active and "󰌵" or "H"

vim.diagnostic.config({
    virtual_text  = true,
    severity_sort = true,
    float         = {
        style  = 'minimal',
        border = 'rounded',
        source = 'if_many',
        header = '',
        prefix = '',
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.error,
            [vim.diagnostic.severity.WARN] = icons.warning,
            [vim.diagnostic.severity.HINT] = icons.hint,
            [vim.diagnostic.severity.INFO]  = icons.info,
        },
    },
})

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'configure lsp options',
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if not client then return end

        vim.keymap.set('n', '[e',
            function() vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR } end,
            { desc = 'diagnostic: previous error' })
        vim.keymap.set('n', ']e',
            function() vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR } end,
            { desc = 'diagnostic: next error' })

        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end

        if client:supports_method('textDocument/foldingRange') then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end

    end,
})

vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
        vim.defer_fn(function()
            local servers = vim.iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
                :map(function(file) return vim.fn.fnamemodify(file, ':t:r') end)
                :totable()
            vim.lsp.enable(servers)
        end, 0)
    end,
})
