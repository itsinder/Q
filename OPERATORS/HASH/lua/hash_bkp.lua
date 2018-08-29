local T = {}

local function hash(input_vec)
  local mk_col   = require 'Q/OPERATORS/MK_COL/lua/mk_col'
  local hashcode = require 'Q/OPERATORS/LOAD_CSV/lua/hashcode'
  local get_ptr  = require 'Q/UTILS/lua/get_ptr'
  local ffi      = require "Q/UTILS/lua/q_ffi"
  local qconsts  = require 'Q/UTILS/lua/q_consts'
  
  assert(type(input_vec) == "lVector", "input vector is not lVector")
  assert(input_vec:qtype() == "SC", "input vector is not of type SC")
  assert(input_vec:length() > 0, "input vector length must be greater than 0")
  local output_tbl = {}
  local num_of_chunks = math.ceil(input_vec:num_elements()/ qconsts.chunk_size)
  -- TODO: get_one does not support for SC datatype
  -- so, currently using ffi.cast logic
  for chunk_num = 0, num_of_chunks-1 do
    local len, base_data, nn_data = input_vec:chunk(chunk_num)
    local casted = get_ptr(base_data, input_vec:qtype())
    for idx = 0, len-1 do 
      local chunk_idx = (idx) % qconsts.chunk_size
      local val = ffi.string(casted + chunk_idx * input_vec:field_width())
      local hash_val = hashcode(val)
      output_tbl[#output_tbl+1] = hash_val 
    end
  end
  local status, output_col = pcall(mk_col, output_tbl, "I8")
  assert(status, "mk_col failed in hash function")
  return output_col
end
T.hash = hash

return require('Q/q_export').export('hash', hash)