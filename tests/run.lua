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

local treesitter_specs = require 'kickstart.plugins.treesitter'
assert_equal(type(treesitter_specs), 'table', 'treesitter module should return a spec list')
assert_true(type(treesitter_specs[1]) == 'table', 'treesitter module should include a first plugin spec')
local treesitter_spec = treesitter_specs[1]
assert_equal(treesitter_spec[1], 'nvim-treesitter/nvim-treesitter', 'treesitter plugin id should match')
assert_equal(treesitter_spec.branch, 'main', 'treesitter should track main branch API')
assert_true(type(treesitter_spec.build) == 'function', 'treesitter should define a build function')
assert_true(type(treesitter_spec.config) == 'function', 'treesitter should define a config function')

local install_calls = {}
package.loaded['nvim-treesitter'] = nil
package.preload['nvim-treesitter'] = function()
  return {
    setup = function(opts)
      _G.__test_ts_setup_opts = opts
    end,
    install = function(parsers)
      install_calls[#install_calls + 1] = parsers
    end,
    indentexpr = function()
      return 'TS_INDENT'
    end,
  }
end

treesitter_spec.build()
assert_equal(#install_calls, 1, 'treesitter build should install parser list once')
assert_true(vim.tbl_contains(install_calls[1], 'lua'), 'treesitter build should include lua parser')
assert_true(vim.tbl_contains(install_calls[1], 'vimdoc'), 'treesitter build should include vimdoc parser')

local original_start = vim.treesitter.start
local started_buffers = {}
vim.treesitter.start = function(buf)
  started_buffers[#started_buffers + 1] = buf
end

treesitter_spec.config()
assert_equal(_G.__test_ts_setup_opts, {}, 'treesitter setup should be called with empty opts table')

local lua_buf = vim.api.nvim_create_buf(false, true)
vim.bo[lua_buf].filetype = 'lua'
vim.api.nvim_exec_autocmds('FileType', { buffer = lua_buf, modeline = false })
assert_equal(vim.bo[lua_buf].indentexpr, "v:lua.require'nvim-treesitter'.indentexpr()", 'non-ruby buffers should use treesitter indentexpr')
assert_equal(started_buffers[#started_buffers], lua_buf, 'treesitter.start should run for non-ruby buffers')

local ruby_buf = vim.api.nvim_create_buf(false, true)
vim.bo[ruby_buf].filetype = 'ruby'
vim.api.nvim_exec_autocmds('FileType', { buffer = ruby_buf, modeline = false })
assert_equal(vim.bo[ruby_buf].indentexpr, '', 'ruby buffers should keep default indentexpr')
assert_equal(started_buffers[#started_buffers], ruby_buf, 'treesitter.start should still run for ruby buffers')

vim.treesitter.start = function()
  error('no parser')
end

local missing_parser_buf = vim.api.nvim_create_buf(false, true)
vim.bo[missing_parser_buf].filetype = 'lua'
vim.api.nvim_exec_autocmds('FileType', { buffer = missing_parser_buf, modeline = false })
assert_equal(vim.bo[missing_parser_buf].indentexpr, '', 'missing parser should not set treesitter indentexpr')

vim.treesitter.start = original_start

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
