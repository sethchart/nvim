local options = require 'config.options'
local keymaps = require 'config.keymaps'
local plugins = require 'config.plugins'

return vim.tbl_extend('force', {}, options, keymaps, plugins)
