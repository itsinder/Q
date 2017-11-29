require 'Q/UTILS/lua/strict'
local qc        = require 'Q/UTILS/lua/q_core'
local ffi       = require 'Q/UTILS/lua/q_ffi'
local qconsts   = require 'Q/UTILS/lua/q_consts'

-- Set CHUNK_SIZE to 64

local fns_name = "where_I4"

local itr_count = 0

local a_qtype = "I4"
local a_ctype = qconsts.qtypes[a_qtype].ctype
local b_qtype = "B1"
local b_ctype = qconsts.qtypes[b_qtype].ctype

local a_input_table = {}
for i = 1, 66 do
  a_input_table[i] = i
end

local b_input_table = {}
for i = 1, 66 do
  b_input_table[i] = 0
end
b_input_table[2] = 1
b_input_table[4] = 1
b_input_table[66] = 1

-- generator validator function
local function my_magic_function(a_chunk, b_chunk, aidx, a_len, out_buf, sz_out, n_out)
  print("Validating Generator Function")
  
  local table_index = qconsts.chunk_size * itr_count
  
  a_chunk = ffi.cast(a_ctype .. " *", a_chunk)
  b_chunk = ffi.cast(b_ctype .. " *", b_chunk)
  out_buf = ffi.cast(a_ctype .. " *", out_buf)
  
  for i = 1, a_len do
    -- validate a vector
    local a_value = a_chunk[i - 1]
    print("a_value: ", a_value)
    assert(a_value == a_input_table[table_index + i])
    
    -- validate b vector
    local char_idx = (i - 1) / 8
    local bit_idx = (i - 1) % 8 
    local b_buf = b_chunk + char_idx
    local b_value = qc.get_bit(b_buf, bit_idx)
    if b_value ~= 0 then b_value = 1 end
    print("b_value: ", b_value)
    assert(b_value == b_input_table[table_index + i])

    -- initialize out_buf vector
    out_buf[i - 1] = 0
  end
  n_out[0] = 2
  itr_count = itr_count + 1
  return 0
end

-- set custom validation function
qc[fns_name] = my_magic_function

local tests = {}

tests.t1 = function()
  -- call where operator
  local Q = require 'Q'
  local a = Q.mk_col(a_input_table, a_qtype)
  --Q.print_csv(a, nil, "/tmp/a_out.txt")
  local b = Q.mk_col(b_input_table, b_qtype)
  --Q.print_csv(b, nil, "/tmp/b_out.txt")
  local c = Q.where(a, b)
  c:eval()
  --Q.print_csv(c, nil, "")
end
--======================================
--[[
print("===================================================")
local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 65540} )
a:eval()

local b = Q.rand( {lb = 0, ub = 1, qtype = "I1", len = 65540})
b:eval()

local b_B1 = Q.convert(b, {qtype = "B1"})
b_B1:eval()
Q.print_csv(b_B1, nil, "")

--print(Q.sum(b_B1):eval())

local c = Q.where(a, b_B1)
c:eval()

print(c:length())
-- Q.print_csv(c, nil, "")
]]
--======================================

return tests