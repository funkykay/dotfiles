local M = {}

local changing_buffer = false
local chooser_pending = false
local file_chooser = nil

local function is_normal_buffer(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.bo[bufnr].buflisted
    and vim.bo[bufnr].buftype == ""
end

local function is_empty_unnamed_buffer(bufnr)
  if not is_normal_buffer(bufnr) then
    return false
  end

  if vim.api.nvim_buf_get_name(bufnr) ~= "" or vim.bo[bufnr].modified then
    return false
  end

  if vim.api.nvim_buf_line_count(bufnr) ~= 1 then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
  return lines[1] == ""
end

local function is_document_buffer(bufnr)
  return is_normal_buffer(bufnr) and not is_empty_unnamed_buffer(bufnr)
end

local function has_document_buffer()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if is_document_buffer(bufnr) then
      return true
    end
  end

  return false
end

local function save_buffer(bufnr)
  if is_empty_unnamed_buffer(bufnr) then
    return true
  end

  if vim.api.nvim_buf_get_name(bufnr) == "" then
    return false, "unnamed buffer cannot be saved automatically"
  end

  if not vim.bo[bufnr].modified then
    return true
  end

  local ok, err = pcall(vim.api.nvim_buf_call, bufnr, function()
    vim.cmd("silent keepalt write")
  end)

  if not ok then
    return false, tostring(err)
  end

  return true
end

local function restore_previous_buffer(previous, current)
  changing_buffer = true

  if vim.api.nvim_buf_is_valid(previous) then
    pcall(vim.api.nvim_win_set_buf, 0, previous)
  end

  if vim.api.nvim_buf_is_valid(current)
    and current ~= previous
    and is_normal_buffer(current)
    and not vim.bo[current].modified
  then
    pcall(vim.api.nvim_buf_delete, current, { force = true })
  end

  changing_buffer = false
end

local function enforce_single_file(current)
  if changing_buffer or not is_document_buffer(current) then
    return
  end

  local previous_buffers = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if bufnr ~= current and is_normal_buffer(bufnr) then
      previous_buffers[#previous_buffers + 1] = bufnr
    end
  end

  for _, bufnr in ipairs(previous_buffers) do
    local ok, err = save_buffer(bufnr)

    if not ok then
      vim.notify(
        ("single-file: %s"):format(err),
        vim.log.levels.ERROR
      )
      restore_previous_buffer(bufnr, current)
      return
    end
  end

  changing_buffer = true

  for _, bufnr in ipairs(previous_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local force = is_empty_unnamed_buffer(bufnr)
      local ok, err = pcall(vim.api.nvim_buf_delete, bufnr, { force = force })

      if not ok then
        vim.notify(
          ("single-file: could not close buffer: %s"):format(err),
          vim.log.levels.ERROR
        )
      end
    end
  end

  changing_buffer = false
end

local function open_file_chooser()
  if file_chooser == nil or chooser_pending then
    return
  end

  chooser_pending = true

  vim.schedule(function()
    chooser_pending = false

    if has_document_buffer() then
      return
    end

    local ok, err = pcall(file_chooser)

    if not ok then
      vim.notify(
        ("single-file: could not open file chooser: %s"):format(err),
        vim.log.levels.ERROR
      )
    end
  end)
end

function M.setup(opts)
  opts = opts or {}
  file_chooser = opts.file_chooser

  local group = vim.api.nvim_create_augroup("NvimCommonSingleFile", { clear = true })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(args)
      enforce_single_file(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      if vim.api.nvim_buf_is_valid(args.buf)
        and vim.bo[args.buf].buftype == ""
        and not is_empty_unnamed_buffer(args.buf)
      then
        open_file_chooser()
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
      local current = vim.api.nvim_get_current_buf()

      if is_document_buffer(current) then
        enforce_single_file(current)
      else
        open_file_chooser()
      end
    end,
  })
end

return M
