local M = {}

M.keymaps = {
  { mode = 'n', lhs = '<Esc>', rhs = '<cmd>nohlsearch<CR>' },
  { mode = 'n', lhs = '<leader>q', rhs = vim.diagnostic.setloclist, desc = 'Open diagnostic [Q]uickfix list' },
  { mode = 't', lhs = '<Esc><Esc>', rhs = '<C-\\><C-n>', desc = 'Exit terminal mode' },
  { mode = 'n', lhs = '<C-h>', rhs = '<C-w><C-h>', desc = 'Move focus to the left window' },
  { mode = 'n', lhs = '<C-l>', rhs = '<C-w><C-l>', desc = 'Move focus to the right window' },
  { mode = 'n', lhs = '<C-j>', rhs = '<C-w><C-j>', desc = 'Move focus to the lower window' },
  { mode = 'n', lhs = '<C-k>', rhs = '<C-w><C-k>', desc = 'Move focus to the upper window' },
  { mode = 'n', lhs = '<C-S-h>', rhs = '<C-w>H', desc = 'Move window to the left' },
  { mode = 'n', lhs = '<C-S-l>', rhs = '<C-w>L', desc = 'Move window to the right' },
  { mode = 'n', lhs = '<C-S-j>', rhs = '<C-w>J', desc = 'Move window to the lower' },
  { mode = 'n', lhs = '<C-S-k>', rhs = '<C-w>K', desc = 'Move window to the upper' },
}

M.autocmds = {
  {
    event = 'TextYankPost',
    desc = 'Highlight when yanking (copying) text',
    group = 'kickstart-highlight-yank',
    callback = function()
      vim.hl.on_yank()
    end,
  },
}

return M
