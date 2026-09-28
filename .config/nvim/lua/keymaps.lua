vim.keymap.set('', '<leader>ts', function()
  local cmd = { 'codesnap' }

  vim.list_extend(cmd, { '--margin-x', 25 })
  vim.list_extend(cmd, { '--margin-y', 25 })
  vim.list_extend(cmd, { '--has-breadcrumbs', 'true' })
  vim.list_extend(cmd, { '--has-line-number' })

  local buffer_name = vim.fn.expand('%:.')
  if buffer_name == nil or #buffer_name == 0 then
    return
  else
    vim.list_extend(cmd, { '--from-file', buffer_name })
  end

  if string.find(vim.fn.mode(), '[vV]') then
    local pos_1 = vim.fn.getpos('v')[2]
    local pos_2 = vim.fn.getpos('.')[2]

    vim.list_extend(cmd, { '--range', math.min(pos_1, pos_2) .. ':' .. math.max(pos_1, pos_2) })
  end

  local output_name = os.date('codesnap_%Y%m%d_%H%M%S.png')
  vim.list_extend(cmd, { '--output', 'pictures/codesnap/' .. output_name })

  local res = vim.system(cmd, { cwd = vim.fn.getcwd() })
  print(vim.inspect(res:wait()))
end, { desc = '[s]nap' })
