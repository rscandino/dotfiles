-----------------------[ Findfunc ]-----------------------
-- Custom fuzzy-completion engine for Neovim's `:find`
-- command (vim.opt.findfunc). It relies on external CLI
-- tools with automatic fallback:
--          fd / fdfind -> rg -> find (system)
----------------------------------------------------------

--- Tweakables Params ---
local BROAD_DIRS = { --- Directories considered "broad"
    '~',
    '/',
    '/mnt',
    '/media',
    '/etc',
}
local MAX_DEPTH = 5        --- Caps research max dir depth for "broad" directories
local MAX_RESULTS = 500000 --- Caps total files searched (fd, rg) and stored in Lua memory (find)
local FUZZY_LIMIT = 100    --- Caps output matches sent to Neovim's completion menu while typing
local DIRS_TO_EXCLUDE = {  --- Directories to exclude from search
    '.git',
    '.cache',
    '.ansible',
    '.npm',
    '.cargo',
    '.rustup',
    '.yarn',
    '.local/share/Trash',
    '.Trash',
    '.venv',
    '.docker',
    '.steam',
}
-------------------------

vim.api.nvim_create_autocmd({ 'ShellCmdPost', 'TermLeave', 'TermClose' }, {
    group = vim.api.nvim_create_augroup('rscandino/FindfuncCache', { clear = true }),
    desc = 'Findfunc: Reset cache files variable after :! or term',
    callback = function()
        CACHE_FILES = nil
    end,
})

local CACHE_CWD = nil
local CACHE_CMD = nil
local CACHE_FILES = nil


local function BuildCMD(cache_cwd, dirs_to_exclude, broad_dirs, max_depth)

    local norm_cwd = vim.fs.normalize(cache_cwd)
    local is_broad =  vim.iter(broad_dirs):any(function(dir)
        return norm_cwd == vim.fs.normalize(dir)
    end)

    local cmd = nil
    if vim.fn.executable 'fd' == 1 or vim.fn.executable 'fdfind' == 1 then
        local backend = vim.fn.executable 'fd' == 1 and 'fd' or 'fdfind'
        cmd = { backend, '.', '--path-separator', '/', '--type', 'f', '--hidden', '--max-results', tostring(MAX_RESULTS) }
        for _, d in ipairs(dirs_to_exclude) do
            vim.list_extend(cmd, { '--exclude', d })
        end
        if is_broad then
            vim.list_extend(cmd, { '--max-depth', tostring(max_depth) })
        end
    elseif vim.fn.executable 'rg' == 1 then
        cmd = { 'rg', '--path-separator', '/', '--files', '--hidden', '--max-count', tostring(MAX_RESULTS) }
        for _, d in ipairs(dirs_to_exclude) do
            vim.list_extend(cmd, { '--glob', '!**/' .. d .. '/**' })
        end
        if is_broad then
            vim.list_extend(cmd, { '--max-depth', tostring(max_depth) })
        end
    elseif vim.fn.executable 'find' == 1 then
        cmd = { 'find', '.' }
        if is_broad then
            vim.list_extend(cmd, { '-maxdepth', tostring(max_depth) })
        end
        vim.list_extend(cmd, { '-type', 'd', '(' })
        for i, d in ipairs(dirs_to_exclude) do
            if i > 1 then table.insert(cmd, '-o') end
            vim.list_extend(cmd, { '-name', d })
        end
        vim.list_extend(cmd, { ')', '-prune', '-o', '-type', 'f', '-print' })
    end

    if not cmd then
        vim.notify('findfunc: backend binary not found.', vim.log.levels.WARN)
        return nil
    end

    return cmd
end

local function ScanFiles(cache_cmd, max_results)
    local obj = vim.system(cache_cmd, { text = true }):wait()
    if (obj.code ~= 0 and obj.code ~= 1) or not obj.stdout then
        vim.notify('findfunc: search command failed', vim.log.levels.ERROR)
        return {}
    end

    local lines = vim.split(obj.stdout, '\n', { trimempty = true })
    return vim.iter(lines):take(max_results):totable()
end

_G.Findfunc = function(cmd_arg, _)

    local cwd = vim.fn.getcwd()
    if cwd ~= CACHE_CWD then
        CACHE_CWD = cwd
        CACHE_CMD = nil
        CACHE_FILES = nil
    end

    if not CACHE_FILES then
        if not CACHE_CMD or #CACHE_CMD == 0 then
            CACHE_CMD = BuildCMD(CACHE_CWD, DIRS_TO_EXCLUDE, BROAD_DIRS, MAX_DEPTH)
        end
        CACHE_FILES = ScanFiles(CACHE_CMD, MAX_RESULTS)
    end

    if cmd_arg and #cmd_arg > 0 then
        local ok, matches = pcall(vim.fn.matchfuzzy, CACHE_FILES, cmd_arg, { limit = FUZZY_LIMIT })
        return ok and matches or {}
    end

    return CACHE_FILES
end

vim.opt.findfunc = 'v:lua.Findfunc'
