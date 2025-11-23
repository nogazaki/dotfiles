local signs = {}
signs[vim.diagnostic.severity.ERROR] = { '', 'ErrorMsg' }
signs[vim.diagnostic.severity.WARN] = { '', 'WarningMsg' }
signs[vim.diagnostic.severity.HINT] = { '', 'DiagnosticHint' }
signs[vim.diagnostic.severity.INFO] = { '', 'DiagnosticInfo' }

local config = {}
config.virtual_lines = { current_line = true }
config.signs = { text = {}, numhl = {} }
for id, sign in pairs(signs) do
  config.signs.text[id] = sign[1]
  config.signs.numhl[id] = sign[2]
end

--------------------------------------------------

vim.diagnostic.config(config)
