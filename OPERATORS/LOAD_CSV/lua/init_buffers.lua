local data_dir      = require('Q/q_export').Q_DATA_DIR
local Dictionary    = require 'Q/UTILS/lua/dictionary'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'

local function get_binary_width(field)
  local w
  if field.qtype == "SC" then
    w = assert(field.width)
  else
    w = assert(qconsts.qtypes[field.qtype].width)
  end
  return w
end

local function init_buffers(M)
  assert(type(M) == "table")
  local num_cols = #M
  assert(num_cols > 0)
  local cols = {} -- cols[i] is Column used for column i
  local dicts = {} -- dicts[i] is di ctionary used for column i
  local out_bufs = {}
  local nn_out_bufs = {}
  --TODO Krushnakant I dont understand what this statement means
  -- If chunk_size is not multiple of num_cols then
  -- the total buffer size (sum of all column buffer size) will be larger than the chunk_size by margin
  -- This loop does following things
  -- (2) create lvector for each is_load column
  -- (3) create Dictionary for each is_load SV column
  -- (4) create output buffer for each is_load column
  for col_idx = 1, num_cols do
    if M[col_idx].is_load then
      binary_width = get_binary_width(M[col_idx])
      cols[col_idx] = lVector{
        qtype=M[col_idx].qtype,
        gen = true,
        width=binary_width,
        is_memo=true,
        has_nulls=M[col_idx].has_nulls}
      M[col_idx].num_nulls = 0
      if M[col_idx].qtype == "SV" then
        dicts[col_idx] = assert(Dictionary(M[col_idx].dict),
        "error creating dictionary " .. M[col_idx].dict .. " for " .. M[col_idx].name)
        cols[col_idx]:set_meta("dir", dicts[col_idx])
      end
      -- Allocate memory for output buf and add to pool
      local x = qconsts.chunk_size * binary_width
      out_bufs[col_idx] = ffi.malloc(x)
      ffi.fill(out_bufs[col_idx], x)
      x = qconsts.chunk_size / 8
      nn_out_bufs[col_idx] = ffi.malloc(x)
      ffi.fill(nn_out_bufs[col_idx], x)
    end
  end
  assert(max_txt_width > 0)
  return cols, dicts, out_bufs, nn_out_bufs
end

return init_buffers
