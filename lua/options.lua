local defaults = require 'config.defaults'

for key, value in pairs(defaults.options) do
  vim.o[key] = value
end

for key, value in pairs(defaults.option_tables) do
  vim.opt[key] = value
end

vim.schedule(function()
  for key, value in pairs(defaults.deferred_options) do
    vim.o[key] = value
  end
end)

-- vim: ts=2 sts=2 sw=2 et
