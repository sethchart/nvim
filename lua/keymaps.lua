local defaults = require 'config.defaults'

for _, keymap in ipairs(defaults.keymaps) do
  local opts = keymap.desc and { desc = keymap.desc } or nil
  vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, opts)
end

for _, autocmd in ipairs(defaults.autocmds) do
  vim.api.nvim_create_autocmd(autocmd.event, {
    desc = autocmd.desc,
    group = vim.api.nvim_create_augroup(autocmd.group, { clear = true }),
    callback = autocmd.callback,
  })
end

-- vim: ts=2 sts=2 sw=2 et
