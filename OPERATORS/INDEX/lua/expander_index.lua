local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local Scalar    = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_index(op, a, b)
  -- Verification
  assert(op == "index")
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(b) == "number", "b must be a number ")
  
  local sp_fn_name = "Q/OPERATORS/INDEX/lua/index_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, tmpl = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)

  local chunk_index = 0
  
  local function index_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_index)
    local idx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
    idx = ffi.cast("int64_t *", idx)
    idx[0] = -1
    while(true) do
      local a_len, a_chunk, nn_a_chunk = a:chunk(chunk_index)
      local chunk_idx = chunk_index * qconsts.chunk_size
      chunk_index = chunk_index + 1
      if a_len and ( a_len > 0 ) then
        local casted_a_chunk = ffi.cast( qconsts.qtypes[a:fldtype()].ctype .. "*",  get_ptr(a_chunk))
        local status = qc[func_name](casted_a_chunk, a_len, b, idx, chunk_idx)
        assert(status == 0, "C error in INDEX")
        if tonumber(idx[0]) ~= -1 then
          break
        end
        -- continue the search
      else
        break
      end
    end
    if tonumber(idx[0]) ~= -1  then 
      return Scalar.new(tonumber(idx[0]), "I8") 
    else
      return nil
    end
  end
  return index_gen(chunk_index)
end

return expander_index
