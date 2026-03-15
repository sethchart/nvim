return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = function()
      local config_dir = vim.fn.stdpath 'config'
      vim.env.PATH = config_dir .. '/node_modules/.bin:' .. vim.env.PATH
      require('nvim-treesitter').install { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query', 'vim', 'vimdoc' }
    end,
    config = function()
      local config_dir = vim.fn.stdpath 'config'
      vim.env.PATH = config_dir .. '/node_modules/.bin:' .. vim.env.PATH

      local ts = require 'nvim-treesitter'

      -- Current API uses explicit setup/install and Neovim's treesitter runtime.
      ts.setup {}

      local ts_group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = ts_group,
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if not ok then
            return
          end

          if vim.bo[args.buf].filetype ~= 'ruby' then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
}
-- vim: ts=2 sts=2 sw=2 et
