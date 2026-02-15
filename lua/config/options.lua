local M = {}

M.globals = {
  mapleader = ' ',
  maplocalleader = ' ',
  have_nerd_font = true,
}

M.options = {
  number = true,
  mouse = 'a',
  showmode = false,
  breakindent = true,
  undofile = true,
  ignorecase = true,
  smartcase = true,
  signcolumn = 'yes',
  updatetime = 250,
  timeoutlen = 300,
  splitright = true,
  splitbelow = true,
  list = true,
  inccommand = 'split',
  cursorline = true,
  scrolloff = 10,
  confirm = true,
}

M.deferred_options = {
  clipboard = 'unnamedplus',
}

M.option_tables = {
  listchars = { tab = '» ', trail = '·', nbsp = '␣' },
}

return M
