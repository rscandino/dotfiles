vim.bo.formatprg = "ansible-lint --auto-fix"
vim.keymap.set("n", "<leader>at", ":!ansible-playbook % --syntax-check<CR>", {
  buffer = true,
  desc = "Ansible Syntax Check",
})
local fname = vim.api.nvim_buf_get_name(0)
if fname:find('tasks/') then
  local paths = {
    vim.bo.path,
    vim.fs.dirname(fname:gsub("tasks/", "files/")),
    vim.fs.dirname(fname:gsub("tasks/", "templates/")),
    vim.fs.dirname(fname)
  }
  vim.bo.path = table.concat(paths, ",")
end
