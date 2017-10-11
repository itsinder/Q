local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

local function expander_where(op, a, b)
  -- Verification
  assert(op == "where")
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(b) == "lVector", "b must be a lVector ")
  assert(b:qtype() == "B1", "b must be of type B1")
  assert(a:length() == b:length(), "size of a and b is not same")
  local sp_fn_name = "Q/OPERATORS/WHERE/lua/where_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, len = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  -- allocate buffer for output
  local out_buf_size = a:length() * qconsts.qtypes[a:qtype()].width
  local out_buf = assert(ffi.malloc(out_buf_size))
  
  local function where_gen(chunk_idx)
    local a_len, a_chunk, a_nn_chunk = a:chunk(chunk_idx)
    local b_len, b_chunk, b_nn_chunk = b:chunk(chunk_idx)
    if a_len == 0 then
      return 0, nil, nil
    end
    assert(a_len == b_len)
    assert(a_nn_chunk == nil, "Null is not supported")
    local out_len = assert(ffi.malloc(ffi.sizeof("uint64_t")))
    out_len = ffi.cast("uint64_t *", out_len)
    local status = qc[func_name](a_chunk, b_chunk, a_len, out_buf, out_len)
    assert(status == 0, "C error in WHERE")
    out_len = tonumber(out_len[0])
    if out_len == 0 then
      return 0, nil, nil
    end
    return out_len, out_buf, nil 
  end
  return lVector( { gen = where_gen, has_nulls = false, qtype = a:qtype() } )
end

return expander_where
