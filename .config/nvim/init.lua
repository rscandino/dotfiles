-----------------------[ Globals ]-----------------------

-- Setting leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Builtin options/tools to DISABLE
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.did_install_default_menus = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_2html_plugin = 1
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
vim.g.loaded_remote_plugins = 1

-- Builtin options/tools to ENABLE
vim.cmd.packadd 'nvim.undotree'
vim.cmd.packadd 'nvim.difftool'
vim.cmd.packadd 'cfilter'

-- Enable the new experimental command-line features
vim.opt.cmdheight = 0
require('vim._core.ui2').enable({enable = true})

-----------------------[ Options ]-----------------------

vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.updatetime = 300
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.confirm = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.laststatus = 3
vim.opt.signcolumn = "yes"
vim.opt.list = true
vim.opt.listchars = {
        tab = '» ',
        trail = '·',
        nbsp = '·'
}
vim.opt.fillchars = {
        eob = ' ',
        fold = ' ',
        foldclose = '',
        foldopen = '',
        foldsep = ' ',
        foldinner = ' ',
        msgsep = '─',
}
vim.opt.termguicolors = true
vim.opt.winborder = "rounded"
vim.opt.pumheight = 15
vim.opt.pumborder = 'rounded'
vim.opt.linebreak = true
vim.opt.foldcolumn = '1'
vim.opt.foldlevelstart = 99
vim.wo.foldtext = ''
vim.opt.inccommand = 'split'
vim.opt.ignorecase = true
vim.opt.smartcase = true
if vim.fn.executable('rg') == 1 then
        vim.opt.grepprg = 'rg --vimgrep --hidden --no-heading '
        vim.opt.grepformat = '%f:%l:%c:%m'
end
vim.opt.wildmode = "noselect:lastused,full"
vim.opt.completeopt = 'menuone,noselect,fuzzy'
