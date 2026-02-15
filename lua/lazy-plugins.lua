local defaults = require 'config.defaults'

local specs = vim.deepcopy(defaults.plugin_specs)
for _, module in ipairs(defaults.plugin_modules) do
  specs[#specs + 1] = require(module)
end

require('lazy').setup(specs, {
  ui = {
    icons = vim.g.have_nerd_font and {} or defaults.lazy_ui_icons,
  },
})

-- vim: ts=2 sts=2 sw=2 et
