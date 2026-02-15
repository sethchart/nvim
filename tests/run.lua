local total = 0

local function fail(message)
  error(message, 0)
end

local function assert_true(condition, message)
  total = total + 1
  if not condition then
    fail('assert_true failed: ' .. message)
  end
end

local function assert_equal(actual, expected, message)
  total = total + 1
  if not vim.deep_equal(actual, expected) then
    fail(string.format('assert_equal failed: %s\nexpected: %s\nactual: %s', message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function has_map(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  return type(mapping) == 'table' and next(mapping) ~= nil
end

local cwd = vim.fn.getcwd()
package.path = table.concat({
  cwd .. '/lua/?.lua',
  cwd .. '/lua/?/init.lua',
  package.path,
}, ';')

local defaults = require 'config.defaults'
assert_true(type(defaults.globals) == 'table', 'defaults.globals should exist')
assert_true(type(defaults.options) == 'table', 'defaults.options should exist')
assert_true(type(defaults.keymaps) == 'table', 'defaults.keymaps should exist')
assert_true(type(defaults.plugin_modules) == 'table', 'defaults.plugin_modules should exist')
assert_equal(defaults.options.spell, true, 'spell should default to true')
assert_equal(defaults.options.spelllang, 'en_us', 'spelllang should default to en_us')

package.loaded.options = nil
require 'options'
assert_equal(vim.o.spell, true, 'options module should enable spell')
assert_equal(vim.o.spelllang, 'en_us', 'options module should set spelllang')
assert_equal(vim.o.number, true, 'options module should set number')

package.loaded.keymaps = nil
require 'keymaps'
assert_true(has_map('n', '<Esc>'), 'normal <Esc> keymap should exist')
assert_true(has_map('n', '<C-h>'), 'normal <C-h> keymap should exist')
assert_true(has_map('t', '<Esc><Esc>'), 'terminal <Esc><Esc> keymap should exist')
assert_true(has_map('n', '<leader>q'), '<leader>q keymap should exist')

local autocmds = vim.api.nvim_get_autocmds { event = 'TextYankPost' }
local found_yank_autocmd = false
for _, autocmd in ipairs(autocmds) do
  if autocmd.desc == 'Highlight when yanking (copying) text' then
    found_yank_autocmd = true
    break
  end
end
assert_true(found_yank_autocmd, 'TextYankPost highlight autocmd should exist')

local plugins = require 'config.plugins'
local expected_modules = {}
for _, category in ipairs({ 'core', 'lsp', 'ui', 'editing' }) do
  assert_true(type(plugins.plugin_categories[category]) == 'table', 'plugin category should exist: ' .. category)
  for _, module in ipairs(plugins.plugin_categories[category]) do
    expected_modules[#expected_modules + 1] = module
  end
end
assert_equal(plugins.plugin_modules, expected_modules, 'plugin_modules should flatten categories in declared order')

for _, module in ipairs(plugins.plugin_modules) do
  local ok, value = pcall(require, module)
  assert_true(ok, 'plugin module should load: ' .. module .. '\n' .. tostring(value))
  assert_true(type(value) == 'table', 'plugin module should return a table: ' .. module)
end

package.loaded.lazy = nil
package.loaded['lazy-plugins'] = nil
package.preload.lazy = function()
  return {
    setup = function(specs, opts)
      _G.__test_lazy_specs = specs
      _G.__test_lazy_opts = opts
    end,
  }
end

require 'lazy-plugins'
assert_true(type(_G.__test_lazy_specs) == 'table', 'lazy.setup should receive specs')
assert_true(type(_G.__test_lazy_opts) == 'table', 'lazy.setup should receive options')
assert_equal(#_G.__test_lazy_specs, 1 + #plugins.plugin_modules, 'lazy specs should include base specs and module specs')
assert_equal(_G.__test_lazy_specs[1], 'NMAC427/guess-indent.nvim', 'first lazy spec should be guess-indent plugin')
assert_equal(_G.__test_lazy_opts.ui.icons, defaults.lazy_ui_icons, 'lazy fallback icons should match defaults')

package.loaded['lazy-bootstrap'] = nil
package.loaded['lazy-plugins'] = nil
package.preload['lazy-bootstrap'] = function()
  _G.__test_bootstrap_called = true
end
package.preload['lazy-plugins'] = function()
  _G.__test_lazy_plugins_called = true
end

dofile(cwd .. '/init.lua')
assert_true(_G.__test_bootstrap_called == true, 'init.lua should require lazy-bootstrap')
assert_true(_G.__test_lazy_plugins_called == true, 'init.lua should require lazy-plugins')
assert_equal(vim.g.mapleader, ' ', 'init.lua should set mapleader')
assert_equal(vim.g.maplocalleader, ' ', 'init.lua should set maplocalleader')

print(string.format('All tests passed (%d assertions)', total))
