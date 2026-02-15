local M = {}

M.plugin_specs = {
  'NMAC427/guess-indent.nvim',
}

M.plugin_categories = {
  core = require 'config.plugins.core',
  lsp = require 'config.plugins.lsp',
  ui = require 'config.plugins.ui',
  editing = require 'config.plugins.editing',
}

M.plugin_modules = {}
for _, category in ipairs({ 'core', 'lsp', 'ui', 'editing' }) do
  for _, module in ipairs(M.plugin_categories[category]) do
    M.plugin_modules[#M.plugin_modules + 1] = module
  end
end

M.lazy_ui_icons = {
  cmd = '⌘',
  config = '🛠',
  event = '📅',
  ft = '📂',
  init = '⚙',
  keys = '🗝',
  plugin = '🔌',
  runtime = '💻',
  require = '🌙',
  source = '📄',
  start = '🚀',
  task = '📌',
  lazy = '💤 ',
}

return M
