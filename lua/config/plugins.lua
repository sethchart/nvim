local M = {}

M.plugin_specs = {
  'NMAC427/guess-indent.nvim',
}

M.plugin_modules = {
  'kickstart.plugins.gitsigns',
  'kickstart.plugins.which-key',
  'kickstart.plugins.telescope',
  'kickstart.plugins.lspconfig',
  'kickstart.plugins.conform',
  'kickstart.plugins.blink-cmp',
  'kickstart.plugins.tokyonight',
  'kickstart.plugins.todo-comments',
  'kickstart.plugins.mini',
  'kickstart.plugins.treesitter',
  'kickstart.plugins.autopairs',
}

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
