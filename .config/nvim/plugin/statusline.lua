-----------------------[ Statusline ]-----------------------
-- Custom statusline with togglable icons (default TRUE).
-- Status added include:
--      - mode
--      - LSP
--      - vim.diagnostics.status
----------------------------------------------------------

local function UseIcons()
    local is_utf8 = (vim.opt.encoding:get() == "utf-8")
    local term = os.getenv("TERM")
    local is_dumb = (term == "dumb" or term == nil)
    return is_utf8 and not is_dumb
end

local icons = {}
local active = UseIcons()

icons.lsp = active and " " or ""
icons.git = active and " " or ""

local function lsp_status()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    end
    local names = vim.iter(attached_clients)
        :map(function(client)
            local name = client.name:gsub("language.server", "ls")
            return name
        end)
        :totable()

    local status = "[" .. icons.lsp .. table.concat(names, ", ")

    if #vim.diagnostic.status() > 0 then
        status = status .. " " .. vim.diagnostic.status()
    end

    return  status .. "] "
end

local function search_cnt_status()
  local res = vim.fn.searchcount({maxcount = 1000, timeout = 500})
  if res.total > 0 then
    return string.format("| %s/%d %s ", res.current, res.total, vim.fn.getreg('/'))
   else
     return ""
  end
end

local MODE_NAMES = {
    ["n"]   = "N",
    ["no"]  = "N",
    ["v"]   = "V",
    ["V"]   = "V",
    ["\22"] = "V",
    ["s"]   = "S",
    ["S"]   = "S",
    ["\19"] = "S",
    ["i"]   = "I",
    ["R"]   = "R",
    ["c"]   = "C",
    ["t"]   = "T",
    ["nt"]  = "T",
}

local function mode_status()
    local mode = vim.api.nvim_get_mode().mode
    return MODE_NAMES[mode] or mode:upper()
end

function _G.statusline()
    return table.concat({
        " " .. mode_status() .. " | ",
        "%f ",
        "%h%w%m%r",
        "%=",
        lsp_status(),
        search_cnt_status(),
        "| %l:%v ",
        "| %L ",
        "",
    }, "")
end

vim.o.statusline = "%{%v:lua._G.statusline()%}"
