require 'Q/UTILS/lua/strict'
local qc        = require 'Q/UTILS/lua/q_core'
local ffi       = require 'Q/UTILS/lua/q_ffi'
local qconsts   = require 'Q/UTILS/lua/q_consts'

local fns_name = "where_I4"

local a_qtype = "I4"
local a_ctype = qconsts.qtypes[a_qtype].ctype
local b_qtype = "B1"
local b_ctype = qconsts.qtypes[b_qtype].ctype
local a_input_table = {10, 20, 30, 40, 50}
local b_input_table = {1, 0, 0, 1, 0}

-- generator validator function
local function my_magic_function(a_chunk, b_chunk, a_len, out_buf, out_len)
  print("Validating Generator Function")
  
  a_chunk = ffi.cast(a_ctype .. " *", a_chunk)
  b_chunk = ffi.cast(b_ctype .. " *", b_chunk)
  out_buf = ffi.cast(a_ctype .. " *", out_buf)
  
  for i = 1, a_len do
    -- validate a vector
    assert(a_chunk[i - 1] == a_input_table[i])
    
    -- validate b vector
    local char_idx = (i - 1) / 8
    local bit_idx = (i - 1) % 8 
    local b_buf = b_chunk + char_idx
    local b_value = qc.get_bit(b_buf, bit_idx)
    if b_value ~= 0 then b_value = 1 end
    assert(b_value == b_input_table[i])

    -- initialize out_buf vector
    out_buf[i - 1] = 0
    
    -- initialize out_len
    out_len[0] = 2
  end
  return 0
end

-- set custom validation function
qc[fns_name] = my_magic_function

-- call where operator
local Q = require 'Q'
local a = Q.mk_col(a_input_table, a_qtype)
local b = Q.mk_col(b_input_table, b_qtype)

local c = Q.where(a, b)
c:eval()
Q.print_csv(c, nil, "")
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

os.execute("rm _*")
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()