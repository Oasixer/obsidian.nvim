local search = require "obsidian.search"

---@param bufnr number
---@param cursor_pos number
---@param direction number
local function find_link(bufnr, direction)
  -- vim.notify("find_link:" .. direction)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  local increment = direction == 1 and 1 or -1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_col = vim.api.nvim_win_get_cursor(0)[2]

  local start_line = current_line
  local start_col = current_col + increment

  if direction == -1 and start_col < 1 then
    start_line = start_line - 1
    start_col = #lines[start_line]
  elseif direction == 1 and start_col > #lines[start_line] then
    start_line = start_line + 1
    start_col = 0
  end

  for i = start_line, direction == 1 and #lines or 1, increment do
    local line = lines[i]
    -- vim.notify(line)
    local matches = search.find_refs(line, { include_naked_urls = true })
    for _, match in ipairs(matches) do
      local m_start, m_end = unpack(match)
      -- vim.notify("start:" .. m_start)
      if
        (direction == 1 and (i > current_line or (i == current_line and m_start > current_col)))
        or (direction == -1 and (i < current_line or (i == current_line and m_end < current_col)))
      then
        local link_start = direction == 1 and m_start or m_end
        vim.api.nvim_win_set_cursor(0, { i, link_start })
        return
      end
    end
  end
end

---@param direction number
return function(direction)
  local bufnr = vim.api.nvim_get_current_buf()
  -- vim.notify("direct:" .. direction)
  find_link(bufnr, direction)
end

-- return {
--   gotoNextLink = function()
--     goto_next_prev_link(1)
--   end,
--   gotoPrevLink = function()
--     goto_next_prev_link(-1)
--   end,
-- }
