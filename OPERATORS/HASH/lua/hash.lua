local T = {}

local function hash(input_vec)
  local mk_col   = require 'Q/OPERATORS/MK_COL/lua/mk_col'
  local get_ptr  = require 'Q/UTILS/lua/get_ptr'
  local ffi      = require "Q/UTILS/lua/q_ffi"
  local qconsts  = require 'Q/UTILS/lua/q_consts'
  local qc      = require 'Q/UTILS/lua/q_core'
  local cmem    = require 'libcmem'
  local Scalar  = require 'libsclr'
  
  assert(type(input_vec) == "lVector", "input vector is not lVector")
  assert(input_vec:qtype() == "SC", "input vector is not of type SC")
  assert(input_vec:length() > 0, "input vector length must be greater than 0")
  -- seed values are referred from AB repo seed values
  local SEED_1 = 961748941
  local SEED_2 = 982451653
  
  local sz_c_mem = ffi.sizeof("spooky_state")
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast("spooky_state *", get_ptr(c_mem))
  qc["spooky_init"](c_mem_ptr , SEED_1, SEED_2)
  
  local output_tbl = {}
  local num_of_chunks = math.ceil(input_vec:num_elements()/ qconsts.chunk_size)
  -- TODO: get_one does not support for SC datatype
  -- so, currently using ffi.cast logic
  for chunk_num = 0, num_of_chunks-1 do
    local len, base_data, nn_data = input_vec:chunk(chunk_num)
    local casted = get_ptr(base_data, input_vec:qtype())
    for idx = 0, len-1 do
      local val = ffi.string(casted + idx * input_vec:field_width(), input_vec:field_width())
      local hash_val = qc["spooky_hash64"](val, #val , SEED_1)
      hash_val = tostring(ffi.cast("int64_t", hash_val))
      if type(hash_val) == "string" and string.match(hash_val,'LL') == 'LL' then
        hash_val = string.sub(hash_val,1,-3)
      end
      -- converting hash value to Scalar as hash_value > lua supported number
      output_tbl[#output_tbl+1] = Scalar.new(hash_val, "I8")
    end
  end
  local status, output_col = pcall(mk_col, output_tbl, "I8")
  assert(status, "mk_col failed in hash function")
  return output_col
end
T.hash = hash

return require('Q/q_export').export('hash', hash)
