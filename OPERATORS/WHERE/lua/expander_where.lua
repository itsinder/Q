local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local Vector  = require 'libvec'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_where(op, a, b)
  -- Verification
  assert(op == "where")
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(b) == "lVector", "b must be a lVector ")
  assert(b:qtype() == "B1", "b must be of type B1")
  if ( ( a:is_eov() ) and ( b:is_eov() ) ) then 
    assert(a:length() == b:length(), "size of a and b is not same")
  end
  local sp_fn_name = "Q/OPERATORS/WHERE/lua/where_specialize"
  local spfn = assert(require(sp_fn_name))

  -- Check min and max value from bit vector metadata
  local meta = b:meta()
  if meta.aux and meta.aux["min"] and meta.aux["max"] then
    if meta.aux["min"] == 1 and meta.aux["max"] == 1 then
      return a
    elseif meta.aux["min"] == 0 and meta.aux["max"] == 0 then
      return nil
    end
  end

  local status, subs, tmpl = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local out_buf = nil
  local first_call = true
  local n_out = nil
  local aidx  = nil
  local a_chunk_idx = 0
  local sz_out = qconsts.chunk_size 

  local cst_a_as   = qconsts.qtypes[a:fldtype()].ctype .. "*"
  local cst_b_as   = "uint64_t *" -- this is a bit vector 
  
  local function where_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    --[[ OKAY TO TAKE THIS OUT????
    assert(chunk_num == a_chunk_idx, 
      "chunk_num/idx = " .. chunk_num .. " ==> " .. a_chunk_idx)
      --]]
    if ( first_call ) then 
      -- allocate buffer for output
      local sz_out_in_bytes = sz_out * qconsts.qtypes[a:qtype()].width
      out_buf = assert(cmem.new(sz_out_in_bytes))

      n_out = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      n_out = ffi.cast("uint64_t *", n_out)

      aidx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      aidx = ffi.cast("uint64_t *", aidx)
      aidx[0] = 0
      
      first_call = false
    end
    
    n_out[0] = 0 -- Initialize to zero
    
    local dbg_iter = 1 -- for debugging
    Vector.print_timers()
    repeat
      if ( a_chunk_idx > 1000 ) then 
        print("Y: a_chunk_idx, n_out = ", a_chunk_idx, tonumber(n_out[0]))
      end
      assert(tonumber(aidx[0]) <= 65536) -- TODO DELETE
      local a_len, a_chunk, a_nn_chunk = a:chunk(a_chunk_idx)
      local b_len, b_chunk, b_nn_chunk = b:chunk(a_chunk_idx)
      if ( a_len == 0 ) then
        return tonumber(n_out[0]), out_buf, nil 
      end
      assert(tonumber(n_out[0]) <= sz_out) -- TODO DELETE
      assert(tonumber(aidx[0]) <= a_len) -- TODO DELETE

      assert(a_len == b_len)
      assert(a_nn_chunk == nil, "Null is not supported")
      assert(b_nn_chunk == nil, "Where vector cannot have nulls")
      
      local cst_a_chunk = ffi.cast(cst_a_as, get_ptr(a_chunk))
      local cst_b_chunk = ffi.cast(cst_b_as, get_ptr(b_chunk))
      local cst_out_buf = ffi.cast(cst_a_as, get_ptr(out_buf))
      -- TODO delete following 2 
      assert(tonumber(n_out[0]) <= sz_out, 
        tonumber(n_out[0]) .. " <= " ..  sz_out)
      assert(tonumber(aidx[0]) <= a_len) -- TODO DELETE
      local status = qc[func_name](cst_a_chunk, cst_b_chunk, aidx, 
        a_len, cst_out_buf, sz_out, n_out)
      assert(status == 0, "C error in WHERE")
      assert(tonumber(n_out[0]) <= sz_out)
      assert(tonumber(aidx[0]) <= a_len)
      if ( tonumber(aidx[0]) == a_len ) then
        a_chunk_idx = a_chunk_idx + 1
        aidx[0] = 0
      end
      --[[
      print("dbg_iter/a_chunk_idx/aidx/a_len/sz_out/n_out/ = ", 
      dbg_iter, a_chunk_idx, aidx, a_len, sz_out, n_out)
      --]]
      dbg_iter = dbg_iter + 1 -- for debugging
    until ( tonumber(n_out[0]) == sz_out )
    return tonumber(n_out[0]), out_buf, nil
  end
  return lVector( { gen = where_gen, has_nulls = false, qtype = a:qtype() } )
end
return expander_where
