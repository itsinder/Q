-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

local expander_ainb = function(op, a, b)
  -- START: verify inputs
  assert(op == "ainb")
  assert(type(a) == "Column", "a must be a Column ")
  assert(type(b) == "Column", "b must be a column ")
  local sp_fn_name = "Q/OPERATORS/AINB/lua/ainb_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs, len = pcall(spfn, a:fldtype(), b:fldtype())
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)
  --all of b needs to be evaluated
  local b_len, bptr, nn_bptr = b:chunk(-1)
  assert(nn_bptr == nil, "Don't support null values")
  assert(bptr)
  -- STOP: verify inputs

  local coro = coroutine.create(function()
    -- malloc space for one chunk worth of output z
    assert(math.floor(qconsts.chunk_size/64) == 
           math.ceil(qconsts.chunk_size/64) )
    local z_sz = qconsts.chunk_size / 8 -- B1 is 1/8 byte
    local z_buf = assert(ffi.malloc(z_sz), "malloc failed")
    local status, Xptr, len
    local cidx = 0 -- chunk index
    local last_chunk = false
    repeat 
      local len = 0
      local a_len, aptr, nn_aptr = a:chunk(cidx) 
      assert(nn_aptr == nil, "Not prepared for null values in a")
      if ( a_len == 0 ) then
        -- TODO tell b that it is all over
        last_chunk = true
      else
        local status = qc[func_name](aptr, a_len, bptr, b_len, z_buf)
        assert(status == 0, "C error in ainb") 
        coroutine.yield(a_len, z_buf, nil)
        cidx = cidx + 1
      end
    until (last_chunk == true )
  end)
  return Column( {gen=coro, nn=false, field_type="B1"} )
end

return expander_ainb
